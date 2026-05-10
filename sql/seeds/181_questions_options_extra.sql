-- =============================================================================
-- SEED 181 — Perguntas 13-40 (28 novas perguntas + 168 opções)
-- Total final com seed 180: 40 perguntas, 240 opções (1 por área RIASEC)
-- IDEMPOTENTE
-- =============================================================================

INSERT INTO questions (statement, sequence) VALUES
  ('Quando recebo um problema novo, gosto de:',                                13),
  ('Eu prefiro estudar/trabalhar com:',                                        14),
  ('Em uma reunião, costumo ser quem:',                                        15),
  ('Atividade que mais me relaxa:',                                            16),
  ('Tipo de leitura que mais gosto:',                                          17),
  ('O que mais me incomoda no trabalho:',                                      18),
  ('Numa cidade nova, eu primeiro:',                                           19),
  ('Forma preferida de aprender uma habilidade:',                              20),
  ('Quando alguém me pede ajuda, eu:',                                         21),
  ('Em projetos longos, eu prefiro:',                                          22),
  ('O melhor presente que posso receber é:',                                   23),
  ('Em viagens, eu gosto de:',                                                 24),
  ('Reconhecimento que mais valorizo:',                                        25),
  ('Em equipes esportivas, eu seria:',                                         26),
  ('O que me motiva a sair da cama é:',                                        27),
  ('Tipo de filme/série favorito:',                                            28),
  ('Em situação de crise, eu:',                                                29),
  ('Hobby que mais combina comigo:',                                           30),
  ('Estilo de comunicação que adoto:',                                         31),
  ('Em uma loja, eu sou o tipo de cliente que:',                               32),
  ('O trabalho dos meus sonhos envolve:',                                      33),
  ('Como organizo meu dia a dia:',                                             34),
  ('O que mais admiro em alguém:',                                             35),
  ('Profissão que sempre achei interessante:',                                 36),
  ('Em uma festa, eu costumo:',                                                37),
  ('Diante de uma falha, eu:',                                                 38),
  ('Como prefiro receber feedback:',                                           39),
  ('Em 10 anos eu quero estar:',                                               40)
ON CONFLICT (sequence) DO NOTHING;

