-- =============================================================================
-- SEED 160 — Cursos que habilitam cada profissão
-- Depende de: professions (120) + courses (130)
-- =============================================================================

INSERT INTO profession_courses (profession_id, course_id, is_primary)
SELECT p.id, c.id, v.is_primary
FROM (VALUES
  ('Engenheiro(a) de Software',     'Engenharia de Software',                  'GRADUACAO', TRUE),
  ('Engenheiro(a) de Software',     'Análise e Desenvolvimento de Sistemas',   'TECNOLOGO', FALSE),
  ('Engenheiro(a) de Software',     'Técnico em Informática',                  'TECNICO',   FALSE),
  ('Médico(a)',                     'Medicina',                                'GRADUACAO', TRUE),
  ('Designer Gráfico',              'Design Gráfico',                          'GRADUACAO', TRUE),
  ('Advogado(a)',                   'Direito',                                 'GRADUACAO', TRUE),
  ('Professor(a) do Ensino Básico', 'Pedagogia',                               'GRADUACAO', TRUE)
) AS v(prof_name, course_name, course_type, is_primary)
JOIN professions p ON p.name = v.prof_name
JOIN courses     c ON c.name = v.course_name AND c.course_type = v.course_type
ON CONFLICT (profession_id, course_id) DO NOTHING;
