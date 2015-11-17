rem www.tavalik.ru
rem ***** УДАЛЕНИЕ ФАЙЛОВ КОПИЙ SQL МЕСЯЧНОЙ ДАВНОСТИ С FTP
rem ***** Параметры: <имя_базы_данных_sql> <каталог_на_ftp>
rem 	Скрипт удаляет файл резервной копии SQL с именем формата <имя_базы_данных_sql>_backup_2013_06_27.bak
rem 	из директории <каталог_на_ftp> на FTP-сервере с сегодняшним днем прошлого месяца,
rem 	формата <имя_базы_данных_sql>_backup_2013_05_27.bak, 
rem 	причем если сегодня 30-ое число, то будет удален и файл от 31-ого числа прошлого месяца,
rem 	а тажке правильно обрабатывается февраль и высокосный год.

rem ***** Отключаем вывод на экран *****
echo off

rem ***** Запишем все значения переменных *****
set ftp_host=
set ftp_username=
set ftp_pass=
set file_transport=transport.txt
set base_name=%1
set dir_name=%2

rem ***** Вычислим параметры текущей даты *****
set year=%date:~6%
set month=%date:~3,-5%
set day=%date:~0,-8%

rem ***** Создаем файл с командами ftp ***** 
echo open %ftp_host%>%file_transport%
echo user %ftp_username% %ftp_pass%>>%file_transport%
echo cd %dir_name%>>%file_transport%

rem ****** В зависимости от месяца перейдем к нужной метке,
rem где будет выполнен связанный с этим месяцем набор команд *****
if %month%==01 GOTO January 
if %month%==02 GOTO February 
if %month%==03 GOTO March
if %month%==04 GOTO April
if %month%==05 GOTO May
if %month%==06 GOTO June
if %month%==07 GOTO July
if %month%==08 GOTO August
if %month%==09 GOTO September
if %month%==10 GOTO October
if %month%==11 GOTO November
if %month%==12 GOTO December

:January
set month=12
set /a year=%year%-1
GOTO DEL_TODAY

:February
set month=01
if %day%==28 GOTO DEL_DAY_29
if %day%==29 GOTO DEL_DAY_30
GOTO DEL_TODAY

:March
if %day%==31 GOTO EXIT_FILE
if %day%==30 GOTO EXIT_FILE
set /a is_leap=%year% %% 4
if %day%==29 if not %is_leap%==0 GOTO EXIT_FILE
set month=02
GOTO DEL_TODAY

:April
set month=03
if %day%==30 GOTO DEL_DAY_31
GOTO DEL_TODAY

:May
set month=04
if %day%==31 GOTO EXIT_FILE
GOTO DEL_TODAY

:June
set month=05
if %day%==30 GOTO DEL_DAY_31
GOTO DEL_TODAY

:July
set month=06
if %day%==31 GOTO EXIT_FILE
GOTO DEL_TODAY

:August
set month=07
GOTO DEL_TODAY

:September
set month=08
if %day%==30 GOTO DEL_DAY_31
GOTO DEL_TODAY

:October
set month=09
if %day%==31 GOTO EXIT_FILE
GOTO DEL_TODAY

:November
set month=10
if %day%==30 GOTO DEL_DAY_31
GOTO DEL_TODAY

:December
set month=11
if %day%==31 GOTO EXIT_FILE
GOTO DEL_TODAY

rem ****** Удаляем файл от 29-ого числа прошлого месяца *****
:DEL_DAY_29
echo delete "%base_name%_backup_%year%_%month%_29.bak">>%file_transport%

rem ****** Удаляем файл от 30-ого числа прошлого месяца *****
:DEL_DAY_30
echo delete "%base_name%_backup_%year%_%month%_30.bak">>%file_transport%

rem ****** Удаляем файл от 31-ого числа прошлого месяца *****
:DEL_DAY_31
echo delete "%base_name%_backup_%year%_%month%_31.bak">>%file_transport%

rem ****** Удаляем файл от сегодняшнего числа прошлого месяца *****
:DEL_TODAY
echo delete "%base_name%_backup_%year%_%month%_%day%.bak">>%file_transport%

rem ***** Допишем завершение сеанса ftp в файл *****
echo bye>>%file_transport%

rem ***** Запускаем на исполнение *****
ftp -v -n -s:%file_transport%

rem ***** Удаляем файл с командами ftp *****
:EXIT_FILE 
del %file_transport%
