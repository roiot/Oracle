explain plan for select * from dual;

select * from table(dbms_xplan.display('PLAN_TABLE', null, 'ADVANCED'));