-- =============================================================================
-- 010 — Row Level Security (RLS) policies
--
-- Estratégia simples e segura:
--   • Tabelas de referência → SELECT público (anon e authenticated podem ler).
--   • Tabelas transacionais  → bloqueadas para anon/authenticated;
--                              somente service_role acessa (bypassa RLS).
--   • O backend FastAPI usa service_role → continua funcionando normalmente.
--   • Quando montarmos o admin com Supabase Auth, criamos policies extras
--     liberando role 'admin' para SELECT em tabelas transacionais.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Habilita RLS em TODAS as tabelas
-- -----------------------------------------------------------------------------
ALTER TABLE cities                          ENABLE ROW LEVEL SECURITY;
ALTER TABLE aptitude_areas                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE professions                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses                         ENABLE ROW LEVEL SECURITY;
ALTER TABLE institutions                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE profession_areas                ENABLE ROW LEVEL SECURITY;
ALTER TABLE profession_courses              ENABLE ROW LEVEL SECURITY;
ALTER TABLE institution_courses             ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions                       ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_options                ENABLE ROW LEVEL SECURITY;

ALTER TABLE leads                           ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessments                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_answers              ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_results              ENABLE ROW LEVEL SECURITY;
ALTER TABLE result_recommended_professions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE result_recommended_institutions ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- Policies: SELECT público em tabelas de referência
-- (necessário só para o caso de o frontend ler diretamente algum dia;
--  o backend com service_role não depende disso.)
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS public_read ON cities;
CREATE POLICY public_read ON cities                          FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS public_read ON aptitude_areas;
CREATE POLICY public_read ON aptitude_areas                  FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS public_read ON professions;
CREATE POLICY public_read ON professions                     FOR SELECT TO anon, authenticated USING (is_active);

DROP POLICY IF EXISTS public_read ON courses;
CREATE POLICY public_read ON courses                         FOR SELECT TO anon, authenticated USING (is_active);

DROP POLICY IF EXISTS public_read ON institutions;
CREATE POLICY public_read ON institutions                    FOR SELECT TO anon, authenticated USING (is_active);

DROP POLICY IF EXISTS public_read ON profession_areas;
CREATE POLICY public_read ON profession_areas                FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS public_read ON profession_courses;
CREATE POLICY public_read ON profession_courses              FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS public_read ON institution_courses;
CREATE POLICY public_read ON institution_courses             FOR SELECT TO anon, authenticated USING (is_active);

DROP POLICY IF EXISTS public_read ON questions;
CREATE POLICY public_read ON questions                       FOR SELECT TO anon, authenticated USING (is_active);

DROP POLICY IF EXISTS public_read ON question_options;
CREATE POLICY public_read ON question_options                FOR SELECT TO anon, authenticated USING (true);

-- -----------------------------------------------------------------------------
-- Tabelas transacionais: nenhuma policy = ninguém (exceto service_role) acessa
-- service_role bypassa RLS automaticamente — backend continua normal.
-- -----------------------------------------------------------------------------
-- (sem CREATE POLICY)
