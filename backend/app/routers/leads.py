"""POST /leads — captura do lead no onboarding."""
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client

from app.deps import get_supabase
from app.schemas.lead import LeadCreate, LeadOut

router = APIRouter(prefix="/leads", tags=["leads"])


@router.post("", response_model=LeadOut, status_code=status.HTTP_201_CREATED)
def create_lead(payload: LeadCreate, supabase: Client = Depends(get_supabase)) -> LeadOut:
    if not payload.consent_lgpd:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="É necessário aceitar os termos LGPD para prosseguir.",
        )

    # Valida cidade
    city = (
        supabase.table("cities")
        .select("id")
        .eq("id", payload.city_id)
        .limit(1)
        .execute()
    )
    if not city.data:
        raise HTTPException(status_code=404, detail="Cidade não encontrada.")

    res = (
        supabase.table("leads")
        .insert(
            {
                "full_name": payload.full_name.strip(),
                "email": str(payload.email).lower(),
                "city_id": payload.city_id,
                "consent_lgpd": payload.consent_lgpd,
                "consent_marketing": payload.consent_marketing,
            }
        )
        .execute()
    )
    if not res.data:
        raise HTTPException(status_code=500, detail="Falha ao criar lead.")
    row = res.data[0]
    return LeadOut(
        id=row["id"],
        full_name=row["full_name"],
        email=row["email"],
        city_id=row["city_id"],
    )
