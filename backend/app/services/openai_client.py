import openai
from app.core.config import settings
from app.models.destination_response import DestinationResponse
from app.constants import openai_constants
from app.utils import common_utils
import logging

# from openai import OpenAI

# client = OpenAI(api_key=settings.OPENAI_API_KEY)

# response = client.responses.create(
#   model="gpt-4.1",
#   input="Tell me a three sentence bedtime story about a unicorn."
# )

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
        logger.info(f"OpenAI response: {response}")
    except Exception as e:
        logger.error(common_utils.get_error_message(get_travel_ideas.__name__, str(e)))
        return None

    return response.choices[0].message.content


def get_optimized_itinerary(destinations: list) -> str:
    openai.api_key = settings.OPENAI_API_KEY
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "You are an itinerary optimizer."},
            {
                "role": "user",
                "content": f"Create an optimized itinerary for: {destinations}",
            },
        ],
    )
    return response["choices"][0]["message"]["content"]
