import timeit
import tracemalloc
import requests
import concurrent.futures

API_URL = "http://127.0.0.1:8000/itinerary/questionnaire"
HEADERS = {
    "Content-Type": "application/json",
    "x-api-key": "your_api_key_here"
}

sample_input = {
    "questionnaire_id": "test1234",
    "selected_activities": [
        {"id": "cultural_experiences", "priority": "medium"},
        {"id": "food_and_drink", "priority": "high"}
    ],
    "selected_destination": {
        "id": "paris",
        "name": "Paris",
        "city": "paris",
        "country": "france"
    },
    "travel_dates": {
        "start_date": "2024-08-10",
        "end_date": "2024-08-17"
    },
    "activity_preferences": {
        "priority_interests": ["cultural", "outdoor", "food", "nightlife", "shopping"],
        "must_see_attractions": ["Eiffel Tower", "Louvre Museum"],
        "activity_types": {
            "cultural": "high",
            "outdoor": "medium",
            "food": "medium",
            "nightlife": "low",
            "shopping": "low"
        },
        "meal_preferences": {
            "breakfast": "hotel",
            "lunch": "local_restaurant",
            "dinner": "local_restaurant"
        },
        "transportation": "walking_and_public",
        "accommodation_area": "city_center",
        "age_group": "25-34",
        "group_size": 2,
        "group_relationship": "family",
        "preferred_location": "None (Open to suggestions)",
        "budget": {"min": 500, "max": 2000},
        "travel_style": "balanced",
        "likes": ["cultural_experiences", "food_and_drink"],
        "dislikes": ["crowded_places"],
        "must_haves": ["walkable city"],
        "deal_breakers": ["extreme weather"],
        "pace": "moderate",
        "daily_start_time": "08:00",
        "daily_end_time": "18:00",
        "max_activities_per_day": 3
    }
}


def print_performance(duration: float, current_mem: int, peak_mem: int) -> None:
    print("\n--- Performance Benchmark ---")
    print(f"Time: {duration:.4f} sec")
    print(f"Memory: current={current_mem / 1_000_000:.2f}MB, peak={peak_mem / 1_000_000:.2f}MB")


def test_itinerary() -> None:
    tracemalloc.start()
    start_time = timeit.default_timer()

    response = requests.post(API_URL, json=sample_input, headers=HEADERS)

    duration = timeit.default_timer() - start_time
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()

    print_performance(duration, current, peak)

    if response.status_code == 200:
        result = response.json()
        if isinstance(result, dict):
            destinations = result.get("destinations") or result.get("itinerary") or []
            print(f"Returned {len(destinations)} destinations")
        else:
            print("Received non-dictionary response")
    else:
        print(f"API call failed with status {response.status_code}")
        try:
            print("Response:", response.json())
        except Exception:
            print("Response text:", response.text)


def stress_test_itinerary(n_requests: int = 50) -> None:
    print(f"\n--- Stress Test: {n_requests} rapid requests ---")
    with requests.Session() as session:
        def make_request(_) -> bool:
            try:
                response = session.post(API_URL, json=sample_input, headers=HEADERS)
                return response.status_code == 200
            except Exception as e:
                print(f"Error: {e}")
                return False

        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            results = list(executor.map(make_request, range(n_requests)))

    successes = sum(results)
    print(f"Successes: {successes}/{n_requests}")


if __name__ == "__main__":
    test_itinerary()
    stress_test_itinerary(150)
