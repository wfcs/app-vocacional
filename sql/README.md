# SQL — Schema & Seeds

Scripts DDL e seeds para o Supabase (PostgreSQL).

> **Status:** vazio. Será populado ao aplicar a Etapa 1 no Supabase.

## Estrutura prevista

```
sql/
├── 001_extensions.sql
├── 002_dimensions.sql        # cities, aptitude_areas, professions, courses, institutions
├── 003_junctions.sql         # profession_areas, profession_courses, institution_courses
├── 004_assessment.sql        # questions, question_options
├── 005_transactional.sql     # leads, assessments, answers, results, recommendations
├── 006_indexes.sql           # índices adicionais
├── 010_rls_policies.sql      # Row Level Security (Supabase)
└── seeds/
    ├── 100_aptitude_areas.sql
    ├── 110_professions.sql
    └── 120_cities_br.sql
```

## Como aplicar

Via Supabase SQL Editor ou via CLI:

```bash
psql "$SUPABASE_DB_URL" -f sql/001_extensions.sql
# ...
```
