"""Smoke test end-to-end contra o uvicorn local.

Não roda no pytest (não começa com test_). Executar manualmente:
    python tests/smoke_e2e.py
"""
import json
import sys
from typing import Any

import httpx

BASE = "http://localhost:8000"
INVESTIGATIVE_BIAS_RATIO = 0.85  # respostas INVESTIGATIVE; resto distribuído


def step(title: str) -> None:
    print(f"\n>>> {title}")


def pretty(data: Any) -> str:
    return json.dumps(data, indent=2, ensure_ascii=False)


def main() -> int:
    with httpx.Client(base_url=BASE, timeout=30.0) as c:
        # 1) Cidades
        step("GET /cities?q=são")
        r = c.get("/cities", params={"q": "são", "limit": 3})
        print(pretty(r.json()))
        sao_paulo = next(x for x in r.json() if x["state_code"] == "SP" and x["name"] == "São Paulo")

        # 2) Lead
        step("POST /leads")
        r = c.post(
            "/leads",
            json={
                "full_name": "Smoke Tester",
                "email": "felipeatalaia.s7@gmail.com",
                "city_id": sao_paulo["id"],
                "consent_lgpd": True,
                "consent_marketing": False,
            },
        )
        r.raise_for_status()
        lead = r.json()
        print(pretty(lead))

        # 3) Inicia assessment
        step("POST /assessments")
        r = c.post("/assessments", json={"lead_id": lead["id"]})
        r.raise_for_status()
        ass = r.json()
        print(f"assessment_id={ass['assessment_id']} | {len(ass['questions'])} perguntas")

        # 4) Monta respostas: bias em INVESTIGATIVE
        # Cada question_option agora expõe `area_id`. Buscamos o id da área
        # INVESTIGATIVE pra garantir que a opção escolhida pontue lá.
        step("Construindo respostas (todas INVESTIGATIVE)")
        # pega o area_id de INVESTIGATIVE a partir de qualquer pergunta
        sample_opts = ass["questions"][0]["options"]
        # area ids: REALISTIC, INVESTIGATIVE, ARTISTIC, SOCIAL, ENTERPRISING, CONVENTIONAL têm ids 1..6
        # mas pra robustez, vamos descobrir pegando uma INVESTIGATIVE conhecida em Q1.
        # A opção "Ler um livro técnico ou estudar um tema novo." é INVESTIGATIVE.
        invest_opt = next(
            (o for o in sample_opts if "livro técnico" in o["label"].lower()), None
        )
        if not invest_opt:
            print("WARN: não achei a opção INVESTIGATIVE de referência")
            return 1
        invest_area_id = invest_opt["area_id"]
        print(f"area_id INVESTIGATIVE = {invest_area_id}")

        answers = []
        for q in ass["questions"]:
            chosen = next(
                (o for o in q["options"] if o["area_id"] == invest_area_id), q["options"][0]
            )
            answers.append({"question_id": q["id"], "option_id": chosen["id"]})
        print(f"respostas montadas: {len(answers)}")

        # 5) Submete respostas
        step(f"POST /assessments/{ass['assessment_id']}/answers")
        r = c.post(
            f"/assessments/{ass['assessment_id']}/answers",
            json={"answers": answers},
        )
        print(f"status={r.status_code}")

        # 6) Finaliza → cálculo do motor
        step(f"POST /assessments/{ass['assessment_id']}/finalize")
        r = c.post(f"/assessments/{ass['assessment_id']}/finalize")
        if r.status_code >= 400:
            print(f"ERRO {r.status_code}: {r.text}")
            return 1
        result = r.json()
        print(pretty(result))

        # 7) Re-busca via GET /results/{id}
        step(f"GET /results/{result['result_id']}")
        r = c.get(f"/results/{result['result_id']}")
        r.raise_for_status()
        print(pretty(r.json()))

        # ----------------------------------------------------------------
        # Asserts
        # ----------------------------------------------------------------
        print("\n=== ASSERTS ===")
        scores = result["area_scores"]
        assert scores["INVESTIGATIVE"] > 0.95, f"INVESTIGATIVE deveria dominar: {scores}"
        assert result["dominant_area_code"] == "INVESTIGATIVE", "área dominante errada"
        top = result["top_professions"][0]
        assert "Engenheiro" in top["name"], f"esperado Engenheiro, veio {top['name']}"
        print("[OK] área dominante = INVESTIGATIVE")
        print(f"[OK] top profissão = {top['name']} (match {top['match_score']}%)")
        if result["top_institutions"]:
            insts_sp = [i for i in result["top_institutions"] if i["city_name"] == "São Paulo"]
            assert insts_sp, "esperava instituições de São Paulo"
            print(f"[OK] {len(insts_sp)} instituições em São Paulo retornadas")
        print("[OK] e-mail enviado (modo Console)" if result["email_sent"] else "[WARN] e-mail não enviado")
        print("\n*** SMOKE TEST PASSOU ***")
        return 0


if __name__ == "__main__":
    sys.exit(main())
