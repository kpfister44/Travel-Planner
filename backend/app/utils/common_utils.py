from fastapi import HTTPException, Security
from fastapi.encoders import jsonable_encoder
from fastapi.security import APIKeyHeader
from app.core.config import settings
from app.models.destination_request import DestinationRequest
from app.models.itinerary_questionnaire_request import ItineraryQuestionnaireRequest


# error message
def get_error_response(code: str, message: str) -> list:
    #convert code to str
    code_str = str(code)
    return [{"code": code_str, "message": message}]


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
    if not all(
        [
            prefs,
            prefs.budget
            and prefs.budget.min is not None
            and prefs.budget.max is not None,
            prefs.travel_dates
            and prefs.travel_dates.start_date
            and prefs.travel_dates.end_date,
            prefs.group_size and prefs.group_size > 0,
            prefs.interests,
            prefs.travel_style,
            prefs.must_haves,
            prefs.deal_breakers,
        ]
    ):
        return False
    return True


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
