# LLM destination discovery service
from app.models.custom_exception import CustomException
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
            raise CustomException("Invalid input data")

        # call OpenAI client to get destination ideas
        response_text = get_travel_ideas(request.preferences)
        if response_text is None:
            logger.warning(
                common_utils.get_error_message(
                    self.get_recommendations.__name__,
                    "OpenAI API failed, returning mock data for testing.",
                )
            )

            # Return mock data for testing when OpenAI API fails
            # return self._get_mock_response()

        try:
            response_json = json.loads(response_text)
            return DestinationResponse(**response_json)

        except Exception as e:
            logger.error(
                common_utils.get_error_message(
                    self.get_recommendations.__name__, str(e)
                )
            )
            raise CustomException("Invalid response format.")

    def _get_mock_response(self) -> DestinationResponse:
        """Returns mock destination data for testing when OpenAI API is unavailable"""
        mock_recommendations = [
            Recommendation(
                id="dest_001",
                name="Barcelona, Spain",
                country="Spain",
                match_score=92,
                estimated_cost=1500,
                highlights=[
                    "Stunning architecture",
                    "Amazing food scene",
                    "Rich culture",
                    "Beautiful beaches",
                ],
                why_recommended="Perfect blend of culture, food, and relaxation. Great for couples who love art and cuisine.",
                image_url=None,
            ),
            Recommendation(
                id="dest_002",
                name="Prague, Czech Republic",
                country="Czech Republic",
                match_score=87,
                estimated_cost=1200,
                highlights=[
                    "Historic old town",
                    "Affordable prices",
                    "Great beer",
                    "Fairy-tale architecture",
                ],
                why_recommended="Budget-friendly destination with incredible history and walkable city center.",
                image_url=None,
            ),
            Recommendation(
                id="dest_003",
                name="Lisbon, Portugal",
                country="Portugal",
                match_score=85,
                estimated_cost=1300,
                highlights=[
                    "Coastal charm",
                    "Delicious seafood",
                    "Vibrant neighborhoods",
                    "Mild weather",
                ],
                why_recommended="Coastal beauty with great food culture and pleasant year-round climate.",
                image_url=None,
            ),
        ]

        return DestinationResponse(errors=None, recommendations=mock_recommendations)


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
