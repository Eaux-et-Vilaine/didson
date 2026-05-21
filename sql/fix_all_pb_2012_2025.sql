-- ce fichier est lié à une erreur 2024-2025 csotis min changé partout
-- du coup je repasse sur tous les fichiers pour chercher les erreurs

SET search_path TO did,public;
SELECT dsf_filename, dsr.* FROM t_didsonread_dsr dsr
join t_didsonfiles_dsf  dsf on dsf_id=dsr_dsf_id
WHERE dsr_csotdb IS NULL 


-- ceux là c'est des complete
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=0.0
  WHERE dsr_id=7363;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=0.0
  WHERE dsr_id=7893;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=0.0
  WHERE dsr_id=5070;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=0.0
  WHERE dsr_id=7468;


SELECT dsf_filename, dsr.* FROM t_didsonread_dsr dsr
join t_didsonfiles_dsf  dsf on dsf_id=dsr_dsf_id
WHERE dsr_csotdb IS NULL 


-- ces fichiers n'ont pas de drr
SELECT dsf_filename, dsr.*, drr.* FROM t_didsonread_dsr dsr
join t_didsonfiles_dsf  dsf on dsf_id=dsr_dsf_id
LEFT JOIN t_didsonreadresult_drr drr ON drr_dsf_id = dsf_id
WHERE dsr_csotdb IS NULL ;

SELECT dsf_filename, dsr.*, drr.* FROM t_didsonread_dsr dsr
join t_didsonfiles_dsf  dsf on dsf_id=dsr_dsf_id
LEFT JOIN t_didsonreadresult_drr drr ON drr_dsr_id = dsr_id
WHERE dsr_csotdb IS NULL ;

-- bon c'est des fichiers pour lequels on a ézéro comptes donc c'est normal de pas avoir de fichier poisson
-- il faut juste un cstodb je vais mettre 2.5

UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=2.5,dsr_comment='ligne sans csotdb je mets 2.5 1x anguille en 5'
  WHERE dsr_id=53402;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=2.5,dsr_comment='fichiers sans csotdb je mets 2.5 1x anguille en 5'
  WHERE dsr_id=53427;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=2.5,dsr_comment='ligne sans csotdb je mets 2.5 1x anguille en 3'
  WHERE dsr_id=53403;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=2.5,dsr_comment='ligne sans csotdb je mets 2.5 '
  WHERE dsr_id=80066;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=2.5,dsr_comment='ligne sans csotdb je mets 2.5 '
  WHERE dsr_id=80068;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=2.5,dsr_comment='fichiers sans csotdb je mets 2.5 '
  WHERE dsr_id=80067;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=2.5,dsr_comment='ligne sans csotdb je mets 2.5 '
  WHERE dsr_id=80065;
UPDATE did.t_didsonread_dsr
  SET dsr_csotdb=2.5,dsr_comment='ligne sans csotdb je mets 2.5 '
  WHERE dsr_id=80064;


SELECT *  FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
WHERE drr_dsr_id IS NULL
ORDER BY dsf_id; --0


WITH sub AS (
SELECT dsf_id,
dsr_id,
drr_id,
drr_dsr_id,
dsr_reader,
dsr_csotdb,
drr_csotminthreshold_db,
dsr_eelplus,
dsr_eelminus,
drr_totalfish,
drr_upstream,
drr_downstream,
drr_filename,
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
WHERE drr_dsr_id IS NULL),
dbr AS (  -- double rows
SELECT * FROM sub
WHERE  countdsr = 1 -- un seul fichier texte
)
SELECT * FROM dbr; --0


WITH 
dbr AS (
SELECT dsf_id,
dsr_id,
drr_id,
drr_dsr_id,
dsr_reader,
dsr_csotdb,
drr_csotminthreshold_db,
dsr_eelplus,
dsr_eelminus,
drr_totalfish,
drr_upstream,
drr_downstream,
drr_filename,
count (*) OVER (PARTITION BY dsf_id) AS countdsf,
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
WHERE drr_dsr_id IS NULL
AND drr_editorid='gerard'
AND dsr_reader='Gerard'
ORDER BY dsf_id
) 
SELECT *  FROM dbr


