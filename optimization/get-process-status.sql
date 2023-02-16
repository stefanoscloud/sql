--Get all SQL process status from a specific database
DECLARE @active BIT = 1
select *
from
(            select       sp1.spid,
                       sp1.blocked,
                       db_name(sp1.dbid) as DatabseName,
                        sp1.status,
                       sp1.hostname,
                       sp1.loginame,
                        --sp1.program_name,
                     --  CASE WHEN sp1.[program_name] LIKE '%SQLAgent - TSQL JobStep%' 
                        --            THEN substring(replace((replace(sp1.[program_name], '(Job 0x', '(0x')),'SQLAgent - TSQL JobStep (', ''),1,charindex(' ',replace((replace(sp1.[program_name], '(Job 0x', '(0x')),'SQLAgent - TSQL JobStep (', ''),1)-1) 
                        --            --substring(@jobID, 1, charindex(' ', @jobID, 1)-1)
                        --    ELSE sp1.[program_name] END 
                        --     AS [executing_Program_name] ,
                     --  sp1.cmd,
                       case when r.wait_type is null then sp1.lastwaittype else r.wait_type end as WaitType,
                       sp1.waitresource,
                       OSW.resource_description,
                       db_name(sp1.dbid) as dbname,
                       sp1.memusage,
                       (SU.internal_objects_alloc_page_count*8)*1.0/1024 as SpaceUsedBySession_in_MB,
                       sp1.login_time as Connection_login_time,
                       sp1.last_batch as batch_execution_time,
                       r.start_time as query_execution_Start_time,
                       sp1.open_tran,
                       ss.text,
                       DATEDIFF(SECOND,sp1.last_batch,getdate()) as duration_in_ss
                       ,DATEDIFF(MINUTE,sp1.last_batch,getdate()) as duration_in_mn
                      ,pl.query_plan
                      ,r.total_elapsed_time/1000 as total_elapsed_time
                      ,r.cpu_time
                      ,sp1.cpu
                      ,r.percent_complete
                      ,r.estimated_completion_time/(60) as estimated_completion_time_in_ss
                FROM sys.sysprocesses sp1
                INNER JOIN sys.dm_db_session_space_usage SU ON SU.session_id = sp1.spid
                LEFT JOIN sys.dm_exec_requests r on r.session_id = sp1.spid 
                LEFT JOIN sys.dm_os_waiting_tasks OSW ON OSW.session_id = sp1.spid
                OUTER APPLY sys.dm_exec_sql_text(sp1.sql_handle) ss
                OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) pl
where db_name(sp1.dbid) in ('[DBNAME]')
       )Inner_query
