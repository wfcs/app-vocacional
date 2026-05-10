# App Vocacional

[![Status](https://img.shields.io/badge/status-MVP%20em%20produ%C3%A7%C3%A3o-brightgreen)](https://app-vocacional-frontend.vercel.app)
[![Backend](https://img.shields.io/badge/backend-FastAPI-009688?logo=fastapi&logoColor=white)](https://app-vocacional-backend.vercel.app/health)
[![Frontend](https://img.shields.io/badge/frontend-React%2018-61DAFB?logo=react&logoColor=black)](https://app-vocacional-frontend.vercel.app)
[![Database](https://img.shields.io/badge/db-PostgreSQL%2017-336791?logo=postgresql&logoColor=white)](https://supabase.com)
[![Deploy](https://img.shields.io/badge/deploy-Vercel-000000?logo=vercel)](https://vercel.com)
[![License](https://img.shields.io/badge/license-MIT-blue)](#licença)

Plataforma de **orientação vocacional** que ajuda pessoas indecisas sobre qual carreira seguir ou curso realizar a descobrir profissões alinhadas ao seu perfil, cursos relevantes (graduação e técnico) e instituições de ensino na sua cidade.

O usuário responde um teste **RIASEC** (Holland) de 40 perguntas e recebe um relatório personalizado por e-mail, gerado por um motor de recomendação que usa similaridade de cosseno entre o vetor de aptidões da pessoa e o vetor RIASEC de cada profissão cadastrada.

---

## Demo ao vivo

| | URL |
|---|---|
| **App (usuário final)** | https://app-vocacional-frontend.vercel.app |
| **API (Swagger)** | https://app-vocacional-backend.vercel.app/docs |
| **Health check** | https://app-vocacional-backend.vercel.app/health |
| **Painel admin** | https://app-vocacional-frontend.vercel.app/admin/login |

---

## Sumário

- [Funcionalidades](#funcionalidades)
- [Arquitetura](#arquitetura)
- [Stack](#stack)
- [Quick Start (local)](#quick-start-local)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Modelo de dados](#modelo-de-dados)
- [Motor de recomendação](#motor-de-recomendação)
- [API](#api)
- [Painel admin](#painel-admin)
- [Segurança e LGPD](#segurança-e-lgpd)
- [Deploy](#deploy)
- [Testes](#testes)
- [Roadmap](#roadmap)
- [Governança do projeto](#governança-do-projeto)
- [Licença](#licença)

---

## Funcionalidades

- **Onboarding lead-first** — captura nome, e-mail e cidade (autocomplete) antes do teste, com consentimento LGPD explícito.
- **Assessment RIASEC** — 40 perguntas, opção única, 1 pergunta por tela com barra de progresso.
- **Motor de recomendação** — calcula vetor RIASEC do usuário, aplica similaridade de cosseno contra cada profissão e ranqueia.
- **Recomendações filtradas pela cidade** — junta as top profissões com os cursos que habilitam → instituições que oferecem o curso na cidade do lead.
- **Relatório por e-mail** — HTML simples disparado via Resend (com fallback para log no console em dev).
- **Painel admin** — login via Supabase Auth + whitelist de e-mails; KPIs (leads, conversão, áreas dominantes) e tabela de leads recentes.
- **Banco serverless** — PostgreSQL no Supabase com RLS habilitada (transacional bloqueada para anon; backend usa `service_role`).

---

## Arquitetura

```
┌──────────────────────────────────────────────────────────────┐
│                      USUÁRIO FINAL                            │
└────────────────────────────┬─────────────────────────────────┘
                             │
       ┌─────────────────────┼─────────────────────┐
       ▼                     ▼                     ▼
  ┌──────────┐        ┌──────────────┐      ┌──────────┐
  │Onboarding│ ─────▶ │  Assessment  │ ───▶ │ Resultado│
  │ (React)  │        │   (React)    │      │ (React)  │
  └──────────┘        └──────────────┘      └──────────┘
       │ POST /leads        │ POST /answers       │ GET /results/:id
       │                    │ POST /finalize      │
       ▼                    ▼                     ▼
  ┌──────────────────────────────────────────────────────────┐
  │              FastAPI (Vercel Serverless)                  │
  │  /cities  /leads  /assessments  /answers  /finalize       │
  │  /results/{id}  /admin/{stats,leads,me}                   │
  │  └─ services.recommendation: cosine similarity (puro)     │
  │  └─ services.email: Resend ou Console                     │
  └────────────────────────────┬─────────────────────────────┘
                               │ supabase-py (service_role)
                               ▼
  ┌──────────────────────────────────────────────────────────┐
  │           Supabase (PostgreSQL 17 + Auth)                 │
  │  Dimensões: cities, aptitude_areas, professions,          │
  │             courses, institutions                          │
  │  Junções:   profession_areas, profession_courses,         │
  │             institution_courses                            │
  │  Assessment: questions, question_options                  │
  │  Transacional: leads, assessments, assessment_answers,    │
  │                 assessment_results, recommendations       │
  │  RLS habilitada: SELECT público em referência;            │
  │                  transacional só via service_role         │
  └──────────────────────────────────────────────────────────┘
                               │
                               ▼
                        ┌─────────────┐
                        │   Resend    │
                        │  (e-mail)   │
                        └─────────────┘
```

---

## Stack

| Camada | Tecnologia | Versão | Hospedagem |
|---|---|---|---|
| Frontend | React + Vite + TypeScript + Tailwind v4 + React Router 6 | React 18.3, Vite 6 | Vercel (Static) |
| Backend | FastAPI + Pydantic v2 + supabase-py | FastAPI 0.115, Python 3.11+ | Vercel (Serverless Functions) |
| Banco/Auth | PostgreSQL + Supabase Auth | Postgres 17 | Supabase Cloud (sa-east-1) |
| E-mail | Resend (HTTP API) | — | Resend SaaS |

---

## Quick Start (local)

### Pré-requisitos
- Python **3.11** ou **3.12** (3.14 não tem wheels do `pydantic-core`)
- Node.js **18+** + npm
- Git
- Conta Supabase (free tier)

### 1. Clonar e instalar

```bash
git clone https://github.com/wfcs/app-vocacional.git
cd app-vocacional

# Backend
cd backend
py -3.11 -m venv .venv
.venv\Scripts\activate              # Windows
# source .venv/bin/activate         # macOS/Linux
pip install -r requirements-dev.txt
cp .env.example .env

# Frontend (em outro terminal)
cd frontend
npm install
cp .env.example .env
```

### 2. Configurar variáveis de ambiente

**`backend/.env`** — preencha com suas credenciais Supabase (Settings → API):

```env
SUPABASE_URL=https://<seu-projeto>.supabase.co
SUPABASE_SERVICE_KEY=<service_role_secret>
SUPABASE_ANON_KEY=<anon_key>
RESEND_API_KEY=                    # vazio = log no console
EMAIL_FROM=Vocacional <onboarding@resend.dev>
TOP_PROFESSIONS=5
TOP_INSTITUTIONS=5
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
ADMIN_EMAILS=seu_email@example.com
```

**`frontend/.env`**:

```env
VITE_API_BASE_URL=http://localhost:8000
VITE_SUPABASE_URL=https://<seu-projeto>.supabase.co
VITE_SUPABASE_ANON_KEY=<anon_key>
```

### 3. Aplicar schema e seeds

No **Supabase SQL Editor** (ou via `psql`), executar na ordem:

```
sql/001_extensions.sql
sql/002_dimensions.sql
sql/003_junctions.sql
sql/004_assessment.sql
sql/005_transactional.sql
sql/010_rls_policies.sql
sql/seeds/100_aptitude_areas.sql
sql/seeds/110_cities.sql
sql/seeds/111_cities_extra.sql
sql/seeds/120_professions.sql
sql/seeds/130_courses.sql
sql/seeds/140_institutions.sql
sql/seeds/141_institutions_extra.sql
sql/seeds/150_profession_areas.sql
sql/seeds/160_profession_courses.sql
sql/seeds/170_institution_courses.sql
sql/seeds/171_institution_courses_extra.sql
sql/seeds/180_questions_options.sql
sql/seeds/181_questions_options_extra.sql
```

Validação esperada:

```sql
SELECT COUNT(*) FROM cities;            -- 28
SELECT COUNT(*) FROM aptitude_areas;    -- 6
SELECT COUNT(*) FROM professions;       -- 5
SELECT COUNT(*) FROM courses;           -- 7
SELECT COUNT(*) FROM institutions;      -- 12
SELECT COUNT(*) FROM questions;         -- 40
SELECT COUNT(*) FROM question_options;  -- 240
```

### 4. Rodar

```bash
# Terminal 1 — Backend
cd backend
.venv\Scripts\activate
uvicorn app.main:app --reload --port 8000
# Swagger: http://localhost:8000/docs

# Terminal 2 — Frontend
cd frontend
npm run dev
# App: http://localhost:5173
```

### 5. Testar

```bash
# Unit tests do motor de recomendação (8 testes, ~60ms)
cd backend && pytest -v

# Smoke E2E completo (lead → assessment → finalize → e-mail)
python tests/smoke_e2e.py
```

---

## Estrutura do repositório

```
app-vocacional/
├── README.md                         # este arquivo
├── PENDENCIAS.md                     # tracker de tasks (gitignored)
├── SESSOES.md                        # histórico de sessões (gitignored)
│
├── backend/                          # FastAPI
│   ├── app/
│   │   ├── main.py                   # FastAPI app + CORS + routers
│   │   ├── config.py                 # Settings (pydantic-settings)
│   │   ├── deps.py                   # Injeção: Supabase, EmailService
│   │   ├── constants.py              # RIASEC_CODES
│   │   ├── schemas/                  # Pydantic v2 (city, lead, assessment, result)
│   │   ├── routers/                  # cities, leads, assessments, results, admin
│   │   └── services/
│   │       ├── recommendation.py     # Motor RIASEC (puro, sem I/O)
│   │       └── email.py              # ResendEmailService + ConsoleEmailService
│   ├── api/index.py                  # Entrypoint ASGI da Vercel
│   ├── tests/
│   │   ├── test_recommendation.py    # 8 testes unitários
│   │   └── smoke_e2e.py              # Smoke test E2E manual
│   ├── pyproject.toml                # deps + ruff + pytest config
│   ├── requirements.txt              # mirror das deps (Vercel)
│   ├── vercel.json                   # build config
│   └── README.md
│
├── frontend/                         # React + Vite + TS + Tailwind v4
│   ├── src/
│   │   ├── main.tsx                  # Entry + BrowserRouter
│   │   ├── App.tsx                   # Routes
│   │   ├── api/{client,endpoints,admin}.ts
│   │   ├── types/api.ts              # Espelha schemas Pydantic
│   │   ├── lib/{storage,supabase}.ts
│   │   ├── components/               # Layout, Button, Loading, ProgressBar, CityCombobox
│   │   └── pages/
│   │       ├── Onboarding.tsx
│   │       ├── Assessment.tsx
│   │       ├── Result.tsx
│   │       └── admin/{Login,Dashboard}.tsx
│   ├── vite.config.ts
│   ├── tsconfig.{,app,node}.json
│   ├── vercel.json                   # SPA rewrites
│   └── README.md
│
├── sql/                              # PostgreSQL DDL + seeds
│   ├── 001_extensions.sql            # pgcrypto, citext, pg_trgm
│   ├── 002_dimensions.sql            # cities, areas, professions, courses, institutions
│   ├── 003_junctions.sql             # profession_areas, profession_courses, institution_courses
│   ├── 004_assessment.sql            # questions, question_options
│   ├── 005_transactional.sql         # leads, assessments, answers, results, recommendations
│   ├── 010_rls_policies.sql          # RLS em 16 tabelas
│   ├── seeds/                        # Dados iniciais (idempotentes)
│   └── README.md
│
└── docs/
    ├── API.md                        # Contrato dos endpoints
    ├── ADMIN_SETUP.md                # Como criar o admin user
    ├── RESEND_SETUP.md               # Setup do provider de e-mail
    └── DEPLOY_VERCEL.md              # Guia de deploy
```

---

## Modelo de dados

### Framework RIASEC (Holland)

Modelo clássico de orientação vocacional com 6 áreas de aptidão:

| Código | Área | Característica |
|---|---|---|
| **R** | Realista | Práticos, manuais, ferramentas, ambientes externos |
| **I** | Investigativo | Analíticos, científicos, pesquisa, dados |
| **A** | Artístico | Criativos, expressivos, autonomia, estética |
| **S** | Social | Relacionais, ensinar, ajudar, cuidar |
| **E** | Empreendedor | Liderar, persuadir, vender, influenciar |
| **C** | Convencional | Organizados, processos, regras, estrutura |

### Schema (visão alto nível)

**Dimensões (referência, leitura pública via RLS):**
- `cities` (28) — capitais BR + Campinas, com `ibge_code`
- `aptitude_areas` (6) — RIASEC
- `professions` (5) — Eng. Software, Médico, Designer Gráfico, Advogado, Professor
- `courses` (7) — graduação, tecnólogo, técnico
- `institutions` (12) — universidades públicas, privadas e institutos federais

**Junções:**
- `profession_areas` — vetor RIASEC de cada profissão (`weight` ∈ [0, 1], soma ≈ 1.0)
- `profession_courses` — quais cursos habilitam cada profissão
- `institution_courses` — oferta de cada instituição (com `modality` e `shift`)

**Assessment:**
- `questions` (40) — sequence é UNIQUE
- `question_options` (240) — cada uma pontua para uma única `aptitude_area`

**Transacional (RLS bloqueia anon; só `service_role` acessa):**
- `leads` — captura do onboarding (`full_name`, `email` CITEXT, `city_id`, consentimentos LGPD)
- `assessments` — uma sessão por tentativa (`status`: IN_PROGRESS / COMPLETED / ABANDONED)
- `assessment_answers` — `(assessment_id, question_id)` UNIQUE → idempotente
- `assessment_results` — `area_scores` JSONB + `dominant_area_id`
- `result_recommended_professions` / `result_recommended_institutions` — pré-ranqueado para evitar recálculo

Detalhes em [`sql/README.md`](./sql/README.md).

---

## Motor de recomendação

Implementado em [`backend/app/services/recommendation.py`](./backend/app/services/recommendation.py) como **funções puras** (sem I/O), o que torna o código facilmente testável.

```python
# 1) Soma scores por área e normaliza para somar 1.0
calculate_area_scores(answers) -> {"REALISTIC": 0.10, "INVESTIGATIVE": 0.45, ...}

# 2) Identifica área dominante
dominant_area(scores) -> "INVESTIGATIVE"

# 3) Ranqueia profissões via cosine similarity
rank_professions(user_vector, profession_vectors, top_n=5) -> [
    ProfessionMatch(profession_id=1, score=89.52),
    ProfessionMatch(profession_id=2, score=82.56),
    ...
]

# 4) Seleciona instituições priorizando top profissões e filtrando pela cidade
select_institutions(top_professions, offers_in_city, top_n=5) -> [...]
```

A escolha de **cosine similarity** evita que profissões com vetores mais "longos" tenham vantagem injusta sobre as mais especializadas. O resultado fica em `[0, 100]` — fácil de interpretar como porcentagem.

---

## API

| Método | Rota | Descrição |
|---|---|---|
| `GET`  | `/health` | liveness check |
| `GET`  | `/cities?q=&state=&limit=` | autocomplete de cidades |
| `POST` | `/leads` | cria lead (Onboarding) |
| `POST` | `/assessments` | inicia assessment, devolve as 40 perguntas |
| `POST` | `/assessments/{id}/answers` | registra respostas em lote (idempotente) |
| `POST` | `/assessments/{id}/finalize` | calcula score, persiste, dispara e-mail |
| `GET`  | `/results/{id}` | recupera relatório consolidado |
| `GET`  | `/admin/me` | debug — valida JWT |
| `GET`  | `/admin/stats` | KPIs do dashboard |
| `GET`  | `/admin/leads?limit=&offset=` | lista paginada de leads + status |

Endpoints `/admin/*` exigem header `Authorization: Bearer <jwt-supabase>` e e-mail na whitelist `ADMIN_EMAILS`.

Contratos detalhados em [`docs/API.md`](./docs/API.md). Swagger interativo em **`/docs`** (FastAPI auto-gera).

---

## Painel admin

- **Login:** `/admin/login` — Supabase Auth (e-mail + senha)
- **Dashboard:** `/admin/dashboard` — KPIs (leads, conversão, áreas dominantes), tabela de leads recentes com status do assessment

Para criar o usuário admin, ver [`docs/ADMIN_SETUP.md`](./docs/ADMIN_SETUP.md).

---

## Segurança e LGPD

- **RLS habilitada** em todas as 16 tabelas. Tabelas de referência: `SELECT` público (`anon, authenticated`). Tabelas transacionais: nenhuma policy → só `service_role` (backend) acessa.
- **JWT do Supabase Auth** + whitelist de e-mails (`ADMIN_EMAILS`) para o painel admin.
- **CITEXT** em e-mail evita duplicidade por caixa diferente.
- **Consentimentos LGPD separados:** `consent_lgpd` (obrigatório) e `consent_marketing` (opcional).
- **Coluna `ip_hash`** preparada (não preenchida ainda) — para rastreio sem PII direta.
- **Sem versionamento de secrets:** `.env` no `.gitignore`; `service_role` e `RESEND_API_KEY` ficam só localmente e nas env vars do Vercel.

---

## Deploy

Deploy em produção usa **2 projetos Vercel** apontando para o mesmo repositório, cada um com seu Root Directory:

| Projeto Vercel | Root | URL |
|---|---|---|
| `app-vocacional-backend` | `backend/` | https://app-vocacional-backend.vercel.app |
| `app-vocacional-frontend` | `frontend/` | https://app-vocacional-frontend.vercel.app |

Guia completo: [`docs/DEPLOY_VERCEL.md`](./docs/DEPLOY_VERCEL.md).

### Notas sobre o setup Vercel + Python

Quatro detalhes que valem documentar:

1. **`pyproject.toml` é prioritário sobre `requirements.txt`** — quando ambos existem, Vercel detecta o pyproject e ignora o requirements. Solução: declarar `dependencies = [...]` em `[project]`.
2. **`includeFiles: "app/**"` no `vercel.json`** — sem isso, o pacote `app/` não é bundled junto com `api/index.py` no lambda.
3. **Import top-level em `api/index.py`** — o analisador estático do `@vercel/python` precisa ver `app` como binding direto. Não envolva `from app.main import app` em `try/except`.
4. **`vercel env add ... --value <VALUE>`** — para non-interactive (CI/agentes), use o flag `--value`. Pipe via `echo` ou `printf` no stdin salva como string vazia.

---

## Testes

### Backend

```bash
cd backend

# Unit (motor de recomendação — funções puras, sem I/O, ~60ms)
pytest -v

# Smoke E2E (precisa do uvicorn rodando + Supabase populado)
python tests/smoke_e2e.py
```

O smoke test executa o pipeline real:

```
GET /cities?q=são       → encontra São Paulo
POST /leads             → cria "Smoke Tester"
POST /assessments       → recebe 40 perguntas
POST /answers           → 40 respostas com bias INVESTIGATIVE
POST /finalize          → valida que retorna Engenheiro de Software como top
GET /results/{id}       → re-busca o relatório
```

Resultado esperado: `dominant_area = INVESTIGATIVE`, `top_profession = Engenheiro(a) de Software (~82% match)`, `email_sent = True`.

### Frontend

```bash
cd frontend
npm run lint     # tsc --noEmit (type check)
npm run build    # validação de build de produção
```

---

## Roadmap

### Concluído
- [x] **Etapa 1** — Modelagem dimensional + DDL + seeds (RIASEC, 28 cidades, 12 instituições, 40 perguntas)
- [x] **Etapa 2** — Backend FastAPI com motor de recomendação (cosine similarity)
- [x] **Etapa 3** — Frontend React (Onboarding → Assessment → Resultado)
- [x] **Etapa 4** — RLS, painel admin (login + dashboard), Resend, deploy Vercel

### Backlog
- [ ] CRUD admin para conteúdo (cidades, profissões, cursos, instituições)
- [ ] Expansão para 30+ profissões com pesos RIASEC validados
- [ ] Importar dataset MEC de instituições (~2.5k)
- [ ] Domínio próprio (`vocacional.com.br`)
- [ ] A/B test no copy do onboarding
- [ ] Geolocalização (auto-detectar cidade via IP)
- [ ] Tela de gestão de consentimento + exclusão de dados (LGPD)
- [ ] Export de leads em CSV no admin

---

## Governança do projeto

Para preservar contexto entre sessões de desenvolvimento, o projeto mantém dois arquivos de governança **fora do tracking git**:

- **`PENDENCIAS.md`** — checklist de tarefas por etapa, sempre consultado antes de iniciar e atualizado ao concluir.
- **`SESSOES.md`** — resumo executivo de cada sessão (decisões, entregas, próximos passos).

Estão em `.gitignore` para não poluir o histórico público do repo.

### Convenção de commits

| Prefixo | Quando |
|---|---|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `docs:` | Documentação |
| `refactor:` | Refatoração sem mudança de comportamento |
| `chore:` | Setup, configs, build |

---

## Licença

MIT — ver [LICENSE](./LICENSE).

---

## Créditos

- **Modelo de aptidão:** John L. Holland (RIASEC, 1959)
- **Stack:** [FastAPI](https://fastapi.tiangolo.com), [React](https://react.dev), [Vite](https://vitejs.dev), [Tailwind CSS](https://tailwindcss.com), [Supabase](https://supabase.com), [Vercel](https://vercel.com), [Resend](https://resend.com)
- **Mantenedor:** [@wfcs](https://github.com/wfcs)
