# Histórico de Sessões — App Vocacional

> Resumo executivo de cada sessão de trabalho para preservar contexto entre conversas.
> Sempre ler este arquivo no início de uma nova sessão.

---

## Sessão #001 — 2026-05-03

### Contexto definido
- **Produto:** App web de "Teste de Aptidão" para orientação vocacional (pessoas indecisas sobre carreira/curso).
- **Stack:** React (Vercel) + Python/FastAPI (Vercel) + Supabase (Postgres + Auth).
- **Fluxo:** Onboarding (Nome, E-mail, Cidade) → Assessment → Motor de Recomendação → E-mail com relatório.
- **Recomendações geradas:** Profissões com maior afinidade + Cursos (graduação/técnico) + Instituições filtradas pela cidade do lead.

### Decisões arquiteturais
1. **Modelo de aptidão:** proposto **RIASEC (Holland)** — 6 áreas. *(aguardando validação)*
2. **Lead-first:** entidade raiz é `leads` (não usuário autenticado); Auth do Supabase fica para área admin futura.
3. **Cidade normalizada:** tabela própria `cities` com FK em `leads` e `institutions` para garantir filtro performático.
4. **Recomendação pré-computada:** tabelas `result_recommended_professions` e `result_recommended_institutions` armazenam o ranking final, evitando recálculo a cada visualização.
5. **JSONB + GIN** em `assessment_results.area_scores` para análises futuras sem alterar schema.
6. **LGPD-ready:** `consent_lgpd`, `consent_marketing` separados + `ip_hash` (sem PII direta).

### Entregas desta sessão
- Etapa 1 (Modelagem): diagrama Mermaid ER + DDL completo (extensões, dimensões, junções, assessment, transacional, índices).
- Setup do repositório `app-vocacional` (GitHub privado).
- Estrutura inicial de governança: `PENDENCIAS.md`, `SESSOES.md`, `README.md`, `docs/API.md`.

### Pendências críticas (5 perguntas em aberto para o usuário)
1. Framework de aptidão: RIASEC ou modelo próprio?
2. Quantidade e tipo de perguntas (escala única / Likert)?
3. Cidade: dropdown a partir de `cities` ou texto livre + autocomplete?
4. Definir RLS agora ou só no admin?
5. Preparar seed inicial de exemplo para testar Etapa 2?

### Próxima sessão deve começar por
- Resolver as 5 pendências acima.
- Aplicar DDL no Supabase.
- Avançar para Etapa 2 (FastAPI).
