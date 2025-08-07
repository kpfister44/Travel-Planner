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
from app.services.openai_client import get_itinerary_activity, get_optimized_itinerary
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import Questionnaire, Activity, RateLimitEntry


logger = logging.getLogger(__name__)

# we can use a context manager to handle database sessions
# to ensure proper cleanup and avoid session leaks
# from contextlib import contextmanager
# @contextmanager
# def get_db_session():
#     """Context manager for database sessions"""
#     db = next(get_db())
#     try:
#         yield db
#     finally:
#         db.close()


class ItineraryService:
    def __init__(self):
        self.questionnaire_repo = None

    def get_activities(self, request: ItineraryQuestionnaireRequest) -> dict:
        """
        Get itinerary activities based on user preferences and selected destination.
        """

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
            activities = response_json.get("suggested_activities", [])

            # Fix: Pass destination data to save method
            destination_data = None
            if request.selected_destination:
                destination_data = {
                    "id": request.selected_destination.id,
                    "name": request.selected_destination.name,
                }

            # Extract travel dates from request
            travel_dates_data = None
            if request.travel_dates:
                travel_dates_data = {
                    "start_date": str(request.travel_dates.start_date),
                    "end_date": str(request.travel_dates.end_date),
                }

            success, id = self._save_activities_to_db(destination_data, activities, travel_dates_data)

            if not success:
                logger.error(
                    common_utils.get_error_message(
                        self.get_activities.__name__,
                        "Failed to save activities to database.",
                    )
                )
                raise CustomException("Failed to save activities to database.")

            response_json["questionnaire_id"] = str(id)
            response_json["destination"] = destination_data
            response_json["ready_for_optimization"] = True
            return ItineraryQuestionnaireResponse(**response_json)

        except Exception as e:
            logger.error(
                common_utils.get_error_message(self.get_activities.__name__, str(e))
            )
            raise CustomException("Invalid response format.")

    def get_itinerary(
        self, request: ItineraryGenerateRequest
    ) -> ItineraryGenerateResponse:
        """
        Generate an optimized itinerary based on user preferences and selected activities.
        """
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

        # Step 1.5: Validate trip length (max 10 days)
        start_date = questionnaire_data.get("start_date")
        end_date = questionnaire_data.get("end_date")
        
        if start_date and end_date:
            try:
                from datetime import datetime
                start_dt = datetime.strptime(start_date, "%Y-%m-%d")
                end_dt = datetime.strptime(end_date, "%Y-%m-%d")
                trip_length = (end_dt - start_dt).days + 1
                
                if trip_length > 10:
                    logger.error(
                        common_utils.get_error_message(
                            self.get_itinerary.__name__,
                            f"Trip length ({trip_length} days) exceeds maximum allowed (10 days)",
                        )
                    )
                    raise CustomException(f"Trip length of {trip_length} days exceeds the maximum allowed length of 10 days. Please select a shorter trip for optimal recommendations.")
                
                if trip_length < 1:
                    logger.error(
                        common_utils.get_error_message(
                            self.get_itinerary.__name__,
                            f"Invalid trip length: {trip_length} days",
                        )
                    )
                    raise CustomException("Trip length must be at least 1 day. Please check your travel dates.")
                    
                logger.info(
                    common_utils.get_logging_message(
                        self.get_itinerary.__name__,
                        f"Validated trip length: {trip_length} days",
                    )
                )
                
            except ValueError as e:
                logger.error(
                    common_utils.get_error_message(
                        self.get_itinerary.__name__,
                        f"Invalid date format in questionnaire: {start_date} to {end_date}",
                    )
                )
                raise CustomException("Invalid travel dates format. Please select valid dates.")
        else:
            logger.error(
                common_utils.get_error_message(
                    self.get_itinerary.__name__,
                    "Missing travel dates in questionnaire data",
                )
            )
            raise CustomException("Travel dates are required for itinerary generation.")

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
            request=request,
        )

        # call openai client to get optimized itinerary
        response_text = get_optimized_itinerary(optimization_request)
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

        except json.JSONDecodeError as e:
            logger.error(
                common_utils.get_error_message(
                    self.get_itinerary.__name__, 
                    f"JSON parsing failed: {str(e)}. Response length: {len(response_text) if response_text else 0}"
                )
            )
            raise CustomException("OpenAI response was truncated. Please try again.")
        except Exception as e:
            logger.error(
                common_utils.get_error_message(self.get_itinerary.__name__, str(e))
            )
            raise CustomException("Invalid response format.")

    def _get_activities_from_db(self, questionnaire_id: str) -> list[dict]:
        """Retrieve activities from the database for a given questionnaire ID"""
        logger.debug(
            common_utils.get_logging_message(self._get_activities_from_db.__name__)
        )
        try:
            db: Session = next(get_db())
            activities = (
                db.query(Activity)
                .filter(Activity.questionnaire_id == questionnaire_id)
                .all()
            )
            return (
                [
                    {
                        "id": activity.original_id,
                        "name": activity.name,
                        "description": activity.description,
                        "category": activity.category,
                        "duration_hours": activity.duration_hours,
                        "cost": activity.cost,
                        "priority": activity.priority,
                    }
                    for activity in activities
                ]
                if activities
                else []
            )
        except Exception as e:
            logger.error(
                common_utils.get_error_message(
                    self._get_activities_from_db.__name__, str(e)
                )
            )
            return []
        finally:
            db.close()

    def _get_questionnaire_from_db(self, questionnaire_id: str) -> dict:
        """Retrieve questionnaire data from the database"""
        logger.debug(
            common_utils.get_logging_message(self._get_questionnaire_from_db.__name__)
        )
        try:
            db: Session = next(get_db())
            questionnaire = (
                db.query(Questionnaire)
                .filter(Questionnaire.id == questionnaire_id)
                .first()
            )
            logger.info(
                common_utils.get_logging_message(
                    self._get_questionnaire_from_db.__name__,
                    f"Found questionnaire: {questionnaire is not None}",
                )
            )

            if not questionnaire:
                return None
            return {
                "id": questionnaire.id,
                "destination_id": questionnaire.destination_id,
                "destination_name": questionnaire.destination_name,
                "start_date": questionnaire.start_date,
                "end_date": questionnaire.end_date,
                "ready_for_optimization": questionnaire.ready_for_optimization,
            }
        except Exception as e:
            logger.error(
                common_utils.get_error_message(
                    self._get_questionnaire_from_db.__name__, str(e)
                )
            )
            return None
        finally:
            db.close()

    def _save_activities_to_db(self, destination: dict, activities: list[dict], travel_dates: dict = None) -> bool:
        """Save questionnaire and activities to database"""
        logger.debug(
            common_utils.get_logging_message(self._save_activities_to_db.__name__)
        )
        try:
            db: Session = next(get_db())

            # create new questionnaire record based on schema
            questionnaire = Questionnaire(
                destination_id=destination.get("id") if destination else None,
                destination_name=destination.get("name", "") if destination else "",
                start_date=travel_dates.get("start_date") if travel_dates else None,
                end_date=travel_dates.get("end_date") if travel_dates else None,
                ready_for_optimization=True,
            )
            db.add(questionnaire)
            db.flush()
            logger.info(
                common_utils.get_logging_message(
                    self._save_activities_to_db.__name__,
                    f"Starting to save questionnaire: {questionnaire.id} and activities",
                )
            )
            # clear any existing activities for this questionnaire
            db.query(Activity).filter(
                Activity.questionnaire_id == questionnaire.id
            ).delete()
            # save new activities based on schema
            for activity_data in activities:
                activity = Activity(
                    original_id=activity_data.get("id"),
                    questionnaire_id=questionnaire.id,
                    name=activity_data.get("name", ""),
                    description=activity_data.get("description", ""),
                    category=activity_data.get("category", ""),
                    duration_hours=activity_data.get("duration_hours", 0.0),
                    cost=activity_data.get("cost", 0.0),
                    priority=activity_data.get("priority", "medium"),
                )
                db.add(activity)
            # commit the changes
            db.commit()
            logger.info(
                common_utils.get_logging_message(
                    self._save_activities_to_db.__name__,
                    "Activities saved successfully",
                )
            )
            return True, questionnaire.id

        except Exception as e:
            logger.error(
                common_utils.get_error_message(
                    self._save_activities_to_db.__name__, str(e)
                )
            )
            db.rollback()
            return False, None
        finally:
            db.close()

    def _filter_selected_activities(
        self, all_activities: list[dict], selected_activities: list
    ) -> list[dict]:
        """Filter activities based on user selection and update priorities"""
        logger.debug(
            common_utils.get_logging_message(self._filter_selected_activities.__name__)
        )
        # Create a mapping of selected activities by ID
        selected_map = {
            activity.id: activity.priority for activity in selected_activities
        }

        # log the unrecognized activities
        all_activities_id = {activity["id"] for activity in all_activities}
        missing_ids = selected_map.keys() - all_activities_id
        if missing_ids:
            logger.warning(
                common_utils.get_logging_message(
                    self._filter_selected_activities.__name__,
                    f"Selected activities not found in database: {missing_ids}",
                )
            )

        # filter the activities based on the selected map
        filtered_activities = []
        for activity in all_activities:
            if activity["id"] in selected_map:
                # Update priority based on user selection
                activity_copy = activity.copy()
                activity_copy["priority"] = selected_map[activity["id"]]
                filtered_activities.append(activity_copy)

        logger.info(
            common_utils.get_logging_message(
                self._filter_selected_activities.__name__,
                f"Selected {len(filtered_activities)} out of {len(all_activities)} activities",
            )
        )
        return filtered_activities

    def _prepare_optimization_request(
        self,
        questionnaire_data: dict,
        selected_activities: list[dict],
        request: ItineraryGenerateRequest,
    ) -> dict:
        """Prepare the request for OpenAI itinerary optimization"""
        logger.debug(
            common_utils.get_logging_message(
                self._prepare_optimization_request.__name__
            )
        )
        return {
            "questionnaire_id": questionnaire_data["id"],
            "destination": {
                "id": questionnaire_data["destination_id"],
                "name": questionnaire_data["destination_name"],
            },
            "travel_dates": {
                "start_date": questionnaire_data["start_date"],
                "end_date": questionnaire_data["end_date"],
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

    def debug_print_all_data(self):
        """Quick method to print all database data - for debugging"""
        print("\n🔍 DEBUG: Printing all database data...")

        try:
            db: Session = next(get_db())

            # Print questionnaires
            questionnaires = db.query(Questionnaire).all()
            print(f"\n📋 QUESTIONNAIRES ({len(questionnaires)}):")
            for q in questionnaires:
                print(
                    f"  {q.id} | {q.destination_name} | Ready: {q.ready_for_optimization}"
                )

            # Print activities
            activities = db.query(Activity).all()
            print(f"\n🎯 ACTIVITIES ({len(activities)}):")
            for a in activities:
                print(f"  {a.id} | {a.questionnaire_id} | {a.name} | {a.priority}")

            rate_limits = db.query(RateLimitEntry).all()
            print(f"\n⏱️ RATE LIMITS ({len(rate_limits)}):")
            for r in rate_limits:
                print(
                    f"  {r.id} | {r.ip_address} | Count: {r.request_count} | "
                    f"Window Start: {r.window_start} | Last Request: {r.last_request}"
                )

        except Exception as e:
            print(f"❌ Debug print failed: {str(e)}")
        finally:
            db.close()
