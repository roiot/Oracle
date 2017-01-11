-- Долго выполняющиеся запросы
select * from v$session_longops where target = 'APPLSYS.WF_ITEMS'

-- Текст запроса
select listagg(sql_text) within group (order by piece) from v$sqltext where sql_id = '6xcg8wa3bhnhr' 

--План запроса
select * from v$sql_plan where sql_id = '6xcg8wa3bhnhr' and plan_hash_value = '3495683138'

-- Форматирование плана запроса
select * from table(dbms_xplan.display_awr('6xcg8wa3bhnhr', '3495683138', null, 'ALL'))

