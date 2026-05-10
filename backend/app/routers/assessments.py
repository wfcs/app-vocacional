"""POST /assessments, /assessments/{id}/answers, /assessments/{id}/finalize."""
from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Response, status
from supabase import Client

from app.config import Settings, get_settings
from app.deps import get_email_service, get_supabase
from app.schemas.assessment import (
    AnswersBatchIn,
    AssessmentStart,
    AssessmentStartOut,
    QuestionOptionOut,
    QuestionOut,
)
from app.schemas.result import InstitutionRecOut, ProfessionRecOut, ResultOut
from app.services.email import EmailService
from app.services.recommendation import (
    AnsweredOption,
    CourseOffer,
    ProfessionVector,
    calculate_area_scores,
    dominant_area,
    rank_professions,
    select_institutions,
)

router = APIRouter(prefix="/assessments", tags=["assessments"])


# ---------------------------------------------------------------------------
# POST /assessments — inicia novo assessment e devolve banco de perguntas
# ---------------------------------------------------------------------------
@router.post("", response_model=AssessmentStartOut, status_code=status.HTTP_201_CREATED)
def start_assessment(
    payload: AssessmentStart, supabase: Client = Depends(get_supabase)
) -> AssessmentStartOut:
    # Valida lead
    lead = supabase.table("leads").select("id").eq("id", str(payload.lead_id)).limit(1).execute()
    if not lead.data:
        raise HTTPException(status_code=404, detail="Lead não encontrado.")

    # Cria assessment
    res = supabase.table("assessments").insert({"lead_id": str(payload.lead_id)}).execute()
    if not res.data:
        raise HTTPException(status_code=500, detail="Falha ao criar assessment.")
    assessment_id = res.data[0]["id"]

    # Carrega perguntas + opções (ordem por sequence)
    qs = (
        supabase.table("questions")
        .select("id, sequence, statement, question_options(id, label)")
        .eq("is_active", True)
        .order("sequence")
        .execute()
    )

    questions = [
        QuestionOut(
            id=q["id"],
            sequence=q["sequence"],
            statement=q["statement"],
            options=[QuestionOptionOut(**opt) for opt in q.get("question_options", [])],
        )
        for q in qs.data
    ]
    return AssessmentStartOut(assessment_id=UUID(assessment_id), questions=questions)


# ---------------------------------------------------------------------------
# POST /assessments/{id}/answers — registra respostas (idempotente por question_id)
# ---------------------------------------------------------------------------
@router.post("/{assessment_id}/answers", status_code=status.HTTP_204_NO_CONTENT)
def submit_answers(
    assessment_id: UUID,
    payload: AnswersBatchIn,
    supabase: Client = Depends(get_supabase),
) -> Response:
    # Valida assessment
    a = (
        supabase.table("assessments")
        .select("id, status")
        .eq("id", str(assessment_id))
        .limit(1)
        .execute()
    )
    if not a.data:
        raise HTTPException(status_code=404, detail="Assessment não encontrado.")
    if a.data[0]["status"] == "COMPLETED":
        raise HTTPException(status_code=409, detail="Assessment já finalizado.")

    rows = [
        {
            "assessment_id": str(assessment_id),
            "question_id": ans.question_id,
            "option_id": ans.option_id,
        }
        for ans in payload.answers
    ]
    # upsert para idempotência por (assessment_id, question_id)
    supabase.table("assessment_answers").upsert(
        rows, on_conflict="assessment_id,question_id"
    ).execute()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


