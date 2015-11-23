/*Check and backup system database*/
Declare @FileName nvarchar(512)
RaisError (N'#gs{TASK_SCRIPT_TITLE_CHECK_AND_BACKUP_SYSTEMDB}#', 0,1) WITH NOWAIT

-- MASTER
RaisError (N'#gs{TASK_SCRIPT_CHECKDB}# master', 0,1) WITH NOWAIT
DBCC CHECKDB ('master') WITH NO_INFOMSGS
if @@ERROR <> 0 Return

Print N'#gs{TASK_SCRIPT_CREATE_FULL_BACKUP_MESSAGE}# master'

Set @FileName = N'?MasterBackupFileName?'

Backup Database [master] TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = N'#gs{TASK_SCRIPT_FULL_BACKUP_DESCRIPTION_0}# master' , SKIP, NOREWIND, NOUNLOAD,  STATS = 10
If @@ERROR <> 0 Return
Print N' #gs{TASK_SCRIPT_BAK_WRITE_TO_FILE}# ' + @FileName

-- MSDB
RaisError (N'#gs{TASK_SCRIPT_CHECKDB}# msdb', 0,1) WITH NOWAIT
DBCC CHECKDB ('master') WITH NO_INFOMSGS
if @@ERROR <> 0 Return

Print N'#gs{TASK_SCRIPT_CREATE_FULL_BACKUP_MESSAGE}# msdb'

Set @FileName = N'?MsdbBackupFileName?'

Backup Database [master] TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = N'#gs{TASK_SCRIPT_FULL_BACKUP_DESCRIPTION_0}# msdb' , SKIP, NOREWIND, NOUNLOAD,  STATS = 10
If @@ERROR <> 0 Return
Print N' #gs{TASK_SCRIPT_BAK_WRITE_TO_FILE}# ' + @FileName

-- MODEL

RaisError (N'#gs{TASK_SCRIPT_CHECKDB}# model', 0,1) WITH NOWAIT
DBCC CHECKDB ('master') WITH NO_INFOMSGS
if @@ERROR <> 0 Return

Print N'#gs{TASK_SCRIPT_CREATE_FULL_BACKUP_MESSAGE}# model'

Set @FileName = N'?ModelBackupFileName?'

Backup Database [master] TO  DISK = @FileName WITH NOFORMAT, NOINIT,  NAME = N'#gs{TASK_SCRIPT_FULL_BACKUP_DESCRIPTION_0}# model' , SKIP, NOREWIND, NOUNLOAD,  STATS = 10
If @@ERROR <> 0 Return
Print N' #gs{TASK_SCRIPT_BAK_WRITE_TO_FILE}# ' + @FileName
Print N''
