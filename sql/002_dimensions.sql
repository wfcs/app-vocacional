-- =============================================================================
-- 002 — Tabelas de Dimensão / Referência
-- Cities, Aptitude Areas, Professions, Courses, Institutions
-- =============================================================================

-- Cidades --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cities (
    id           BIGSERIAL PRIMARY KEY,
    name         TEXT      NOT NULL,
    state_code   CHAR(2)   NOT NULL,
    country_code CHAR(2)   NOT NULL DEFAULT 'BR',
    ibge_code    VARCHAR(10),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_city UNIQUE (country_code, state_code, name)
);

CREATE INDEX IF NOT EXISTS idx_cities_state_name
    ON cities (state_code, LOWER(name));

CREATE INDEX IF NOT EXISTS idx_cities_name_trgm
    ON cities USING GIN (name gin_trgm_ops);

-- Áreas de aptidão (RIASEC) --------------------------------------------------
CREATE TABLE IF NOT EXISTS aptitude_areas (
    id          SMALLSERIAL PRIMARY KEY,
    code        VARCHAR(20) NOT NULL UNIQUE,
    name        TEXT        NOT NULL,
    description TEXT
);

-- Profissões -----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS professions (
    id              BIGSERIAL PRIMARY KEY,
    name            TEXT      NOT NULL UNIQUE,
    description     TEXT,
    cbo_code        VARCHAR(10),
    avg_salary_brl  NUMERIC(12,2),
    is_active       BOOLEAN   NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_professions_active
    ON professions (is_active) WHERE is_active;

-- Cursos ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS courses (
    id              BIGSERIAL PRIMARY KEY,
    name            TEXT      NOT NULL,
    course_type     VARCHAR(15) NOT NULL
                    CHECK (course_type IN ('GRADUACAO','TECNOLOGO','TECNICO','POS')),
    duration_months SMALLINT,
    description     TEXT,
    is_active       BOOLEAN   NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_course UNIQUE (name, course_type)
);

-- Instituições ---------------------------------------------------------------
CREATE TABLE IF NOT EXISTS institutions (
    id               BIGSERIAL PRIMARY KEY,
    name             TEXT    NOT NULL,
    institution_type VARCHAR(20) NOT NULL
                     CHECK (institution_type IN ('UNIVERSIDADE','FACULDADE','ESCOLA_TECNICA','INSTITUTO','CENTRO')),
    city_id          BIGINT  NOT NULL REFERENCES cities(id) ON UPDATE CASCADE,
    is_public        BOOLEAN,
    mec_code         VARCHAR(15),
    website          TEXT,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_institution UNIQUE (name, city_id)
);

-- Índice CRÍTICO: filtro por cidade é caminho quente da recomendação
CREATE INDEX IF NOT EXISTS idx_institutions_city_active
    ON institutions (city_id) WHERE is_active;

CREATE INDEX IF NOT EXISTS idx_institutions_name_trgm
    ON institutions USING GIN (name gin_trgm_ops);
