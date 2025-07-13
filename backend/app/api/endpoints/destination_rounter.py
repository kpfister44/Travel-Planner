from fastapi import APIRouter
import logging
from app.models.destination_request import DestinationRequest
from app.models.destination_response import DestinationResponse
from app.services.destination_service import DestinationService
from app.utils import common_utils

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/destinations", tags=["destinations"])

destination_service = DestinationService()


@router.post("/recommendations", response_model=DestinationResponse)
async def get_destination_recommendations(request: DestinationRequest):
    logger.debug(
        common_utils.get_logging_message(get_destination_recommendations.__name__)
    )
    try:
        return destination_service.get_recommendations(request)
    except Exception as e:
        logger.error(
            common_utils.get_error_message(
                get_destination_recommendations.__name__, str(e)
            )
        )
        return DestinationResponse(
            errors=[{"code": "500", "message": "Internal server error"}]
        )


@router.get("/health", response_model=dict)
async def health_check():
    return {"status": "ok", "message": "Destination service is running"}
