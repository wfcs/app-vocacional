# Pendências — App Vocacional

> Arquivo de controle de tarefas. Sempre consultar antes de iniciar uma nova etapa e atualizar ao concluir.

**Última atualização:** 2026-05-03

---

## Legenda
- [ ] Pendente
- [~] Em andamento
- [x] Concluído
- [!] Bloqueado / aguardando decisão

---

## Etapa 0 — Setup do Repositório
- [x] Criar repositório no GitHub (`app-vocacional`, private)
- [x] Criar `PENDENCIAS.md`
- [x] Criar `SESSOES.md`
- [x] Criar `README.md`
- [x] Criar `docs/API.md` (esqueleto FastAPI)
- [x] `.gitignore` Python + Node
- [ ] Definir estrutura de pastas (`/frontend`, `/backend`, `/sql`, `/docs`)

## Etapa 1 — Modelagem Dimensional & Banco de Dados
- [x] Diagrama lógico (Mermaid ER) entregue
- [x] DDL completo entregue (extensões, dimensões, junções, assessment, transacional)
- [!] **Aguardando validação do usuário sobre:**
  - [ ] Framework de aptidão: RIASEC vs. modelo próprio
  - [ ] Cardinalidade do assessment (qtde de perguntas, tipo de escala)
  - [ ] Cidade no onboarding: dropdown vs. texto livre + autocomplete
  - [ ] RLS (Row Level Security) agora ou só no admin
  - [ ] Seed inicial (areas, profissões, instituições de exemplo)
- [ ] Provisionar projeto Supabase
- [ ] Rodar DDL no Supabase
- [ ] Popular seed (`/sql/seed.sql`)
- [ ] Validar índices via `EXPLAIN ANALYZE`

## Etapa 2 — Backend (Python / FastAPI)
- [ ] Aguardando validação da Etapa 1
- [ ] Estrutura do projeto FastAPI
- [ ] Configuração Supabase client + envs
- [ ] Endpoints: `/leads`, `/assessments`, `/assessments/{id}/answers`, `/assessments/{id}/results`
- [ ] Motor de recomendação (cálculo de score RIASEC × profissões)
- [ ] Integração de e-mail (provider a definir: Resend / SendGrid / Postmark)
- [ ] Configuração de deploy serverless na Vercel
- [ ] Testes unitários do motor de recomendação

## Etapa 3 — Frontend (React)
- [ ] Aguardando validação da Etapa 2
- [ ] Setup Vite + React + TypeScript
- [ ] Telas: Onboarding → Assessment → Resultado
- [ ] Integração com FastAPI
- [ ] Deploy Vercel

## Backlog / Futuro
- [ ] Painel admin (Supabase Auth + RLS)
- [ ] Dashboard analítico (conversão, áreas dominantes por região)
- [ ] A/B test no copy do onboarding
- [ ] LGPD: tela de gestão de consentimento e exclusão de dados
