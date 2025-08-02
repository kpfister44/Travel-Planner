from pydantic import BaseModel
from typing import List, Optional
from .errors import ErrorItem


class ActivityDetails(BaseModel):
    name: str
    type: str
    notes: str


class ScheduledActivity(BaseModel):
    start_time: str  # format: "HH:MM"
    end_time: str  # format: "HH:MM"
    activity: ActivityDetails


class DailySchedule(BaseModel):
    date: str  # format: "YYYY-MM-DD"
    day_number: int
    theme: str
    activities: List[ScheduledActivity]
    daily_cost: float
    walking_distance: str


class Itinerary(BaseModel):
    destination: str
    total_days: int
    daily_schedules: List[DailySchedule]


class ItinerarySummary(BaseModel):
    total_cost: float
    total_activities: int
    optimization_score: float


class ItineraryGenerateResponse(BaseModel):
    errors: Optional[List[ErrorItem]] = None
    itinerary: Optional[Itinerary] = None
    summary: Optional[ItinerarySummary] = None

    class Config:
        schema_extra = {
            "example": {
                "itinerary": {
                    "destination": "Barcelona, Spain",
                    "total_days": 7,
                    "daily_schedules": [
                        {
                            "date": "2024-07-15",
                            "day_number": 1,
                            "theme": "Arrival & Gothic Quarter",
                            "activities": [
                                {
                                    "start_time": "14:00",
                                    "end_time": "15:00",
                                    "activity": {
                                        "name": "Hotel Check-in",
                                        "type": "logistics",
                                        "notes": "Relax after arrival",
                                    },
                                },
                                {
                                    "start_time": "15:30",
                                    "end_time": "17:30",
                                    "activity": {
                                        "name": "Las Ramblas Walk",
                                        "type": "cultural",
                                        "notes": "Introduction to the city",
                                    },
                                },
                                {
                                    "start_time": "18:00",
                                    "end_time": "19:30",
                                    "activity": {
                                        "name": "Dinner at El Xampanyet",
                                        "type": "dining",
                                        "notes": "Traditional tapas experience",
                                    },
                                },
                            ],
                            "daily_cost": 85,
                            "walking_distance": "3.2 km",
                        }
                    ],
                },
                "summary": {
                    "total_cost": 1650,
                    "total_activities": 18,
                    "optimization_score": 0.91,
                },
            }
        }
