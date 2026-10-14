-- Definição dos tipos

CREATE TYPE status_coaches AS ENUM ('ativo', 'inativo');
CREATE TYPE status_pagamento AS ENUM ('pendente', 'pago', 'cancelado', 'atrasado');
CREATE TYPE status_lessons AS ENUM ('agendada', 'realizada');

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
    senha VARCHAR(255) NOT NULL,
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
    cpf_coach VARCHAR(11) NOT NULL,
    organization_cnpj VARCHAR(14) NOT NULL,
    
    CONSTRAINT fk_payments_coach FOREIGN KEY (cpf_coach) REFERENCES coaches(cpf) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_organization FOREIGN KEY (organization_cnpj) REFERENCES organization(cnpj) ON DELETE CASCADE
);

-- Tabela para gerenciamento das aulas
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_aula DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    capacidade INT NOT NULL,
    status status_lessons NOT NULL DEFAULT 'agendada',
    descricao VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cpf_coach VARCHAR(11) NOT NULL,
    
    CONSTRAINT fk_lessons_coach FOREIGN KEY (cpf_coach) REFERENCES coaches(cpf) ON DELETE RESTRICT
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
    
    CONSTRAINT fk_salary_history_coach FOREIGN KEY (cpf_coach) REFERENCES coaches(cpf) ON DELETE CASCADE
);
