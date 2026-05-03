-- =============================================================================
-- SEED 180 — Banco mínimo de 12 perguntas (2 por área RIASEC)
-- Cada pergunta tem 6 opções (1 por área), score = 1.0
-- IDEMPOTENTE
-- Depende de: aptitude_areas (100)
-- Obs.: o banco final terá 30-50 perguntas; este seed serve para validar
--       o motor de recomendação na Etapa 2.
-- =============================================================================

-- 1) Perguntas (sequence é UNIQUE)
INSERT INTO questions (statement, sequence) VALUES
  ('Em um final de semana livre, eu prefiro:',                                   1),
  ('Diante de um problema novo no trabalho, minha primeira reação é:',           2),
  ('Em um trabalho em grupo, eu naturalmente assumo o papel de:',                3),
  ('O tipo de tarefa que mais me motiva é:',                                     4),
  ('Quando me apresentam um projeto, presto mais atenção em:',                   5),
  ('Em um ambiente de trabalho ideal, eu valorizo:',                             6),
  ('Se pudesse escolher um curso livre amanhã, escolheria:',                     7),
  ('Diante de uma decisão importante, eu prefiro:',                              8),
  ('A atividade que mais me dá satisfação é:',                                   9),
  ('Para mim, ter sucesso na carreira significa principalmente:',               10),
  ('Quando aprendo algo novo, prefiro:',                                        11),
  ('Se tivesse que liderar um projeto, gostaria que ele envolvesse:',           12)
ON CONFLICT (sequence) DO NOTHING;

