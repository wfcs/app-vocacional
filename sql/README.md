# SQL — Schema & Seeds

Scripts DDL e seeds para o Supabase (PostgreSQL ≥ 15).

## Decisões da Etapa 1

- **Framework:** RIASEC (Holland), 6 áreas.
- **Cidade:** dropdown a partir de `cities` (FK obrigatória em `leads`).
- **Pergunta:** opção única (cada `question_option` pontua para 1 `aptitude_area`).
- **RLS:** será adicionada apenas quando montarmos o admin.
- **Seeds:** mínimo viável para testar a Etapa 2 (FastAPI).

---

## Estrutura

```
sql/
├── 001_extensions.sql       # pgcrypto, citext, pg_trgm
├── 002_dimensions.sql       # cities, aptitude_areas, professions, courses, institutions
├── 003_junctions.sql        # profession_areas, profession_courses, institution_courses
├── 004_assessment.sql       # questions, question_options
├── 005_transactional.sql    # leads, assessments, answers, results, recommendations
└── seeds/
    ├── 100_aptitude_areas.sql       # 6 áreas RIASEC
    ├── 110_cities.sql               # 15 capitais BR
    ├── 120_professions.sql          # 5 profissões
    ├── 130_courses.sql              # 7 cursos
    ├── 140_institutions.sql         # 3 instituições (USP, PUC-Rio, ETEC-SP)
    ├── 150_profession_areas.sql     # vetor RIASEC por profissão
    ├── 160_profession_courses.sql   # cursos × profissão
    ├── 170_institution_courses.sql  # oferta de cada instituição
    └── 180_questions_options.sql    # 12 perguntas com 6 opções cada
```

## Ordem de execução

Rodar **na ordem numérica** (DDL primeiro, depois seeds):

```
001 → 002 → 003 → 004 → 005
        ↓
        seeds/100 → 110 → 120 → 130 → 140 → 150 → 160 → 170 → 180
```

Todos os arquivos são **idempotentes** (`CREATE … IF NOT EXISTS`, `INSERT … ON CONFLICT`).

## Como aplicar

### Via Supabase SQL Editor (mais simples)
Copiar/colar cada arquivo na ordem acima e executar.

### Via psql / CLI
```bash
export SUPABASE_DB_URL="postgresql://..."

for f in 001_extensions.sql 002_dimensions.sql 003_junctions.sql \
         004_assessment.sql 005_transactional.sql; do
  psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f "sql/$f"
done

for f in sql/seeds/*.sql; do
  psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f "$f"
done
```

## Validação rápida pós-aplicação

```sql
SELECT 'cities'             AS t, COUNT(*) FROM cities
UNION ALL SELECT 'aptitude_areas',  COUNT(*) FROM aptitude_areas
UNION ALL SELECT 'professions',     COUNT(*) FROM professions
UNION ALL SELECT 'courses',         COUNT(*) FROM courses
UNION ALL SELECT 'institutions',    COUNT(*) FROM institutions
UNION ALL SELECT 'profession_areas',COUNT(*) FROM profession_areas
UNION ALL SELECT 'questions',       COUNT(*) FROM questions
UNION ALL SELECT 'question_options',COUNT(*) FROM question_options;
```

Esperado: 15, 6, 5, 7, 3, 22, 12, 72.
