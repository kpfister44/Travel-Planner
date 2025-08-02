from fastapi import HTTPException, status
from typing import Dict, Any
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
