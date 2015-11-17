rem www.tavalik.ru
rem ***** КОПИРОВАНИЕ ФАЙЛОВ КОПИЙ SQL НА FTP
rem ***** Параметры: <имя_базы_данных_sql> <каталог_на_локальном_компьютере> <каталог_на_ftp>
rem 	Скрипт копирует файл с имененем формата <имя_базы_данных_sql>_backup_2013_06_27_030007_1733203.bak
rem 	из директории <каталог_на_локальном_компьютере>, сохраняя его на FTP-сервере
rem 	в директории <каталог_на_ftp> под именем формата <имя_базы_данных_sql>_backup_2013_06_27.bak

rem ***** Отключаем вывод на экран *****
echo off

rem ***** Запишем все значения переменных *****
set ftp_host=
set ftp_username=
set ftp_pass=
set file_transport=transport.txt
set base_name=%1
set dir_from=%2
set dir_to=%3

rem ***** Вычислим параметры текущей даты и имена файлов *****
set year=%date:~6%
set month=%date:~3,-5%
set day=%date:~0,-8%
set file_name="%base_name%_backup_%year%_%month%_%day%_*.bak"
set file_name_on_ftp="%base_name%_backup_%year%_%month%_%day%.bak"

rem ***** Создаем файл с командами ftp ***** 
echo open %ftp_host%>%file_transport%
echo user %ftp_username% %ftp_pass%>>%file_transport%
echo cd %dir_to%>>%file_transport%
echo lcd %dir_from%>>%file_transport%
echo put %file_name% %file_name_on_ftp%>>%file_transport%
echo bye>>%file_transport%

rem ***** Запускаем на исполнение *****
ftp -v -n -s:%file_transport%

rem ***** Удаляем файл с командами ftp *****
del %file_transport%
