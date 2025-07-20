from fastapi import HTTPException, Security
from fastapi.encoders import jsonable_encoder
from fastapi.security import APIKeyHeader
from app.core.config import settings
from app.models.destination_request import DestinationRequest
from app.models.itinerary_questionnaire_request import ItineraryQuestionnaireRequest


# error message
def get_error_response(code: str, message: str) -> list:
    return [{"code": code, "message": message}]


# logging utility
def get_error_message(method_name: str, exception: str) -> str:
    return f"Error in {method_name}: {exception}"


def get_logging_message(method_name: str) -> str:
    return f"Inside {method_name}"


def get_logging_message_request(request: object) -> str:
    return f"Request Received From UI: {jsonable_encoder(request)}"


# input validation for destination request
def input_validation_destination(destinationRequest: DestinationRequest) -> bool:
    prefs = destinationRequest.preferences
    try:
        # Check required fields
        if not prefs:
            return False
        if not (prefs.traveler_info and prefs.traveler_info.age_group):
            return False
        if not (prefs.budget and prefs.budget.min is not None and prefs.budget.max is not None):
            return False
        if not (prefs.travel_dates and prefs.travel_dates.start_date and prefs.travel_dates.end_date):
            return False
        if not (prefs.group_size and prefs.group_size > 0):
            return False
        if not prefs.group_relationship:
            return False
        if not prefs.preferred_location:
            return False
        if not prefs.travel_style:
            return False
        # Allow empty arrays for interests, must_haves, deal_breakers
        if prefs.interests is None or prefs.must_haves is None or prefs.deal_breakers is None:
            return False
        return True
    except Exception as e:
        return False


def input_validation_itinerary_questionnaire(
    itinerary_questionnaire_request: ItineraryQuestionnaireRequest,
) -> bool:
    pref = itinerary_questionnaire_request
    if not all(
        [
            pref,
            pref.selected_destination,
            pref.selected_destination.id is not None,
            pref.selected_destination.name is not None,
            pref.travel_dates,
            pref.travel_dates.start_date is not None,
            pref.travel_dates.end_date is not None,
            pref.activity_preferences,
        ]
    ):
        return False
    return True


# API Key Setup
api_key_header = APIKeyHeader(name=settings.API_KEY_NAME, auto_error=False)


# dependency for api key validation
async def validate_api_key(api_key: str = Security(api_key_header)):
    if api_key != settings.API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API Key")
