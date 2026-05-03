# Backend — FastAPI

App FastAPI servindo o motor de recomendação vocacional.

> **Status:** vazio. Será implementado na Etapa 2.

## Estrutura prevista

```
backend/
├── app/
│   ├── main.py             # entrypoint FastAPI
│   ├── config.py           # settings (pydantic-settings)
│   ├── deps.py             # dependências (Supabase client, auth)
│   ├── models/             # Pydantic schemas
│   ├── routers/            # leads, assessments, results, cities
│   ├── services/           # motor de recomendação, e-mail
│   └── repositories/       # acesso ao Supabase
├── tests/
├── pyproject.toml
└── vercel.json             # config deploy serverless
```

## Variáveis de ambiente (`.env`)

```
SUPABASE_URL=
SUPABASE_SERVICE_KEY=
EMAIL_PROVIDER_API_KEY=
EMAIL_FROM=
```
