/* Shring log file */

Print N'#gs{TASK_SCRIPT_TITLE_SHRINK_LOG}#' 

Use [?DataBaseName?]
Set Nocount ON
Declare @fileid int
Declare @dbsize1  dec(15,0)
Declare @dbsize2  dec(15,0)
Declare @pagesperMB dec(15,0)

Select @pagesperMB = 1048576.0/low from master.dbo.spt_values where number = 1 and type = 'E'
Select @fileid = fileid, @dbsize1 = convert(dec(15),size)/@pagesperMB  from  dbo.sysfiles Where groupid = 0
Print N'#gs{TASK_SCRIPT_LOG_SIZE_BEFORE_SHRINK}# '  + ltrim(str(@dbsize1,15,2)) +N' MB'
DBCC SHRINKFILE (@fileid, 0, TRUNCATEONLY)  WITH NO_INFOMSGS

Select @dbsize2 = convert(dec(15),size)/@pagesperMB  from  dbo.sysfiles Where groupid = 0
Print N'#gs{TASK_SCRIPT_LOG_SIZE_AFTER_SHRINK}# ' + ltrim(str(@dbsize2,15,2)) + N' MB, #gs{TASK_SCRIPT_SHRINK_RESIZING}# ' + ltrim(str(@dbsize1  - @dbsize2,15,2)) + N' MB'
Print N''
