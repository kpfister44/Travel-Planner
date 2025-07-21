from sqlalchemy import Column, Integer, String, Text, ForeignKey, TIMESTAMP
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
import datetime

Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(TIMESTAMP, default=datetime.datetime.now)

    # relationships
    prompts = relationship("Prompt", back_populates="user")


class Destination(Base):
    __tablename__ = "destinations"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    country = Column(String)
    description = Column(Text)
    image_url = Column(String)

    # relationships
    activities = relationship("Activity", back_populates="destination", cascade="all, delete-orphan")
    attractions = relationship("Attraction", back_populates="destination", cascade="all, delete-orphan")


class Activity(Base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True, index=True)
    destination_id = Column(Integer, ForeignKey("destinations.id"), nullable=False)
    name = Column(String, nullable=False)
    description = Column(Text)

    # relationships
    destination = relationship("Destination", back_populates="activities")


class Attraction(Base):
    __tablename__ = "attractions"

    id = Column(Integer, primary_key=True, index=True)
    destination_id = Column(Integer, ForeignKey("destinations.id"), nullable=False)
    name = Column(String, nullable=False)
    description = Column(Text)
    image_url = Column(String)

    # relationships
    destination = relationship("Destination", back_populates="attractions")


class Prompt(Base):
    __tablename__ = "prompts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    input_text = Column(Text)
    llm_output = Column(Text)
    prompt_template = Column(Text)
    created_at = Column(TIMESTAMP, default=datetime.datetime.now)

    # relationships
    user = relationship("User", back_populates="prompts")
