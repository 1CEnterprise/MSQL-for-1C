/*Deleting old backups*/

Set NoCount ON
Use [master]
Declare @DelDate Datetime, @DateLastModified Datetime,
		@Path nvarchar(500), @FName nvarchar(300), @FullName nvarchar (1000),
		@Cmd nvarchar(500), @Msg nvarchar(4000),  
		@StrMsg nvarchar (3000), @result Int, @IsError Int, @CountFiles int


Set @DelDate = CAST(N'?SaveBackupDate?' AS DATETIME)
Set @Path = N'?BackupDirectory?'
If Right (@Path, 1) <> '\' Set @Path = @Path + '\'

RaisError ('#gs{TASK_SCRIPT_DELETE_OLDER_BACKUPS}#', 0,1) WITH NOWAIT


Set @IsError = 0
Set DateFormat MDY

Set @Msg = N'#gs{TASK_SCRIPT_GET_BACKUP_FILES_IN_FOLDER}# ' + @Path
RaisError (@Msg, 0,1) WITH NOWAIT


If OBJECT_ID('tempdb..#smFileInfo') IS NOT NULL Drop Table #smFileInfo
Create table #smFileInfo (
		[FileName] nvarchar(200), 
		[DateLastModified] datetime,
		[Size] bigint,
		[Compressed] tinyint,
		[FirstDatabaseName] nvarchar(128),
		[FirstBackupStartDate] datetime,
		[FirstBackupType] smallint,
		[LastBackupStartDate] datetime,
		[ErrDescription] nvarchar (200))

Exec master..qmb_GetBakFilesInfo @Path, 0,0
if @@ERROR <> 0 
Begin
	RaisError (N'#gs{TASK_SCRIPT_COMPLETED_WITH_ERRORS}#', 16,1)
	return
End

Select @CountFiles =  Count(1) From #smFileInfo

Set @Msg = N'#gs{TASK_SCRIPT_IN_FOLDER}# ' + CONVERT(nvarchar, @CountFiles) + N' #gs{TASK_SCRIPT_MESSAGE_BEFORE_DEL_BACKUP}# ' + Convert (nvarchar(255), @DelDate, 13)
RaisError (@Msg, 0,1) WITH NOWAIT
RaisError (N'-------------------------------------------------------------------', 0,1) WITH NOWAIT

If @CountFiles = 0 Goto NoFiles

Set @CountFiles = 0

If OBJECT_ID('tempdb..#qmbDeleteResul') IS NOT NULL Drop Table #qmbDeleteResul
Create table #qmbDeleteResult ([ResultCode] int, [ResultString] nvarchar(255))

Declare curDir Cursor READ_ONLY LOCAL FOR Select [FileName], [DateLastModified] From #smFileInfo Where [DateLastModified] < @DelDate Order By [FileName] 

Open curDir

FETCH NEXT FROM curDir INTO @Fname, @DateLastModified
While (@@fetch_status = 0)
	Begin		
		Set @Msg = N'#gs{TASK_SCRIPT_FILE_DEL}# ' + @FName + N'; #gs{TASK_SCRIPT_LAST_BACKUP_OF}# ' +  Convert (nvarchar(255), @DateLastModified,13)
		RaisError (@Msg, 0,1) WITH NOWAIT
		Set @FullName = @Path + @FName

		Insert Into #qmbDeleteResult exec master..xp_Qmb 32972997, @FullName
		Select @result = ResultCode, @Msg = ResultString from #qmbDeleteResult 

		IF @result <> 0 
		   Begin
		    Set @IsError = 1
		    Set @Msg = N'#gs{TASK_SCRIPT_ERROR_DELETING_FILE}#:' + @Msg
			RaisError(@Msg, 16, 1)
		   End
		Else Set @CountFiles = @CountFiles + 1

		FETCH NEXT FROM curDir INTO @Fname, @DateLastModified
	End
Drop Table #smFileInfo

Close curDir
Deallocate curDir

NoFiles:

RaisError (N'-------------------------------------------------------------------', 0,1) WITH NOWAIT
Set @Msg = N'#gs{TASK_SCRIPT_DELETED}# ' + CONVERT(nvarchar, @CountFiles) + N' #gs{TASK_SCRIPT_FILES}#'
RaisError (@Msg, 0,1) WITH NOWAIT

If OBJECT_ID('tempdb..#smFileInfo') IS NOT NULL Drop Table #smFileInfo
If OBJECT_ID('tempdb..#qmbDeleteResult') IS NOT NULL Drop Table #qmbDeleteResult

If (@IsError <> 0)  RaisError (N'#gs{TASK_SCRIPT_COMPLETED_WITH_ERRORS}#', 16,1)