# App Vocacional

Aplicação web de **Teste de Aptidão** para orientação vocacional. Usuário indeciso sobre carreira ou curso recebe, por e-mail, um relatório com profissões de maior afinidade, cursos recomendados (graduação e técnico) e instituições de ensino na sua cidade.

---

## Stack

| Camada | Tecnologia | Hospedagem |
|---|---|---|
| Frontend | React + Vite + TypeScript | Vercel |
| Backend | Python + FastAPI | Vercel (Serverless Functions) |
| Banco / Auth | Supabase (PostgreSQL) | Supabase Cloud |
| E-mail | A definir (Resend / SendGrid / Postmark) | — |

---

## Fluxo do Produto

```
Onboarding (Nome, E-mail, Cidade)
        │
        ▼
Assessment (perguntas RIASEC)
        │
        ▼
Motor de Recomendação (FastAPI)
        │
        ├── Top profissões (afinidade RIASEC)
        ├── Cursos (graduação / técnico)
        └── Instituições (filtradas pela cidade)
        │
        ▼
E-mail com relatório final
```

---

## Estrutura do Repositório

```
app-vocacional/
├── PENDENCIAS.md         # tracker de tarefas
├── SESSOES.md            # histórico de decisões por sessão
├── README.md             # este arquivo
├── docs/
│   └── API.md            # documentação dos endpoints FastAPI
├── sql/                  # DDL e seeds (a criar)
├── backend/              # FastAPI app (a criar)
└── frontend/             # React app (a criar)
```

---

## Roadmap

- **Etapa 1 — Modelagem & Banco** (entregue, aguarda validação)
- **Etapa 2 — Backend FastAPI**
- **Etapa 3 — Frontend React**

Detalhes em [`PENDENCIAS.md`](./PENDENCIAS.md).

---

## Governança

- **`PENDENCIAS.md`** — sempre consultado antes de iniciar e atualizado ao concluir uma task.
- **`SESSOES.md`** — resumo de cada sessão para preservar contexto entre conversas.
- **`docs/API.md`** — contrato dos endpoints FastAPI.

---

## Status

🚧 Em desenvolvimento — Etapa 1 concluída.
