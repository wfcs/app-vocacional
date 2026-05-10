-- =============================================================================
-- SEED 141 — Mais instituições espalhadas pelas capitais (9 novas, total = 12)
-- Depende de: cities (110/111)
-- =============================================================================

INSERT INTO institutions (name, institution_type, city_id, is_public, mec_code, website)
SELECT v.name, v.itype, c.id, v.is_public, v.mec_code, v.website
FROM (VALUES
  ('Universidade Federal do Rio de Janeiro (UFRJ)',
     'UNIVERSIDADE'::text, 'RJ', 'Rio de Janeiro', TRUE, '0586', 'https://ufrj.br'),
  ('Universidade Federal de Minas Gerais (UFMG)',
     'UNIVERSIDADE',       'MG', 'Belo Horizonte', TRUE, '0584', 'https://ufmg.br'),
  ('Universidade Federal do Rio Grande do Sul (UFRGS)',
     'UNIVERSIDADE',       'RS', 'Porto Alegre',   TRUE, '0588', 'https://ufrgs.br'),
  ('Universidade Estadual de Campinas (UNICAMP)',
     'UNIVERSIDADE',       'SP', 'Campinas',       TRUE, '0512', 'https://unicamp.br'),
  ('Universidade Federal de Santa Catarina (UFSC)',
     'UNIVERSIDADE',       'SC', 'Florianópolis',  TRUE, '0589', 'https://ufsc.br'),
  ('Universidade Federal da Bahia (UFBA)',
     'UNIVERSIDADE',       'BA', 'Salvador',       TRUE, '0581', 'https://ufba.br'),
  ('Universidade Federal de Pernambuco (UFPE)',
     'UNIVERSIDADE',       'PE', 'Recife',         TRUE, '0587', 'https://ufpe.br'),
  ('Universidade de Brasília (UnB)',
     'UNIVERSIDADE',       'DF', 'Brasília',       TRUE, '0543', 'https://unb.br'),
  ('Instituto Federal de Educação, Ciência e Tecnologia de São Paulo (IFSP)',
     'INSTITUTO',          'SP', 'São Paulo',      TRUE, '5454', 'https://ifsp.edu.br')
) AS v(name, itype, state_code, city_name, is_public, mec_code, website)
JOIN cities c ON c.state_code = v.state_code AND c.name = v.city_name
ON CONFLICT (name, city_id) DO NOTHING;
