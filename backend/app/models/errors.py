from pydantic import BaseModel
from typing import Union


class ErrorItem(BaseModel):
    code: Union[str, int]  #error code to be accepted as str or int
    message: str
