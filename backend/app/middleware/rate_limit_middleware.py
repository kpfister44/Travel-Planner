from fastapi import Request, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response
from datetime import datetime, timezone
from app.middleware.rate_limiter import RateLimiter
from app.db.database import get_db
from app.utils import common_utils
from exceptions import RateLimitExceededException
import logging

logger = logging.getLogger(__name__)


class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, rate_limiter: RateLimiter):
        super().__init__(app)
        self.rate_limiter = rate_limiter

    async def dispatch(self, request: Request, call_next) -> Response:
        logger.debug(common_utils.get_logging_message(self.dispatch.__name__))
        # Get database session
        db = next(get_db())

        try:
            # Check rate limit
            await self.rate_limiter.check_rate_limit(request, db)

            # If rate limit check passes, continue to the actual endpoint
            response = await call_next(request)
            return response

        except RateLimitExceededException as e:
            # Handle rate limit exception directly in middleware
            logger.warning(
                f"Rate limit exceeded - IP: {e.client_ip}, "
                f"Limit: {e.limit_value} requests per {e.limit_type}, "
                f"Path: {request.url.path}, "
                f"Method: {request.method}, "
                f"User-Agent: {request.headers.get('User-Agent', 'Unknown')}, "
                f"Timestamp: {datetime.now(timezone.utc).isoformat()}"
            )

            # Log internal details for debugging
            logger.error(
                common_utils.get_error_message(
                    self.dispatch.__name__,
                    f"Rate Limit Exception on {request.url.path}: {e.internal_detail}",
                )
            )

            # Return the exact structure you want
            response_content = {
                "errors": [
                    {
                        "code": str(status.HTTP_429_TOO_MANY_REQUESTS),
                        "message": e.detail,
                    }
                ]
            }

            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content=response_content,
                headers={
                    "Retry-After": str(e.retry_after),
                    "X-RateLimit-Limit": str(e.limit_value),
                    "X-RateLimit-Remaining": "0",
                    "X-RateLimit-Reset": str(
                        int(datetime.now(timezone.utc).timestamp()) + e.retry_after
                    ),
                },
            )

        except Exception as e:
            # Handle any other unexpected exceptions
            logger.error(f"Unexpected error in rate limit middleware: {str(e)}")
            # Let other exceptions bubble up to be handled by FastAPI's exception handlers
            raise e

        finally:
            # Clean up database session
            db.close()
