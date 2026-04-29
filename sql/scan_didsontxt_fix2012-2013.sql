SET search_path TO did,public;

-- 2025 j'ai du merder sur tous les cstot is min, il faut refaire le travail, 

--125 lignes en 2012-2013

SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id=6999; 

WITH ss as (
SELECT dsf_filename, dsf_season,dsf_id, drr_dsr_id,drr_id,dsr_csotismin,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus AS dsr_total,
drr_upstream,drr_downstream,drr_eelplus, drr_eelminus,drr_eelplus-drr_eelminus AS drr_total
FROM t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN t_didsonreadresult_drr drr ON drr_dsr_id=dsr_id
),
pbdsf as (
SELECT distinct dsf_id FROM ss 
WHERE dsr_total>0 AND drr_total IS NULL
AND dsr_csotismin
AND dsf_season = '2012-2013')
SELECT * FROM t_didsonread_dsr where dsr_dsf_id in (
SELECT dsf_id FROM pbdsf
) order by dsr_dsf_id, dsr_csotdb;

-- remove all lines with csotdb 4,2

WITH ss as (
SELECT dsf_filename, dsf_season,dsf_id, drr_dsr_id,drr_id,dsr_csotismin,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus AS dsr_total,
drr_upstream,drr_downstream,drr_eelplus, drr_eelminus,drr_eelplus-drr_eelminus AS drr_total
FROM t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN t_didsonreadresult_drr drr ON drr_dsr_id=dsr_id
),
pbdsf as (
SELECT distinct dsf_id FROM ss 
WHERE dsr_total>0 AND drr_total IS NULL
AND dsr_csotismin
AND dsf_season = '2012-2013')
UPDATE  t_didsonread_dsr set dsr_csotismin = FALSE where dsr_csotdb = 4.2 and dsr_dsf_id in (
SELECT dsf_id FROM pbdsf) ;--101

--en virant le csotdb 2.4 j'en vire 101 il en reste 24

SELECT * from(
SELECT dsf_filename, dsf_season,dsf_id, drr_dsr_id,drr_id,dsr_csotismin,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus AS dsr_total,
drr_upstream,drr_downstream,drr_eelplus, drr_eelminus,drr_eelplus-drr_eelminus AS drr_total, dsr_pertefichiertxt
FROM t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN t_didsonreadresult_drr drr ON drr_dsr_id=dsr_id) sub
WHERE dsr_total>0 AND drr_total IS NULL
AND dsr_csotismin
AND dsf_season = '2012-2013';

-- necessite un check manuel avec le fichier ci dessus

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4127;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7238;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4149;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7240;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4153;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=7241;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4155;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7243;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7245;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4163;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7246;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4167;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4166;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=7247;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4168;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7270;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4622;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4631;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=4630;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4645;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4768;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4805;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4807;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4811;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4813;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4815;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=5072;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=5090;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=5089;
  
-- reste 8 lignes sans correspondance dans t_didsonreadresult_drr

SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 6999
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 6999
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4127;

UPDATE did.t_didsonreadresult_drr
  SET drr_dsr_id=4128
  WHERE drr_id='FC_CSOT_2012-10-14_070000_HF_P1013';
  
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 8153
SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 8153

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4622;
  
SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 6999 

UPDATE did.t_didsonread_dsr
  SET dsr_comment='PAS DE FICHER DRR pas de courant, anguilles se baladent',dsr_pertefichiertxt=true,dsr_csotismin=false
  WHERE dsr_id=4128;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=4127;

UPDATE did.t_didsonread_dsr
  SET dsr_pertefichiertxt=true,dsr_comment='PAS DE FICHIER DRR',dsr_csotismin=false
  WHERE dsr_id=4623;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=4622;

 -- 8194
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 8194  ; 2.1
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 8194
 
