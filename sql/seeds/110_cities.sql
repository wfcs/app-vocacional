-- =============================================================================
-- SEED 110 — Cidades (15 capitais para popular o dropdown)
-- =============================================================================

INSERT INTO cities (name, state_code, ibge_code) VALUES
  ('São Paulo',      'SP', '3550308'),
  ('Rio de Janeiro', 'RJ', '3304557'),
  ('Belo Horizonte', 'MG', '3106200'),
  ('Brasília',       'DF', '5300108'),
  ('Salvador',       'BA', '2927408'),
  ('Curitiba',       'PR', '4106902'),
  ('Porto Alegre',   'RS', '4314902'),
  ('Recife',         'PE', '2611606'),
  ('Fortaleza',      'CE', '2304400'),
  ('Manaus',         'AM', '1302603'),
  ('Goiânia',        'GO', '5208707'),
  ('Florianópolis',  'SC', '4205407'),
  ('Vitória',        'ES', '3205309'),
  ('Belém',          'PA', '1501402'),
  ('Campinas',       'SP', '3509502')
ON CONFLICT (country_code, state_code, name) DO NOTHING;
