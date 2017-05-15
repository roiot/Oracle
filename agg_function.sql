drop type oneOrNothingAgg;

create type oneOrNothingAgg as object
    ( val number,
      state number,
      static function ODCIAggregateInitialize(ctx in out oneOrNothingAgg) return number,
      member function ODCIAggregateIterate(self in out oneOrNothingAgg, val in number) return number,
      member function ODCIAggregateTerminate(self in oneOrNothingAgg, returnvalue out number, flags in number) return number,
      member function ODCIAggregateMerge(self in out oneOrNothingAgg, ctx2 in oneOrNothingAgg) return number
    );
/

create or replace type body oneOrNothingAgg is
    static function ODCIAggregateInitialize(ctx in out oneOrNothingAgg) return number is
    begin
      ctx := oneOrNothingAgg(null, -1);
      return ODCIConst.Success;
    end;
    --
    member function ODCIAggregateIterate(self in out oneOrNothingAgg, val in number) return number is
    begin
      if self.state = -1 then
        self.val := val;
        self.state := 0;
      elsif self.state = 0 and self.val != val then
        self.val := null;
        self.state := 1;
      end if;
     return ODCIConst.Success;
    end;
    --
    member function ODCIAggregateTerminate(
        self in oneornothingagg,
        returnvalue out number,
        flags in number) return number is
    begin
      returnValue := self.val;
      return ODCIConst.Success;
    end;
    --
    member function ODCIAggregateMerge(self in out oneornothingagg, ctx2 in oneOrNothingAgg) return number is
    begin
      if self.state = 0 and self.val != ctx2.val then
        self.val := null;
        self.state := 1;
      end if;
      return ODCIConst.Success;
    end;
end;
/

create or replace function oneOrNothing(input number) return number
parallel_enable aggregate using oneOrNothingAgg;

grant execute on oneOrNothing to xxportal;
create or replace synonym xxportal.oneOrNothing for apps.oneOrNothing;

-- Example
select oneOrNothing(gl_account) over (partition by b), b
from (  select 1 as gl_account, 'a' as b from dual
        union all select 2, 'a' from dual
        union all select 1, 'b' from dual
        union all select 1, 'b' from dual
     )
