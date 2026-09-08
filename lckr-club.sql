-- CRIAÇÃO DA TABELA ORGANIZATION
-- Tabela para as informações importantes da empresa
create table organization(
	cnpj varchar(14) primary key,
	razao_social varchar(50) not null,
	nome varchar(50) not null,
	email varchar(50) not null,
	endereco varchar(100) not null
);

-- CRIAÇÃO DA TABELA USERS
-- Tabela para informações gerais dos usuários
create table users(
	id uuid primary key default gen_random_uuid(),
	nome varchar(50) not null,
	email varchar(50) not null,
	senha varchar(50) not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	organization_cnpj varchar(14) not null,
	foreign key (organization_cnpj) references organization(cnpj)
);

-- CRIAÇÃO DO TIPO UTILIZADO PARA STATUS DE PAYMENT
create type status_pagamento as enum('pendente', 'pago', 'cancelado', 'atrasado');

-- CRIAÇÃO DA TABELA PAYMENTS
-- Tabela para controle e histórico dos pagamentos
create table payments(
	id uuid primary key default gen_random_uuid(),
	valor decimal(5,2) not null,
	data_pagamento date not null,
	status status_pagamento not null default 'pendente',
	mes_referencia varchar(10) not null,
	descricao varchar(50) not null,
	pago_em date not null,
	organization_cnpj varchar(14) not null,
	foreign key (organization_cnpj) references organization(cnpj)
);

-- CRIAÇÃO DO TIPO UTILIZADO PARA STATUS DOS COACHES
create type status_coaches as enum('ativo', 'inativo');

-- CRIAÇÃO DA TABELA COACHES
-- Tabela para cadastro e gerenciamento dos coaches
create table coaches(
	cpf varchar(11) primary key not null,
	nome varchar(50) not null,
	email varchar(50) not null,
	senha varchar(50) not null,
	telefone varchar(11) not null,
	data_admissao date not null,
	especialidade varchar(50) not null,
	status status_coaches not null default 'inativo',
	salario_atual decimal(6,2) not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	organization_cnpj varchar(14) not null,
	foreign key (organization_cnpj) references organization(cnpj)
);

-- CRIAÇÃO DO TIPO UTILIZADO PARA STATUS DAS LESSONS
create type status_lessons as enum('agendada', 'realizada');

-- CRIAÇÃO DA TABELA LESSONS
-- Tabela para gerenciamento das aulas
create table lessons(
	id uuid primary key default gen_random_uuid(),
	data_aula date not null,
	hora_inicio time not null,
	hora_fim time not null,
	capacidade int not null,
	status status_lessons not null default 'agendada',
	descricao varchar(50) not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	coach_cpf varchar(11) not null,
	foreign key (coach_cpf) references coaches(cpf)
);

-- CRIAÇÃO DA TABELA COACH_SALARY_HISTORY
-- Tabela para registrar o histórico de salário
-- dos coaches ao longo do tempo
create table coach_salary_history(
	id uuid primary key default gen_random_uuid(),
	coach_cpf varchar(11) not null,
	salario decimal(6,2) not null,
	data_inicio date not null,
	data_fim date,
	motivo varchar(100),
	data_pagamento date,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	foreign key (coach_cpf) references coaches(cpf)
);
