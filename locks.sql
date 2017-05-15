-- Залоченны объекты
  select lo.object_id,
         lo.session_id,
         ses.status,
         ses.serial#,
         ses.action,
         al.object_name
    from all_objects al,
         sys.v_$locked_object lo,
         sys.v_$session ses
   where lo.object_id = al.object_id and ses.sid = lo.session_id
order by object_name
/

--убить сессию
alter system kill session '45,2572' --session_id, serial#
/

--Кто держит пакет
begin
    sys.who_is_using('XXGLA_A025_PKG');
end;

--Сессии
select * from sys.v_$session where sid = 5869

--Залоченная временная таблица
select /*+rule*/
        s.inst_id,
        s.sid,
        s.serial#,
        s.username,
        s.status,
        s.machine
  from gv$lock l,
       gv$session s
 where l.inst_id = s.inst_id
   and l.type = 'TO'
   and l.sid = s.sid
   and l.id1 in (select o.object_id
                   from dba_objects o
                  where o.object_name = upper('EPROOF_CONTRACT_HEADERS_T'))
