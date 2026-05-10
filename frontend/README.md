# Frontend — React + Vite + Tailwind v4

App React (Vite + TypeScript) com 3 telas: Onboarding → Assessment → Resultado.

## Stack

- **React 18** + **TypeScript**
- **Vite 6** (build + dev server)
- **Tailwind CSS v4** (zero-config via `@tailwindcss/vite`)
- **React Router v6** (3 rotas)
- **Native fetch** (sem axios — wrapper em `src/api/client.ts`)

## Estrutura

```
frontend/
├── index.html
├── package.json
├── vite.config.ts
├── tsconfig.{,app,node}.json
├── vercel.json                 # SPA rewrites
├── .env.example                # VITE_API_BASE_URL
└── src/
    ├── main.tsx                # React entry + BrowserRouter
    ├── App.tsx                 # Routes
    ├── index.css               # Tailwind import
    ├── vite-env.d.ts           # tipos de import.meta.env
    ├── api/
    │   ├── client.ts           # fetch wrapper + ApiError
    │   └── endpoints.ts        # Cities, Leads, Assessments, Results
    ├── types/api.ts            # tipos espelhando schemas Pydantic do backend
    ├── lib/storage.ts          # sessionStorage helpers
    ├── components/             # Layout, Button, Loading, ProgressBar, CityCombobox
    └── pages/
        ├── Onboarding.tsx      # Nome / E-mail / Cidade (autocomplete) / LGPD
        ├── Assessment.tsx      # 1 pergunta por vez + progress bar
        └── Result.tsx          # Área dominante + barras RIASEC + profissões + instituições
```

## Setup

```bash
cd frontend
npm install
cp .env.example .env       # opcional — default já aponta para localhost:8000
```

## Rodar dev (frontend + backend)

Em dois terminais:

```bash
# Terminal A — backend
cd backend
.venv\Scripts\activate
uvicorn app.main:app --port 8000

# Terminal B — frontend
cd frontend
npm run dev
# → http://localhost:5173
```

## Build de produção

```bash
npm run build      # gera dist/
npm run preview    # serve dist/ localmente
```

## Deploy Vercel

`vercel.json` faz rewrite de tudo para `/index.html` (SPA). Defina no dashboard:

```
VITE_API_BASE_URL=https://<backend-vercel>.vercel.app
```

## Fluxo de dados

```
Onboarding → POST /leads → POST /assessments → /assessment/:id (state.questions)
            → POST /answers → POST /finalize → /result/:resultId
                                              → GET /results/:id
```

`sessionStorage` guarda `lead_id` e `assessment_id` para resiliência a refresh
(não usado pra autenticação — apenas conveniência).

## Tipos TS

`src/types/api.ts` espelha exatamente os schemas em `backend/app/schemas/`.
Se o backend mudar o contrato, atualize os tipos.
