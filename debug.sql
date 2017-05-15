create or replace package xxdebug_test1 is
    procedure f1(i number);
end;

create or replace package body xxdebug_test1 is
    procedure f1(i number) is
    begin
        for j in 1 .. i loop
            xxdebug_test2.f2(j);
        end loop;
    end;
end;



create or replace package xxdebug_test2 is
    procedure f2(j number);
end;

create or replace package body xxdebug_test2 is
    procedure f2(j number) is
    begin
       dbms_output.put_line('j='||j);
    end;
end;


--Запуск
begin
    xxdebug_test1.f1(10);
end;