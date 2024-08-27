--  see ticket #6

-- 2022-12-21 07:00:00


select * from did.t_env_env 
        where env_time>'2022-12-21 04:00:00'
     and env_time<'2022-12-21 10:00:00' order by env_time;
     
   
select * from did.v_ddde
        where dsf_timeinit>'2022-12-21 04:00:00' 
        and dsf_timeinit<'2022-12-21 10:00:00'
        ORDER BY dsf_timeinit
-- 2024-08-27    fix integration
    
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_filename IN ('2024-03-31_020000_HF','2024-03-31_023000_HF');
DELETE FROM did.t_didsonfiles_dsf WHERE dsf_filename IN ('2024-03-31_020000_HF','2024-03-31_023000_HF');


SELECT dsf_timeinit FROM did.t_didsonfiles_dsf WHERE dsf_filename IN ('2024-03-31_030000_HF');
-- 2024-03-31 03:00:00.000 OK c'est la bonne horodate