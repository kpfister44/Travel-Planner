from pydantic import BaseModel
from typing import List, Literal, Optional, Dict
from datetime import date, time


class SelectedDestination(BaseModel):
    id: str
    name: str


class TravelDates(BaseModel):
    start_date: date
    end_date: date


class MealPreferences(BaseModel):
    breakfast: Literal["hotel", "local_restaurant", "skip", "other"]
    lunch: Literal["hotel", "local_restaurant", "skip", "other"]
    dinner: Literal["hotel", "local_restaurant", "skip", "other"]


class ActivityTypes(BaseModel):
    cultural: Literal["low", "medium", "high"]
    outdoor: Literal["low", "medium", "high"]
    food: Literal["low", "medium", "high"]
    nightlife: Literal["low", "medium", "high"]
    shopping: Literal["low", "medium", "high"]


class ActivityPreferences(BaseModel):
    pace: Literal["relaxed", "moderate", "intense"]
    daily_start_time: str  # or time if you prefer strict validation
    daily_end_time: str  # or time
    max_activities_per_day: int
    priority_interests: List[str]
    must_see_attractions: List[str]
    activity_types: ActivityTypes
    meal_preferences: MealPreferences
    transportation: Literal[
        "walking", "public_transport", "walking_and_public", "car", "mixed"
    ]
    accommodation_area: str


class ItineraryQuestionnaireRequest(BaseModel):
    selected_destination: SelectedDestination
    travel_dates: TravelDates
    activity_preferences: ActivityPreferences

    class Config:
        schema_extra = {
            "example": {
                "selected_destination": {"id": "dest_001", "name": "Barcelona, Spain"},
                "travel_dates": {"start_date": "2024-07-15", "end_date": "2024-07-22"},
                "activity_preferences": {
                    "pace": "moderate",
                    "daily_start_time": "09:00",
                    "daily_end_time": "22:00",
                    "max_activities_per_day": 4,
                    "priority_interests": [
                        "architecture",
                        "food_experiences",
                        "local_culture",
                    ],
                    "must_see_attractions": [
                        "Sagrada Familia",
                        "Park Güell",
                        "Las Ramblas",
                    ],
                    "activity_types": {
                        "cultural": "high",
                        "outdoor": "medium",
                        "food": "high",
                        "nightlife": "low",
                        "shopping": "low",
                    },
                    "meal_preferences": {
                        "breakfast": "hotel",
                        "lunch": "local_restaurant",
                        "dinner": "local_restaurant",
                    },
                    "transportation": "walking_and_public",
                    "accommodation_area": "city_center",
                },
            }
        }
