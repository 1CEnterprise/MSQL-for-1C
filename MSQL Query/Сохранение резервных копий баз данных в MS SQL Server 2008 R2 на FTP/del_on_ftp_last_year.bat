rem www.tavalik.ru
rem ***** УДАЛЕНИЕ ФАЙЛОВ КОПИЙ SQL ГОДИЧНОЙ ДАВНОСТИ С FTP
rem ***** Параметры: <имя_базы_данных_sql> <каталог_на_ftp>
rem 	Скрипт удаляет файл резервной копии SQL с именем формата <имя_базы_данных_sql>_backup_2013_06_27.bak
rem 	из директории <каталог_на_ftp> на FTP-сервере с сегодняшним днем прошлого года, 
rem 	формата <имя_базы_данных_sql>_backup_2012_06_27.bak,
rem 	причем в случае высокосного года удаляется и файл от 29 февраля.

rem ***** Отключаем вывод на экран *****
echo off

rem ***** Запишем все значения переменных *****
set ftp_host=
set ftp_username=
set ftp_pass=
set file_transport=transport.txt
set base_name=%1
set dir_name=%2

rem ***** Вычислим параметры прошлой даты *****
set /a year=%date:~6%-1
set /a is_leap=%year% %% 4
set month=%date:~3,-5%
set day=%date:~0,-8%

rem ***** Если высокосный год сейчас, то удалять ничего не нужно *****
if %month%==02 if %day%==29 GOTO EXIT_FILE

rem ***** Создаем файл с командами ftp ***** 
echo open %ftp_host%>%file_transport%
echo user %ftp_username% %ftp_pass%>>%file_transport%
echo cd %dir_name%>>%file_transport%

rem ***** Если высокосный год прошлый, то удалим и копию от 29 февраля *****
if %month%==02 if %day%==28 if %is_leap%==0 echo delete "%base_name%_backup_%year%_02_29.bak">>%file_transport%

rem ****** Удаляем файл от сегодняшнего числа прошлого года *****
echo delete "%base_name%_backup_%year%_%month%_%day%.bak">>%file_transport%

rem ***** Допишем завершение сеанса ftp в файл *****
echo bye>>%file_transport%

rem ***** Запускаем на исполнение *****
ftp -v -n -s:%file_transport%

rem ***** Удаляем файл с командами ftp *****
del %file_transport%

:EXIT_FILE 
