import pydantic
from typing import List, Optional

class Budget(pydantic.BaseModel):
    min: int
    max: int
    currency: str

class TravelDates(pydantic.BaseModel):
    start_date: str
    end_date: str

class Preferences(pydantic.BaseModel):
    budget: Budget
    travel_dates: TravelDates
    group_size: int
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
