select program_name,net_transport
from sys.dm_exec_sessions as t1
left join sys.dm_exec_connections AS t2 ON t1.session_id=t2.session_id
where not t1.program_name is null