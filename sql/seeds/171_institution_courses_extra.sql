-- =============================================================================
-- SEED 171 — Catálogo de oferta para as novas instituições (seed 141)
-- Depende de: institutions (140/141) + courses (130)
-- =============================================================================

INSERT INTO institution_courses (institution_id, course_id, modality, shift)
SELECT i.id, c.id, v.modality, v.shift
FROM (VALUES
  -- UFRJ
  ('Universidade Federal do Rio de Janeiro (UFRJ)', 'Engenharia de Software', 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Federal do Rio de Janeiro (UFRJ)', 'Medicina',               'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Federal do Rio de Janeiro (UFRJ)', 'Direito',                'GRADUACAO', 'PRESENCIAL', 'NOITE'),
  ('Universidade Federal do Rio de Janeiro (UFRJ)', 'Pedagogia',              'GRADUACAO', 'PRESENCIAL', 'NOITE'),

  -- UFMG
  ('Universidade Federal de Minas Gerais (UFMG)',  'Engenharia de Software', 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Federal de Minas Gerais (UFMG)',  'Medicina',               'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Federal de Minas Gerais (UFMG)',  'Design Gráfico',         'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),

  -- UFRGS
  ('Universidade Federal do Rio Grande do Sul (UFRGS)', 'Engenharia de Software', 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Federal do Rio Grande do Sul (UFRGS)', 'Direito',                'GRADUACAO', 'PRESENCIAL', 'NOITE'),
  ('Universidade Federal do Rio Grande do Sul (UFRGS)', 'Medicina',               'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),

  -- UNICAMP
  ('Universidade Estadual de Campinas (UNICAMP)', 'Engenharia de Software', 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Estadual de Campinas (UNICAMP)', 'Medicina',               'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Estadual de Campinas (UNICAMP)', 'Design Gráfico',         'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),

  -- UFSC
  ('Universidade Federal de Santa Catarina (UFSC)', 'Engenharia de Software', 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Federal de Santa Catarina (UFSC)', 'Pedagogia',              'GRADUACAO', 'PRESENCIAL', 'NOITE'),

  -- UFBA
  ('Universidade Federal da Bahia (UFBA)', 'Medicina', 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Federal da Bahia (UFBA)', 'Direito',  'GRADUACAO', 'PRESENCIAL', 'NOITE'),

  -- UFPE
  ('Universidade Federal de Pernambuco (UFPE)', 'Engenharia de Software', 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),
  ('Universidade Federal de Pernambuco (UFPE)', 'Medicina',               'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),

  -- UnB
  ('Universidade de Brasília (UnB)', 'Direito',                'GRADUACAO', 'PRESENCIAL', 'NOITE'),
  ('Universidade de Brasília (UnB)', 'Engenharia de Software', 'GRADUACAO', 'PRESENCIAL', 'INTEGRAL'),

  -- IFSP
  ('Instituto Federal de Educação, Ciência e Tecnologia de São Paulo (IFSP)',
     'Análise e Desenvolvimento de Sistemas', 'TECNOLOGO', 'PRESENCIAL', 'NOITE'),
  ('Instituto Federal de Educação, Ciência e Tecnologia de São Paulo (IFSP)',
     'Técnico em Informática',                'TECNICO',   'PRESENCIAL', 'NOITE')
) AS v(inst_name, course_name, course_type, modality, shift)
JOIN institutions i ON i.name = v.inst_name
JOIN courses      c ON c.name = v.course_name AND c.course_type = v.course_type
ON CONFLICT (institution_id, course_id, modality, shift) DO NOTHING;
