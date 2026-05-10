# Backend — FastAPI

App FastAPI servindo o motor de recomendação vocacional (RIASEC) sobre o Supabase.

## Estrutura

```
backend/
├── api/index.py                 # entrypoint Vercel (ASGI)
├── app/
│   ├── main.py                  # FastAPI app + middlewares + routers
│   ├── config.py                # Settings via pydantic-settings (.env)
│   ├── deps.py                  # injeção: Supabase client, EmailService
│   ├── constants.py             # RIASEC_CODES e defaults
│   ├── schemas/                 # Pydantic models (city, lead, assessment, result)
│   ├── routers/                 # cities, leads, assessments, results
│   └── services/
│       ├── recommendation.py    # motor RIASEC (puro, sem I/O)
│       └── email.py             # Resend ou Console (fallback)
├── tests/                       # pytest do motor de recomendação
├── requirements.txt             # deps de produção (Vercel)
├── requirements-dev.txt         # + pytest, ruff
├── pyproject.toml
├── vercel.json
└── .env.example
```

## Setup local

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows
# source .venv/bin/activate     # macOS/Linux
pip install -r requirements-dev.txt
cp .env.example .env
# edite .env e cole o SUPABASE_SERVICE_KEY (pegue no dashboard)
```

## Rodar local

```bash
uvicorn app.main:app --reload --port 8000
# Swagger:  http://localhost:8000/docs
# Health:   http://localhost:8000/health
```

## Rodar testes

```bash
pytest -v
```

Os testes cobrem o motor de recomendação (funções puras). Testes de integração
contra o Supabase serão adicionados quando tivermos um ambiente de staging.

## Endpoints

| Método | Rota | Descrição |
|---|---|---|
| GET  | `/health` | liveness |
| GET  | `/cities?q=&state=&limit=` | autocomplete de cidades |
| POST | `/leads` | cria lead (onboarding) |
| POST | `/assessments` | inicia assessment + retorna perguntas |
| POST | `/assessments/{id}/answers` | registra respostas (idempotente) |
| POST | `/assessments/{id}/finalize` | calcula resultado, salva, dispara e-mail |
| GET  | `/results/{id}` | relatório consolidado |

Detalhes dos contratos: [`docs/API.md`](../docs/API.md).

## Motor de recomendação

1. **`calculate_area_scores(answers)`** — soma scores por área RIASEC e normaliza para somar 1.0.
2. **`dominant_area(scores)`** — área com maior pontuação.
3. **`rank_professions(scores, vectors)`** — similaridade de cosseno entre vetor do usuário e cada `profession_areas`. Match em [0, 100].
4. **`select_institutions(top_profs, offers_in_city)`** — itera profissões em ordem de match e empilha ofertas (já filtradas pela cidade do lead) até `top_n`, deduplicando.

Tudo é função pura → fácil de testar e trocar (ex.: substituir cosseno por Jaccard).

## E-mail

`build_email_service(settings)` decide pelo provider:
- `RESEND_API_KEY` setado → `ResendEmailService` (POST para `https://api.resend.com/emails`).
- Vazio → `ConsoleEmailService` (loga, não envia). Útil em dev e CI.

## Deploy Vercel

`vercel.json` aponta todas as rotas para `api/index.py`, que importa `app.main:app`.

```bash
cd backend
vercel deploy
# defina env vars no dashboard: SUPABASE_URL, SUPABASE_SERVICE_KEY, RESEND_API_KEY, etc.
```
