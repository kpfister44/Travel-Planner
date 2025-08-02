from pydantic import BaseModel
from typing import List, Optional


class Recommendation(BaseModel):
    id: str
    name: str
    country: str
    match_score: int
    estimated_cost: int
    highlights: List[str]
    why_recommended: str
    image_url: Optional[str] = None


class ErrorItem(BaseModel):
    code: str
    message: str


class DestinationResponse(BaseModel):
    errors: Optional[List[ErrorItem]] = None
    recommendations: Optional[List[Recommendation]] = None

    class Config:
        schema_extra = {
            "example": {
                "errors": [
                    {
                        "code": "invalid_request",
                        "message": "The request is missing required fields.",
                    }
                ],
                "recommendations": [
                    {
                        "id": "dest_001",
                        "name": "Barcelona, Spain",
                        "country": "Spain",
                        "match_score": 92,
                        "estimated_cost": 1650,
                        "highlights": [
                            "Stunning Gaudí architecture",
                            "World-class food scene",
                            "Beautiful beaches within city",
                        ],
                        "why_recommended": "Perfect for cultural interests with great walkability...",
                        "image_url": "https://example.com/barcelona.jpg",
                    },
                    {
                        "id": "dest_002",
                        "name": "Prague, Czech Republic",
                        "country": "Czech Republic",
                        "match_score": 88,
                        "estimated_cost": 1200,
                        "highlights": [
                            "Medieval Old Town",
                            "Affordable prices",
                            "Rich history",
                        ],
                        "why_recommended": "Great value destination with amazing architecture...",
                        "image_url": "https://example.com/prague.jpg",
                    },
                ],
            }
        }
