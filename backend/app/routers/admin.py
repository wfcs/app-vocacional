"""Endpoints administrativos.

Auth: Bearer JWT do Supabase Auth. Email do usuário deve estar em ADMIN_EMAILS.
"""
from __future__ import annotations

from collections import Counter

from fastapi import APIRouter, Depends, Header, HTTPException, status
from supabase import Client

from app.config import Settings, get_settings
from app.deps import get_supabase

router = APIRouter(prefix="/admin", tags=["admin"])


# ---------------------------------------------------------------------------
# Dependency: valida JWT e checa whitelist de e-mails admin
# ---------------------------------------------------------------------------
def require_admin(
    authorization: str | None = Header(default=None),
    supabase: Client = Depends(get_supabase),
    settings: Settings = Depends(get_settings),
) -> dict:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing bearer token.")
    token = authorization.split(" ", 1)[1].strip()

    try:
        # supabase-py v2: get_user(jwt) valida a assinatura via GoTrue
        user_resp = supabase.auth.get_user(token)
        user = user_resp.user
    except Exception as e:  # noqa: BLE001
        raise HTTPException(status_code=401, detail=f"Invalid token: {e}") from e

    if not user or not user.email:
        raise HTTPException(status_code=401, detail="Invalid token (no user).")

    allow = {e.strip().lower() for e in (settings.admin_emails or "").split(",") if e.strip()}
    if user.email.lower() not in allow:
        raise HTTPException(status_code=403, detail="Not an admin.")

    return {"id": user.id, "email": user.email}


# ---------------------------------------------------------------------------
# GET /admin/me — debug rápido pra validar token
# ---------------------------------------------------------------------------
@router.get("/me")
def me(admin: dict = Depends(require_admin)) -> dict:
    return admin


# ---------------------------------------------------------------------------
# GET /admin/stats — KPIs do dashboard
# ---------------------------------------------------------------------------
@router.get("/stats")
def stats(
    _admin: dict = Depends(require_admin),
    supabase: Client = Depends(get_supabase),
) -> dict:
    leads_count = supabase.table("leads").select("id", count="exact").execute().count or 0
    completed = (
        supabase.table("assessments")
        .select("id", count="exact")
        .eq("status", "COMPLETED")
        .execute()
        .count
        or 0
    )
    in_progress = (
        supabase.table("assessments")
        .select("id", count="exact")
        .eq("status", "IN_PROGRESS")
        .execute()
        .count
        or 0
    )
    results = (
        supabase.table("assessment_results")
        .select("aptitude_areas(code)")
        .execute()
    )
    dom_counter: Counter[str] = Counter()
    for r in results.data:
        code = (r.get("aptitude_areas") or {}).get("code")
        if code:
            dom_counter[code] += 1
    by_area = [{"code": c, "count": n} for c, n in dom_counter.most_common()]

    conversion = round(completed / leads_count * 100, 1) if leads_count else 0.0

    return {
        "leads": leads_count,
        "assessments_completed": completed,
        "assessments_in_progress": in_progress,
        "conversion_pct": conversion,
        "dominant_areas": by_area,
    }


# ---------------------------------------------------------------------------
# GET /admin/leads — paginação simples
# ---------------------------------------------------------------------------
@router.get("/leads")
def list_leads(
    limit: int = 50,
    offset: int = 0,
    _admin: dict = Depends(require_admin),
    supabase: Client = Depends(get_supabase),
) -> dict:
    if limit > 200:
        limit = 200
    res = (
        supabase.table("leads")
        .select(
            "id, full_name, email, created_at, cities(name, state_code), "
            "assessments(id, status, completed_at, assessment_results(aptitude_areas(code, name)))",
            count="exact",
        )
        .order("created_at", desc=True)
        .range(offset, offset + limit - 1)
        .execute()
    )
    items = []
    for row in res.data:
        ass = (row.get("assessments") or [None])[0] if row.get("assessments") else None
        result = (ass or {}).get("assessment_results") if ass else None
        result_obj = (result or [None])[0] if isinstance(result, list) else result
        area = (result_obj or {}).get("aptitude_areas") if result_obj else None
        items.append(
            {
                "id": row["id"],
                "full_name": row["full_name"],
                "email": row["email"],
                "city": f'{row["cities"]["name"]} - {row["cities"]["state_code"]}'
                if row.get("cities")
                else None,
                "created_at": row["created_at"],
                "assessment_status": ass["status"] if ass else None,
                "dominant_area": area["name"] if area else None,
            }
        )
    return {"total": res.count or 0, "items": items, "limit": limit, "offset": offset}
