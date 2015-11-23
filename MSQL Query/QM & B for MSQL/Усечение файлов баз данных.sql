/* Shrink database */
USE [?DataBaseName?]
Declare @dbsize1  dec(15,0)
Declare @dbsize2  dec(15,0)
Declare @pagesperMB dec(15,0)

Print N'#gs{TASK_SCRIPT_TITLE_SHRINK_DATABASE_FILE}#' 

-- Get size database
DBCC UPDATEUSAGE (0) WITH NO_INFOMSGS;
Select @pagesperMB = 1048576.0/low from master.dbo.spt_values where number = 1 and type = 'E'
Select @dbsize1 = sum(convert(dec(15),size)) / @pagesperMB from dbo.sysfiles 

Print N'#gs{TASK_SCRIPT_SIZE_BEFORE_SHRINK}# '  + ltrim(str(@dbsize1,15,2)) +N' MB'

DBCC SHRINKDATABASE(N'?DataBaseName?', 10, TRUNCATEONLY) WITH NO_INFOMSGS

Select @dbsize2 = sum(convert(dec(15),size)) / @pagesperMB from dbo.sysfiles 
Print N'#gs{TASK_SCRIPT_SIZE_AFTER_SHRINK}# ' + ltrim(str(@dbsize2,15,2)) + N' MB, #gs{TASK_SCRIPT_SHRINK_RESIZING}# ' + ltrim(str(@dbsize1  - @dbsize2,15,2)) + N' MB'
Print N''
