/* Clear backup history*/

Declare @dt datetime 
Print N'#gs{TASK_SCRIPT_TITLE_CLEAR_BACKUP_HISTORY}#' 

Select @dt = cast(N'?SaveBackupDate?' as datetime)
Exec msdb.dbo.sp_delete_backuphistory @dt