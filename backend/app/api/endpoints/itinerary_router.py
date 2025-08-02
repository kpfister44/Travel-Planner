from fastapi import APIRouter, Depends, Body
import logging
from app.utils import common_utils
from app.models.errors import ErrorItem
from app.models.itinerary_questionnaire_request import ItineraryQuestionnaireRequest
from app.models.itinerary_questionnaire_response import ItineraryQuestionnaireResponse
from app.models.itinerary_generate_request import ItineraryGenerateRequest
from app.models.itinerary_generate_response import ItineraryGenerateResponse
from app.services.itinerary_service import ItineraryService
from app.utils.auth_utils import validate_api_key
from exceptions import APIException

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/itinerary", tags=["itinerary"])


# dependency injection for ItineraryService
def get_itinerary_service() -> ItineraryService:
    return ItineraryService()


@router.post("/questionnaire", response_model=ItineraryQuestionnaireResponse)
async def get_itinerary_activities(
    _: None = Depends(validate_api_key),
    request: ItineraryQuestionnaireRequest = Body(...),
    service: ItineraryService = Depends(get_itinerary_service),
):
    logger.info(common_utils.get_logging_message_request(request))
    try:
        # return {"status": "ok", "message": "Itinerary service is running"}
        return service.get_activities(request)

    except Exception as e:
        logger.error(
            common_utils.get_error_message(get_itinerary_activities.__name__, str(e))
        )
        raise APIException(
            status_code=500,
            detail="Internal server error",
        )


@router.post("/generate", response_model=ItineraryGenerateResponse)
async def get_optimized_itinerary(
    _: None = Depends(validate_api_key),
    request: ItineraryGenerateRequest = Body(...),
    service: ItineraryService = Depends(get_itinerary_service),
):
    logger.info(common_utils.get_logging_message_request(request))
    try:
        return service.get_itinerary(request)
    except Exception as e:
        logger.error(
            common_utils.get_error_message(get_optimized_itinerary.__name__, str(e))
        )
        raise APIException(
            status_code=500,
            detail="Internal server error",
        )


@router.get("/health", response_model=dict)
async def health_check(service: ItineraryService = Depends(get_itinerary_service)):
    logger.info(common_utils.get_logging_message(health_check.__name__))
    if service is None:
        return {"status": "error", "message": "Itinerary service is not available"}
    return {"status": "ok", "message": "Itinerary service is running"}


@router.get("/health/db", response_model=dict)
async def health_check(service: ItineraryService = Depends(get_itinerary_service)):
    logger.info(common_utils.get_logging_message(health_check.__name__))
    service.debug_print_all_data()
    if service is None:
        return {"status": "error", "message": "Itinerary service is not available"}
    return {"status": "ok", "message": "printed all data"}
