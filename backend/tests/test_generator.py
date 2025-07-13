from faker import Faker
import random

fake = Faker()

AGE_GROUPS = ["18-24", "25-34", "35-44", "45-54", "55+"]
TRAVEL_STYLES = ["relaxed", "adventurous", "balanced"]
LIKES = [
    "cultural_experiences", "food_and_drink", "outdoor_activities",
    "historical_sites", "art_and_museums", "shopping", "beaches"
]
DISLIKES = ["crowded_places", "extreme_weather", "long_flights"]
MUST_HAVES = ["walkable city", "good food scene", "safe neighborhoods"]
DEAL_BREAKERS = ["long_flights", "extreme_weather", "high crime"]
GROUP_RELATIONSHIPS = ["solo", "couple", "family", "friends"]
CURRENCIES = ["USD", "EUR", "GBP"]

def generate_valid_user_preferences():
    min_budget = random.randint(300, 1000)
    max_budget = random.randint(min_budget + 1, 3000)
    return {
        "traveler_info": {
            "age_group": random.choice(AGE_GROUPS)
        },
        "budget": {
            "min": min_budget,
            "max": max_budget,
            "currency": random.choice(CURRENCIES)
        },
        "travel_dates": {
            "start_date": "2025-08-01",
            "end_date": "2025-08-10"
        },
        "group_size": random.randint(1, 5),
        "group_relationship": random.choice(GROUP_RELATIONSHIPS),
        "preferred_location": "None (Open to suggestions)",
        "likes": random.sample(LIKES, k=3),
        "dislikes": random.sample(DISLIKES, k=2),
        "travel_style": random.choice(TRAVEL_STYLES),
        "must_haves": random.sample(MUST_HAVES, k=2),
        "deal_breakers": random.sample(DEAL_BREAKERS, k=1)
    }
