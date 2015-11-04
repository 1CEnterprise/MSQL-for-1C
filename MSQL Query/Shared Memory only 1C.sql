SELECT PROGRAM_NAME, net_transport
FROM sys.dm_exec_sessions AS T1
LEFT JOIN sys.dm_exec_connections AS T2
ON T1.session_id=T2.session_id
WHERE T1.program_name LIKE '1CV8%'