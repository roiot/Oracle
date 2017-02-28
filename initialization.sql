-- текущий пользователь БД
select sys_context( 'userenv', 'current_schema' ) from dual;

-- Смена языка
alter session set nls_language=american

--Сброс состояния plsqls для сессии (глобальные переменные и т.п.)
execute dbms_session.reset_package;
