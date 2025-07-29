from sqlalchemy import Column, Integer, String, Text, ForeignKey, TIMESTAMP, Boolean, REAL
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
import datetime

Base = declarative_base()


class Questionnaire(Base):
    __tablename__ = "questionnaires"

    id = Column(String, primary_key=True, index=True)  # quest_xxxxx format
    destination_id = Column(Integer)
    destination_name = Column(String, nullable=False)
    ready_for_optimization = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, default=datetime.datetime.now)

    # relationships
    activities = relationship("Activity", back_populates="questionnaire",
                              cascade="all, delete-orphan")


class Activity(Base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True, index=True)
    questionnaire_id = Column(String, ForeignKey("questionnaires.id"),
                              nullable=False)
    name = Column(String, nullable=False)
    description = Column(Text)
    category = Column(String)
    duration_hours = Column(REAL)
    cost = Column(REAL)
    priority = Column(String, default="medium")  # high, medium, low

    # relationships
    questionnaire = relationship("Questionnaire", back_populates="activities")
