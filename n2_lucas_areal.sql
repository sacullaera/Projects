
--excluindo todas as tabelas caso elas existam para evitar conflito de duplicidade
drop table if exists auditoria;
drop table if exists ativos_vulnerabilidade;
drop table if exists vulnerabilidades;
drop table if exists ativos;
drop table if exists usuarios;
drop table if exists perfil_permissao;
drop table if exists permissoes;
drop table if exists perfil;


create table perfil (
	idperfil integer not null primary key autoincrement,
	tipo_perfil varchar (30) not null,
	status not null default 1 --permite que o perfil seja criado e mantido ativo, sendo necessário desativar no sistema.
);

create table permissoes (
	idpermissao integer not null primary key autoincrement,
	descricao_permissao varchar (30) not null
);

create table perfil_permissao (
	idperfil integer not null,
	idpermissao integer not NULL,
	foreign key (idperfil) references perfil(idperfil),
	foreign key (idpermissao) references permissoes(idpermissao)
);

create table usuarios (
	idusuario integer not null primary key autoincrement,
	nome_usuario varchar (50) not null,
	email_usuario varchar (50) not null,
	data_inclusao datetime not null,
	status not null default 0, --o usuário será registrado como 0 para ser inativo, sendo necessário ativar o usuário após seu cadastro
	idperfil integer not null,
	foreign key (idperfil) references perfil(idperfil)
);

create table ativos (
	idativo integer not null primary key autoincrement,
	hostname varchar (30) not null,
	endereco_ip varchar(39) not null,
	endereco_mac varchar (30) not null,
	sistemaoperacional varchar (25) not null,
	versao_so varchar (20) not null,
	proprietario varchar (30) not null,
	departamento varchar (20) not null,
	dt_aquisicao datetime not null,
	dt_manutencao datetime not null,
	criticidade varchar (20) not null,
	status not null default 0
);

create table vulnerabilidades (
	idvulnerabilidade integer not null primary key autoincrement,
	cve_id varchar(25) not null,
	cve_score real not null,
	classificacao_criticidade varchar (30) not null,
	descricao_cve text,
	dt_publicacao datetime not null,
	dt_remediacao datetime
);

create table ativos_vulnerabilidade (
	idativo integer not null,
	idvulnerabilidade integer not null,
	dt_remediacao date,
	foreign key (idativo) references ativos(idativo),
	foreign key (idvulnerabilidade) references vulnerabilidades(idvulnerabilidade)
);

-- Tabela auditoria para utilização das triggers
create table auditoria (
	idauditoria integer not null primary key autoincrement,
	idativo integer not null,
	hostname varchar (30) not null,
	hostname_antigo varchar (30),
	endereco_ip varchar (39) not null,
	endereco_ip_antigo varchar (39),
	endereco_mac varchar (30) not null,
	proprietario varchar (30) not null,
	proprietario_antigo varchar (30),
	departamento varchar (20) not null,
	departamento_antigo varchar (20),
	operacao varchar (7) not null,
	data datetime
);

--criando a trigger para exclusão e atualização dos ativos
drop trigger if exists trg_salva_exclusao;
create trigger trg_salva_exclusao
before delete on ativos
for each ROW
BEGIN
	insert into auditoria (idativo, hostname, endereco_ip, endereco_mac, proprietario, departamento, operacao, data)
	values (old.idativo, old.hostname, old.endereco_ip, old.endereco_mac, old.proprietario, old.departamento, 'DELETE', datetime());
END;

drop trigger if exists trg_salva_atualizacao;
create trigger trg_salva_atualizacao
after update on ativos
for each ROW
begin
	insert into auditoria (idativo, hostname, hostname_antigo, endereco_ip, endereco_ip_antigo, endereco_mac, proprietario, proprietario_antigo, departamento, departamento_antigo, operacao, data)
	values (old.idativo, new.hostname, old.hostname, new.endereco_ip, old.endereco_ip, old.endereco_mac, new.proprietario, old.proprietario, new.departamento, old.departamento, 'UPDATE', datetime());
end;

--criando a visualização das triggers
create view if not exists vw_trigger_update as
SELECT
		idauditoria,
		idativo,
		hostname,
		hostname_antigo,
		endereco_ip,
		endereco_ip_antigo,
		proprietario,
		proprietario_antigo,
		departamento,
		departamento_antigo,
		operacao,
		data
FROM auditoria
where operacao = 'UPDATE'
order by data desc;

create view if not exists vw_trigger_delete as
SELECT
	idauditoria,
	idativo,
	hostname,
	endereco_ip,
	proprietario,
	departamento,
	operacao,
	data
from auditoria
where operacao = 'DELETE'
order by data DESC;

-- criando a visualização das vulnerabilidades tratadas e não tradas para dashboard
create view if not exists vw_dashboard_vulnerabilidade as
select
	(select count(*) from ativos_vulnerabilidade where dt_remediacao is not null) as tratadas,
	(select count(*) from ativos_vulnerabilidade where dt_remediacao is null) as nao_tratadas;
	
--Populando as tabelas

