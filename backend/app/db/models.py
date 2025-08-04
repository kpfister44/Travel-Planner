from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    ForeignKey,
    TIMESTAMP,
    Boolean,
    REAL,
    Index,
    DateTime,
)
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime, timezone

Base = declarative_base()


class Questionnaire(Base):
    __tablename__ = "questionnaires"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    destination_id = Column(Integer)
    destination_name = Column(String, nullable=False)
    ready_for_optimization = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, default=datetime.now)

    # relationships
    activities = relationship(
        "Activity", back_populates="questionnaire", cascade="all, delete-orphan"
    )


class Activity(Base):
    __tablename__ = "activities"

    # Auto-increment primary key
    id = Column(Integer, primary_key=True, autoincrement=True)

    # Store original activity ID from OpenAI
    original_id = Column(String, nullable=True)  # act_001, act_002, etc.
    questionnaire_id = Column(Integer, ForeignKey("questionnaires.id"), nullable=False)
    name = Column(String, nullable=False)
    description = Column(Text)
    category = Column(String)
    duration_hours = Column(REAL)
    cost = Column(REAL)
    priority = Column(String, default="medium")  # high, medium, low

    # relationships
    questionnaire = relationship("Questionnaire", back_populates="activities")


class RateLimitEntry(Base):
    __tablename__ = "rate_limits"

    id = Column(Integer, primary_key=True, index=True)
    ip_address = Column(String, nullable=False)
    request_count = Column(Integer, default=1)
    window_start = Column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    last_request = Column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    # Create composite index for faster lookups
    __table_args__ = (Index("idx_ip_endpoint_window", "ip_address", "window_start"),)
