from fastapi import Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from app.utils import common_utils
from app.models.errors import ErrorItem
from exceptions import APIException, RateLimitExceededException
import logging
from datetime import datetime, timezone

logger = logging.getLogger(__name__)


async def validation_exception_handler(request: Request, exc):
    """Handle Pydantic validation errors (422) securely"""

    # Log detailed validation errors for debugging
    logger.error(f"Validation error from {request.client.host}: {exc.errors()}")
    logger.error(f"Request body: {exc.body}")

    # Format errors for user-friendly response
    formatted_errors = common_utils.format_validation_errors(exc.errors())
    # Create appropriate response based on endpoint
    error_response = common_utils.create_error_response(request, formatted_errors)

    # Return structured error response
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=error_response.dict(exclude_none=True),
    )


async def api_exception_handler(request: Request, exc: APIException):
    """Handle custom API exceptions with appropriate response format"""

    # Log internal details for debugging
    logger.error(f"API Exception on {request.url.path}: {exc.internal_detail}")

    # Map status codes to error codes
    error_code_mapping = {
        400: "invalid_request",
        401: "authentication_failed",
        403: "access_forbidden",
        404: "resource_not_found",
        500: "internal_error",
    }

    error_code = error_code_mapping.get(exc.status_code, "api_error")
    error_item = ErrorItem(code=str(exc.status_code), message=exc.detail)

    # Create appropriate response based on endpoint
    error_response = common_utils.create_error_response(request, [error_item])

    return JSONResponse(
        status_code=exc.status_code, content=error_response.dict(exclude_none=True)
    )


async def general_exception_handler(request: Request, exc: Exception):
    """Catch-all exception handler with appropriate response format"""

    # Log full error details for debugging
    logger.error(
        f"Unhandled exception on {request.url.path}: {str(exc)}", exc_info=True
    )

    # Create generic error response
    error_item = ErrorItem(code="internal_error", message="An internal error occurred")
    error_response = common_utils.create_error_response(request, [error_item])

    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=error_response.dict(exclude_none=True),
    )
