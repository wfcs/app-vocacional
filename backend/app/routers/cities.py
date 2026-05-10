"""GET /cities — autocomplete para o dropdown do onboarding."""
from fastapi import APIRouter, Depends, Query
from supabase import Client

from app.deps import get_supabase
from app.schemas.city import CityOut

router = APIRouter(prefix="/cities", tags=["cities"])


@router.get("", response_model=list[CityOut])
def list_cities(
    q: str | None = Query(None, max_length=80, description="Busca parcial pelo nome"),
    state: str | None = Query(None, min_length=2, max_length=2, description="UF (ex.: SP)"),
    limit: int = Query(20, ge=1, le=100),
    supabase: Client = Depends(get_supabase),
) -> list[CityOut]:
    query = supabase.table("cities").select("id, name, state_code")
    if q:
        query = query.ilike("name", f"%{q}%")
    if state:
        query = query.eq("state_code", state.upper())
    query = query.order("name").limit(limit)
    res = query.execute()
    return [CityOut(**row) for row in res.data]
