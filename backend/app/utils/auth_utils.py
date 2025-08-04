from fastapi import Depends, Request
from fastapi.security import APIKeyHeader
from exceptions import AuthenticationError
from app.core.config import settings
from app.utils import common_utils
import logging

logger = logging.getLogger(__name__)

# Use APIKeyHeader
api_key_header = APIKeyHeader(name=settings.API_KEY_NAME, auto_error=False)


async def validate_api_key(
    request: Request, api_key: str = Depends(api_key_header)
) -> None:
    """Validate API key with secure error handling"""
    logger.debug(common_utils.get_logging_message(validate_api_key.__name__))
    try:
        # Check if API key is provided
        if not api_key:
            logger.warning(f"Missing API key attempt from {request.client.host}")
            raise AuthenticationError("API key required")

        # API key validation logic
        if not is_valid_api_key(api_key):
            # Log detailed info for debugging, but don't expose it
            logger.warning(
                f"Invalid API key attempt from {request.client.host}: {api_key[:10]}..."
            )
            raise AuthenticationError("Invalid API key provided")

    except AuthenticationError:
        # Re-raise authentication errors as-is
        raise
    except Exception as e:
        # Log the actual error for debugging
        logger.error(f"API key validation error: {str(e)}")
        # Return generic auth error to client
        raise AuthenticationError("Authentication failed")


def is_valid_api_key(api_key: str) -> bool:
    logger.debug(common_utils.get_logging_message(is_valid_api_key.__name__))
    if api_key != settings.API_KEY:
        return False
    return True
