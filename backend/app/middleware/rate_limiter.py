from fastapi import HTTPException, Request
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone
from app.db.models import RateLimitEntry
from app.utils import common_utils
import logging
from app.core.config import settings
from exceptions import RateLimitExceededException

logger = logging.getLogger(__name__)


class RateLimiter:
    def __init__(
        self,
        requests_per_minute: int = settings.REQUEST_PER_MINUTE,
        requests_per_hour: int = settings.REQUEST_PER_HOUR,
        cleanup_interval_hours: int = settings.CLEANUP_INTERVAL_HOUR,
    ):
        self.requests_per_minute = requests_per_minute
        self.requests_per_hour = requests_per_hour
        self.cleanup_interval_hours = cleanup_interval_hours

    def get_client_ip(self, request: Request) -> str:
        """Extract client IP address from request"""
        logger.debug(common_utils.get_logging_message(self.get_client_ip.__name__))
        # Check for forwarded IP first (if behind proxy/load balancer)
        forwarded_for = request.headers.get("X-Forwarded-For")
        if forwarded_for:
            return forwarded_for.split(",")[0].strip()

        real_ip = request.headers.get("X-Real-IP")
        if real_ip:
            return real_ip

        return request.client.host

    async def check_rate_limit(self, request: Request, db: Session) -> bool:
        """
        Check if request should be rate limited
        Returns True if request is allowed, False if rate limited
        """
        logger.debug(
            common_utils.get_logging_message(
                self.check_rate_limit.__name__,
                f"Checking rate limit for {request.url.path}",
            )
        )
        client_ip = self.get_client_ip(request)
        now = datetime.now(timezone.utc)

        # Check minute-based rate limit
        minute_window = now - timedelta(minutes=1)
        minute_count = (
            db.query(RateLimitEntry)
            .filter(
                RateLimitEntry.ip_address == client_ip,
                RateLimitEntry.last_request >= minute_window,
            )
            .count()
        )

        if minute_count >= self.requests_per_minute:
            raise RateLimitExceededException(
                limit_type="minute",
                limit_value=self.requests_per_minute,
                client_ip=client_ip,
                retry_after=60,
                detail=f"Rate limit exceeded: {self.requests_per_minute} requests per minute",
                internal_detail=f"Minute rate limit exceeded for IP {client_ip}: {minute_count}/{self.requests_per_minute} requests in the last minute",
            )

        # Check hour-based rate limit
        hour_window = now - timedelta(hours=1)
        hour_count = (
            db.query(RateLimitEntry)
            .filter(
                RateLimitEntry.ip_address == client_ip,
                RateLimitEntry.last_request >= hour_window,
            )
            .count()
        )

        if hour_count >= self.requests_per_hour:
            raise RateLimitExceededException(
                limit_type="hour",
                limit_value=self.requests_per_hour,
                client_ip=client_ip,
                retry_after=3600,
                detail=f"Rate limit exceeded: {self.requests_per_hour} requests per hour",
                internal_detail=f"Hour rate limit exceeded for IP {client_ip}: {hour_count}/{self.requests_per_hour} requests in the last hour",
            )

        # Record this request
        rate_entry = RateLimitEntry(ip_address=client_ip, last_request=now)
        db.add(rate_entry)
        db.commit()

        # Cleanup old entries periodically (every 100 requests)
        import random

        if random.randint(1, 100) == 1:
            self.cleanup_old_entries(db)

        return True

    def cleanup_old_entries(self, db: Session):
        """Remove old rate limit entries to keep database clean"""
        cleanup_before = datetime.utcnow() - timedelta(
            hours=self.cleanup_interval_hours
        )

        deleted_count = (
            db.query(RateLimitEntry)
            .filter(RateLimitEntry.last_request < cleanup_before)
            .delete()
        )

        db.commit()
        logger.info(f"Cleaned up {deleted_count} old rate limit entries")
