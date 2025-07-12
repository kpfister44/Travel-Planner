from fastapi import APIRouter
import logging
from app.utils import common_utils
from app.models.itinerary_questionnaire_request import ItineraryQuestionnaireRequest
from app.models.itinerary_questionnaire_response import ItineraryQuestionnaireResponse
from app.models.itinerary_generate_request import ItineraryGenerateRequest
from app.models.itinerary_generate_response import ItineraryGenerateResponse

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/itinerary", tags=["itinerary"])


@router.post("/questionnaire", response_model=ItineraryQuestionnaireResponse)
async def get_itinerary_activities(request: ItineraryQuestionnaireRequest):
    logger.debug(common_utils.get_logging_message(get_itinerary_activities.__name__))
    try:
        return {"message": "sample itinerary activities response"}
    except Exception as e:
        logger.error(
            common_utils.get_error_message(get_itinerary_activities.__name__, str(e))
        )
        return {"error": "Internal server error"}


@router.post("/generate", response_model=ItineraryGenerateResponse)
async def get_optimized_itinerary(request: ItineraryGenerateRequest):
    logger.debug(common_utils.get_logging_message(get_optimized_itinerary.__name__))
    try:
        return {"message": "sample itinerary response"}
    except Exception as e:
        logger.error(
            common_utils.get_error_message(get_optimized_itinerary.__name__, str(e))
        )
        return {"error": "Internal server error"}


@router.get("/health", response_model=dict)
async def health_check():
    return {"status": "ok", "message": "Itinerary service is running"}
