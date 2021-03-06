---------------------------------------------------------------------------------------------------------
--Трассировка сессии
---------------------------------------------------------------------------------------------------------
alter session set events =' 10046 TRACE NAME CONTEXT FOREVER, LEVEL 12' tracefile_identifier='WF_SKRYABIN_DG'

---------------------------------------------------------------------------------------------------------
--PL/SQL Трассировка 
--http://dbaora.com/tracing-plsql-using-dbms_trace-oracle-database-11g-release-2-11-2/
---------------------------------------------------------------------------------------------------------

--start trace
begin  
dbms_trace.set_plsql_trace
    ( dbms_trace.trace_all_calls + 
      dbms_trace.trace_all_exceptions + 
      dbms_trace.trace_all_sql +
      dbms_trace.trace_all_lines +
      dbms_trace.no_trace_administrative);
end;

--stop trace
begin
  dbms_trace.clear_plsql_trace;
end;
 
--Таблицы с результатами трассировки 
select owner, object_name, object_type  from dba_objects where object_name like 'PLSQL%' order by 2, 1;   

select * from sys.plsql_trace_events

select * from sys.plsql_trace_runs

 


---------------------------------------------------------------------------------------------------------
--https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:1855700000346846274
---------------------------------------------------------------------------------------------------------
When we run a trace and TKPROF on a query (a select statement), we see timing information for three phases:
1. Parse
2. Execute
3. Fetch
Can you clarify exactly what it means to "execute" a statement?



1) parse - pretty well defined, that is prepareStatement - we do a soft or hard parse, compile the statement, figure out how to execute it.

2) execute - we OPEN the statement. For an update, for a delete, for an insert - that would be it, when you OPEN the statement, we execute it. All of the work happens here.

for select it is more complex. Most selects will do ZERO work during the execute. All we are doing is opening the cursor - the cursor is a pointer to the space in the shared pool where the plan is, your bind variable values, the SCN that represents the "as of" time for your query - in short the cursor at this point is your context, your virtual machine state, think of the SQL plan as if it were bytecode (it is) executed as a program (it is) in a virtual machine (it is). The cursor is your instruction pointer (where are you in the execution of this statement), your state (like registers), etc. Normally, a select does nothing here - it just "gets ready to rock and roll, the program is ready to go, but not yet really started".

However, there are exceptions to everything - turn on trace and do a select * from scott.emp FOR UPDATE. That is a select, but it is also an update. You would see work done during the execute as well as the fetch phase. The work done during the execute was that of going out and touching every row and locking it. The work done during the fetch phase was that of going out and retrieving the data back to the client.

3) fetch - this is where we see almost all of the work for SELECTS (and nothing really for the other DMLS as you do not fetch from an update).

There are two ways a SELECT might be processed. What I call a "quick return query" and a "slow return query"

http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:275215756923#39255764276301

is an excerpt from Effective Oracle by Design describing this in depth, but suffice to say a query of the form:

select * from one_billion_row_table;

would not copy the data anywhere, would not need to access the last row before returning the first row. We would just read the data as you fetch it from the blocks it resides on.

However, a query of the form:

select * from one_billion_row_table order by unindexed_column;

that we would probably have to read the last row before returning the first row (since the last row read could well be the first row returned!) and we'd need to copy that somewhere (temp, sort area space) first.


In the case of the first query, if you:

parsed it (little work parsing)
opened it (no real world, just getting ready)
fetched 1 row and closed it

you would see VERY little work performed in the fetch phase, we'd just have to read one block probably to return the first record.

However, do the same steps against the second query and you would see the fetch of a single row do a TON of work - since we have to find the last row before the first can be returned.


---------------------------------------
TKPROF - https://docs.oracle.com/cd/B10500_01/server.920/a96533/sqltrace.htm#1317
---------------------------------------
PARSE - Translates the SQL statement into an execution plan, including checks for proper security authorization and checks for the existence of tables, columns, and other referenced objects.

EXECUTE - Actual execution of the statement by Oracle. For INSERT, UPDATE, and DELETE statements, this modifies the data. For SELECT statements, this identifies the selected rows.

FETCH - Retrieves rows returned by a query. Fetches are only performed for SELECT statements.


COUNT - Number of times a statement was parsed, executed, or fetched.

CPU - Total CPU time in seconds for all parse, execute, or fetch calls for the statement. This value is zero (0) if TIMED_STATISTICS is not turned on.

ELAPSED - Total elapsed time in seconds for all parse, execute, or fetch calls for the statement. This value is zero (0) if TIMED_STATISTICS is not turned on.

DISK - Total number of data blocks physically read from the datafiles on disk for all parse, execute, or fetch calls.

QUERY - Total number of buffers retrieved in consistent mode for all parse, execute, or fetch calls. Usually, buffers are retrieved in consistent mode for queries.

CURRENT - Total number of buffers retrieved in current mode. Buffers are retrieved in current mode for statements such as INSERT, UPDATE, and DELETE.