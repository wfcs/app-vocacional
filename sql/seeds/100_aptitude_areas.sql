-- =============================================================================
-- SEED 100 — Áreas de Aptidão (RIASEC / Holland)
-- =============================================================================

INSERT INTO aptitude_areas (code, name, description) VALUES
  ('REALISTIC',     'Realista (R)',
   'Prefere atividades práticas e manuais, com ferramentas, máquinas, animais ou ambientes externos.'),
  ('INVESTIGATIVE', 'Investigativo (I)',
   'Gosta de investigar, analisar, resolver problemas, pesquisar e trabalhar com ideias e dados.'),
  ('ARTISTIC',      'Artístico (A)',
   'Valoriza expressão criativa, estética, autonomia e ambientes pouco estruturados.'),
  ('SOCIAL',        'Social (S)',
   'Gosta de ajudar, ensinar, cuidar e trabalhar diretamente com pessoas.'),
  ('ENTERPRISING',  'Empreendedor (E)',
   'Gosta de liderar, persuadir, vender, empreender e influenciar pessoas.'),
  ('CONVENTIONAL',  'Convencional (C)',
   'Prefere atividades organizadas, rotinas claras, regras e trabalho com dados estruturados.')
ON CONFLICT (code) DO NOTHING;
