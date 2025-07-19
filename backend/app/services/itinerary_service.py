# LLM itinerary optimization service
import logging
import json
from app.utils import common_utils
from app.models.errors import ErrorItem
from app.models.custom_exception import CustomException
from app.models.itinerary_questionnaire_request import ItineraryQuestionnaireRequest
from app.models.itinerary_questionnaire_response import ItineraryQuestionnaireResponse
from app.models.itinerary_generate_request import ItineraryGenerateRequest
from app.models.itinerary_generate_response import ItineraryGenerateResponse
from app.services.openai_client import get_itinerary_activity


logger = logging.getLogger(__name__)


class ItineraryService:
    def __init__(self):
        pass

    def get_activities(self, request: ItineraryQuestionnaireRequest) -> dict:
        # Placeholder for actual activity retrieval logic
        logger.debug(common_utils.get_logging_message(self.get_activities.__name__))

        response_text = get_itinerary_activity(request)
        if response_text is None:
            logger.error(
                common_utils.get_error_message(
                    self.get_activities.__name__,
                    "Failed to fetch activities from OpenAI.",
                )
            )
            raise CustomException("Failed to fetch activities from OpenAI.")

        # DB call should be happened here to save the activities?
        # For now, we will just return the response from OpenAI
        # set ready_for_optimize to True when DB saving is successful

        try:
            response_json = json.loads(response_text)
            return ItineraryQuestionnaireResponse(**response_json)

        except Exception as e:
            logger.error(
                common_utils.get_error_message(self.get_activities.__name__, str(e))
            )
            raise CustomException("Invalid response format.")

    def get_itinerary(
        self, request: ItineraryGenerateRequest
    ) -> ItineraryGenerateResponse:
        return ItineraryGenerateResponse(
            errors=[{"code": "500", "message": "Invalid response format."}]
        )
