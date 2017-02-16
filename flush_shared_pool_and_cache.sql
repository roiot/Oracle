begin
    execute immediate 'alter system flush shared_pool'; 
    execute immediate 'alter system flush buffer_cache';
end;
