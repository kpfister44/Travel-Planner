from pydantic import BaseModel


class ErrorItem(BaseModel):
    code: str
    message: str
