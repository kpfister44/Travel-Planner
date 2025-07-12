from app.models.destination_request import DestinationRequest


# error message
def get_error_response(code: str, message: str) -> list:
    return [{"code": code, "message": message}]


# logging utility
def get_error_message(method_name: str, exception: str) -> str:
    return f"Error in {method_name}: {exception}"


def get_logging_message(method_name: str) -> str:
    return f"Inside {method_name}"


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
