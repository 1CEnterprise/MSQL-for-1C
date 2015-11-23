/* Set Full recovery mode*/

Print N'#gs{TASK_SCRIPT_SET_FULL_RECOVERY_MODE}#' 
USE [master]
ALTER DATABASE [?DataBaseName?] SET RECOVERY FULL WITH NO_WAIT
Print N''