/* Rebuilding database indexes */

USE [?DataBaseName?]
Declare @version nvarchar(12)
RaisError (N'#gs{TASK_SCRIPT_TITLE_REBUILD_DATABASE_INDEX}#',0,1) WITH NOWAIT

Set @version = Convert (nvarchar, SERVERPROPERTY('productversion'));
Select @version = SUBSTRING (@version,0 , CHARINDEX(N'.', @version) )

If @version = '8'  exec sp_msforeachtable N'DBCC DBREINDEX (''?'') WITH NO_INFOMSGS'
else Exec sp_MSForEachtable N'SET QUOTED_IDENTIFIER ON; ALTER INDEX ALL ON ? REBUILD'