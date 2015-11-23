/* Backup log*/ 

Declare @FileName nvarchar(255)
Declare @BaseName nvarchar(128)
Declare @Name nvarchar (128)
Declare @Verify nchar

Set @Verify = '?VerifyBackup?'

Set @BaseName = N'?DataBaseName?';
Set @FileName = N'?LogBackupFileName?';

Print N'#gs{TASK_SCRIPT_TITLE_CREATE_LOGBAK}#' 
Set @Name =  N'Log backup database:' + @BaseName
BACKUP LOG @BaseName TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = @Name, SKIP, NOREWIND, NOUNLOAD,  STATS = 10
If @@ERROR <> 0 Return
Print N' #gs{TASK_SCRIPT_BAK_WRITE_TO_FILE}# ' + @FileName
Print N'' 

If @@ERROR = 0 AND @Verify ='Y'
Begin
   Declare @backupSetId as int
   Print N''
   Print N'#gs{VERIFY_BACKUP}#: ?LogBackupFileName?'
   Select @backupSetId = position from msdb..backupset where database_name = @BaseName and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name = @BaseName )
   If @backupSetId is null begin raiserror(N'#gs{TASK_SCRIPT_VERIFY_BACKUP_FAIL_MEGGASE}#', 16, 1) end
   Restore VERIFYONLY FROM DISK = @FileName WITH FILE = @backupSetId, NOUNLOAD, NOREWIND, STATS =10
End