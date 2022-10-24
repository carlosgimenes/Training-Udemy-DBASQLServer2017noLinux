/*

    1. Habilitar o DB Mail
    2. Criar uma conta nova
    3. Criar um perfil padrão
    4. Adicionar a conta de email de banco de dados a um perfil do Database Mail
    5. Adicionar conta ao perfil
    6. Enviar email de teste
    7. Definir o perfil de email do banco de dados usando a variável de ambiente ou mssql conf
    8. Configurar um operador para notificações de SQLAgent
    9. Enviar email quando 'Trabalho de teste do agente' concluído com êxito
    Próximas etapas
*/

--1. Habilitar o DB Mail
USE master 
GO 
sp_configure 'show advanced options',1 
GO 
RECONFIGURE WITH OVERRIDE 
GO 
sp_configure 'Database Mail XPs', 1 
GO 
RECONFIGURE  
GO  
--2. Criar uma conta nova
EXECUTE msdb.dbo.sysmail_add_account_sp 
@account_name = 'envia', 
@description = 'Conta para envia de notificações', 
@email_address = 'envia@itforest.com.br', --trocar por seu email
@replyto_address = 'envia@itforest.com.br', -- trocar por seu email
@display_name = 'SQL Agent', 
@mailserver_name = 'mail.itforest.com.br', --trocar pelo seu mail server
@port = 587, --altera porta se necessario
@enable_ssl = 0, --habilitar para 1 se necessario =ligado
@username = 'seuemail@teste.com.br',  --alterar para seu usuario de e-mail
@password = 'sua_senha'   --alterar para sua senha
GO

--3. Criar um perfil padrão
EXECUTE msdb.dbo.sysmail_add_profile_sp 
@profile_name = 'default', 
@description = 'Perfil  para envia de notificações' 
GO

--4. Adicionar a conta de email de banco de dados a um perfil do Database Mail
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp 
@profile_name = 'default', 
@principal_name = 'public', 
@is_default = 1 ; 

--5. Adicionar conta ao perfil

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp   
@profile_name = 'default',   
@account_name = 'envia',   
@sequence_number = 1;  

--6. Enviar email de teste

EXECUTE msdb.dbo.sp_send_dbmail 
@profile_name = 'default', 
@recipients = 'seuemail@teste.com.br', 
@Subject = 'Teste de Notificação  DBA', 
@Body = 'Este mensagem é um teste' 
GO



--SHELL LINUX
--7. Definir o perfil de email do banco de dados usando a variável de ambiente ou mssql conf
-- via mssql-conf
sudo /opt/mssql/bin/mssql-conf set sqlagent.databasemailprofile default
-- via environment variable
MSSQL_AGENT_EMAIL_PROFILE=default
--verificando
--verifica mssql mssql.conf
sudo cat /var/opt/mssql/mssql.conf

--8. Configurar um operador para notificações de SQLAgent

EXEC msdb.dbo.sp_add_operator 
@name=N'enviajob',  
@enabled=1, 
@email_address=N'envia@itforest.com.br',  
@category_name=N'[Uncategorized]' 
GO 

--9. Enviar email quando 'Trabalho de teste do agente' concluído com êxito
--Criar job com update statistics
--exemplo do job 'Agent teste'
USE curso;  
GO  
EXEC sp_updatestats; 

--Adicionar E-mail para envia quando executado
EXEC msdb.dbo.sp_update_job 
@job_name='Agent teste', 
@notify_level_email=1, 
@notify_email_operator_name=N'enviajob' 
GO

  

--verificações
use msdb
select * ,sent_status from sysmail_allitems 
--excluindo emails com falhas
EXECUTE msdb.dbo.sysmail_delete_mailitems_sp   
    @sent_status = 'sent' ;  
GO  