WITH sub AS (
SELECT dsf_id,
dsr_id,
drr_id,
drr_dsr_id,
dsr_reader,
dsr_csotdb,
dsr_csotismin, 
drr_csotminthreshold_db,
dsr_eelplus,
dsr_eelminus,
drr_totalfish,
drr_upstream,
drr_downstream,
drr_filename
FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
WHERE dsr_csotismin
),
dbr AS (
SELECT 
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr,
sub.*
FROM sub),
dbr2 AS (
SELECT * FROM dbr
WHERE  countdsr>1
) -- double ROWS
SELECT * FROM dbr2
ORDER BY dsf_id, dsr_csotismin; --312


UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4070;

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4070;

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4069;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7249;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4260;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=4261;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7409;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4264;


-- Auto-generated SQL script #202605051116
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7408;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4261;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7441;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7449;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4265;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7450;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4266;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7451;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4267;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7452;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4268;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7453;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4269;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4270;


-- Auto-generated SQL script #202605051120
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27824;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=27823;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27878;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27883;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27902;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27908;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27909;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27932;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27933;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27935;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27938;

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27823;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27877;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27884;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27901;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27907;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27910;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27922;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27922;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27931;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27934;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27936;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27937;

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=27921;


WITH sub AS (
SELECT dsf_id,
dsr_id,
drr_id,
drr_dsr_id,
dsr_reader,
dsr_csotdb,
dsr_csotismin, 
drr_csotminthreshold_db,
dsr_eelplus,
dsr_eelminus,
drr_totalfish,
drr_upstream,
drr_downstream,
drr_filename
FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
WHERE dsr_csotismin
),
dbr AS (
SELECT 
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr,
sub.*
FROM sub),
dbr2 AS (
SELECT * FROM dbr
WHERE  countdsr>1
) -- double ROWS
SELECT * FROM dbr2
ORDER BY dsf_id, dsr_csotismin; --0




WITH sub AS (
SELECT dsf_id,
dsr_id,
drr_id,
drr_dsr_id,
dsr_reader,
dsr_csotdb,
dsr_csotismin, 
drr_csotminthreshold_db,
dsr_eelplus,
dsr_eelminus,
drr_totalfish,
drr_upstream,
drr_downstream,
drr_filename
FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_dsr_id)=(dsr_id)
WHERE dsr_csotismin
),
dbr AS (
SELECT 
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr,
sub.*
FROM sub),
dbr2 AS (
SELECT * FROM dbr
WHERE  countdsr>1
) -- double ROWS
SELECT * FROM dbr2
ORDER BY dsf_id, dsr_csotismin; --0



SELECT dsf_id, 
did.round_time_30(dsf_timeinit) AS dsf_timeinit,
did.round_time_30(dsf_timeend) AS dsf_timeend,
dsf_position, dsf_incl, dsf_distancestart,
dsf_depth, dsf_fls_id, dsf_readok, dsf_filename, dsf_season, dsf_mois, dsf_periode, 
dsr_id, dsr_dsf_id, dsr_readinit, dsr_readend, dsr_reader, dsr_eelplus, dsr_eelminus, 
dsr_csotdb, dsr_complete, dsr_muletscore, dsr_fryscore, dsr_comment, dsr_csotismin, 
dsr_pertefichiertxt, drr_filename, drr_path, drr_date, drr_start, drr_end, drr_upstreammotion, drr_countfilename,
drr_editorid, drr_intensity_db, drr_threshold_db, drr_csotmincluster_cm2, drr_csotminthreshold_db, drr_windowstart_m,
drr_windowend_m, drr_totalfish, drr_upstream, drr_downstream, drr_unknown, drr_id, drr_dsf_id, drr_dsr_id, drr_eelplus, drr_eelminus
FROM  did.t_didsonfiles_dsf  dsf  
        left join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
        left join did.t_didsonreadresult_drr drr on   drr_dsr_id=dsr_id
        where dsr_csotismin or dsr_csotismin is null; --119494
        
        
        

