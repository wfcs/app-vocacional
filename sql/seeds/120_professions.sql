-- =============================================================================
-- SEED 120 — Profissões (5 exemplos cobrindo perfis RIASEC variados)
-- =============================================================================

INSERT INTO professions (name, description, cbo_code, avg_salary_brl) VALUES
  ('Engenheiro(a) de Software',
   'Projeta, desenvolve e mantém sistemas de software.',
   '212405',  9000.00),
  ('Médico(a)',
   'Diagnostica e trata doenças, promove saúde.',
   '225125', 14000.00),
  ('Designer Gráfico',
   'Cria identidade visual, peças gráficas e interfaces.',
   '262605',  4500.00),
  ('Advogado(a)',
   'Atua em consultoria e contencioso jurídico.',
   '241005',  7500.00),
  ('Professor(a) do Ensino Básico',
   'Planeja e ministra aulas no ensino fundamental e médio.',
   '233205',  4200.00)
ON CONFLICT (name) DO NOTHING;
