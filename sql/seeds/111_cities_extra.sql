-- =============================================================================
-- SEED 111 — Capitais brasileiras restantes (12)
-- Total final com seed 110: 27 cidades (todas as capitais BR + Campinas)
-- =============================================================================

INSERT INTO cities (name, state_code, ibge_code) VALUES
  ('Aracaju',      'SE', '2800308'),
  ('Boa Vista',    'RR', '1400100'),
  ('Campo Grande', 'MS', '5002704'),
  ('Cuiabá',       'MT', '5103403'),
  ('João Pessoa',  'PB', '2507507'),
  ('Macapá',       'AP', '1600303'),
  ('Maceió',       'AL', '2704302'),
  ('Natal',        'RN', '2408102'),
  ('Palmas',       'TO', '1721000'),
  ('Porto Velho',  'RO', '1100205'),
  ('Rio Branco',   'AC', '1200401'),
  ('São Luís',     'MA', '2111300'),
  ('Teresina',     'PI', '2211001')
ON CONFLICT (country_code, state_code, name) DO NOTHING;
