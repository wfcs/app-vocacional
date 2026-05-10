from pydantic import BaseModel, Field


class CityOut(BaseModel):
    id: int
    name: str
    state_code: str = Field(..., min_length=2, max_length=2)
