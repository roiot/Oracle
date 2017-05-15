create table xx_log(message           varchar2(4000),
                    module            varchar2(240),
                    created_at        timestamp(6));


function err_stack return varchar2 is
begin
    return sys.dbms_utility.format_error_stack || sys.dbms_utility.format_error_backtrace;
end;



procedure log(p_message   varchar2,
              p_module    varchar2 default null) is
    pragma autonomous_transaction;
begin
    insert into xx_log(message, module, created_at) values (p_message, p_module, systimestamp);
    commit;
end;