/* Create a differential backup */

Declare @FileName nvarchar(255)
Declare @BaseName nvarchar(128)
Declare @Name nvarchar (128)
Declare @Verify nchar

Set @Verify = '?VerifyBackup?'

Print N'#gs{TASK_SCRIPT_TITLE_CREATE_DIFF_BACKUP}#' 

Set @BaseName = N'?DataBaseName?';
Set @FileName = N'?DiffBackupFileName?';

Set @Name =  N'#gs{TASK_SCRIPT_DIFF_BACKUP_DESCRIPTION}#'
BACKUP DATABASE @BaseName TO  DISK = @FileName WITH  DIFFERENTIAL , NOFORMAT, NOINIT,  NAME = @Name, SKIP, NOREWIND, NOUNLOAD,  STATS = 10
If @@ERROR <> 0 Return
Print N' #gs{TASK_SCRIPT_BAK_WRITE_TO_FILE}# ' + @FileName
Print N'' 

If @@ERROR = 0 AND @Verify = 'Y'
Begin
   Declare @backupSetId as int
   Print N''
   Print N'#gs{VERIFY_BACKUP}#: ?DiffBackupFileName?'
   Select @backupSetId = position from msdb..backupset where database_name = @BaseName and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name = @BaseName )
   If @backupSetId is null begin raiserror(N'#gs{TASK_SCRIPT_VERIFY_BACKUP_FAIL_MEGGASE}#', 16, 1) end
   Restore VERIFYONLY FROM DISK = @FileName WITH FILE = @backupSetId, NOUNLOAD, NOREWIND, STATS =10
End