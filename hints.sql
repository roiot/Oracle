--https://www.pythian.com/blog/oracles-opt_estimate-hint-usage-guide/
select /*+OPT_ESTIMATE(TABLE DD ROWS=10)*/ count(*) from dual DD
