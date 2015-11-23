/* Selective update statistics on tables containing the changes
    since the statistics were last updated*/
Set Nocount ON


Print N'#gs{TASK_SCRIPT_TITLE_SELECTIVE_STATISTICS_UPDATE}#' 

Declare @Command0 nvarchar (2500)

Set @Command0 = '
Use [?DataBaseName?]
Declare @cmd varchar(2000), @rowcnt nvarchar(20), @rowmodctr nvarchar(20)'

Declare @verstr nvarchar(12), @version int

Set @verstr = Convert (nvarchar, SERVERPROPERTY('productversion'))
Set @version = SUBSTRING (@verstr, 0 , CHARINDEX(N'.', @verstr))

if @version > 8
Begin
-- sql 2005 and higher
Set @Command0 = @Command0 + '
Declare curs cursor local fast_forward for
Select   ''update statistics '' + quotename(schema_name(so.schema_id), ''['') + N''.'' + quotename(so.name, ''['') + N'' '' + quotename(si.name, ''[''), CAST (si.rowcnt as nvarchar), CAST (si.rowmodctr as nvarchar)
From sys.sysindexes as si  
LEFT Join sys.objects as so on si.id = so.object_id
Where  si.rowmodctr >  0 And si.rowcnt > 0 
and si.id > 1000
and indid between 1 and 254
Order By rowcnt Desc'
End

Else

Begin
-- sql 2000
Set @Command0 = @Command0 + '
Declare curs cursor local fast_forward for 
Select ''update statistics [''+object_name(id)+''] (''+name+'')'', CAST (rowcnt as nvarchar), CAST (rowmodctr as nvarchar)
From sysindexes
Where rowmodctr >  0 And rowcnt > 0
and id > 1000
and indid between 1 and 254 
Order By rowcnt Desc'
End	

Set @Command0 = @Command0 + '
Open curs
While 1=1
	Begin
		fetch next from curs into @cmd, @rowcnt, @rowmodctr
		If @@fetch_status <> 0 Break
		RaisError(''#gs{TASK_SCRIPT_FOUND_UPDATE_RECORD}#'', 10, 1, @cmd, @rowmodctr, @rowcnt) WITH NOWAIT
		Exec(@cmd)
	End'


EXECUTE sp_executesql @statement = @Command0