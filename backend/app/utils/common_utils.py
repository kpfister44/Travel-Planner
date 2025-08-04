from fastapi import HTTPException, Security, Request, status
from fastapi.encoders import jsonable_encoder
from fastapi.security import APIKeyHeader
from app.core.config import settings
from app.models.destination_request import DestinationRequest
from app.models.itinerary_questionnaire_request import ItineraryQuestionnaireRequest
from app.models.destination_response import DestinationResponse
from app.models.itinerary_questionnaire_response import ItineraryQuestionnaireResponse
from app.models.itinerary_generate_response import ItineraryGenerateResponse
from app.models.errors import ErrorItem
from typing import List, Union


# error message
def get_error_response(code: str, message: str) -> list:
    # convert code to str
    code_str = str(code)
    return [{"code": code_str, "message": message}]


# logging utility
def get_error_message(method_name: str, exception: str) -> str:
    return f"ERROR IN {method_name}: {exception}"


def get_logging_message(method_name: str, message: str = None) -> str:
    if message:
        return f"{method_name} - {message}"
    return f"INSIDE {method_name}"


def get_logging_message_request(request: object) -> str:
    return f"REQUEST FROM UI: {jsonable_encoder(request)}"


def get_logging_message_response(response: object) -> str:
    return f"RESPONSE TO UI: {jsonable_encoder(response)}"


# API Key Setup
api_key_header = APIKeyHeader(name=settings.API_KEY_NAME, auto_error=False)


# dependency for api key validation
async def validate_api_key(api_key: str = Security(api_key_header)):
    if api_key != settings.API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API Key")


def determine_response_type(request: Request) -> str:
    """
    Determine which response format to use based on the request path

    Args:
        request: FastAPI Request object

    Returns:
        String indicating response type: 'destination', 'itinerary', or 'generic'
    """
    path = request.url.path

    if "/destinations/" in path:
        return "destination"
    elif "/itinerary/" in path or "/itineraries/" in path:
        return "questionnaire"
    else:
        return "generate"


def create_error_response(
    request: Request, errors: List[ErrorItem]
) -> Union[
    DestinationResponse, ItineraryQuestionnaireResponse, ItineraryGenerateResponse
]:
    """
    Create appropriate error response based on endpoint

    Args:
        request: FastAPI Request object
        errors: List of ErrorItem objects

    Returns:
        Appropriate response object with errors
    """
    response_type = determine_response_type(request)

    error_dicts = [
        error.dict() if hasattr(error, "dict") else error for error in errors
    ]
    if response_type == "destination":
        return DestinationResponse(errors=error_dicts, recommendations=None)
    elif response_type == "questionnaire":
        return ItineraryQuestionnaireResponse(
            errors=error_dicts, itinerary=None, total_cost=None
        )
    else:
        return ItineraryGenerateResponse(errors=error_dicts, data=None, message=None)


def format_validation_errors(errors):
    """Convert Pydantic validation errors into ErrorItem objects"""
    formatted_errors = []

    for error in errors:
        field_path = ".".join(str(loc) for loc in error["loc"])
        error_msg = error["msg"]
        error_type = error["type"]

        if error_type == "missing":
            # code = "missing_field"
            message = f"Field '{field_path}' is required"
        elif error_type == "value_error":
            # code = "invalid_value"
            message = f"Field '{field_path}': {error_msg}"
        elif error_type == "type_error":
            # code = "invalid_type"
            message = f"Field '{field_path}' has invalid type: {error_msg}"
        elif error_type in ["value_error.number.not_ge", "value_error.number.not_le"]:
            # code = "invalid_range"
            message = f"Field '{field_path}': {error_msg}"
        elif error_type == "value_error.list.min_items":
            # code = "insufficient_items"
            limit = error.get("ctx", {}).get("limit_value", 1)
            message = f"Field '{field_path}' must contain at least {limit} item(s)"
        else:
            # code = "validation_error"
            message = f"Field '{field_path}': {error_msg}"

        code = str(status.HTTP_422_UNPROCESSABLE_ENTITY)
        formatted_errors.append(ErrorItem(code=code, message=message))

    return formatted_errors