UPDATE did.t_didsonread_dsr
  SET dsr_pertefichiertxt=true,dsr_csotismin=false
  WHERE dsr_id=4646;
 -- 8794 
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 8794  ; -- csotdb => 0 1 fichier
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 8794;

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4813;
-- 7041
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 7041  ; -- csotdb => 2.1 1 fichier
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 7041;
-- deux fichier en 2.1 je choisis le bon
 UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4161;

--7046
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 7046  ; -- csotdb => 2.1 1 fichier
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 7046;
 SELECT * FROM t_didsonread_dsr WHERE dsr_id= 7247;
 -- il y a un décalage d'heure, pointe vers le mauvais fichier.
 UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=7247;
-- le fichier avec 12 poissons doit être un pb de cochage de la case permettant d'incrémenter les fichiers
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4167;

-- 7027 2012-10-14_190000_HF
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 7027  ; -- csotdb => 2.1 1 fichier
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 7027;
 UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4147;
-- 8792 2012-11-19_210000_HF
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 8792  ; -- csotdb => 2.1 1 fichier
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 8792;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4811;
-- 8788 2012-11-19_200000_HF
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 8788  ; -- csotdb => 0 1 fichier
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 8788;
 UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4807;
-- 7064 2012-10-15_073000_HF
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 7064  ; -- csotdb => 2.1 1 fichier dsr 7270
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 7064;
 UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4171
-- 8453 2012-11-12_223000_HF
 SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 8453  ; -- csotdb => 2.1 1 fichier dsr 4775
 SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 8453;  
 -- le fichier 0 a été perdu il ne peut pas etre csotismin
 UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=4775
 
-- 7037 2012-10-14_213000_HF
SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 7027  ; -- csotdb => 2.1 1 fichier dsr 4147
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 7027;  
-- Auto-generated SQL script #202604281141
-- le fichier csotdb 0 a disparu
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7238;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=4147;

-- 7029 2012-10-14_193000_HF
SELECT * FROM did.t_didsonreadresult_drr where drr_dsf_id = 7029  ; -- csotdb => 2.1 1 fichier dsr 7239
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id= 7029;  
-- je vire un doublon
-- Auto-generated SQL script #202604281143
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4149;

-- 9291 2012-11-29_203000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 9291; -- 2.1 5089
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 9291;  
-- perte de fichier pour le zero on choisit le 2.1
-- Auto-generated SQL script #202604281148
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=5089;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=5090;
-- 7037  2012-10-14_213000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 7037; -- 2.1 7243
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 7037; 
-- doublon 2.1
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4157
-- 8446 2012-11-12_200000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 8446; -- 2.1 4769
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 8446;  
-- le 2.8 n'est pas csotismin
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4768;
-- 8161 2012-11-07_033000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 8161; -- 2.1 4630
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 8161;  
-- perte de fichier sur zero
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=true
  WHERE dsr_id=4630;
-- 7031 2012-10-14_200000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 7031; -- 2.1 7240
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 7031;  
-- je choisis le fichier existant sur le doublon meme si il y une anguille de moins
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4151;
-- 7035 2012-10-14_210000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 7035; -- 2.1 7242
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 7035;  
-- je vire le doublon sur 2.1
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4155;
-- 8796 2012-11-19_220000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 8796; -- 0.0 4816
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 8796;  
-- je vire le 2.8
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4815
-- 9117 2012-11-26_053000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 9117; -- 0.0 5071
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 9117;  
-- le 2.1 n'est pas csotismin
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=5072;
-- 7043 2012-10-14_230000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 7043; -- NULL 4164
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 7043;  
-- Y en a deux à virer et je choisi le zero
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4163;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=7246;
-- 7033 2012-10-14_203000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 7033; -- 2.1 7241
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 7033;  
-- je vire le mauvais avec perte de fichier
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4153;
-- 7049 2012-10-15_000000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 7049; -- 2.1 7248
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 7049;  
-- Je vire le doublon
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4168
-- 8786 2012-11-19_193000_HF
SELECT drr_csotminthreshold_db, drr_dsr_id  FROM did.t_didsonreadresult_drr where drr_dsf_id = 8786; -- 0.0 4806
SELECT dsr_id, dsr_reader, dsr_eelplus, dsr_eelminus, dsr_csotdb, dsr_complete, dsr_comment, dsr_csotismin, dsr_pertefichiertxt 
  FROM t_didsonread_dsr WHERE dsr_dsf_id= 8786;  
