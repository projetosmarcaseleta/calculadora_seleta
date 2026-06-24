-- 1. CRIAR AS TABELAS

-- Tabela de Leads
CREATE TABLE IF NOT EXISTS leads (
  id TEXT PRIMARY KEY,
  "refCode" TEXT,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  empresa TEXT,
  skus TEXT,
  ticket TEXT,
  service TEXT,
  "serviceLabel" TEXT,
  plan TEXT,
  value NUMERIC,
  "setupValue" NUMERIC,
  status TEXT,
  temperatura TEXT,
  responsavel TEXT,
  notes JSONB DEFAULT '[]'::jsonb,
  "sacState" JSONB,
  "volCat" JSONB,
  "pontualConfig" JSONB,
  "planoAssessoria" JSONB,
  "planoFull" JSONB,
  "contasAssessoria" INTEGER,
  "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de Membros do Time / Usuários
CREATE TABLE IF NOT EXISTS team_members (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  telefone TEXT, -- Duplicado para compatibilidade com Admin (telefone) e CRM (phone)
  status TEXT DEFAULT 'ativo',
  codigo TEXT UNIQUE,
  comissao NUMERIC,
  pontos INTEGER,
  "isGestor" BOOLEAN DEFAULT FALSE,
  "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de Serviços Personalizados
CREATE TABLE IF NOT EXISTS services (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL,
  status TEXT DEFAULT 'ativo',
  valor NUMERIC,
  prazo TEXT,
  descricao TEXT,
  color TEXT,
  "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de Configurações do CRM/Admin
CREATE TABLE IF NOT EXISTS config (
  key TEXT PRIMARY KEY,
  value JSONB
);

-- Tabela de Cliques de Indicadores
CREATE TABLE IF NOT EXISTS ref_clicks (
  "refCode" TEXT PRIMARY KEY,
  clicks INTEGER DEFAULT 0
);


-- 2. HABILITAR ROW LEVEL SECURITY (RLS)

ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE config ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_clicks ENABLE ROW LEVEL SECURITY;


-- 3. CRIAR POLÍTICAS DE ACESSO (RLS POLICIES)

-- leads: Permite inserção pública (qualquer um via calculadora), mas leitura/escrita completa só para autenticados
CREATE POLICY "Allow public insert leads" ON leads FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow auth all leads" ON leads FOR ALL TO authenticated USING (true);

-- team_members: Apenas usuários autenticados
CREATE POLICY "Allow auth all team_members" ON team_members FOR ALL TO authenticated USING (true);

-- services: Apenas usuários autenticados
CREATE POLICY "Allow auth all services" ON services FOR ALL TO authenticated USING (true);

-- config: Apenas usuários autenticados
CREATE POLICY "Allow auth all config" ON config FOR ALL TO authenticated USING (true);

-- ref_clicks: Permite atualizar/inserir cliques publicamente, mas leitura apenas autenticado
CREATE POLICY "Allow public insert ref_clicks" ON ref_clicks FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update ref_clicks" ON ref_clicks FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Allow auth select ref_clicks" ON ref_clicks FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow auth delete ref_clicks" ON ref_clicks FOR DELETE TO authenticated USING (true);


-- 4. INSERIR DADOS DE DEMONSTRAÇÃO (SEED DATA)

-- Membros do Time / Usuários
INSERT INTO team_members (id, nome, tipo, email, phone, telefone, status, codigo, comissao, pontos, "isGestor", "createdAt") VALUES
('t1', 'Marcos Lima', 'bdr', 'marcos@marcaseleta.com', '(44) 99100-0001', '(44) 99100-0001', 'ativo', NULL, NULL, NULL, FALSE, NOW() - INTERVAL '90 days'),
('t2', 'Fernanda Costa', 'closer', 'fernanda@marcaseleta.com', '(44) 99100-0002', '(44) 99100-0002', 'ativo', NULL, NULL, NULL, FALSE, NOW() - INTERVAL '90 days'),
('t3', 'Lucas Melo', 'responsavel', 'lucas@marcaseleta.com', '(44) 99100-0003', '(44) 99100-0003', 'ativo', NULL, NULL, NULL, TRUE, NOW() - INTERVAL '90 days'),
('t4', 'Patricia Alves', 'indicador', 'patricia@parceiro.com', '(44) 99100-0004', '(44) 99100-0004', 'ativo', 'PAT2025', 5, 10, FALSE, NOW() - INTERVAL '60 days'),
('t5', 'Rafael Torres', 'indicador', 'rafael@parceiro.com', '(44) 99100-0005', '(44) 99100-0005', 'ativo', 'RAF2025', 5, 10, FALSE, NOW() - INTERVAL '45 days'),
('u3', 'Lucas Mantovani', 'indicador', 'lucas@parceiro.com', '(44) 99146-5252', '(44) 99146-5252', 'ativo', 'LUCAS2025', 8, 10, FALSE, NOW() - INTERVAL '30 days')
ON CONFLICT (id) DO NOTHING;

-- Configuração inicial
INSERT INTO config (key, value) VALUES
('ms_admin_cfg', '{"baseUrl": "", "ptsLead": 1, "ptsFechado": 10, "com": {"sac": 5, "full": 5, "ambos": 5, "pontual": 5, "assessoria": 5, "catalogacao": 5}}'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- Cliques de Indicadores
INSERT INTO ref_clicks ("refCode", clicks) VALUES
('LUCAS2025', 34),
('PAT2025', 18),
('RAF2025', 7)
ON CONFLICT ("refCode") DO NOTHING;

-- Leads de demonstração
INSERT INTO leads (id, "refCode", name, email, phone, empresa, skus, ticket, service, "serviceLabel", plan, value, "setupValue", status, temperatura, responsavel, notes, "sacState", "volCat", "pontualConfig", "planoAssessoria", "planoFull", "contasAssessoria", "createdAt") VALUES
('ld01', NULL, 'Juliana Ferreira', 'juliana@modafeminina.com.br', '(11)99201-3345', 'Moda Feminina LTDA', '1800', '200-300', 'catalogacao', 'Catalogação', 'Plano Plus Ate 2.000 transm.', 10000, 1000, 'fechado', 'quente', 't2', '[{"at":"2026-04-10T12:00:00Z","text":"Contrato assinado."},{"at":"2026-04-25T12:00:00Z","text":"Primeiras entregas concluidas."}]'::jsonb, NULL, '{"price": 10000, "label": "Ate 2.000 transm./mes", "overageLabel": "R$5,00/transm. excedente"}'::jsonb, NULL, NULL, NULL, 2, NOW() - INTERVAL '75 days'),
('ld02', NULL, 'Carlos Augusto', 'carlos@eletronicos.com', '(21)98877-1234', 'Eletronicos Brasil', '3200', '400-500', 'full', 'Pacote Full', '12 meses 3 contas', 32000, 3000, 'negociando', 'quente', 't2', '[{"at":"2026-06-06T12:00:00Z","text":"Reuniao realizada. Muito interesse."},{"at":"2026-06-13T12:00:00Z","text":"Solicitou desconto no setup."}]'::jsonb, '{"chatPos": {"volume": 220, "selected": true}, "preVendas": {"volume": 480, "selected": true}}'::jsonb, '{"price": 20000, "label": "Ate 5.000 transm./mes", "overageLabel": "R$4,00/transm. excedente"}'::jsonb, NULL, NULL, '{"price": 1800, "name": "12 meses", "contrato": "12 meses"}'::jsonb, 3, NOW() - INTERVAL '18 days'),
('ld03', 'PAT2025', 'Tatiane Rodrigues', 'tatiane@cosmeticospremium.com', '(41)99532-8801', 'Cosmeticos Premium', '650', '300-400', 'assessoria', 'Assessoria Marketplace', '6 meses 2 contas', 2200, 1000, 'proposta', 'quente', 't3', '[{"at":"2026-06-12T12:00:00Z","text":"Proposta enviada por e-mail."},{"at":"2026-06-17T12:00:00Z","text":"Cobra retorno ate sexta."}]'::jsonb, NULL, NULL, NULL, '{"price": 2200, "name": "6 meses", "contrato": "6 meses"}'::jsonb, NULL, 2, NOW() - INTERVAL '12 days'),
('ld04', NULL, 'Bruno Mendonca', 'bruno@superferragens.com.br', '(31)99401-7722', 'Super Ferragens', '5400', '100-200', 'ambos', 'Pacote Operacao', 'Plano Pro SAC Completo', 23500, 2000, 'fechado', 'quente', 't2', '[{"at":"2026-04-23T12:00:00Z","text":"Contrato assinado por 12 meses."}]'::jsonb, '{"chatPos": {"volume": 250, "selected": true}, "preVendas": {"volume": 500, "selected": true}}'::jsonb, '{"price": 20000, "label": "Ate 5.000 transm./mes", "overageLabel": "R$4,00/transm. excedente"}'::jsonb, NULL, NULL, NULL, 2, NOW() - INTERVAL '62 days'),
('ld05', NULL, 'Amanda Silveira', 'amanda@petshoplux.com', '(48)98800-4411', 'Pet Shop Lux', '920', '200-300', 'sac', 'SAC Operacional', 'Pre-vendas Chat Pos-vendas', 2500, 1000, 'contatado', 'morno', 't1', '[{"at":"2026-06-17T12:00:00Z","text":"Primeiro contato WA. Interesse no SAC."}]'::jsonb, '{"chatPos": {"volume": 180, "selected": true}, "preVendas": {"volume": 420, "selected": true}}'::jsonb, NULL, NULL, NULL, NULL, 2, NOW() - INTERVAL '7 days'),
('ld06', 'RAF2025', 'Rodrigo Pinheiro', 'rodrigo@calcadosvip.com.br', '(85)99900-2233', 'Calcados VIP', '2700', '200-300', 'pontual', 'Catalogacao Pontual', '2.000 transm. padrao', 10000, 0, 'fechado', 'morno', 't3', '[{"at":"2026-05-04T12:00:00Z","text":"Pedido confirmado. Entrega em 1 mes."}]'::jsonb, NULL, NULL, '{"total": 10000, "mkpStd": 4, "tierStd": {"faixa": "Faixa 2 501 a 2.000"}, "tierKit": null, "valorStd": 10000, "valorKit": 0, "anunciosStd": 500, "anunciosKit": 0, "totalTransm": 2000, "mesesEntrega": 1, "transmStd": 2000, "transmKit": 0}'::jsonb, NULL, NULL, 2, NOW() - INTERVAL '50 days')
ON CONFLICT (id) DO NOTHING;
