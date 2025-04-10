-- This is issue #8


show timezone; -- Europe/Paris
--So the db will act LIKE IF it was WITH SET timezone ='Europe/Paris';


SELECT dsf_timeinit FROM did.t_didsonfiles_dsf ORDER BY dsf_timeinit LIMIT 1; -- 2012-09-21 17:30:00.000



DROP VIEW did.v_ddd CASCADE;-- OK
DROP VIEW did.v_dddp CASCADE;-- OK
DROP VIEW did.v_dddpall CASCADE;-- OK
DROP VIEW did.v_depouillement CASCADE; --OK
DROP VIEW did.v_fish CASCADE; --OK
DROP VIEW did.v_nb_parjour; -- NOT USED ? I didn't find IN code
DROP VIEW v_didsonlectures; --v_lectures en plus
DROP VIEW did.v_env; -- OK
DROP VIEW did.v_fctvanne1235; --OK
DROP VIEW did.v_fctvanne4; -- OK


ALTER TABLE did.t_didsonfiles_dsf DROP constraint c_ck_dsf_timeend;



ALTER TABLE did.t_didsonfiles_dsf 
ALTER COLUMN dsf_timeinit TYPE timestamptz 
USING dsf_timeinit AT TIME ZONE 'Europe/Paris';

ALTER TABLE did.t_didsonfiles_dsf 
ALTER COLUMN dsf_timeend TYPE timestamptz 
USING dsf_timeend AT TIME ZONE 'Europe/Paris';

ALTER TABLE did.t_didsonfiles_dsf ADD constraint c_ck_dsf_timeend check (dsf_timeend>dsf_timeinit);

SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_timeinit>=dsf_timeend
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_id IN (229912,229913,229914,229915)


-- change hour
DELETE FROM did.t_didsonfiles_dsf WHERE dsf_filename IN ('2023-03-26_020000_HF', '2023-03-26_023000_HF229');

SELECT EXTRACT(TIMEZONE FROM dsf_timeend) FROM did.t_didsonfiles_dsf;


-- t_didsonread_dsr

SELECT EXTRACT(TIMEZONE FROM dsr_readinit) FROM did.t_didsonread_dsr AS tdd ;

ALTER TABLE did.t_didsonread_dsr 
ALTER COLUMN dsr_readinit TYPE timestamptz 
USING dsr_readinit AT TIME ZONE 'Europe/Paris';

ALTER TABLE did.t_didsonread_dsr
ALTER COLUMN dsr_readendenv_time
USING dsr_readend AT TIME ZONE 'Europe/Paris';

ALTER TABLE did.t_didsonread_dsr  ADD constraint c_ck_dsr_readend check (dsr_readend>=dsr_readinit);

SELECT * FROM did.t_didsonread_dsr WHERE dsr_readend<dsr_readinit;

--DROP TABLE did.t_env_env;

-- the env_id is missing always, this is dumb. And there is no PK.
SELECT * FROM did.t_env_env WHERE env_id IS NOT NULL;

ALTER TABLE did.t_env_env DROP COLUMN env_id;
ALTER TABLE did.t_env_env ADD COLUMN env_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY;

CREATE TABLE did.tenv_envutc AS 
SELECT * FROM did.t_env_env WHERE env_time > '2016-01-01 00:00:00'; --327986

DELETE FROM did.t_env_env WHERE env_time > '2016-01-01 00:00:00';--327986

ALTER TABLE did.tenv_envutc
ALTER COLUMN env_time  TYPE timestamptz 
USING env_time AT TIME ZONE 'Europe/Paris';

ALTER TABLE did.t_env_env
ALTER COLUMN env_time  TYPE timestamptz 
USING env_time AT TIME ZONE 'GMT';

INSERT INTO did.t_env_env 
SELECT  env_time, env_volet1, env_volet2, env_volet3, env_volet4,
env_volet5, env_vanne1, env_vanne2, env_vanne3, env_vanne4, env_vanne5,
env_tempamont, env_tempaval, env_tempamont1, env_tempair, env_debitvilaine,
env_debitpasse, env_volvanne, env_volpasse, env_volsiphon, env_volvolet,
env_volecluse, env_volumetotal, env_niveaumer, env_niveauvilaine,
env_debitmoyencran, env_qvanne1, env_qvanne2, env_qvanne3, 
env_qvanne4, env_qvanne5, deb_qtotal, env_qvolet1, env_qvolet2,
env_qvolet3, env_qvolet4, env_qvolet5, env_debitvolet, env_debitsiphon, 
env_debitvanne
FROM did.tenv_envutc;



ALTER TABLE did.t_env_env
ALTER COLUMN env_time  TYPE timestamptz 
USING env_time AT TIME ZONE 'GMT';

SELECT * FROM did.tenv_envutc WHERE env_time < '2021-03-28 05:00:00'
AND env_time > '2021-03-28 01:00:00';

DELETE FROM did.tenv_envutc WHERE env_id BETWEEN 30081 AND 30086;

SELECT * FROM did.tenv_envutc WHERE env_time < '2020-03-29 05:00:00'
AND env_time > '2020-03-29 01:00:00';

DELETE FROM did.tenv_envutc WHERE env_id BETWEEN 275163 AND 275168;

INSERT INTO did.t_env_env SELECT 
 env_time, env_volet1, env_volet2, env_volet3, env_volet4, env_volet5, env_vanne1, env_vanne2, env_vanne3, env_vanne4, env_vanne5, env_tempamont, env_tempaval, env_tempamont1, env_tempair, env_debitvilaine, env_debitpasse, env_volvanne, env_volpasse, env_volsiphon, env_volvolet, env_volecluse, env_volumetotal, env_niveaumer, env_niveauvilaine, env_debitmoyencran, env_qvanne1, env_qvanne2, env_qvanne3, env_qvanne4, env_qvanne5, deb_qtotal, env_qvolet1, env_qvolet2, env_qvolet3, env_qvolet4, env_qvolet5, env_debitvolet, env_debitsiphon, env_debitvanne
