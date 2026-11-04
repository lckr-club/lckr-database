-- Definição dos tipos

CREATE TYPE status_coaches AS ENUM ('ativo', 'inativo');
CREATE TYPE status_pagamento AS ENUM ('pendente', 'pago', 'cancelado', 'atrasado');
CREATE TYPE status_lessons AS ENUM ('agendada', 'realizada');
CREATE TYPE status_periodo AS ENUM ('aberto', 'fechado');

-- TABELAS

-- Tabela para as informações importantes da empresa
CREATE TABLE organization (
    cnpj VARCHAR(14) PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    endereco VARCHAR(255) NOT NULL
);

-- Tabela para informações gerais dos usuários
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    organization_cnpj VARCHAR(14) NOT NULL,
    
    CONSTRAINT fk_users_organization FOREIGN KEY (organization_cnpj) REFERENCES organization(cnpj) ON DELETE CASCADE
);

-- Tabela para cadastro e gerenciamento dos coaches
CREATE TABLE coaches (
    cpf VARCHAR(11) PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(15) NOT NULL,
    data_admissao DATE NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    status status_coaches NOT NULL DEFAULT 'inativo',
    salario_atual DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    organization_cnpj VARCHAR(14) NOT NULL,
    
    CONSTRAINT fk_coaches_organization FOREIGN KEY (organization_cnpj) REFERENCES organization(cnpj) ON DELETE CASCADE
);

-- Tabela para controle e histórico dos pagamentos
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    valor DECIMAL(10,2) NOT NULL,
    data_pagamento DATE NOT NULL,
    status status_pagamento NOT NULL DEFAULT 'pendente',
    mes_referencia VARCHAR(7) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    pago_em DATE,
    horas_totais DECIMAL(8,2) NOT NULL DEFAULT 0,
    cpf_coach VARCHAR(11) NOT NULL,
    organization_cnpj VARCHAR(14) NOT NULL,
    
    CONSTRAINT fk_payments_coach FOREIGN KEY (cpf_coach) REFERENCES coaches(cpf) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_organization FOREIGN KEY (organization_cnpj) REFERENCES organization(cnpj) ON DELETE CASCADE,
    CONSTRAINT ck_payments_pago CHECK (status <> 'pago' OR pago_em IS NOT NULL),
    CONSTRAINT ck_payments_valor CHECK (valor >= 0)
);

CREATE UNIQUE INDEX ux_payments_coach_mes_ativo ON payments (cpf_coach, mes_referencia) WHERE status <> 'cancelado';

-- Tabela para gerenciamento das aulas
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_aula DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    capacidade INT NOT NULL,
    status status_lessons NOT NULL DEFAULT 'agendada',
    modalidade VARCHAR(50) NOT NULL,
    descricao VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cpf_coach VARCHAR(11) NOT NULL,
    cpf_coach_previsto VARCHAR(11),
    
    CONSTRAINT fk_lessons_coach FOREIGN KEY (cpf_coach) REFERENCES coaches(cpf) ON DELETE RESTRICT,
    CONSTRAINT fk_lessons_coach_previsto FOREIGN KEY (cpf_coach_previsto) REFERENCES coaches(cpf) ON DELETE RESTRICT,
    CONSTRAINT ck_lessons_horario CHECK (hora_fim > hora_inicio),
    CONSTRAINT ck_lessons_previsto CHECK (cpf_coach_previsto IS NULL OR cpf_coach_previsto <> cpf_coach)
);

-- Tabela para registrar o histórico de salário dos coaches ao longo do tempo
CREATE TABLE coach_salary_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cpf_coach VARCHAR(11) NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    motivo VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT fk_salary_history_coach FOREIGN KEY (cpf_coach) REFERENCES coaches(cpf) ON DELETE CASCADE,
    CONSTRAINT ck_salary_history_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

CREATE UNIQUE INDEX ux_salary_history_aberto ON coach_salary_history (cpf_coach) WHERE data_fim IS NULL;

-- Tabela para os períodos da folha de pagamento
CREATE TABLE payroll_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mes_referencia VARCHAR(7) NOT NULL UNIQUE,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    status status_periodo NOT NULL DEFAULT 'aberto',
    data_fechamento TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    organization_cnpj VARCHAR(14) NOT NULL,
    
    CONSTRAINT fk_periods_organization FOREIGN KEY (organization_cnpj) REFERENCES organization(cnpj) ON DELETE CASCADE,
    CONSTRAINT ck_periods_mes CHECK (mes_referencia ~ '^[0-9]{4}-(0[1-9]|1[0-2])$'),
    CONSTRAINT ck_periods_datas CHECK (data_fim >= data_inicio),
    CONSTRAINT ck_periods_fechamento CHECK (status = 'aberto' OR data_fechamento IS NOT NULL)
);
