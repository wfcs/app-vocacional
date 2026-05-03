-- =============================================================================
-- SEED 140 — Instituições (3 exemplos: USP, PUC-Rio, ETEC-SP)
-- Depende de: cities (110)
-- =============================================================================

INSERT INTO institutions (name, institution_type, city_id, is_public, mec_code, website)
SELECT v.name, v.itype, c.id, v.is_public, v.mec_code, v.website
FROM (VALUES
  ('Universidade de São Paulo (USP)',
     'UNIVERSIDADE'::text, 'SP', 'São Paulo',
     TRUE,  '0507',  'https://www5.usp.br'),
  ('Pontifícia Universidade Católica do Rio de Janeiro (PUC-Rio)',
     'UNIVERSIDADE',       'RJ', 'Rio de Janeiro',
     FALSE, '0014',  'https://www.puc-rio.br'),
  ('Centro Paula Souza — ETEC São Paulo',
     'ESCOLA_TECNICA',     'SP', 'São Paulo',
     TRUE,  NULL,    'https://www.cps.sp.gov.br')
) AS v(name, itype, state_code, city_name, is_public, mec_code, website)
JOIN cities c
  ON c.state_code = v.state_code AND c.name = v.city_name
ON CONFLICT (name, city_id) DO NOTHING;