FROM did.tenv_envutc WHERE 
env_time> (SELECT 
max(env_time) FROM did.t_env_env); --327986



/*
SELECT * FROM did.t_env_env WHERE env_time < '2013-03-31 05:00:00'
AND env_time > '2013-03-31 01:00:00';

DELETE FROM did.t_env_env WHERE env_id BETWEEN 309971 AND 309976;

SELECT * FROM did.t_env_env WHERE env_time < '2014-03-30  05:00:00'
AND env_time > '2014-03-30  01:00:00';


DELETE FROM did.t_env_env WHERE env_id BETWEEN 309971 AND 309976;
*/


-- CHECK IF THERE IS A MISMATCH


  SELECT (substring(dsf_filename,1,10)||' '||substring(dsf_filename,12,2)||':'||substring(dsf_filename,14,2)||':'||substring(dsf_filename,16,2))::timestamp AS newtime, * 
    FROM did.t_didsonfiles_dsf WHERE dsf_season='2023-2024'



  WITH settime AS (
  SELECT (substring(dsf_filename,1,10)||' '||substring(dsf_filename,12,2)||':'||substring(dsf_filename,14,2)||':'||substring(dsf_filename,16,2)):: timestamptz AS newtime, * 
    FROM did.t_didsonfiles_dsf WHERE dsf_season='2021-2022'),
  rounded AS (
  SELECT 
  dsf_id,
  newtime AS new_dsf_timeinit,
  newtime + (30 * interval '1 minute') AS new_dsf_timeend,
  dsf_timeinit,
  did.round_time_30(dsf_timeinit) AS rounddsf_timeinit,
  dsf_timeend,
  did.round_time_30(dsf_timeend) AS rounddsf_timeend
    FROM settime)
    
  SELECT * FROM rounded WHERE new_dsf_timeinit !=rounddsf_timeinit
    
  WITH settime AS (
  SELECT (substring(dsf_filename,1,10)||' '||substring(dsf_filename,12,2)||':'||substring(dsf_filename,14,2)||':'||substring(dsf_filename,16,2)):: timestamptz AS newtime, * 
    FROM did.t_didsonfiles_dsf WHERE dsf_season IN ('2016-2017','2017-2028','2018-2019','2019-2020','2020-2021')),
  rounded AS (
  SELECT 
  dsf_id,
  newtime AS new_dsf_timeinit,
  newtime + (30 * interval '1 minute') AS new_dsf_timeend,
  dsf_timeinit,
  did.round_time_30(dsf_timeinit) AS rounddsf_timeinit,
  dsf_timeend,
  did.round_time_30(dsf_timeend) AS rounddsf_timeend
    FROM settime)
    
  SELECT * FROM rounded WHERE new_dsf_timeinit !=rounddsf_timeinit
  
  
CREATE OR REPLACE FUNCTION convert_to_timestamp(v_input text)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
    BEGIN
        RETURN v_input::timestamptz;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Invalid value: "%".  Returning NULL.', v_input;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;


  WITH settime AS (
  SELECT (substring(dsf_filename,1,10)||' '||substring(dsf_filename,12,2)||':'||substring(dsf_filename,14,2)||':'||substring(dsf_filename,16,2)) AS newtime, * 
    FROM did.t_didsonfiles_dsf ),
    sorties AS(
  SELECT 
    convert_to_timestamp(newtime) c,
    *
    FROM settime)

    SELECT c FROM sorties 
  
  
SELECT * FROM did.t_didsonfiles_dsf WHERE substring(dsf_filename,1,10)||' '||substring(dsf_filename,12,2)||':'||substring(dsf_filename,14,2)||':'||substring(dsf_filename,16,2) = '  ::'
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_filename =' ';
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_id ='89613';

WITH settime AS (
  SELECT convert_to_timestamp(substring(dsf_filename,1,10)||' '||substring(dsf_filename,12,2)||':'||substring(dsf_filename,14,2)||':'||substring(dsf_filename,16,2)) AS newtime, * 
    FROM did.t_didsonfiles_dsf),
  rounded AS (
  SELECT 
  dsf_id,
  newtime AS new_dsf_timeinit,
  newtime + (30 * interval '1 minute') AS new_dsf_timeend,
  dsf_timeinit,
  did.round_time_30(dsf_timeinit) AS rounddsf_timeinit,
  dsf_timeend,
  did.round_time_30(dsf_timeend) AS rounddsf_timeend
    FROM settime)
    
  SELECT * FROM rounded WHERE new_dsf_timeinit !=rounddsf_timeinit



SELECT convert_to_timestamp(v_input text)
  
  
  
  DELETE FROM did.t_didsonfiles_dsf WHERE dsf_id IN (98544,98545);
    
  SELECT * FROM rounded WHERE new_dsf_timeinit !=rounddsf_timeinit

   ORDER BY dsf_timeinit
   
   
  UPDATE did.t_didsonfiles_dsf SET 
  dsf_timeinit = new_dsf_timeinit,
  dsf_timeend = new_dsf_timeend
  FROM tochange WHERE tochange.dsf_id = t_didsonfiles_dsf.dsf_id; 

-- trying to check why I have missing values every 30 min
SELECT env_time,did.round_time_30(env_time) FROM did.t_env_env  WHERE env_time > '2024-01-01 00:00:00';
SELECT round_time FROM did.v_env WHERE round_time > '2024-01-01 00:00:00' -- v_env IS OK but 
-- ddde is perhaps not rounded
