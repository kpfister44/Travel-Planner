import openai
from app.core.config import settings
from app.models.destination_response import DestinationResponse
from app.constants import openai_constants
from app.utils import common_utils
import logging

logger = logging.getLogger(__name__)


def get_travel_ideas(preferences: dict) -> str:
    logger.debug(common_utils.get_logging_message(get_travel_ideas.__name__))
    try:
        openai.api_key = settings.OPENAI_API_KEY
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": openai_constants.DEFAULT_DESTINATION_SYSTEM_PROMPT,
                },
                {
                    "role": "user",
                    "content": f"Suggest 3 to 5 destination recommendations based on the following preferences: {preferences}",
                },
            ],
            max_tokens=500,
            temperature=0.7,
        )

        # testing purpose
        # response = None
        # raise Exception("OpenAI API is not available for testing.")

        logger.info(f"OpenAI response for destination: {response}")
    except Exception as e:
        logger.error(common_utils.get_error_message(get_travel_ideas.__name__, str(e)))
        return None

    return response.choices[0].message.content


def get_itinerary_activity(activity_request: list) -> str:
    try:
        openai.api_key = settings.OPENAI_API_KEY
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": openai_constants.DEFAULT_QUESTIONARY_ACTIVITY_SYSTEM_PROMPT,
                },
                {
                    "role": "user",
                    "content": f"Suggest 10 activities based on the following preference: {activity_request}",
                },
            ],
            max_tokens=1000,
            temperature=0.7,
        )
        logger.info(f"OpenAI response for itinerary_activity: {response}")
    except Exception as e:
        logger.error(common_utils.get_error_message(get_travel_ideas.__name__, str(e)))
        return None
    return response.choices[0].message.content


def get_optimized_itinerary(optimization_request: list) -> str:
    try:
        openai.api_key = settings.OPENAI_API_KEY
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": openai_constants.DEFAULT_ITINERARY_OPTIMIZING_SYSTEM_PROMPT,
                },
                {
                    "role": "user",
                    "content": f"Create an optimized itinerary based on the following preference: {optimization_request}",
                },
            ],
            max_tokens=500,
            temperature=0.7,
        )
        logger.info(f"OpenAI response for optimized itinerary: {response}")
    except Exception as e:
        logger.error(common_utils.get_error_message(get_travel_ideas.__name__, str(e)))
        return None
    return response.choices[0].message.content
