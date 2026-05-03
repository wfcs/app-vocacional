-- =============================================================================
-- SEED 130 — Cursos (graduação, tecnólogo e técnico)
-- =============================================================================

INSERT INTO courses (name, course_type, duration_months, description) VALUES
  ('Engenharia de Software',                'GRADUACAO', 60,
   'Bacharelado focado em desenvolvimento e arquitetura de sistemas.'),
  ('Análise e Desenvolvimento de Sistemas', 'TECNOLOGO', 30,
   'Tecnólogo com foco prático em desenvolvimento de software.'),
  ('Técnico em Informática',                'TECNICO',   24,
   'Curso técnico com noções de hardware, redes e programação.'),
  ('Medicina',                              'GRADUACAO', 72,
   'Bacharelado de 6 anos para formação médica.'),
  ('Design Gráfico',                        'GRADUACAO', 48,
   'Bacharelado em comunicação visual e design.'),
  ('Direito',                               'GRADUACAO', 60,
   'Bacharelado em ciências jurídicas.'),
  ('Pedagogia',                             'GRADUACAO', 48,
   'Licenciatura para atuação em educação infantil e ensino fundamental.')
ON CONFLICT (name, course_type) DO NOTHING;
