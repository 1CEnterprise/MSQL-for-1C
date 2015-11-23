/*Update columns statistics*/
RaisError (N'#gs{TASK_SCRIPT_TITLE_COLUMNS_STATISTICS_UPDATE}#', 0,1) WITH NOWAIT
USE [?DataBaseName?]
EXEC sp_msforeachtable N'UPDATE STATISTICS ? WITH FULLSCAN, COLUMNS'