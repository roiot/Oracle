-- Вывод сообщения об ошибке
function dbms_error return varchar2 is 
begin
    return sys.dbms_utility.format_error_stack || chr(10) || sys.dbms_utility.format_error_backtrace;
end;

-- Форматирование числа при переводе в текст
function num_to_char(p_number in number) return varchar2 is
    l_char   varchar2(100);
begin
    if remainder(p_number, 1) = 0 then
        l_char := to_char(to_number(p_number), 'FM999G999G999G999G999G999', 'NLS_NUMERIC_CHARACTERS = ''. ''');
    else
        l_char := to_char(to_number(p_number), 'FM999G999G999G999G999G999D99', 'NLS_NUMERIC_CHARACTERS = ''. ''');
    end if;
    return l_char;
end;

--Вывод текста длиной более 32k
procedure output(p_text in clob) is
    l_chars   number := 10000;
begin
    for i in 1 .. ceil(dbms_lob.getlength(p_text) / l_chars)
    loop
        htp.prn(dbms_lob.substr(p_text, l_chars, l_chars * (i - 1) + 1));
    end loop;
end;
