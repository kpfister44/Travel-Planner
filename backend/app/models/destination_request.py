import pydantic
from typing import List, Optional

class Budget(pydantic.BaseModel):
    min: int
    max: int
    currency: str

class TravelDates(pydantic.BaseModel):
    start_date: str
    end_date: str

class TravelerInfo(pydantic.BaseModel):
    age_group: str

class Preferences(pydantic.BaseModel):
    traveler_info: TravelerInfo
    budget: Budget
    travel_dates: TravelDates
    group_size: int
    group_relationship: str
    preferred_location: str
    interests: List[str]
    travel_style: str
    must_haves: List[str]
    deal_breakers: List[str]

class DestinationRequest(pydantic.BaseModel):
    preferences: Preferences
    
    class Config:
        schema_extra = {
            "example": {
                "preferences": {
                    "traveler_info": {
                        "age_group": "25-34"
                    },
                    "budget": {
                        "min": 500,
                        "max": 2000,
                        "currency": "USD"
                    },
                    "travel_dates": {
                        "start_date": "2024-07-15",
                        "end_date": "2024-07-22"
                    },
                    "group_size": 2,
                    "group_relationship": "couple",
                    "preferred_location": "None (Open to suggestions)",
                    "interests": [
                        "cultural_experiences",
                        "food_and_drink",
                        "outdoor_activities",
                        "historical_sites"
                    ],
                    "travel_style": "balanced",
                    "must_haves": ["walkable city", "good food scene"],
                    "deal_breakers": ["extreme weather"]
                }
            }
        }
