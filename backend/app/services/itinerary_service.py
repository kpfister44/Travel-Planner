# LLM itinerary optimization service
import logging
import json
from app.utils import common_utils
from app.models.errors import ErrorItem
from app.models.custom_exception import CustomException
from app.models.itinerary_questionnaire_request import ItineraryQuestionnaireRequest
from app.models.itinerary_questionnaire_response import ItineraryQuestionnaireResponse
from app.models.itinerary_generate_request import ItineraryGenerateRequest
from app.models.itinerary_generate_response import ItineraryGenerateResponse
from app.services.openai_client import get_itinerary_activity
from database import SessionLocal
from models import Activity, Destination, Prompt

logger = logging.getLogger(__name__)


class ItineraryService:
    def __init__(self):
        pass

    def get_activities(self, request: ItineraryQuestionnaireRequest, user_id = None) -> dict:
        # Placeholder for actual activity retrieval logic
        logger.debug(common_utils.get_logging_message(self.get_activities.__name__))

        response_text = get_itinerary_activity(request)
        if response_text is None:
            logger.error(
                common_utils.get_error_message(
                    self.get_activities.__name__,
                    "Failed to fetch activities from OpenAI.",
                )
            )
            raise CustomException("Failed to fetch activities from OpenAI.")

        try:
            response_json = json.loads(response_text)
            response = ItineraryQuestionnaireResponse(**response_json)
           
            # Save to database
            self._save_activities_to_database(request, response_text, response, user_id)
            
            return response
        except Exception as e:
            logger.error(
                common_utils.get_error_message(self.get_activities.__name__, str(e))
            )
            raise CustomException("Invalid response format.")

    def _save_activities_to_database(self, request, response_text, response, user_id):
        """Save the activities and prompt to database"""
        db = SessionLocal()
        try:
            # Save the prompt interaction
            if user_id:
                prompt = Prompt(
                    user_id=user_id,
                    input_text=json.dumps(request.dict()),
                    llm_output=response_text,
                    prompt_template="itinerary_activities"
                )
                db.add(prompt)

            # Save activities if we got them
            if hasattr(response, 'suggested_activities') and response.suggested_activities:
                # For now, we'll save activities without linking to a specific destination
                
                for activity_data in response.suggested_activities:
                    # Only save if it doesn't already exist
                    existing = db.query(Activity).filter(
                        Activity.name == activity_data.name
                    ).first()

                    if not existing:
                        activity = Activity(
                            destination_id=None,  # will need to link this properly
                            name=activity_data.name,
                            description=activity_data.description if hasattr(activity_data, 'description') else None
                        )
                        db.add(activity)

            db.commit()
            logger.info("Saved activities to database successfully")

        except Exception as e:
            logger.error(f"Failed to save activities to database: {e}")
            db.rollback()
        finally:
            db.close()

    def get_itinerary(self, request: ItineraryGenerateRequest, user_id=None) -> ItineraryGenerateResponse:
        # Save the itinerary request to database
        db = SessionLocal()
        try:
            if user_id:
                prompt = Prompt(
                    user_id=user_id,
                    input_text=json.dumps(request.dict()),
                    llm_output="Itinerary generation not implemented yet",
                    prompt_template="itinerary_generation"
                )
                db.add(prompt)
                db.commit()
        except Exception as e:
            logger.error(f"Failed to save itinerary request: {e}")
        finally:
            db.close()

        return ItineraryGenerateResponse(
            errors=[{"code": "500", "message": "Invalid response format."}]
        )
