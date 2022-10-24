/*
-------------------------------------------------------------------------------------------------------------------------
Executar as seguintes instruções no Primário para configurar o Envio de Logs
para o banco de dados [192.168.0.138].[homolog]
O script precisa ser executado no Primário, no contexto do banco de dados [msdb]
-------------------------------------------------------------------------------------------------------------------------
*/

DECLARE @LS_BackupJobId		AS uniqueidentifier
DECLARE @LS_PrimaryId		AS uniqueidentifier
DECLARE @SP_Add_RetCode		As int

EXEC @SP_Add_RetCode = master.dbo.sp_add_log_shipping_primary_database
		@database = N'homolog'
		,@backup_directory = N'/datafiles/tlogs'
		,@backup_share = N'/datafiles/tlogs'
		,@backup_job_name = N'LSBackup_homolog'
		,@backup_retention_period = 4320
		,@backup_compression = 2
		,@backup_threshold = 60
		,@threshold_alert_enabled = 1
		,@history_retention_period = 5760
		,@backup_job_id = @LS_BackupJobId OUTPUT
		,@primary_id = @LS_PrimaryId OUTPUT
		,@overwrite = 1


IF (@@ERROR = 0 AND @SP_Add_RetCode = 0)
BEGIN

DECLARE @LS_BackUpScheduleUID	As uniqueidentifier
DECLARE @LS_BackUpScheduleID	AS int

EXEC msdb.dbo.sp_add_schedule
		@schedule_name =N'LSBackupSchedule'
		,@enabled = 1
		,@freq_type = 4
		,@freq_interval = 1
		,@freq_subday_type = 4
		,@freq_subday_interval = 15
		,@freq_recurrence_factor = 0
		,@active_start_date = 20181017
		,@active_end_date = 99991231
		,@active_start_time = 0
		,@active_end_time = 235900
		,@schedule_uid = @LS_BackUpScheduleUID OUTPUT
		,@schedule_id = @LS_BackUpScheduleID OUTPUT

EXEC msdb.dbo.sp_attach_schedule
		@job_id = @LS_BackupJobId
		,@schedule_id = @LS_BackUpScheduleID

EXEC msdb.dbo.sp_update_job
		@job_id = @LS_BackupJobId
		,@enabled = 1

END

EXEC master.dbo.sp_add_log_shipping_alert_job

EXEC master.dbo.sp_add_log_shipping_primary_secondary
		@primary_database = N'homolog'
		,@secondary_server = N'192.168.0.139'
		,@secondary_database = N'homolog'
		,@overwrite = 1


/*

Fim do arquivo


*/