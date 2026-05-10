"""GET /results/{id} — devolve relatório consolidado já calculado."""
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from supabase import Client

from app.deps import get_supabase
from app.schemas.result import InstitutionRecOut, ProfessionRecOut, ResultOut

router = APIRouter(prefix="/results", tags=["results"])


@router.get("/{result_id}", response_model=ResultOut)
def get_result(result_id: UUID, supabase: Client = Depends(get_supabase)) -> ResultOut:
    res = (
        supabase.table("assessment_results")
        .select(
            "id, assessment_id, area_scores, email_sent, "
            "aptitude_areas(code, name)"
        )
        .eq("id", str(result_id))
        .limit(1)
        .execute()
    )
    if not res.data:
        raise HTTPException(status_code=404, detail="Resultado não encontrado.")
    row = res.data[0]
    area = row["aptitude_areas"]

    profs = (
        supabase.table("result_recommended_professions")
        .select("profession_id, match_score, rank, professions(name, description)")
        .eq("result_id", str(result_id))
        .order("rank")
        .execute()
    )
    insts = (
        supabase.table("result_recommended_institutions")
        .select(
            "institution_id, course_id, profession_id, rank, "
            "institutions(name, institution_type, cities(name)), "
            "courses(name, course_type)"
        )
        .eq("result_id", str(result_id))
        .order("rank")
        .execute()
    )

    return ResultOut(
        result_id=result_id,
        assessment_id=row["assessment_id"],
        dominant_area_code=area["code"],
        dominant_area_name=area["name"],
        area_scores=row["area_scores"],
        top_professions=[
            ProfessionRecOut(
                profession_id=p["profession_id"],
                name=p["professions"]["name"],
                description=p["professions"].get("description"),
                match_score=float(p["match_score"]),
                rank=p["rank"],
            )
            for p in profs.data
        ],
        top_institutions=[
            InstitutionRecOut(
                institution_id=i["institution_id"],
                institution_name=i["institutions"]["name"],
                institution_type=i["institutions"]["institution_type"],
                city_name=i["institutions"]["cities"]["name"],
                course_id=i["course_id"],
                course_name=i["courses"]["name"],
                course_type=i["courses"]["course_type"],
                profession_id=i.get("profession_id"),
                rank=i["rank"],
            )
            for i in insts.data
        ],
        email_sent=row["email_sent"],
    )
