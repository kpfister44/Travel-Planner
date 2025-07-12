from pydantic import BaseModel
from typing import List, Literal


class SelectedActivity(BaseModel):
    id: str
    priority: Literal["low", "medium", "high"]


class ItineraryPreferences(BaseModel):
    pace: Literal["relaxed", "moderate", "fast"]
    daily_start_time: str
    daily_end_time: str
    max_activities_per_day: int


class ItineraryGenerateRequest(BaseModel):
    questionnaire_id: str
    selected_activities: List[SelectedActivity]
    preferences: ItineraryPreferences

    class Config:
        schema_extra = {
            "example": {
                "questionnaire_id": "quest_001",
                "selected_activities": [
                    {"id": "act_001", "priority": "high"},
                    {"id": "act_002", "priority": "high"},
                    {"id": "act_003", "priority": "medium"},
                ],
                "preferences": {
                    "pace": "moderate",
                    "daily_start_time": "09:00",
                    "daily_end_time": "22:00",
                    "max_activities_per_day": 4,
                },
            }
        }
