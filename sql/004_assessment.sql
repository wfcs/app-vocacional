-- =============================================================================
-- 004 — Banco de Perguntas
-- questions + question_options
-- =============================================================================

CREATE TABLE IF NOT EXISTS questions (
    id         BIGSERIAL PRIMARY KEY,
    statement  TEXT     NOT NULL,
    sequence   SMALLINT NOT NULL UNIQUE,
    is_active  BOOLEAN  NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS question_options (
    id          BIGSERIAL PRIMARY KEY,
    question_id BIGINT       NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    label       TEXT         NOT NULL,
    area_id     SMALLINT     NOT NULL REFERENCES aptitude_areas(id),
    score       NUMERIC(4,2) NOT NULL DEFAULT 1.0
);

CREATE INDEX IF NOT EXISTS idx_qoptions_question
    ON question_options (question_id);
