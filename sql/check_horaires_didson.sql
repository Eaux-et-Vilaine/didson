--  see ticket #6

-- 2022-12-21 07:00:00


select * from did.t_env_env 
        where env_time>'2022-12-21 04:00:00'
     and env_time<'2022-12-21 10:00:00' order by env_time;
     
   
select * from did.v_ddde
        where dsf_timeinit>'2022-12-21 04:00:00' 
        and dsf_timeinit<'2022-12-21 10:00:00'
        ORDER BY dsf_timeinit