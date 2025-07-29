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
from sqlalchemy.orm import Session
from database import get_db
from models import Questionnaire, Activity

logger = logging.getLogger(__name__)


class ItineraryService:
    def __init__(self):
        self.questionnaire_repo = None

    def get_activities(self, request: ItineraryQuestionnaireRequest) -> dict:
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

        id = self._generate_questionnaire_id()

        try:
            response_json = json.loads(response_text)
            activities = response_json.get("suggested_activities", [])
            is_ready_for_optimize = self._save_activities_to_db(id, activities)

            response_json["questionnaire_id"] = id
            response_json["destination"] = (
                {
                    "id": request.selected_destination.id,
                    "name": request.selected_destination.name,
                }
                if request.selected_destination
                else None
            )
            response_json["ready_for_optimization"] = is_ready_for_optimize
            return ItineraryQuestionnaireResponse(**response_json)

        except Exception as e:
            logger.error(
                common_utils.get_error_message(self.get_activities.__name__, str(e))
            )
            raise CustomException("Invalid response format.")

    def get_itinerary(
        self, request: ItineraryGenerateRequest
    ) -> ItineraryGenerateResponse:
        logger.debug(common_utils.get_logging_message(self.get_itinerary.__name__))

        # optimization logic go here
        # Step 1: Get questionnaire and destination info from database
        questionnaire_data = self._get_questionnaire_from_db(request.questionnaire_id)
        if not questionnaire_data:
            logger.error(
                common_utils.get_error_message(
                    self.get_activities.__name__,
                    f"Questionnaire not found: {request.questionnaire_id}",
                )
            )
            raise CustomException("Questionnaire not found")

        if not questionnaire_data.get("ready_for_optimization", False):
            logger.error(
                common_utils.get_error_message(
                    self.get_activities.__name__,
                    f"Questionnaire not ready for optimization: {request.questionnaire_id}",
                )
            )
            raise CustomException("Questionnaire not ready for optimization")

        # Step 2: Get all activities from database and filter by selected ones
        all_activities = self._get_activities_from_db(request.questionnaire_id)
        if not all_activities:
            logger.error(
                common_utils.get_error_message(
                    self.get_activities.__name__,
                    f"No activities found for questionnaire: {request.questionnaire_id}",
                )
            )
            raise CustomException("No activities found for this questionnaire")

        # Step 3: Filter activities based on selected activities in request
        selected_activities = self._filter_selected_activities(
            all_activities, request.selected_activities
        )
        if not selected_activities:
            logger.error(
                common_utils.get_error_message(
                    self.get_activities.__name__,
                    "None of the selected activities were found in the database",
                )
            )
            raise CustomException("Selected activities not found")

        # Step 4: Prepare optimization request with selected activities + preferences
        optimization_request = self._prepare_optimization_request(
            questionnaire_data=questionnaire_data,
            selected_activities=selected_activities,
            user_request=request,
        )

        response_text = get_itinerary_activity(optimization_request)
        if response_text is None:
            logger.error(
                common_utils.get_error_message(
                    self.get_itinerary.__name__,
                    "Failed to fetch activities from OpenAI.",
                )
            )
            raise CustomException("Failed to fetch activities from OpenAI.")

        try:
            response_json = json.loads(response_text)
            return ItineraryGenerateResponse(**response_json)

        except Exception as e:
            logger.error(
                common_utils.get_error_message(self.get_itinerary.__name__, str(e))
            )
            raise CustomException("Invalid response format.")

    def _generate_questionnaire_id(self) -> str:
        # Placeholder for ID generation logic
        # In a real application, this could be a UUID or an auto-incremented DB ID
        import uuid

        return f"quest_{uuid.uuid4().hex[:8]}"

    def _save_activities_to_db(
        self, questionnaire_id: str, destination: dict, activities: list[dict]
    ) -> bool:
        """Save questionnaire and activities to database"""
        try:
            db: Session = next(get_db())

            # create or update the questionnaire record
            questionnaire = db.query(Questionnaire).filter(
                Questionnaire.id == questionnaire_id
            ).first()
            if not questionnaire:
                # create new questionnaire record based on schema
                questionnaire = Questionnaire(
                    id=questionnaire_id,
                    destination_id=None,
                    destination_name="",
                    ready_for_optimization=True
                )
                db.add(questionnaire)
            # clear any existing activities for this questionnaire
            db.query(Activity).filter(Activity.questionnaire_id ==
                                      questionnaire_id).delete()
            # save new activities based on schema
            for activity_data in activities:
                activity = Activity(
                    questionnaire_id=questionnaire_id,
                    name=activity_data.get("name", ""),
                    description=activity_data.get("description", ""),
                    category=activity_data.get("category", ""),
                    duration_hours=activity_data.get("duration_hours", 0.0),
                    cost=activity_data.get("cost", 0.0),
                    priority=activity_data.get("priority", "medium")
                )
                db.add(activity)
            db.commit()
            return True

        except Exception as e:
            logger.error(f"Error saving activities to database: {str(e)}")
            db.rollback()
            return False
        finally:
            db.close()

    def _filter_selected_activities(
        self, all_activities: list[dict], selected_activities: list
    ) -> list[dict]:
        """Filter activities based on user selection and update priorities"""

        # Create a mapping of selected activities by ID
        selected_map = {
            activity.id: activity.priority for activity in selected_activities
        }

        filtered_activities = []
        for activity in all_activities:
            if activity["id"] in selected_map:
                # Update priority based on user selection
                activity_copy = activity.copy()
                activity_copy["priority"] = selected_map[activity["id"]]
                filtered_activities.append(activity_copy)

        logger.info(
            f"Selected {len(filtered_activities)} out of {len(all_activities)} activities"
        )
        return filtered_activities

    def _prepare_optimization_request(
        self,
        questionnaire_data: dict,
        selected_activities: list[dict],
        request: ItineraryGenerateRequest,
    ) -> dict:
        """Prepare the request for OpenAI itinerary optimization"""
        return {
            "questionnaire_id": questionnaire_data["id"],
            "destination": {
                "id": questionnaire_data["destination_id"],
                "name": questionnaire_data["destination_name"],
            },
            "selected_activities": selected_activities,
            "preferences": {
                "pace": request.preferences.pace,
                "daily_start_time": request.preferences.daily_start_time,
                "daily_end_time": request.preferences.daily_end_time,
                "max_activities_per_day": request.preferences.max_activities_per_day,
            },
            "optimization_details": {
                "total_activities": len(selected_activities),
                "high_priority_count": len(
                    [a for a in selected_activities if a["priority"] == "high"]
                ),
                "medium_priority_count": len(
                    [a for a in selected_activities if a["priority"] == "medium"]
                ),
                "low_priority_count": len(
                    [a for a in selected_activities if a["priority"] == "low"]
                ),
                "categories": list(set([a["category"] for a in selected_activities])),
                "total_estimated_duration": sum(
                    [a["duration_hours"] for a in selected_activities]
                ),
                "total_estimated_cost": sum([a["cost"] for a in selected_activities]),
            },
        }