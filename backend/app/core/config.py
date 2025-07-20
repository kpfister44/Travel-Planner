# App configuration settings
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    OPENAI_API_KEY: str
    DATABASE_URL: str
    API_KEY: str
    API_KEY_NAME: str = "x-api-key"

    class Config:
        env_file = ".env"


settings = Settings()
