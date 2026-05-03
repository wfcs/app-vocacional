-- =============================================================================
-- SEED 150 — Vetor RIASEC por profissão (pesos somam ~1.0 por profissão)
-- Depende de: professions (120) + aptitude_areas (100)
-- =============================================================================

INSERT INTO profession_areas (profession_id, area_id, weight)
SELECT p.id, a.id, v.weight
FROM (VALUES
  -- Engenheiro(a) de Software → I + R dominantes
  ('Engenheiro(a) de Software',     'INVESTIGATIVE', 0.45::numeric),
  ('Engenheiro(a) de Software',     'REALISTIC',     0.25),
  ('Engenheiro(a) de Software',     'CONVENTIONAL',  0.15),
  ('Engenheiro(a) de Software',     'ARTISTIC',      0.10),
  ('Engenheiro(a) de Software',     'ENTERPRISING',  0.05),

  -- Médico(a) → I + S
  ('Médico(a)',                     'INVESTIGATIVE', 0.45),
  ('Médico(a)',                     'SOCIAL',        0.30),
  ('Médico(a)',                     'REALISTIC',     0.15),
  ('Médico(a)',                     'CONVENTIONAL',  0.10),

  -- Designer Gráfico → A + E
  ('Designer Gráfico',              'ARTISTIC',      0.55),
  ('Designer Gráfico',              'ENTERPRISING',  0.20),
  ('Designer Gráfico',              'INVESTIGATIVE', 0.15),
  ('Designer Gráfico',              'SOCIAL',        0.10),

  -- Advogado(a) → E + S + C
  ('Advogado(a)',                   'ENTERPRISING',  0.35),
  ('Advogado(a)',                   'SOCIAL',        0.25),
  ('Advogado(a)',                   'CONVENTIONAL',  0.25),
  ('Advogado(a)',                   'INVESTIGATIVE', 0.15),

  -- Professor(a) do Ensino Básico → S + A
  ('Professor(a) do Ensino Básico', 'SOCIAL',        0.50),
  ('Professor(a) do Ensino Básico', 'ARTISTIC',      0.20),
  ('Professor(a) do Ensino Básico', 'INVESTIGATIVE', 0.15),
  ('Professor(a) do Ensino Básico', 'CONVENTIONAL',  0.15)
) AS v(prof_name, area_code, weight)
JOIN professions    p ON p.name = v.prof_name
JOIN aptitude_areas a ON a.code = v.area_code
ON CONFLICT (profession_id, area_id)
DO UPDATE SET weight = EXCLUDED.weight;
