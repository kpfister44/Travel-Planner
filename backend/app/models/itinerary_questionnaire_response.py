from pydantic import BaseModel
from typing import List, Literal, Optional
from .errors import ErrorItem


class Destination(BaseModel):
    id: str
    name: str


class SuggestedActivity(BaseModel):
    id: str
    name: str
    category: str
    duration_hours: int
    cost: float
    priority: Literal["low", "medium", "high"]
    description: str


class ItineraryQuestionnaireResponse(BaseModel):
    errors: Optional[List[ErrorItem]] = None
    questionnaire_id: Optional[str] = None
    destination: Optional[Destination] = None
    suggested_activities: Optional[List[SuggestedActivity]] = None
    ready_for_optimization: Optional[bool] = None

    class Config:
        schema_extra = {
            "example": {
                "questionnaire_id": "quest_001",
                "destination": {"id": "dest_001", "name": "Barcelona, Spain"},
                "suggested_activities": [
                    {
                        "id": "act_001",
                        "name": "Sagrada Familia",
                        "category": "cultural",
                        "duration_hours": 2,
                        "cost": 26,
                        "priority": "high",
                        "description": "Iconic basilica by Gaudí",
                    },
                    {
                        "id": "act_002",
                        "name": "Park Güell",
                        "category": "outdoor",
                        "duration_hours": 2,
                        "cost": 10,
                        "priority": "high",
                        "description": "Colorful park with city views",
                    },
                    {
                        "id": "act_003",
                        "name": "Tapas Walking Tour",
                        "category": "food",
                        "duration_hours": 3,
                        "cost": 65,
                        "priority": "medium",
                        "description": "Guided food tour in Gothic Quarter",
                    },
                ],
                "ready_for_optimization": True,
            }
        }
