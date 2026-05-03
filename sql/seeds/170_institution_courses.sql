-- =============================================================================
-- SEED 170 — Catálogo de oferta: instituição × curso
-- Depende de: institutions (140) + courses (130)
-- =============================================================================

INSERT INTO institution_courses (institution_id, course_id, modality, shift)
SELECT i.id, c.id, v.modality, v.shift
FROM (VALUES
  -- USP — São Paulo
  ('Universidade de São Paulo (USP)',
     'Engenharia de Software',                  'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade de São Paulo (USP)',
     'Medicina',                                'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade de São Paulo (USP)',
     'Direito',                                 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade de São Paulo (USP)',
     'Pedagogia',                               'GRADUACAO', 'PRESENCIAL', 'NOITE'),
  ('Universidade de São Paulo (USP)',
     'Design Gráfico',                          'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),

  -- PUC-Rio
  ('Pontifícia Universidade Católica do Rio de Janeiro (PUC-Rio)',
     'Engenharia de Software',                  'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Pontifícia Universidade Católica do Rio de Janeiro (PUC-Rio)',
     'Direito',                                 'GRADUACAO', 'PRESENCIAL', 'NOITE'),
  ('Pontifícia Universidade Católica do Rio de Janeiro (PUC-Rio)',
     'Design Gráfico',                          'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),

  -- ETEC São Paulo
  ('Centro Paula Souza — ETEC São Paulo',
     'Técnico em Informática',                  'TECNICO',   'PRESENCIAL', 'NOITE'),
  ('Centro Paula Souza — ETEC São Paulo',
     'Análise e Desenvolvimento de Sistemas',   'TECNOLOGO', 'PRESENCIAL', 'NOITE')
) AS v(inst_name, course_name, course_type, modality, shift)
JOIN institutions i ON i.name = v.inst_name
JOIN courses      c ON c.name = v.course_name AND c.course_type = v.course_type
ON CONFLICT (institution_id, course_id, modality, shift) DO NOTHING;
