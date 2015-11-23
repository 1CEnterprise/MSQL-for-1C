/*
IndexOptimize is the SQL Server Maintenance Solution’s stored procedure for rebuilding and reorganizing
indexes and updating statistics. IndexOptimize is supported on SQL Server 2005, SQL Server 2008, 
SQL Server 2008 R2, SQL Server 2012, and SQL Server 2014

(c) Ola Hallengren 
Full documentation https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html
*/

Use [master]

Declare @StrVer nvarchar(12), @ver int;
Set @StrVer = Convert (nvarchar, SERVERPROPERTY('productversion'));
Select @ver = Convert (int, SUBSTRING (@StrVer,0 , CHARINDEX(N'.', @StrVer)));
If @Ver < 9 
Begin
	RaisError ('#gs{TASK_OLA_INCORRECT_SQL_VERSION_WARNING}#', 16,1) WITH NOWAIT
	return
End

EXECUTE dbo.IndexOptimize
@Databases = '?DataBaseName?',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@UpdateStatistics = 'ALL',
@OnlyModifiedStatistics = 'Y'