INSERT INTO question_options (question_id, label, area_id, score)
SELECT q.id, v.label, a.id, 1.0
FROM (VALUES
  -- Q13
  (13, 'Quebrar em partes e atacar uma de cada vez, na prática.',         'REALISTIC'),
  (13, 'Pesquisar a fundo até entender as causas.',                       'INVESTIGATIVE'),
  (13, 'Imaginar várias soluções diferentes.',                            'ARTISTIC'),
  (13, 'Discutir com alguém para ter outra perspectiva.',                 'SOCIAL'),
  (13, 'Definir prioridade pelo impacto e começar.',                      'ENTERPRISING'),
  (13, 'Criar um checklist e seguir passo a passo.',                      'CONVENTIONAL'),
  -- Q14
  (14, 'Equipamentos, ferramentas ou materiais.',                         'REALISTIC'),
  (14, 'Dados, estatísticas e teorias.',                                  'INVESTIGATIVE'),
  (14, 'Cores, sons, formas e ideias.',                                   'ARTISTIC'),
  (14, 'Pessoas e suas histórias.',                                       'SOCIAL'),
  (14, 'Negócios, mercados e oportunidades.',                             'ENTERPRISING'),
  (14, 'Documentos, planilhas e processos.',                              'CONVENTIONAL'),
  -- Q15
  (15, 'Resume o que precisa ser feito e parte para a ação.',             'REALISTIC'),
  (15, 'Faz perguntas para entender o problema.',                         'INVESTIGATIVE'),
  (15, 'Propõe ideias diferentes do convencional.',                       'ARTISTIC'),
  (15, 'Cuida para que todos sejam ouvidos.',                             'SOCIAL'),
  (15, 'Toma a frente e direciona as decisões.',                          'ENTERPRISING'),
  (15, 'Anota tudo e cobra os encaminhamentos depois.',                   'CONVENTIONAL'),
  -- Q16
  (16, 'Fazer um esporte ou cuidar do jardim.',                           'REALISTIC'),
  (16, 'Ler sobre algo que me intriga.',                                  'INVESTIGATIVE'),
  (16, 'Tocar música, escrever ou desenhar.',                             'ARTISTIC'),
  (16, 'Encontrar amigos e conversar.',                                   'SOCIAL'),
  (16, 'Planejar uma viagem ou projeto novo.',                            'ENTERPRISING'),
  (16, 'Organizar um espaço da casa ou os arquivos.',                     'CONVENTIONAL'),
  -- Q17
  (17, 'Manuais práticos e guias de "como fazer".',                       'REALISTIC'),
  (17, 'Ciência, divulgação científica, ensaios.',                        'INVESTIGATIVE'),
  (17, 'Ficção, poesia, biografias criativas.',                           'ARTISTIC'),
  (17, 'Autoajuda, relacionamentos, memórias.',                           'SOCIAL'),
  (17, 'Negócios, biografias de empreendedores.',                         'ENTERPRISING'),
  (17, 'Referências técnicas, normas e regulamentos.',                    'CONVENTIONAL'),
  -- Q18
  (18, 'Ficar parado o dia todo na frente do computador.',                'REALISTIC'),
  (18, 'Tarefas repetitivas que não exigem pensar.',                      'INVESTIGATIVE'),
  (18, 'Regras rígidas que limitam a criatividade.',                      'ARTISTIC'),
  (18, 'Ambientes frios, sem conexão entre pessoas.',                     'SOCIAL'),
  (18, 'Falta de oportunidades de crescimento.',                          'ENTERPRISING'),
  (18, 'Bagunça, prazos perdidos, falta de processo.',                    'CONVENTIONAL'),
  -- Q19
  (19, 'Vou caminhar pelas ruas e conhecer no presencial.',               'REALISTIC'),
  (19, 'Pesquiso sobre história, dados e mapas.',                         'INVESTIGATIVE'),
  (19, 'Visito museus, galerias, lugares fotogênicos.',                   'ARTISTIC'),
  (19, 'Procuro pessoas locais para conversar.',                          'SOCIAL'),
  (19, 'Identifico oportunidades de negócio ou networking.',              'ENTERPRISING'),
  (19, 'Faço um roteiro detalhado dos pontos a visitar.',                 'CONVENTIONAL'),
  -- Q20
  (20, 'Praticando, errando e ajustando.',                                'REALISTIC'),
  (20, 'Estudando a fundo a teoria primeiro.',                            'INVESTIGATIVE'),
  (20, 'Experimentando do meu jeito, sem manual.',                        'ARTISTIC'),
  (20, 'Em grupo, trocando com outros aprendizes.',                       'SOCIAL'),
  (20, 'Aprendendo o essencial e aplicando rápido.',                      'ENTERPRISING'),
  (20, 'Seguindo um curso estruturado e completo.',                       'CONVENTIONAL'),
  -- Q21
  (21, 'Faço junto, mostrando na prática.',                               'REALISTIC'),
  (21, 'Pergunto detalhes para entender o problema.',                     'INVESTIGATIVE'),
  (21, 'Sugiro caminhos criativos, fora do óbvio.',                       'ARTISTIC'),
  (21, 'Escuto primeiro, depois oriento.',                                'SOCIAL'),
  (21, 'Tomo a frente e resolvo rápido.',                                 'ENTERPRISING'),
  (21, 'Indico o procedimento correto a seguir.',                         'CONVENTIONAL'),
  -- Q22
  (22, 'Ter resultados visíveis e palpáveis a cada etapa.',               'REALISTIC'),
  (22, 'Aprofundar em cada área até dominar.',                            'INVESTIGATIVE'),
  (22, 'Variar bastante para não ficar repetitivo.',                      'ARTISTIC'),
  (22, 'Trabalhar perto de pessoas que admiro.',                          'SOCIAL'),
  (22, 'Ver o impacto direto no negócio ou cliente.',                     'ENTERPRISING'),
  (22, 'Ter cronograma claro e marcos definidos.',                        'CONVENTIONAL'),
  -- Q23
  (23, 'Ferramentas, equipamentos esportivos, kit DIY.',                  'REALISTIC'),
  (23, 'Livros, assinatura de revistas, cursos.',                         'INVESTIGATIVE'),
  (23, 'Materiais de arte, ingressos para shows.',                        'ARTISTIC'),
  (23, 'Encontros, dinâmicas em grupo, viagens com amigos.',              'SOCIAL'),
  (23, 'Algo exclusivo ou de status (gadgets, marcas).',                  'ENTERPRISING'),
  (23, 'Itens de organização (planners, agendas).',                       'CONVENTIONAL'),
  -- Q24
  (24, 'Trilhas, esportes radicais, contato com a natureza.',             'REALISTIC'),
  (24, 'Visitar locais históricos e museus de ciência.',                  'INVESTIGATIVE'),
  (24, 'Galerias, festivais, cultura local.',                             'ARTISTIC'),
  (24, 'Conhecer pessoas e histórias do destino.',                        'SOCIAL'),
  (24, 'Aproveitar para fazer negócios ou networking.',                   'ENTERPRISING'),
  (24, 'Roteiro pronto, hotel reservado, tudo planejado.',                'CONVENTIONAL'),
  -- Q25
  (25, '"Você fez isso funcionar!"',                                      'REALISTIC'),
  (25, '"Você é referência nessa área."',                                 'INVESTIGATIVE'),
  (25, '"Você tem um olhar único."',                                      'ARTISTIC'),
  (25, '"Você fez diferença na minha vida."',                             'SOCIAL'),
  (25, '"Você lidera muito bem."',                                        'ENTERPRISING'),
  (25, '"Pode contar com você, sempre entrega."',                         'CONVENTIONAL'),
  -- Q26
  (26, 'Quem corre, defende, joga forte.',                                'REALISTIC'),
  (26, 'Quem analisa o adversário e a tática.',                           'INVESTIGATIVE'),
  (26, 'Quem motiva com criatividade e energia.',                         'ARTISTIC'),
  (26, 'Quem mantém o time unido.',                                       'SOCIAL'),
  (26, 'Quem capitaneia e decide jogadas.',                               'ENTERPRISING'),
  (26, 'Quem cuida de horários, escala e logística.',                     'CONVENTIONAL'),
  -- Q27
  (27, 'Construir ou consertar algo concreto.',                           'REALISTIC'),
  (27, 'Resolver um quebra-cabeça intelectual.',                          'INVESTIGATIVE'),
  (27, 'Criar algo do zero.',                                             'ARTISTIC'),
  (27, 'Estar com pessoas que amo.',                                      'SOCIAL'),
  (27, 'Conquistar uma meta ousada.',                                     'ENTERPRISING'),
  (27, 'Fechar pendências e ter ordem.',                                  'CONVENTIONAL'),
  -- Q28
  (28, 'Ação, aventura, esportes.',                                       'REALISTIC'),
  (28, 'Documentário, ficção científica, mistério.',                      'INVESTIGATIVE'),
  (28, 'Drama autoral, animação artística.',                              'ARTISTIC'),
  (28, 'Romance, drama humano, biografias.',                              'SOCIAL'),
  (28, 'Negócios, política, suspense estratégico.',                       'ENTERPRISING'),
  (28, 'Procedural / investigação detalhada (CSI, Law & Order).',         'CONVENTIONAL'),
  -- Q29
  (29, 'Ajo rápido, faço o que precisa ser feito.',                       'REALISTIC'),
  (29, 'Tento entender exatamente o que aconteceu.',                      'INVESTIGATIVE'),
  (29, 'Busco uma forma criativa de virar o jogo.',                       'ARTISTIC'),
  (29, 'Acolho quem está mais afetado.',                                  'SOCIAL'),
  (29, 'Assumo a liderança e mobilizo a equipe.',                         'ENTERPRISING'),
  (29, 'Sigo o protocolo, mantenho o controle.',                          'CONVENTIONAL'),
  -- Q30
  (30, 'Marcenaria, mecânica, jardinagem.',                               'REALISTIC'),
  (30, 'Astronomia, programação, xadrez.',                                'INVESTIGATIVE'),
  (30, 'Música, fotografia, escrita.',                                    'ARTISTIC'),
  (30, 'Voluntariado, trabalho social.',                                  'SOCIAL'),
  (30, 'Investimentos, marketplace, side hustles.',                       'ENTERPRISING'),
  (30, 'Colecionismo, genealogia, contabilidade pessoal.',                'CONVENTIONAL'),
  -- Q31
  (31, 'Direto, objetivo, prático.',                                      'REALISTIC'),
  (31, 'Analítico, com dados e referências.',                             'INVESTIGATIVE'),
  (31, 'Imaginativo, com metáforas e narrativas.',                        'ARTISTIC'),
  (31, 'Empático, atento ao tom e às emoções.',                           'SOCIAL'),
  (31, 'Persuasivo, focado em convencer e mover.',                        'ENTERPRISING'),
  (31, 'Formal, estruturado, sem ambiguidade.',                           'CONVENTIONAL'),
  -- Q32
  (32, 'Quer testar o produto antes de comprar.',                         'REALISTIC'),
  (32, 'Compara especificações técnicas.',                                'INVESTIGATIVE'),
  (32, 'Se encanta com o design e a apresentação.',                       'ARTISTIC'),
  (32, 'Conversa bastante com o vendedor.',                               'SOCIAL'),
  (32, 'Negocia e busca o melhor custo-benefício.',                       'ENTERPRISING'),
  (32, 'Pesquisa avaliações e garantia antes.',                           'CONVENTIONAL'),
  -- Q33
  (33, 'Atividade física e resultados tangíveis.',                        'REALISTIC'),
  (33, 'Pesquisa e descobertas.',                                         'INVESTIGATIVE'),
  (33, 'Expressão criativa e estética.',                                  'ARTISTIC'),
  (33, 'Impacto direto na vida das pessoas.',                             'SOCIAL'),
  (33, 'Liderança e construção de algo novo.',                            'ENTERPRISING'),
  (33, 'Excelência operacional e qualidade.',                             'CONVENTIONAL'),
  -- Q34
  (34, 'Faço o que precisa ser feito quando aparece.',                    'REALISTIC'),
  (34, 'Estudo prioridades antes de começar.',                            'INVESTIGATIVE'),
  (34, 'Vario bastante, depende do humor.',                               'ARTISTIC'),
  (34, 'Combino com pessoas e me adapto.',                                'SOCIAL'),
  (34, 'Foco no que dá maior retorno.',                                   'ENTERPRISING'),
  (34, 'Tenho agenda planejada do dia anterior.',                         'CONVENTIONAL'),
  -- Q35
  (35, 'Habilidade prática — sabe fazer com as mãos.',                    'REALISTIC'),
  (35, 'Inteligência e profundidade de conhecimento.',                    'INVESTIGATIVE'),
  (35, 'Originalidade e talento criativo.',                               'ARTISTIC'),
  (35, 'Empatia e generosidade.',                                         'SOCIAL'),
  (35, 'Determinação e capacidade de realizar.',                          'ENTERPRISING'),
  (35, 'Disciplina, integridade e palavra cumprida.',                     'CONVENTIONAL'),
  -- Q36
  (36, 'Engenheiro, mecânico, atleta, agricultor.',                       'REALISTIC'),
  (36, 'Cientista, médico, programador, analista.',                       'INVESTIGATIVE'),
  (36, 'Designer, escritor, músico, arquiteto.',                          'ARTISTIC'),
  (36, 'Professor, psicólogo, enfermeiro, assistente social.',            'SOCIAL'),
  (36, 'Empreendedor, advogado, executivo, vendedor.',                    'ENTERPRISING'),
  (36, 'Contador, auditor, gerente de projetos, paralegal.',              'CONVENTIONAL'),
  -- Q37
  (37, 'Buscar atividades práticas (jogos, dança).',                      'REALISTIC'),
  (37, 'Conversar sobre temas que me interessam profundamente.',          'INVESTIGATIVE'),
  (37, 'Apreciar a música, decoração, atmosfera.',                        'ARTISTIC'),
  (37, 'Circular conhecendo pessoas novas.',                              'SOCIAL'),
  (37, 'Articular conexões e possíveis colaborações.',                    'ENTERPRISING'),
  (37, 'Ficar com os amigos próximos e conhecidos.',                      'CONVENTIONAL'),
  -- Q38
  (38, 'Ajusto na hora e tento de novo.',                                 'REALISTIC'),
  (38, 'Investigo o que deu errado.',                                     'INVESTIGATIVE'),
  (38, 'Vejo como oportunidade de fazer diferente.',                      'ARTISTIC'),
  (38, 'Compartilho com alguém de confiança.',                            'SOCIAL'),
  (38, 'Aprendo rápido e parto para a próxima.',                          'ENTERPRISING'),
  (38, 'Documento para não acontecer de novo.',                           'CONVENTIONAL'),
  -- Q39
  (39, 'Direto, com exemplo prático.',                                    'REALISTIC'),
  (39, 'Com dados e evidências.',                                         'INVESTIGATIVE'),
  (39, 'Em conversa aberta, sem julgamento.',                             'ARTISTIC'),
  (39, 'Em particular, com cuidado e empatia.',                           'SOCIAL'),
  (39, 'Focado em resultados e próximos passos.',                         'ENTERPRISING'),
  (39, 'Estruturado, por escrito, com pontos claros.',                    'CONVENTIONAL'),
  -- Q40
  (40, 'Construindo algo concreto que dura.',                             'REALISTIC'),
  (40, 'Reconhecido por descobrir ou criar conhecimento.',                'INVESTIGATIVE'),
  (40, 'Com uma obra própria, deixando minha marca.',                     'ARTISTIC'),
  (40, 'Ajudando muitas pessoas a viverem melhor.',                       'SOCIAL'),
  (40, 'Liderando algo grande, com autonomia.',                           'ENTERPRISING'),
  (40, 'Em posição estável, com vida bem organizada.',                    'CONVENTIONAL')
) AS v(seq, label, area_code)
JOIN questions      q ON q.sequence = v.seq
JOIN aptitude_areas a ON a.code     = v.area_code
WHERE NOT EXISTS (
  SELECT 1 FROM question_options qo
  WHERE qo.question_id = q.id AND qo.area_id = a.id
);