--Je vire le 2.8 et je garde le zero
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=4805;

-- verif ultime
SELECT * from(
SELECT dsf_filename, dsf_season,dsf_id, drr_dsr_id,drr_id,dsr_csotismin,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus AS dsr_total,
drr_upstream,drr_downstream,drr_eelplus, drr_eelminus,drr_eelplus-drr_eelminus AS drr_total, dsr_pertefichiertxt
FROM t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN t_didsonreadresult_drr drr ON drr_dsr_id=dsr_id) sub
WHERE dsr_total>0 AND drr_total IS NULL
AND dsr_csotismin
AND dsf_season = '2012-2013';
--zero fichiers

SELECT * FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id WHERE (dsr_eelplus>0 or dsr_eelminus>0) and
dsr_id not in (SELECT drr_dsr_id FROM t_didsonreadresult_drr) AND dsr_csotismin ORDER BY dsf_timeinit; --12 lines now corrected

|dsf_id|dsf_timeinit                 |dsf_timeend                  |dsf_position|dsf_incl|dsf_distancestart|dsf_depth|dsf_fls_id|dsf_readok|dsf_filename        |
|------|-----------------------------|-----------------------------|------------|--------|-----------------|---------|----------|----------|--------------------|
|5 938 |2012-09-25 00:00:00.000 +0200|2012-09-25 00:30:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-25_000000_HF|
|5 995 |2012-09-25 20:00:00.000 +0200|2012-09-25 20:30:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-25_200000_HF|
|6 015 |2012-09-26 01:00:00.000 +0200|2012-09-26 01:30:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-26_010000_HF|
|6 071 |2012-09-26 21:00:00.000 +0200|2012-09-26 21:30:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-26_210000_HF|
|6 075 |2012-09-26 22:00:00.000 +0200|2012-09-26 22:30:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-26_220000_HF|
|6 177 |2012-09-28 07:30:00.000 +0200|2012-09-28 08:00:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-28_073000_HF|
|6 215 |2012-09-28 22:00:00.000 +0200|2012-09-28 22:30:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-28_220000_HF|
|6 245 |2012-09-29 07:00:00.000 +0200|2012-09-29 07:30:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-29_070000_HF|
|6 277 |2012-09-29 20:00:00.000 +0200|2012-09-29 20:30:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-29_200000_HF|
|6 291 |2012-09-29 23:30:00.000 +0200|2012-09-30 00:00:00.000 +0200|volet       |-7      |5                |1,03     |0         |false     |2012-09-29_233000_HF|
|10 636|2012-12-27 18:00:00.000 +0100|2012-12-27 18:29:00.000 +0100|vanne       |-3      |2,08             |-6,82    |3         |false     |2012-12-27_180000_HF|


SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id IN (5938,5995,6015,6071,6075,6177,6215,6245,6277,6291,10636)
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id IN (5938,5995,6015,6071,6075,6177,6215,6245,6277,6291,10636) ORDER BY dsr_dsf_id, dsr_csotdb

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3657;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3691;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3711;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3743;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3747;

UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3818;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3836;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3860;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3872;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=3886;
UPDATE did.t_didsonread_dsr
  SET dsr_csotismin=false
  WHERE dsr_id=5514;
UPDATE did.t_didsonread_dsr
  SET dsr_comment='Le fichier plein est perdu mais ici c''est le même nombre',dsr_csotismin=true
  WHERE dsr_id=5515;