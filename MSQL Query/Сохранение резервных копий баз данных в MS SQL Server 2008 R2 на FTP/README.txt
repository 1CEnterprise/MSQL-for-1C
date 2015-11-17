В *.bat указываем настройкип одключения к ftp Например:
set ftp_host=ftp.softservice.by
set ftp_username=Zarpl
set ftp_pass=******

При использовании в названии путей каталога ИБ кирилицы необходимо дополнительно еще добавить в *.bat строку:
echo off
chcp 1251 