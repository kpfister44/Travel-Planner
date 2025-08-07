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


def get_optimized_itinerary(optimization_request: dict) -> str:
    try:
        openai.api_key = settings.OPENAI_API_KEY
        
        # Extract travel dates and calculate duration
        travel_dates = optimization_request.get("travel_dates", {})
        start_date = travel_dates.get("start_date")
        end_date = travel_dates.get("end_date")
        
        # Create enhanced user prompt with date context
        destination_name = optimization_request.get('destination', {}).get('name', 'the destination')
        selected_activities = optimization_request.get('selected_activities', [])
        
        user_prompt = f"Create an optimized itinerary for {destination_name}. The user has selected {len(selected_activities)} activities they definitely want to include: {[a.get('name', 'Unknown') for a in selected_activities]}. Use these as foundation activities and generate additional complementary activities to create a complete, varied itinerary. Full request details: {optimization_request}"
        
        if start_date and end_date:
            from datetime import datetime
            try:
                start_dt = datetime.strptime(start_date, "%Y-%m-%d")
                end_dt = datetime.strptime(end_date, "%Y-%m-%d")
                total_days = (end_dt - start_dt).days + 1
                
                user_prompt = f"Create an optimized {total_days}-day itinerary for {destination_name} from {start_date} to {end_date}. The user has selected {len(selected_activities)} foundation activities: {[a.get('name', 'Unknown') for a in selected_activities]}. You must include these activities and generate additional complementary activities to fill all {total_days} days with varied, engaging experiences. Avoid repeating the same activity multiple times. Full preferences: {optimization_request}"
            except ValueError:
                logger.warning(f"Invalid date format in optimization request: {start_date} to {end_date}")
        
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": openai_constants.DEFAULT_ITINERARY_OPTIMIZING_SYSTEM_PROMPT,
                },
                {
                    "role": "user",
                    "content": user_prompt,
                },
            ],
            max_tokens=3000,  # Increased for longer itineraries
            temperature=0.7,
        )
        logger.info(f"OpenAI response for optimized itinerary: {response}")
    except Exception as e:
        logger.error(common_utils.get_error_message(get_travel_ideas.__name__, str(e)))
        return None
    return response.choices[0].message.content
