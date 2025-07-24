import os
import sys
import pytest

from unittest.mock import patch
from fastapi.testclient import TestClient
from dotenv import load_dotenv

#load env with provided path
load_dotenv(dotenv_path=os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '.env')))
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from main import app

client = TestClient(app)
API_KEY = os.getenv("API_KEY", "testkey")
HEADERS = {"x-api-key": API_KEY}


#basic health
@pytest.mark.parametrize("endpoint, expected_status, expected_json", [
    ("/", 200, {"message": "Health check: Traveler-Planner API is running"}),
    ("/nonexistent", 404, None),
])
def test_root_and_invalid_endpoints(endpoint, expected_status, expected_json):
    response = client.get(endpoint)
    assert response.status_code == expected_status
    if expected_json:
        assert response.json() == expected_json

def test_root_returns_json():
    response = client.get("/")
    assert response.headers["content-type"].startswith("application/json")

def test_method_not_allowed():
    response = client.post("/")
    assert response.status_code == 405


#Destination API
DESTINATION_PAYLOAD = {
    "age": 32,
    "travel_dates": {"start_date": "2024-07-15", "end_date": "2024-07-22"},
    "group_size": 2,
    "group_relationship": "friends",
    "destination_preferences": ["beach", "nature"],
    "budget": {"min": 500, "max": 2000, "currency": "USD"},
    "travel_style": "balanced",
    "interests": ["cultural_experiences", "food_and_drink", "outdoor_activities", "historical_sites"],
    "must_haves": ["walkable city", "good food scene"],
    "deal_breakers": ["extreme weather"],
    "preferences": {
        "budget": {"min": 500, "max": 2000, "currency": "USD"},
        "travel_dates": {"start_date": "2024-07-15", "end_date": "2024-07-22"},
        "group_size": 2,
        "interests": ["cultural_experiences", "food_and_drink", "outdoor_activities", "historical_sites"],
        "travel_style": "balanced",
        "must_haves": ["walkable city", "good food scene"],
        "deal_breakers": ["extreme weather"]
    }
}

@pytest.mark.parametrize("headers, expected_status", [(None, 403), (HEADERS, 200)])
@patch("app.services.destination_service.DestinationService.get_recommendations")
def test_destination_recommendations(mock_get_recommendations, headers, expected_status):
    mock_get_recommendations.return_value = {
        "recommendations": [{
            "id": "rec_001",
            "name": "Test Destination",
            "country": "Test Country",
            "match_score": 1,
            "estimated_cost": 1000,
            "highlights": ["Highlight 1", "Highlight 2"],
            "why_recommended": "Test reason"
        }]
    }
    response = client.post("/destinations/recommendations", headers=headers, json=DESTINATION_PAYLOAD)
    assert response.status_code == expected_status
    if expected_status == 200:
        assert "recommendations" in response.json() or "errors" in response.json()

def test_destination_health():
    response = client.get("/destinations/health")
    assert response.status_code == 200
    assert response.json().get("status") == "ok"


#Itinerary API
ITINERARY_QUESTIONNAIRE_PAYLOAD = {
    "selected_destination": {"id": "dest_001", "name": "Barcelona, Spain"},
    "travel_dates": {"start_date": "2024-07-15", "end_date": "2024-07-22"},
    "activity_preferences": {
        "pace": "moderate",
        "daily_start_time": "09:00",
        "daily_end_time": "22:00",
        "max_activities_per_day": 4,
        "priority_interests": ["architecture", "food_experiences", "local_culture"],
        "must_see_attractions": ["Sagrada Familia", "Park Güell", "Las Ramblas"],
        "activity_types": {
            "cultural": "high", "outdoor": "medium", "food": "high", "nightlife": "low", "shopping": "low"
        },
        "meal_preferences": {
            "breakfast": "hotel", "lunch": "local_restaurant", "dinner": "local_restaurant"
        },
        "transportation": "walking_and_public",
        "accommodation_area": "city_center"
    }
}

@pytest.mark.parametrize("headers, expected_status", [(None, 403), (HEADERS, 200)])
def test_itinerary_questionnaire(headers, expected_status):
    response = client.post("/itinerary/questionnaire", headers=headers, json=ITINERARY_QUESTIONNAIRE_PAYLOAD)
    assert response.status_code == expected_status
    if expected_status == 200:
        assert "activities" in response.json() or "errors" in response.json()

ITINERARY_GENERATE_PAYLOAD = {
    "questionnaire_id": "quest_001",
    "selected_activities": [
        {"id": "act_001", "priority": "high"},
        {"id": "act_002", "priority": "high"},
        {"id": "act_003", "priority": "medium"}
    ],
    "preferences": {
        "pace": "moderate",
        "daily_start_time": "09:00",
        "daily_end_time": "22:00",
        "max_activities_per_day": 4
    }
}

@pytest.mark.parametrize("headers, expected_status", [(None, 403), (HEADERS, 200)])
@patch("app.services.itinerary_service.ItineraryService.get_itinerary")
def test_itinerary_generate(mock_get_itinerary, headers, expected_status):
    if expected_status == 200:
        mock_get_itinerary.return_value = {
            "itinerary": {
                "id": "itinerary_001",
                "activities": [],
                "destination": "Test Destination",
                "total_days": 3,
                "daily_schedules": []
            },
            "summary": {
                "total_cost": 1000,
                "total_activities": 5,
                "optimization_score": 95
            }
        }
    response = client.post("/itinerary/generate", headers=headers, json=ITINERARY_GENERATE_PAYLOAD)
    assert response.status_code == expected_status
    if expected_status == 200:
        assert "itinerary" in response.json() or "errors" in response.json()
