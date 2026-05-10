# 🎯 App Vocacional

[![Status](https://img.shields.io/badge/status-MVP%20Production%20Ready-brightgreen)](https://github.com/wfcs/app-vocacional)
[![License](https://img.shields.io/badge/license-MIT-blue)](#licença)
[![Python 3.11+](https://img.shields.io/badge/python-3.11%2B-blue)](https://www.python.org)
[![React 18+](https://img.shields.io/badge/react-18%2B-blue)](https://react.dev)

Plataforma de **orientação vocacional** que ajuda pessoas indecisas sobre carreira ou curso a descobrir profissões alinhadas com suas aptidões, cursos recomendados e instituições de ensino na sua cidade.

Usuários respondem um **teste RIASEC** (Holland) de 40 perguntas e recebem um **relatório personalizado** por e-mail com recomendações baseadas em análise estatística.

---

## ✨ Features

- **Teste vocacional adaptativo** — 40 perguntas RIASEC com resultado instantâneo
- **Motor de recomendação inteligente** — cosine similarity entre perfil do usuário e profissões
- **Recomendações contextualizadas** — profissões, cursos (graduação/técnico) e instituições filtradas pela cidade
- **Relatório por e-mail** — PDF com insights e próximos passos
- **Painel administrativo** — KPIs, estatísticas, leads e export de dados
- **Deploy serverless** — zero downtime, escalabilidade automática
- **LGPD-ready** — consentimento separado, sem PII direta no banco

---

## 🏗️ Arquitetura

### Stack Técnico

| Camada | Tecnologia | Hospedagem |
|--------|-----------|-----------|
| **Frontend** | React 18 + TypeScript + Vite + Tailwind v4 | Vercel |
| **Backend** | Python 3.11 + FastAPI + Pydantic | Vercel (Serverless) |
| **Banco de dados** | PostgreSQL 15+ | Supabase Cloud |
| **Autenticação** | Supabase Auth (JWT) | Supabase |
| **E-mail** | Resend (com fallback Console) | Resend SaaS |

### Fluxo de Dados

```
┌─────────────────────────────────────────────────────────────────┐
│                      USUÁRIO FINAL                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
   ┌────────────┐    ┌────────────┐    ┌────────────┐
   │ Onboarding │    │ Assessment │    │  Resultado │
   │ (React)    │───▶│ (React)    │───▶│  (React)   │
   └────────────┘    └────────────┘    └────────────┘
        │                 │                  │
        │POST /leads      │POST /answers     │GET /results/{id}
        │                 │POST /finalize    │
        ▼                 ▼                  ▼
   ┌────────────────────────────────────────────────────┐
   │          FastAPI (Backend)                          │
   │  ├─ /cities (autocomplete)                          │
   │  ├─ /leads (criar novo lead)                        │
   │  ├─ /assessments (iniciar teste)                    │
   │  ├─ /answers (registrar respostas)                  │
   │  ├─ /finalize (calcular resultado)                  │
   │  └─ /results/{id} (recuperar relatório)             │
   └────────────────────────────────────────────────────┘
        │
        ▼
   ┌────────────────────────────────────────────────────┐
   │     SUPABASE (PostgreSQL + Auth)                    │
   │  ├─ leads (PII hashada, LGPD)                       │
   │  ├─ assessment_results (scores RIASEC)              │
   │  ├─ result_recommended_professions (ranking)        │
   │  ├─ result_recommended_institutions (filtradas)     │
   │  └─ [dimensões] cities, professions, courses, etc. │
   └────────────────────────────────────────────────────┘
        │
        ▼
   ┌──────────────────┐
   │  Resend (Email)  │
   │  Relatório final │
   └──────────────────┘
```

---

## 🚀 Quick Start

### Pré-requisitos

- **Python** 3.11+ (recomendado: 3.11 ou 3.12)
- **Node.js** 18+ + npm
- **Git**
- Conta **Supabase** (free tier aceita)
- **(Opcional)** Conta **Resend** para e-mails reais

### 1. Clone e setup inicial

```bash
git clone https://github.com/wfcs/app-vocacional.git
cd app-vocacional

# Backend setup
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows
# source .venv/bin/activate     # macOS/Linux
pip install -r requirements-dev.txt
cp .env.example .env

# Frontend setup (novo terminal)
cd frontend
npm install
cp .env.example .env
```

### 2. Configure variáveis de ambiente

**`backend/.env`:**
```env
SUPABASE_URL=https://vimxebnhbmtqegkjifvq.supabase.co
SUPABASE_SERVICE_KEY=<seu_service_role_key>
ADMIN_EMAILS=seu_email@example.com
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
RESEND_API_KEY=           # deixe vazio para dev (usa console)
```

**`frontend/.env`:**
```env
VITE_API_BASE_URL=http://localhost:8000
```

### 3. Rodar local (2 terminais)

```bash
# Terminal 1 — Backend
cd backend
uvicorn app.main:app --reload --port 8000
# → Swagger: http://localhost:8000/docs

# Terminal 2 — Frontend
cd frontend
npm run dev
# → App: http://localhost:5173
```

### 4. Testar smoke E2E

```bash
cd backend
python tests/smoke_e2e.py
```

Esperado: ✅ cria lead em São Paulo, responde teste com bias INVESTIGATIVE, retorna "Engenheiro de Software" como top profissão.

---

## 📁 Estrutura do Projeto

```
app-vocacional/
├── 📋 README.md                    # este arquivo
├── 📋 PENDENCIAS.md                # tracker de tarefas (não versionado)
├── 📋 SESSOES.md                   # histórico de decisões (não versionado)
│
├── 📁 backend/                     # FastAPI (Python 3.11)
│   ├── 📁 app/
│   │   ├── main.py                 # FastAPI app + middlewares
│   │   ├── config.py               # Settings via pydantic-settings
│   │   ├── deps.py                 # Injeção de dependências
│   │   ├── constants.py            # RIASEC_CODES, defaults
│   │   ├── 📁 schemas/             # Pydantic models (lead, assessment, result)
│   │   ├── 📁 routers/             # Endpoints (cities, leads, assessments, etc.)
│   │   └── 📁 services/
│   │       ├── recommendation.py   # Motor RIASEC (funções puras)
│   │       └── email.py            # ResendEmailService + ConsoleEmailService
│   ├── 📁 api/
│   │   └── index.py                # ASGI entrypoint para Vercel
│   ├── 📁 tests/
│   │   ├── test_recommendation.py  # 8 testes unitários
│   │   └── smoke_e2e.py            # Smoke test end-to-end
│   ├── requirements.txt            # deps produção
│   ├── requirements-dev.txt        # + pytest, ruff
│   ├── pyproject.toml              # config pyproject + ruff
│   ├── vercel.json                 # deploy config Vercel
│   ├── .env.example                # template de env vars
│   └── README.md                   # instruções técnicas backend
│
├── 📁 frontend/                    # React 18 + Vite + TypeScript
│   ├── 📁 src/
│   │   ├── main.tsx                # React entry point
│   │   ├── App.tsx                 # Routes + layout
│   │   ├── index.css               # Tailwind import
│   │   ├── 📁 api/
│   │   │   ├── client.ts           # Fetch wrapper + ApiError
│   │   │   └── endpoints.ts        # Tipado API client (cities, leads, etc.)
│   │   ├── 📁 types/
│   │   │   └── api.ts              # Tipos espelhando schemas Pydantic
│   │   ├── 📁 lib/
│   │   │   ├── storage.ts          # sessionStorage helpers
│   │   │   └── supabase.ts         # Supabase Auth client
│   │   ├── 📁 components/          # Reutilizáveis (Button, Layout, etc.)
│   │   └── 📁 pages/
│   │       ├── Onboarding.tsx      # Nome / E-mail / Cidade / LGPD
│   │       ├── Assessment.tsx      # Teste RIASEC (1 pergunta/vez)
│   │       └── admin/
│   │           ├── Login.tsx       # Auth via Supabase
│   │           └── Dashboard.tsx   # KPIs + tabela leads
│   ├── package.json
│   ├── vite.config.ts              # Vite + React plugin
│   ├── tsconfig.json               # Tipos TypeScript
│   ├── vercel.json                 # SPA rewrites
│   ├── .env.example
│   └── README.md                   # instruções técnicas frontend
│
├── 📁 sql/                         # DDL + Seeds (PostgreSQL)
│   ├── 001_extensions.sql          # pgcrypto, citext, pg_trgm
│   ├── 002_dimensions.sql          # Tabelas de referência (cidades, profissões, etc.)
│   ├── 003_junctions.sql           # Many-to-many (profession_areas, etc.)
│   ├── 004_assessment.sql          # Estrutura de teste (questions, options)
│   ├── 005_transactional.sql       # Leads, results, transacional
│   ├── 010_rls_policies.sql        # Row-Level Security
│   ├── 📁 seeds/
│   │   ├── 100_aptitude_areas.sql  # 6 áreas RIASEC
│   │   ├── 110_cities.sql          # 28 capitais BR + Campinas
│   │   ├── 120_professions.sql     # Catálogo de profissões
│   │   ├── 130_courses.sql         # Cursos (graduação/técnico)
│   │   ├── 140_institutions.sql    # Instituições de ensino
│   │   ├── 150_profession_areas.sql # Vetor RIASEC por profissão
│   │   ├── 160_profession_courses.sql # Oferta profissão × curso
│   │   ├── 170_institution_courses.sql # Oferta instituição × curso
│   │   ├── 171_institution_courses_extra.sql
│   │   ├── 180_questions_options.sql # Banco de perguntas (40) + opções (240)
│   │   └── 181_questions_options_extra.sql
│   └── README.md                   # instruções SQL
│
├── 📁 docs/                        # Documentação
│   ├── API.md                      # Contrato dos endpoints FastAPI
│   ├── ADMIN_SETUP.md              # Criar usuário admin no Supabase
│   ├── RESEND_SETUP.md             # Configurar e-mail com Resend
│   └── DEPLOY_VERCEL.md            # Deploy em produção (2 projetos)
│
├── .gitignore                      # Python, Node, env, PENDENCIAS, SESSOES
└── LICENSE                         # MIT
```

---

## 🧠 Como Funciona

### 1️⃣ Onboarding
Usuário preenche: nome, e-mail, cidade (dropdown) e concorda com LGPD.
```
POST /leads
→ Cria record em leads (sem senha — lead anônimo)
← Retorna lead_id
```

### 2️⃣ Assessment (Teste RIASEC)
40 perguntas com 6 opções cada. Uma opção pontua para uma área Holland (R/I/A/S/E/C).
```
POST /assessments → Recebe as 40 perguntas
POST /answers → Registra respostas em lote (idempotente)
```

### 3️⃣ Finalização e Motor de Recomendação
Backend calcula:
1. **Area scores** — soma pontos por área, normaliza para [0, 1]
2. **Dominant area** — área com maior pontuação
3. **Profession ranking** — cosine similarity entre vetor usuário e vetor profissão
4. **Institution filtering** — profissões top × cursos × instituições na cidade
5. **Email** — enfileira relatório para envio via Resend

```
POST /finalize
↓
Motor RIASEC (puro, sem I/O)
├─ calculate_area_scores(answers) → [R: 0.2, I: 0.5, A: 0.1, S: 0.1, E: 0.05, C: 0.05]
├─ dominant_area(scores) → "INVESTIGATIVE"
├─ rank_professions(scores, vectors) → ["Eng. Software (89%)", "Científista de dados (82%)", ...]
└─ select_institutions(top_profs, city) → [USP, UNICAMP, ETEC-SP]
↓
Salva resultado em result_recommended_professions e result_recommended_institutions
Enfileira e-mail em email_queue (ou envia imediatamente se Resend OK)
← Retorna result_id + dados consolidados
```

### 4️⃣ Resultado
Página mostra:
- Área dominante com visual
- Barras RIASEC (radar chart concept)
- Top 5 profissões com match %
- Top 5 instituições na cidade com cursos oferecidos

---

## 📊 Dados & Modelo de Banco

### Framework RIASEC (Holland)
Seis dimensões de aptidão:
- **R**ealistic (Realista) — manuais, práticos, concretos
- **I**nvestigative (Investigativo) — analíticos, científicos
- **A**rtistic (Artístico) — criativos, expressivos
- **S**ocial (Social) — relacionais, humanitários
- **E**ntrepreneur (Empreendedor) — liderança, vendas
- **C**onventional (Convencional) — organizados, estruturados

### Tabelas Principais

**Dimensões (referência):**
- `cities` (28) — Capitais + Campinas
- `aptitude_areas` (6) — RIASEC
- `professions` (~20-30) — Carreiras
- `courses` (~30) — Graduação + técnico
- `institutions` (~12) — Universidades + institutos

**Junções:**
- `profession_areas` — Vetor RIASEC de cada profissão [R: 0.1, I: 0.5, ...]
- `profession_courses` — Profissão oferece qual curso
- `institution_courses` — Instituição oferece qual curso

**Transacional:**
- `leads` — Usuários (anônimos, só nome + email)
- `assessments` — Sessões de teste
- `assessment_answers` — Respostas (pergunta × opção selecionada)
- `assessment_results` — Score RIASEC final
- `result_recommended_professions` — Ranking profissões (denormalizado para evitar recálculo)
- `result_recommended_institutions` — Ranking instituições por profissão (denormalizado)

---

## 🔐 Segurança & LGPD

- **RLS (Row-Level Security)** habilitado — apenas `service_role` (backend) acessa transacionais
- **JWT via Supabase Auth** para admin (painel só acessível para whitelist de e-mails)
- **IP hash** — não armazenamos IP direto, apenas SHA256(IP + salt)
- **Campos de consentimento separados** — `consent_lgpd` (obrigatório) e `consent_marketing` (opcional)
- **Sem PII sem consentimento** — dados pessoais deletáveis via futuro endpoint admin

---

## 🌐 Deploy em Produção

### Arquitetura
Monorepo com **2 projetos Vercel** separados (backend + frontend) apontando pro mesmo repo:
- `app-vocacional-backend` (root: `/backend`)
- `app-vocacional-frontend` (root: `/frontend`)

### Passo a passo

1. **Backend**
   - `https://vercel.com/new` → Import `wfcs/app-vocacional`
   - Root: `backend`
   - Install: `pip install -r requirements.txt`
   - Env vars (Production + Preview + Development):
     ```
     SUPABASE_URL=https://vimxebnhbmtqegkjifvq.supabase.co
     SUPABASE_SERVICE_KEY=<service_role_key_do_supabase>
     ADMIN_EMAILS=seu_email@example.com
     CORS_ORIGINS=https://app-vocacional-frontend.vercel.app,http://localhost:5173
     RESEND_API_KEY=<opcional—re_xxx>
     EMAIL_FROM=Vocacional <onboarding@resend.dev>
     ```
   - Anote URL gerada: ex. `https://app-vocacional-backend.vercel.app`

2. **Frontend**
   - `https://vercel.com/new` → Import `wfcs/app-vocacional`
   - Root: `frontend`
   - Build Command: `npm run build`
   - Env vars:
     ```
     VITE_API_BASE_URL=https://app-vocacional-backend.vercel.app
     ```

3. **Supabase**
   - Crie admin user via Dashboard: Auth → Users → Add user
   - Preencha e-mail (deve estar em `ADMIN_EMAILS`) + senha
   - Marque "Auto Confirm User"

4. **Validação**
   ```bash
   curl https://app-vocacional-backend.vercel.app/health
   # → {"status":"ok"}
   
   # Teste frontend
   curl https://app-vocacional-frontend.vercel.app
   # → HTML da SPA
   ```

Detalhes: [docs/DEPLOY_VERCEL.md](./docs/DEPLOY_VERCEL.md)

---

## 🛠️ Desenvolvimento

### Estrutura de Commits
- `feat: <descrição>` — nova feature
- `fix: <descrição>` — bug
- `docs: <descrição>` — documentação
- `refactor: <descrição>` — refatoração sem mudança comportamental
- `test: <descrição>` — testes

### Testes

**Backend:**
```bash
cd backend

# Unit (motor de recomendação — puro)
pytest -v

# Smoke E2E (requer local running + Supabase)
python tests/smoke_e2e.py
```

**Frontend:**
```bash
cd frontend

# Type check
npm run lint

# Build (validação sem errors)
npm run build
```

### Code Quality

**Backend:**
- Ruff: linter + formatter (configurado em `pyproject.toml`)
  ```bash
  ruff check app tests
  ruff format app tests
  ```

**Frontend:**
- TypeScript strict mode
- Tailwind CSS v4 (zero-config)

---

## 📈 Roadmap

### ✅ Concluído (MVP)
- Etapa 1: Modelagem dimensional + banco PostgreSQL
- Etapa 2: Backend FastAPI com motor RIASEC
- Etapa 3: Frontend React (3 telas)
- Etapa 4: Admin + Deploy Vercel + E-mail Resend

### 🔄 Em Andamento
- [ ] Deploy em produção com domínio próprio
- [ ] Validação UX/UI com usuários reais

### 📋 Roadmap Futuro
- [ ] CRUD admin para referências (cidades, profissões, cursos, instituições)
- [ ] Expansão de profissões (~30) com pesos RIASEC validados
- [ ] Importar catálogo MEC de instituições (~2.5k)
- [ ] A/B test de copy no onboarding
- [ ] Geolocalização automática (detectar cidade via IP)
- [ ] Notificações por SMS
- [ ] Dashboard de recomendações recebidas (para usuários)
- [ ] Integração com plataformas de bolsas (Fundação Lemann, etc.)

---

## 🤝 Governança Local

Para preservar contexto entre sessões de desenvolvimento, mantemos 2 arquivos **não versionados**:

- **`PENDENCIAS.md`** — tracker de tarefas (checklist de cada etapa)
- **`SESSOES.md`** — resumo executivo de cada sessão (decisões + entregas)

Ambos estão em `.gitignore` para não poluir history do git.

**Consulte antes de iniciar uma etapa** e **atualize ao concluir**.

---

## 📞 Suporte & Contato

### Issues
Abra uma issue no GitHub: [wfcs/app-vocacional/issues](https://github.com/wfcs/app-vocacional/issues)

### Setup Específico
- **Resend (E-mail):** Ver [docs/RESEND_SETUP.md](./docs/RESEND_SETUP.md)
- **Admin (Painel):** Ver [docs/ADMIN_SETUP.md](./docs/ADMIN_SETUP.md)
- **Deploy (Vercel):** Ver [docs/DEPLOY_VERCEL.md](./docs/DEPLOY_VERCEL.md)

### FAQ

**P: Posso usar a app offline?**
R: Não. É necessário conexão internet para comunicar com Supabase e receber e-mail.

**P: Os dados dos usuários são privados?**
R: Sim. Apenas nome, e-mail, cidade e respostas do teste são armazenados. RLS garante que só o backend acessa. IP é hashado (sem PII).

**P: Quantas perguntas tem o teste?**
R: 40 perguntas (30 iniciais + 10 extras na Etapa 4). Framework RIASEC (Holland).

**P: Posso customizar as perguntas/respostas?**
R: Sim. Acesse `/sql/seeds/180_questions_options.sql` e `/sql/seeds/181_questions_options_extra.sql` para adicionar/editar. Após mudanças, execute em `psql` ou Supabase SQL Editor.

**P: Como faço backup dos dados?**
R: Use o Supabase Dashboard (Settings → Backups) ou `pg_dump`:
```bash
pg_dump postgresql://... > backup.sql
```

**P: Posso rodar tudo localmente (sem Supabase cloud)?**
R: Não recomendado (setup PostgreSQL é complexo). Use Supabase free tier — é rápido.

---

## 📄 Licença

MIT License — Veja [LICENSE](./LICENSE) para detalhes.

---

## 🙌 Créditos

- **Modelo de Aptidão:** John Holland (RIASEC)
- **Stack:** React, FastAPI, Supabase, Vercel, Tailwind CSS, TypeScript
- **Infraestrutura:** Vercel (serverless), Supabase (PostgreSQL + Auth), Resend (e-mail)

---

## 📌 Status do Projeto

**🚀 MVP Production Ready**

- Backend: ✅ Todos os endpoints testados
- Frontend: ✅ 3 telas com UX respondente
- Banco: ✅ 28 cidades, 40 perguntas, 12 instituições
- Admin: ✅ Painel com KPIs + leads
- Deploy: ✅ Pronto para Vercel

**Próximos passos:** Deploy em produção e validação com usuários reais.

---

**Última atualização:** 9 de maio de 2026  
**Versão:** 0.1.0 (MVP)  
**Mantenedor:** [wfcs](https://github.com/wfcs)