-- Perfis
INSERT INTO perfil (tipo_perfil, status) 
VALUES
  ('Administrador', 1),
  ('Analista de Segurança', 1),
  ('Usuário Comum', 1);

-- Permissões
INSERT INTO permissoes (descricao_permissao) 
VALUES
  ('Cadastrar Ativo'),
  ('Editar Ativo'),
  ('Excluir Ativo'),
  ('Registrar Vulnerabilidade'),
  ('Gerar Relatório'),
  ('Visualizar Dashboard');

 -- relação de permissão x perfil
INSERT INTO perfil_permissao (idperfil, idpermissao)
SELECT 1, idpermissao FROM permissoes;  -- Admin tem todas

-- Analista: permissões limitadas
INSERT INTO perfil_permissao (idperfil, idpermissao) VALUES
  (2, 1), (2, 2), (2, 4), (2, 5), (2, 6);  -- Não pode excluir
 
-- Usuários
INSERT INTO usuarios (nome_usuario, email_usuario, data_inclusao, status, idperfil)
VALUES
  ('Adilson Admin', 'admin@empresa.com', datetime(), 1, 1),
  ('Lucas Areal', 'analista@empresa.com', datetime(), 1, 2);

-- Ativos de TI (dados realistas)
INSERT INTO ativos (hostname, endereco_ip, endereco_mac, sistemaoperacional, versao_so, proprietario, departamento, dt_aquisicao, dt_manutencao, criticidade, status)
VALUES
  ('SRV-WEB-01', '192.168.1.10', '00:1A:2B:3C:4D:5E', 'Ubuntu Linux', '22.04', 'TI', 'Infraestrutura', '2023-06-15', '2025-10-01', 'Alta', 1),
  ('PC-FIN-22', '192.168.1.22', 'A0:B1:C2:D3:E4:F5', 'Windows 10', '21H2', 'Maria Santos', 'Financeiro', '2022-11-20', '2025-09-10', 'Média', 1),
  ('SRV-DB-01', '192.168.1.30', '11:22:33:44:55:66', 'CentOS Linux', '7', 'TI', 'Infraestrutura', '2021-03-10', '2025-08-15', 'Crítica', 1),
  ('NB-DEV-05', '192.168.1.45', 'FF:EE:DD:CC:BB:AA', 'Windows 11', '23H2', 'João Ferreira', 'Desenvolvimento', '2024-01-30', '2025-11-01', 'Baixa', 1),
  ('NTB-SEC-02', '192.168.1.61', 'A2:B3:C4:D5:E6:F7', 'Windows 11', '23H1', 'Joana Dark', 'Secretaria', '2022-11-21', '2025-09-11', 'Média', 1);

-- Vulnerabilidades (CVEs reais e plausíveis)
INSERT INTO vulnerabilidades (cve_id, cve_score, classificacao_criticidade, descricao_cve, dt_publicacao) 
VALUES
  ('CVE-2024-12345', 9.8, 'Crítica', 'Buffer overflow no Apache HTTP Server 2.4.58', '2024-04-10'),
  ('CVE-2023-5678', 7.5, 'Alta', 'Falha de autenticação no OpenSSH', '2023-11-22'),
  ('CVE-2025-9876', 5.3, 'Média', 'XSS refletido no painel de administração', '2025-02-14'),
  ('CVE-2022-1111', 3.1, 'Baixa', 'Vazamento de informação em logs', '2022-08-05');
  

-- Formato: idativo, idvulnerabilidade, dt_remediacao (NULL = não tratada)

-- SRV-WEB-01 (id=1) tem 2 vulns: uma tratada, uma não
INSERT INTO ativos_vulnerabilidade (idativo, idvulnerabilidade, dt_remediacao) 
VALUES
  (1, 1, '2025-05-20'),  -- CVE-2024-12345 → tratada
  (1, 3, NULL);           -- CVE-2025-9876 → não tratada

-- PC-FIN-22 (id=2) tem 1 vuln não tratada
INSERT INTO ativos_vulnerabilidade (idativo, idvulnerabilidade, dt_remediacao) 
VALUES
  (2, 2, NULL);           -- CVE-2023-5678 → não tratada

-- SRV-DB-01 (id=3) tem 2 vulns: ambas não tratadas (crítico!)
INSERT INTO ativos_vulnerabilidade (idativo, idvulnerabilidade, dt_remediacao) 
VALUES
  (3, 1, NULL),           -- CVE-2024-12345
  (3, 2, NULL);           -- CVE-2023-5678

-- NB-DEV-05 (id=4) tem 1 vuln tratada
INSERT INTO ativos_vulnerabilidade (idativo, idvulnerabilidade, dt_remediacao) 
VALUES
  (4, 4, '2025-03-10');  -- CVE-2022-1111 → tratada


--atualizando um ativo para exemplificação da trigger de UPDATE
update ativos
set hostname = 'SRV-DD-01',
	endereco_ip = '192.168.1.55',
	proprietario = 'Paula',
	departamento = 'Financeiro'
where
	idativo = 1;

--deletando um ativo para exemplificação da trigger de DELETE
delete from ativos
where idativo = 5;

