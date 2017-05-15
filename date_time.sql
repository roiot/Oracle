alter session set time_zone='+4:00';

select current_date, --current date in the session time zone in a value in the Gregorian calendar, of the DATE datatype
       sysdate 
from dual 