WITH sub AS (
SELECT dsf_id,
dsr_id,
drr_id,
drr_dsr_id,
dsr_reader,
dsr_csotdb,
dsr_csotismin, 
drr_csotminthreshold_db,
dsr_eelplus,
dsr_eelminus,
drr_totalfish,
drr_upstream,
drr_downstream,
drr_filename
FROM   t_didsonfiles_dsf  dsf 
 JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
 JOIN t_didsonreadresult_drr drr ON (drr_dsr_id)=(dsr_id)
WHERE dsr_csotismin OR dsr_csotismin IS null
),
dbr AS (
SELECT 
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr,
count (*) OVER (PARTITION BY dsf_id) AS countdsf,
sub.*
FROM sub),
dbr2 AS (
SELECT * FROM dbr
WHERE  countdsf>1
) -- double ROWS
SELECT * FROM dbr2
ORDER BY dsf_id, dsr_csotdb; --0


UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4271;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4272;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4273;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4274;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4275;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4276;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4277;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4278;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4742;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4746;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=5203;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=5259;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=5607;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=30523;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=30632;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=30697;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=30730;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=30957;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31043;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31049;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31064;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31075;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31092;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31095;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31106;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31113;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31240;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31353;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31358;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31414;

-- Auto-generated SQL script #202605051202
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31480;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31490;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31542;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31723;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31780;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31850;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=31914;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=32269;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=36875;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46289;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46340;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46396;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46415;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46441;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46484;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46528;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46653;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46657;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=46755;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=47306;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=77537;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=81996;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=82014;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=82055;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=82058;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=82101;



WITH ddde AS(
select * from did.v_ddde
        where dsf_timeinit>'2012-09-01 00:00:00' 
        and dsf_timeinit<'2025-05-01 00:00:00' 
        and dsr_csotismin 
        and NOT dsr_pertefichiertxt),
dbr AS(
SELECT count(*) OVER (PARTITION BY dsf_id) AS countdsf,
* FROM ddde),
sel_largest AS (
SELECT * FROM dbr 
WHERE countdsf>1
order by dsf_id, dsr_csotdb DESC),
unq AS(
SELECT DISTINCT ON (dsf_id) * FROM sel_largest WHERE drr_id IS NULL)
UPDATE did.t_didsonread_dsr SET dsr_csotismin = FALSE WHERE dsr_id IN (SELECT dsr_id FROM unq); --312





WITH ddde AS(
select * from did.v_ddde
        where dsf_timeinit>'2012-09-01 00:00:00' 
        and dsf_timeinit<'2025-05-01 00:00:00' 
        and dsr_csotismin 
        and NOT dsr_pertefichiertxt),
dbr AS(
SELECT count(*) OVER (PARTITION BY dsf_id) AS countdsf,
* FROM ddde)

SELECT * FROM dbr WHERE countdsf>1 --0


-- in R pb with drr counts
-- deux ficheres avec des dsf des drr mais pas de dsr

SELECT * FROM did.t_didsonreadresult_drr WHERE drr_dsf_id = 5761 ;
SELECT * FROM did.t_didsonread_dsr WHERE dsr_dsf_id = 5761 ;

UPDATE did.t_didsonread_dsr
  SET dsr_pertefichiertxt=false
  WHERE dsr_id=3582;

SELECT * FROM did.t_didsonreadresult_drr WHERE drr_dsf_id = 6594; -- 1 fichier OK
SELECT * FROM did.t_didsonread_dsr WHERE dsr_dsf_id = 6594 ;

UPDATE did.t_didsonread_dsr
  SET dsr_pertefichiertxt=false
  WHERE dsr_id=3934;


