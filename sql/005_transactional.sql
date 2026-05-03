-- =============================================================================
-- 005 — Tabelas Transacionais
-- leads, assessments, assessment_answers, assessment_results, recommendations
-- =============================================================================

-- Lead capturado no onboarding -----------------------------------------------
CREATE TABLE IF NOT EXISTS leads (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name         TEXT    NOT NULL,
    email             CITEXT  NOT NULL,
    city_id           BIGINT  NOT NULL REFERENCES cities(id),
    consent_marketing BOOLEAN NOT NULL DEFAULT FALSE,
    consent_lgpd      BOOLEAN NOT NULL DEFAULT FALSE,
    user_agent        TEXT,
    ip_hash           TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_lead_email CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);

CREATE INDEX IF NOT EXISTS idx_leads_email      ON leads (email);
CREATE INDEX IF NOT EXISTS idx_leads_city       ON leads (city_id);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON leads (created_at DESC);

-- Assessment (cada tentativa de teste) ---------------------------------------
CREATE TABLE IF NOT EXISTS assessments (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id      UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    status       VARCHAR(15) NOT NULL DEFAULT 'IN_PROGRESS'
                 CHECK (status IN ('IN_PROGRESS','COMPLETED','ABANDONED')),
    started_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_assessments_lead
    ON assessments (lead_id);

CREATE INDEX IF NOT EXISTS idx_assessments_status
    ON assessments (status) WHERE status <> 'COMPLETED';

-- Respostas (fato fino) ------------------------------------------------------
CREATE TABLE IF NOT EXISTS assessment_answers (
    id            BIGSERIAL PRIMARY KEY,
    assessment_id UUID    NOT NULL REFERENCES assessments(id) ON DELETE CASCADE,
    question_id   BIGINT  NOT NULL REFERENCES questions(id),
    option_id     BIGINT  NOT NULL REFERENCES question_options(id),
    answered_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_answer UNIQUE (assessment_id, question_id)
);

CREATE INDEX IF NOT EXISTS idx_answers_assessment
    ON assessment_answers (assessment_id);

-- Resultado consolidado ------------------------------------------------------
CREATE TABLE IF NOT EXISTS assessment_results (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id     UUID    NOT NULL UNIQUE REFERENCES assessments(id) ON DELETE CASCADE,
    area_scores       JSONB   NOT NULL,
    dominant_area_id  SMALLINT REFERENCES aptitude_areas(id),
    email_sent        BOOLEAN NOT NULL DEFAULT FALSE,
    email_sent_at     TIMESTAMPTZ,
    generated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Fila de e-mails pendentes (índice parcial)
CREATE INDEX IF NOT EXISTS idx_results_email_pending
    ON assessment_results (generated_at)
    WHERE email_sent = FALSE;

-- Top N profissões pré-ranqueadas --------------------------------------------
CREATE TABLE IF NOT EXISTS result_recommended_professions (
    id            BIGSERIAL PRIMARY KEY,
    result_id     UUID    NOT NULL REFERENCES assessment_results(id) ON DELETE CASCADE,
    profession_id BIGINT  NOT NULL REFERENCES professions(id),
    match_score   NUMERIC(5,2) NOT NULL,
    rank          SMALLINT NOT NULL,
    CONSTRAINT uq_rec_prof UNIQUE (result_id, profession_id)
);

CREATE INDEX IF NOT EXISTS idx_recprof_result_rank
    ON result_recommended_professions (result_id, rank);

-- Top N instituições pré-ranqueadas (filtradas pela cidade do lead) ----------
CREATE TABLE IF NOT EXISTS result_recommended_institutions (
    id             BIGSERIAL PRIMARY KEY,
    result_id      UUID    NOT NULL REFERENCES assessment_results(id) ON DELETE CASCADE,
    institution_id BIGINT  NOT NULL REFERENCES institutions(id),
    course_id      BIGINT  NOT NULL REFERENCES courses(id),
    profession_id  BIGINT  REFERENCES professions(id),
    rank           SMALLINT NOT NULL,
    CONSTRAINT uq_rec_inst UNIQUE (result_id, institution_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_recinst_result
    ON result_recommended_institutions (result_id, rank);
