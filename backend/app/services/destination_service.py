# LLM destination discovery service

from app.models.destination_request import DestinationRequest
from app.models.destination_response import DestinationResponse, Recommendation
from app.services.openai_client import get_travel_ideas
from app.utils import common_utils
import json
import logging

logger = logging.getLogger(__name__)


class DestinationService:
    def __init__(self):
        pass

    def get_recommendations(self, request: DestinationRequest) -> DestinationResponse:
        # Placeholder for actual recommendation logic
        logger.debug(
            common_utils.get_logging_message(self.get_recommendations.__name__)
        )
        if not common_utils.input_validation_destination(request):
            logger.error(
                common_utils.get_error_message(
                    self.get_recommendations.__name__, "Invalid input"
                )
            )
            return DestinationResponse(
                errors=common_utils.get_error_response(400, "Invalid input data")
            )
        response_text = get_travel_ideas(request.preferences)
        if response_text is None:
            print("Failed to fetch recommendations from OpenAI.")
            return DestinationResponse(
                errors=[{"code": "500", "message": "Failed to fetch recommendations."}]
            )

        try:
            response_json = json.loads(response_text)
            return DestinationResponse(**response_json)

        except Exception as e:
            logger.error(
                common_utils.get_error_message(
                    self.get_recommendations.__name__, str(e)
                )
            )
            return DestinationResponse(
                errors=[{"code": "500", "message": "Invalid response format."}]
            )


# recommendations = [
#     Recommendation(
#         id="dest_001",
#         name="Barcelona, Spain",
#         country="Spain",
#         match_score=92,
#         estimated_cost=1650,
#         highlights=[
#             "Stunning Gaudí architecture",
#             "World-class food scene",
#             "Beautiful beaches within city"
#         ],
#         why_recommended="Perfect for cultural interests with great walkability...",
#         image_url="https://example.com/barcelona.jpg"
#     ),
#     Recommendation(
#         id="dest_002",
#         name="Prague, Czech Republic",
#         country="Czech Republic",
#         match_score=88,
#         estimated_cost=1200,
#         highlights=[
#             "Medieval Old Town",
#             "Affordable prices",
#             "Rich history"
#         ],
#         why_recommended="Great value destination with amazing architecture...",
#         image_url="https://example.com/prague.jpg"
#     )
# ]
