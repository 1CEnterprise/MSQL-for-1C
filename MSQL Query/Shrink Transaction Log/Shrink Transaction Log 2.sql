USE [Database] 
BACKUP LOG [Database]  TO DISK='NUL:'  
go
DBCC SHRINKFILE ([Database]_log, 1)
go