-- 2) Opções (1 por área, score = 1.0). Idempotente via WHERE NOT EXISTS.
INSERT INTO question_options (question_id, label, area_id, score)
SELECT q.id, v.label, a.id, 1.0
FROM (VALUES
  -- Q1
  (1, 'Consertar ou montar algo com as próprias mãos.',                'REALISTIC'),
  (1, 'Ler um livro técnico ou estudar um tema novo.',                 'INVESTIGATIVE'),
  (1, 'Desenhar, pintar, fotografar ou tocar música.',                 'ARTISTIC'),
  (1, 'Encontrar amigos e conversar bastante.',                        'SOCIAL'),
  (1, 'Vender algo ou negociar uma oportunidade.',                     'ENTERPRISING'),
  (1, 'Organizar finanças, agenda ou armário.',                        'CONVENTIONAL'),
  -- Q2
  (2, 'Tentar resolver na prática, testando soluções.',                'REALISTIC'),
  (2, 'Investigar a fundo as causas antes de agir.',                   'INVESTIGATIVE'),
  (2, 'Buscar uma abordagem original e diferente.',                    'ARTISTIC'),
  (2, 'Conversar com colegas para entender impactos.',                 'SOCIAL'),
  (2, 'Definir um plano e começar a delegar tarefas.',                 'ENTERPRISING'),
  (2, 'Documentar passo a passo e seguir um roteiro.',                 'CONVENTIONAL'),
  -- Q3
  (3, 'Quem coloca a mão na massa e executa.',                         'REALISTIC'),
  (3, 'Quem analisa dados e levanta hipóteses.',                       'INVESTIGATIVE'),
  (3, 'Quem traz ideias criativas e visuais.',                         'ARTISTIC'),
  (3, 'Quem conecta as pessoas e mantém o clima.',                     'SOCIAL'),
  (3, 'Quem lidera, motiva e bate metas.',                             'ENTERPRISING'),
  (3, 'Quem organiza prazos, planilhas e checklists.',                 'CONVENTIONAL'),
  -- Q4
  (4, 'Trabalhar com ferramentas, máquinas ou ambientes externos.',    'REALISTIC'),
  (4, 'Resolver problemas complexos com lógica e dados.',              'INVESTIGATIVE'),
  (4, 'Criar algo do zero, com liberdade estética.',                   'ARTISTIC'),
  (4, 'Ajudar alguém a aprender ou a se desenvolver.',                 'SOCIAL'),
  (4, 'Convencer alguém de uma ideia ou produto.',                     'ENTERPRISING'),
  (4, 'Garantir que tudo esteja correto e dentro das normas.',         'CONVENTIONAL'),
  -- Q5
  (5, 'Como será executado na prática.',                               'REALISTIC'),
  (5, 'Quais hipóteses sustentam o projeto.',                          'INVESTIGATIVE'),
  (5, 'A estética e a originalidade da proposta.',                     'ARTISTIC'),
  (5, 'O impacto que terá nas pessoas envolvidas.',                    'SOCIAL'),
  (5, 'O retorno financeiro e o potencial de mercado.',                'ENTERPRISING'),
  (5, 'O cronograma, escopo e riscos formais.',                        'CONVENTIONAL'),
  -- Q6
  (6, 'Espaços abertos, atividade física, contato com a realidade.',   'REALISTIC'),
  (6, 'Tempo para estudar, pesquisar e refletir.',                     'INVESTIGATIVE'),
  (6, 'Liberdade criativa e ambiente esteticamente inspirador.',       'ARTISTIC'),
  (6, 'Colegas próximos e cultura colaborativa.',                      'SOCIAL'),
  (6, 'Oportunidades de crescimento, bônus e reconhecimento.',         'ENTERPRISING'),
  (6, 'Processos claros, regras estáveis e previsibilidade.',          'CONVENTIONAL'),
  -- Q7
  (7, 'Mecânica, marcenaria ou eletrônica.',                           'REALISTIC'),
  (7, 'Estatística, programação ou astronomia.',                       'INVESTIGATIVE'),
  (7, 'Fotografia, escrita criativa ou música.',                       'ARTISTIC'),
  (7, 'Psicologia, educação ou cuidados em saúde.',                    'SOCIAL'),
  (7, 'Vendas, oratória ou empreendedorismo.',                         'ENTERPRISING'),
  (7, 'Contabilidade, gestão de projetos ou Excel avançado.',          'CONVENTIONAL'),
  -- Q8
  (8, 'Testar opções na prática para ver qual funciona.',              'REALISTIC'),
  (8, 'Pesquisar dados e literatura antes de decidir.',                'INVESTIGATIVE'),
  (8, 'Confiar na intuição e na criatividade.',                        'ARTISTIC'),
  (8, 'Ouvir opiniões de pessoas próximas.',                           'SOCIAL'),
  (8, 'Avaliar o que dá maior retorno e seguir rápido.',               'ENTERPRISING'),
  (8, 'Comparar critérios objetivos em uma planilha.',                 'CONVENTIONAL'),
  -- Q9
  (9, 'Ver algo físico funcionando após meu trabalho.',                'REALISTIC'),
  (9, 'Descobrir uma resposta que ninguém tinha visto.',               'INVESTIGATIVE'),
  (9, 'Receber elogios pela originalidade do que criei.',              'ARTISTIC'),
  (9, 'Ajudar alguém a superar um desafio pessoal.',                   'SOCIAL'),
  (9, 'Fechar um negócio ou conquistar um novo cliente.',              'ENTERPRISING'),
  (9, 'Concluir um relatório completo e impecável.',                   'CONVENTIONAL'),
  -- Q10
  (10, 'Construir coisas concretas e duráveis.',                       'REALISTIC'),
  (10, 'Ser referência técnica em uma área de conhecimento.',          'INVESTIGATIVE'),
  (10, 'Deixar uma obra ou marca pessoal reconhecível.',               'ARTISTIC'),
  (10, 'Causar impacto positivo na vida das pessoas.',                 'SOCIAL'),
  (10, 'Ter independência financeira e influência.',                   'ENTERPRISING'),
  (10, 'Ter estabilidade, organização e segurança.',                   'CONVENTIONAL'),
  -- Q11
  (11, 'Aprender fazendo, em projetos reais.',                         'REALISTIC'),
  (11, 'Estudar a teoria a fundo antes de praticar.',                  'INVESTIGATIVE'),
  (11, 'Explorar livremente, sem método rígido.',                      'ARTISTIC'),
  (11, 'Aprender em grupo, debatendo com outros.',                     'SOCIAL'),
  (11, 'Aprender o que tem aplicação imediata e dá resultado.',        'ENTERPRISING'),
  (11, 'Seguir um curso estruturado, com módulos e certificado.',      'CONVENTIONAL'),
  -- Q12
  (12, 'Construção, manutenção ou operação de algo físico.',           'REALISTIC'),
  (12, 'Pesquisa, descoberta ou desenvolvimento técnico.',             'INVESTIGATIVE'),
  (12, 'Design, comunicação visual ou produção criativa.',             'ARTISTIC'),
  (12, 'Educação, saúde ou desenvolvimento humano.',                   'SOCIAL'),
  (12, 'Lançamento de produto, negociação ou venda.',                  'ENTERPRISING'),
  (12, 'Padronização, qualidade ou gestão administrativa.',            'CONVENTIONAL')
) AS v(seq, label, area_code)
JOIN questions      q ON q.sequence = v.seq
JOIN aptitude_areas a ON a.code     = v.area_code
WHERE NOT EXISTS (
  SELECT 1 FROM question_options qo
  WHERE qo.question_id = q.id AND qo.area_id = a.id
);
