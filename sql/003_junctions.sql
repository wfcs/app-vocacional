-- =============================================================================
-- 003 — Tabelas de Junção (N:N)
-- profession_areas, profession_courses, institution_courses
-- =============================================================================

-- Vetor de afinidade: profissão × área RIASEC ---------------------------------
CREATE TABLE IF NOT EXISTS profession_areas (
    profession_id BIGINT       NOT NULL REFERENCES professions(id) ON DELETE CASCADE,
    area_id       SMALLINT     NOT NULL REFERENCES aptitude_areas(id),
    weight        NUMERIC(4,3) NOT NULL CHECK (weight BETWEEN 0 AND 1),
    PRIMARY KEY (profession_id, area_id)
);

-- Cursos que habilitam cada profissão ----------------------------------------
CREATE TABLE IF NOT EXISTS profession_courses (
    profession_id BIGINT  NOT NULL REFERENCES professions(id) ON DELETE CASCADE,
    course_id     BIGINT  NOT NULL REFERENCES courses(id)     ON DELETE CASCADE,
    is_primary    BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (profession_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_profcourses_course
    ON profession_courses (course_id);

-- Catálogo de oferta: instituição × curso ------------------------------------
CREATE TABLE IF NOT EXISTS institution_courses (
    id             BIGSERIAL PRIMARY KEY,
    institution_id BIGINT  NOT NULL REFERENCES institutions(id) ON DELETE CASCADE,
    course_id      BIGINT  NOT NULL REFERENCES courses(id)      ON DELETE CASCADE,
    modality       VARCHAR(15) NOT NULL DEFAULT 'PRESENCIAL'
                   CHECK (modality IN ('PRESENCIAL','EAD','HIBRIDO')),
    shift          VARCHAR(15) CHECK (shift IN ('MANHA','TARDE','NOITE','INTEGRAL')),
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_inst_course UNIQUE (institution_id, course_id, modality, shift)
);

CREATE INDEX IF NOT EXISTS idx_instcourses_course
    ON institution_courses (course_id) WHERE is_active;

CREATE INDEX IF NOT EXISTS idx_instcourses_inst
    ON institution_courses (institution_id) WHERE is_active;