# ---------------------------------------------------------------------------
# POST /assessments/{id}/finalize — calcula recomendação, persiste, dispara e-mail
# ---------------------------------------------------------------------------
@router.post("/{assessment_id}/finalize", response_model=ResultOut)
async def finalize_assessment(
    assessment_id: UUID,
    supabase: Client = Depends(get_supabase),
    email: EmailService = Depends(get_email_service),
    settings: Settings = Depends(get_settings),
) -> ResultOut:
    # 1) Carrega assessment + lead + cidade
    a = (
        supabase.table("assessments")
        .select("id, status, lead_id, leads(full_name, email, city_id, cities(name))")
        .eq("id", str(assessment_id))
        .limit(1)
        .execute()
    )
    if not a.data:
        raise HTTPException(status_code=404, detail="Assessment não encontrado.")
    arow = a.data[0]
    if arow["status"] == "COMPLETED":
        raise HTTPException(status_code=409, detail="Assessment já finalizado.")

    lead = arow["leads"]
    lead_city_id: int = lead["city_id"]

    # 2) Carrega respostas + área da opção escolhida
    ans_resp = (
        supabase.table("assessment_answers")
        .select("option_id, question_options(area_id, score, aptitude_areas(code))")
        .eq("assessment_id", str(assessment_id))
        .execute()
    )
    if not ans_resp.data:
        raise HTTPException(status_code=400, detail="Nenhuma resposta registrada.")

    answered = [
        AnsweredOption(
            option_id=row["option_id"],
            area_code=row["question_options"]["aptitude_areas"]["code"],
            score=float(row["question_options"]["score"]),
        )
        for row in ans_resp.data
    ]

    # 3) Calcula scores e área dominante
    area_scores = calculate_area_scores(answered)
    dom_code = dominant_area(area_scores)

    # 4) Carrega vetores de profissões
    pa = supabase.table("profession_areas").select(
        "profession_id, weight, aptitude_areas(code)"
    ).execute()
    by_prof: dict[int, dict[str, float]] = defaultdict(dict)
    for row in pa.data:
        by_prof[row["profession_id"]][row["aptitude_areas"]["code"]] = float(row["weight"])
    vectors = [ProfessionVector(profession_id=pid, weights=w) for pid, w in by_prof.items()]

    top_profs = rank_professions(area_scores, vectors, top_n=settings.top_professions)
    if not top_profs:
        raise HTTPException(status_code=500, detail="Nenhuma profissão para ranquear.")

    top_prof_ids = [p.profession_id for p in top_profs]

    # 5) Carrega ofertas de cursos das top profissões na cidade do lead
    pc = (
        supabase.table("profession_courses")
        .select("profession_id, course_id")
        .in_("profession_id", top_prof_ids)
        .execute()
    )
    course_to_profs: dict[int, list[int]] = defaultdict(list)
    for row in pc.data:
        course_to_profs[row["course_id"]].append(row["profession_id"])

    course_ids = list(course_to_profs.keys())
    offers: list[CourseOffer] = []
    if course_ids:
        ic = (
            supabase.table("institution_courses")
            .select("institution_id, course_id, institutions!inner(city_id)")
            .in_("course_id", course_ids)
            .eq("is_active", True)
            .eq("institutions.city_id", lead_city_id)
            .execute()
        )
        # Cruza com profession_courses para anexar profession_id
        for row in ic.data:
            for pid in course_to_profs.get(row["course_id"], []):
                if pid in top_prof_ids:
                    offers.append(
                        CourseOffer(
                            institution_id=row["institution_id"],
                            course_id=row["course_id"],
                            profession_id=pid,
                        )
                    )

    top_inst_offers = select_institutions(top_profs, offers, top_n=settings.top_institutions)

    # 6) Carrega área dominante (id) e nome
    areas_res = supabase.table("aptitude_areas").select("id, code, name").execute()
    code_to_area = {a["code"]: a for a in areas_res.data}
    dom_area = code_to_area[dom_code]

    # 7) Persiste assessment_results
    res_ins = (
        supabase.table("assessment_results")
        .insert(
            {
                "assessment_id": str(assessment_id),
                "area_scores": area_scores,
                "dominant_area_id": dom_area["id"],
            }
        )
        .execute()
    )
    result_id: str = res_ins.data[0]["id"]

    # 8) Persiste recomendações de profissões
    if top_profs:
        supabase.table("result_recommended_professions").insert(
            [
                {
                    "result_id": result_id,
                    "profession_id": m.profession_id,
                    "match_score": m.score,
                    "rank": idx + 1,
                }
                for idx, m in enumerate(top_profs)
            ]
        ).execute()

    # 9) Persiste recomendações de instituições
    if top_inst_offers:
        supabase.table("result_recommended_institutions").insert(
            [
                {
                    "result_id": result_id,
                    "institution_id": o.institution_id,
                    "course_id": o.course_id,
                    "profession_id": o.profession_id,
                    "rank": idx + 1,
                }
                for idx, o in enumerate(top_inst_offers)
            ]
        ).execute()

    # 10) Marca assessment como COMPLETED
    supabase.table("assessments").update(
        {"status": "COMPLETED", "completed_at": datetime.now(timezone.utc).isoformat()}
    ).eq("id", str(assessment_id)).execute()

    # 11) Hidrata payload de saída (nomes de profissões/cursos/instituições)
    profs_meta = (
        supabase.table("professions")
        .select("id, name, description")
        .in_("id", top_prof_ids)
        .execute()
    )
    profs_by_id = {p["id"]: p for p in profs_meta.data}
    top_profs_out = [
        ProfessionRecOut(
            profession_id=m.profession_id,
            name=profs_by_id[m.profession_id]["name"],
            description=profs_by_id[m.profession_id].get("description"),
            match_score=m.score,
            rank=idx + 1,
        )
        for idx, m in enumerate(top_profs)
    ]

    insts_out: list[InstitutionRecOut] = []
    if top_inst_offers:
        inst_ids = list({o.institution_id for o in top_inst_offers})
        course_ids_out = list({o.course_id for o in top_inst_offers})
        inst_meta = (
            supabase.table("institutions")
            .select("id, name, institution_type, cities(name)")
            .in_("id", inst_ids)
            .execute()
        )
        inst_by_id = {i["id"]: i for i in inst_meta.data}
        course_meta = (
            supabase.table("courses")
            .select("id, name, course_type")
            .in_("id", course_ids_out)
            .execute()
        )
        course_by_id = {c["id"]: c for c in course_meta.data}
        for idx, o in enumerate(top_inst_offers):
            inst = inst_by_id[o.institution_id]
            course = course_by_id[o.course_id]
            insts_out.append(
                InstitutionRecOut(
                    institution_id=o.institution_id,
                    institution_name=inst["name"],
                    institution_type=inst["institution_type"],
                    city_name=inst["cities"]["name"],
                    course_id=o.course_id,
                    course_name=course["name"],
                    course_type=course["course_type"],
                    profession_id=o.profession_id,
                    rank=idx + 1,
                )
            )

    payload = {
        "dominant_area_code": dom_code,
        "dominant_area_name": dom_area["name"],
        "top_professions": [p.model_dump() for p in top_profs_out],
        "top_institutions": [i.model_dump() for i in insts_out],
    }

    # 12) Dispara e-mail
    sent = await email.send_result(
        to=lead["email"],
        lead_name=lead["full_name"],
        result_payload=payload,
    )
    if sent:
        supabase.table("assessment_results").update(
            {"email_sent": True, "email_sent_at": datetime.now(timezone.utc).isoformat()}
        ).eq("id", result_id).execute()

    return ResultOut(
        result_id=UUID(result_id),
        assessment_id=assessment_id,
        dominant_area_code=dom_code,
        dominant_area_name=dom_area["name"],
        area_scores=area_scores,
        top_professions=top_profs_out,
        top_institutions=insts_out,
        email_sent=sent,
    )
