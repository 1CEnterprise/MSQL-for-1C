/* Database Index Defrag 
   SQL 2000 - INDEXDEFRAG
   SQL 2005 and upper Defrag or Rebuild*/
Set NoCount ON

Use [?DataBaseName?]

Declare @command nvarchar(4000); 
Declare @version nvarchar(12);
Declare @objectid int;
Declare @indexid int;
Declare @frag decimal


Print N'#gs{TASK_SCRIPT_TITLE_INDEX_DEFRAG}#' 

Set @version = Convert (nvarchar, SERVERPROPERTY('productversion'));
Set @version = SUBSTRING (@version, 0 , CHARINDEX(N'.', @version))

if @version = N'8'  
Begin
	/* Database Index Defrag for SQL 2000
	Script taken http://msdn.microsoft.com/ru-ru/library/ms177571.aspx
	*/

	Declare @tablename nvarchar(128)
	Declare @maxfrag   DECIMAL
	
	Select @maxfrag = 30.0

	DECLARE tables CURSOR FOR
	   SELECT TABLE_NAME
	   FROM INFORMATION_SCHEMA.TABLES
	   WHERE TABLE_TYPE = 'BASE TABLE'

	CREATE TABLE #fraglist (
	   ObjectName CHAR (255),
	   ObjectId INT,
	   IndexName CHAR (255),
	   IndexId INT,
	   Lvl INT,
	   CountPages INT,
	   CountRows INT,
	   MinRecSize INT,
	   MaxRecSize INT,
	   AvgRecSize INT,
	   ForRecCount INT,
	   Extents INT,
	   ExtentSwitches INT,
	   AvgFreeBytes INT,
	   AvgPageDensity INT,
	   ScanDensity DECIMAL,
	   BestCount INT,
	   ActualCount INT,
	   LogicalFrag DECIMAL,
	   ExtentFrag DECIMAL)


	OPEN tables

	FETCH NEXT
	   FROM tables
	   INTO @tablename

	WHILE @@FETCH_STATUS = 0
	BEGIN
	   INSERT INTO #fraglist 
	   EXEC (N'DBCC SHOWCONTIG (N''' + @tablename + ''') WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS')
	   FETCH NEXT
		  FROM tables
		  INTO @tablename
	END

	CLOSE tables
	DEALLOCATE tables

	DECLARE indexes CURSOR FOR
	   SELECT ObjectName, ObjectId, IndexId, LogicalFrag
	   FROM #fraglist
	   WHERE LogicalFrag >= @maxfrag
		  AND INDEXPROPERTY (ObjectId, IndexName, 'IndexDepth') > 0

	OPEN indexes

	FETCH NEXT
	   FROM indexes
	   INTO @tablename, @objectid, @indexid, @frag

	WHILE @@FETCH_STATUS = 0
	BEGIN
	   PRINT N'Executing DBCC INDEXDEFRAG (0, N' + RTRIM(@tablename) + ', ' + RTRIM(@indexid) + ') - fragmentation currently ' + RTRIM(CONVERT(varchar(15),@frag)) + '%'
	   SELECT @command = N'DBCC INDEXDEFRAG (0, ' + RTRIM(@objectid) + ', ' + RTRIM(@indexid) + ') WITH NO_INFOMSGS'
	   EXEC (@command)

	   FETCH NEXT
		  FROM indexes
		  INTO @tablename, @objectid, @indexid, @frag
	END

	CLOSE indexes
	DEALLOCATE indexes

	DROP TABLE #fraglist

End

Else
	Begin
	/*===== Database Index Defrag for SQL 2005 and upper =====
	Script taken http://www.sql-server-performance.com/2012/performance-tuning-re-indexing-update-statistics/
	*/
	Declare @db_id int;
	Declare @partitioncount bigint;
	Declare @schemaname nvarchar(130); 
	Declare @objectname nvarchar(130); 
	Declare @indexname nvarchar(130); 
	Declare @partitionnum bigint;
	Declare @partitions bigint;
	
	Set @db_id = DB_ID(N'?DataBaseName?');

	Select
		object_id AS objectid,
		index_id AS indexid,
		partition_number AS partitionnum,
		avg_fragmentation_in_percent AS frag
	Into #work_to_do
	From sys.dm_db_index_physical_stats (@db_id, NULL, NULL , NULL, 'LIMITED')
	Where avg_fragmentation_in_percent > 10.0 AND index_id > 0;

	Declare partitions CURSOR FOR SELECT * FROM #work_to_do;

	Open partitions;

	While (1=1)
		Begin
			FETCH NEXT
			   From partitions
			   Into @objectid, @indexid, @partitionnum, @frag;
			If @@FETCH_STATUS < 0 Break;
        
			Select @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name)
			From sys.objects as o
			JOIN sys.schemas as s ON s.schema_id = o.schema_id
			Where o.object_id = @objectid;
        
			Select @indexname = QUOTENAME(name)
			From sys.indexes
			Where  object_id = @objectid AND index_id = @indexid;
        
			Select @partitioncount = count (*)
			From sys.partitions
			Where object_id = @objectid AND index_id = @indexid;

			IF @frag < 30.0 Set @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REORGANIZE';
			IF @frag >= 30.0 Set @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD';
			IF @partitioncount > 1 Set @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));
			Exec (@command);
			Print N'Executed: ' + @command;
		End;

	Close partitions;
	Deallocate partitions;

	Drop Table #work_to_do;
End

Print N''