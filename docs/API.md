# API — FastAPI (App Vocacional)

> Documentação dos endpoints do backend. Será preenchida na **Etapa 2**.
> Esqueleto inicial reflete o fluxo já definido em `README.md` e a modelagem de `sql/`.

---

## Base URL

| Ambiente | URL |
|---|---|
| Local | `http://localhost:8000` |
| Produção | `https://<projeto>.vercel.app/api` |

---

## Autenticação

- Endpoints públicos (lead): sem auth, protegidos por rate limit + CAPTCHA (a definir).
- Endpoints admin (futuros): JWT do Supabase Auth.

---

## Endpoints (planejados)

### POST `/leads`
Cria um lead (Nome, E-mail, Cidade) e retorna o `lead_id`.

**Request**
```json
{
  "full_name": "string",
  "email": "string",
  "city_id": 1234,
  "consent_lgpd": true,
  "consent_marketing": false
}
```

**Response 201**
```json
{ "lead_id": "uuid" }
```

---

### POST `/assessments`
Inicia um novo assessment para um lead.

**Request**
```json
{ "lead_id": "uuid" }
```

**Response 201**
```json
{
  "assessment_id": "uuid",
  "questions": [
    {
      "id": 1,
      "statement": "string",
      "options": [
        { "id": 11, "label": "string" }
      ]
    }
  ]
}
```

---

### POST `/assessments/{assessment_id}/answers`
Registra um lote de respostas. Idempotente por `(assessment_id, question_id)`.

**Request**
```json
{
  "answers": [
    { "question_id": 1, "option_id": 11 }
  ]
}
```

**Response 204** (sem corpo)

---

### POST `/assessments/{assessment_id}/finalize`
Encerra o assessment, dispara o motor de recomendação e enfileira o e-mail.

**Response 200**
```json
{
  "result_id": "uuid",
  "dominant_area": "INVESTIGATIVE",
  "top_professions": [
    { "name": "Engenheiro de Software", "score": 87.5 }
  ],
  "top_institutions": [
    { "name": "USP", "course": "Ciência da Computação", "city": "São Paulo" }
  ]
}
```

---

### GET `/results/{result_id}`
Retorna o relatório completo (mesma payload do e-mail).

---

### GET `/cities?q=...`
Autocomplete de cidades para o onboarding (usa índice trigram em `cities`).

**Response 200**
```json
[
  { "id": 1, "name": "São Paulo", "state_code": "SP" }
]
```

---

## Códigos de erro

| HTTP | Motivo |
|---|---|
| 400 | Payload inválido (Pydantic) |
| 404 | Recurso não encontrado |
| 409 | Conflito (e.g., assessment já finalizado) |
| 422 | Validação semântica (e.g., e-mail mal formatado) |
| 429 | Rate limit |
| 500 | Erro interno |

---

## Observabilidade (planejado)
- Logs estruturados JSON.
- Sentry para exceções.
- Métrica de conversão lead → assessment finalizado.
