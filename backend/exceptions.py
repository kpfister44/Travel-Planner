from fastapi import HTTPException, status
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)


class APIException(HTTPException):
    """Base API Exception with secure error handling"""

    def __init__(self, status_code: int, detail: str, internal_detail: str = None):
        super().__init__(status_code=status_code, detail=detail)
        self.internal_detail = internal_detail or detail


class AuthenticationError(APIException):
    def __init__(self, internal_detail: str = None):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed",
            internal_detail=internal_detail,
        )


class ValidationError(APIException):
    def __init__(self, internal_detail: str = None):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid request data",
            internal_detail=internal_detail,
        )


class InternalServerError(APIException):
    def __init__(self, internal_detail: str = None):
        super().__init__(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error",
            internal_detail=internal_detail,
        )


class RateLimitExceededException(Exception):
    """Custom exception for rate limiting"""

    def __init__(
        self,
        limit_type: str,  # "minute" or "hour"
        limit_value: int,
        client_ip: str,
        retry_after: int,
        detail: Optional[str] = None,
        internal_detail: Optional[str] = None,
    ):
        self.limit_type = limit_type
        self.limit_value = limit_value
        self.client_ip = client_ip
        self.retry_after = retry_after
        self.internal_detail = (
            internal_detail
            or f"Rate limit exceeded for IP {client_ip}: {limit_value} requests per {limit_type}"
        )

        if not detail:
            detail = f"Rate limit exceeded: {limit_value} requests per {limit_type}"

        self.detail = detail
        super().__init__(detail)
