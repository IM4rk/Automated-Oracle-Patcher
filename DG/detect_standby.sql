connect / as sysdba
set linesize 200
col instance_name for a20
col separator for a5
set heading off

spool /oracle/APO/DG/dg_list.log append;


select instance_name || ':TING:Y' from
(select instance_name from v$instance) t1
,(select ':'  separator from dual) t2
,(select database_role from v$database where database_role like '%STANDBY%' ) t3



/

spool off
exit;


