/* Set Simple recovery mode*/

Print N'#gs{TASK_SCRIPT_SET_SIMPLE_RECOVERY_MODE}#' 
USE [master]
ALTER DATABASE [?DataBaseName?] SET RECOVERY SIMPLE WITH NO_WAIT
Print N''