SET search_path TO did,public;

SELECT sub1.dsf_timeinit, dsf_id, count_psf, count_dsr FROM(
  SELECT dsf_timeinit , dsf_id, count(*)  AS count_psf 
  FROM  t_didsonfiles_dsf 
    JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
    JOIN t_didsonreadresult_drr ON drr_dsr_id=dsr_id
    JOIN t_poissonfile_psf ON psf_drr_id=drr_id
    WHERE dsr_csotismin
    AND dsr_pertefichiertxt IS FALSE
    AND psf_species='2038'
    group by dsf_timeinit, dsf_id) sub1
LEFT JOIN (
  SELECT dsf_timeinit,sum(dsr_eelplus) + sum(dsr_eelminus) AS count_dsr
  FROM  t_didsonfiles_dsf 
    LEFT JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
    WHERE dsr_csotismin
    AND dsr_pertefichiertxt IS FALSE
    group by dsf_timeinit )sub2
ON sub1.dsf_timeinit=sub2.dsf_timeinit
WHERE count_psf!=count_dsr
  ORDER BY sub1.dsf_timeinit;

-- 2025 41 errors in 2023-2024 ???

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232091
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 232091
-- one drr downstream
-- zero drr_eeminus
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232091)

UPDATE t_didsonreadresult_drr SET drr_eelminus = 1 WHERE drr_id = 'FC_CSOT_2023-10-25_223000_HF_P0959';
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79499 AND dsr_dsf_id = 232091;

-- 2023-11-01 22:30:00.000 +0100 232427

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232427
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 232427
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232427)
-- 18 drr eelplus
-- 0 drr_eeminus
-- 18 up 1 dn dans t_poissonfile

UPDATE did.t_didsonread_dsr
  SET dsr_eelminus=1
  WHERE dsr_id=79596;

--2023-11-03 10:30:00.000 +0100 232499

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232499
-- 0 drr eelplus
-- 0 drr_eeminus
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232499)
-- 1 Dn 2038 10:34 OK
UPDATE t_didsonreadresult_drr SET drr_eelminus = 1 WHERE drr_id = 'FC_CSOT_2023-11-03_103000_HF_P1421';
-- 18 up 1 dn dans t_poissonfile
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 232499;-- 79635
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79635 AND dsr_dsf_id = 232499;

-- 2023-11-03 17:00:00.000 +0100 232512

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232512; -- FC_CSOT_2023-11-03_170000_HF_P1004
-- 5 drr eelplus
-- 0 drr_eeminus (1 drr_downstream)
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232512)
-- 5 Up 1 Dn 2038 17:01 17:22 OK
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 232512; -- dsr_id 79648
UPDATE t_didsonreadresult_drr SET drr_eelminus = 1 WHERE drr_id = 'FC_CSOT_2023-11-03_170000_HF_P1004';
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79648 AND dsr_dsf_id = 232512;

-- 2023-11-04 11:29:59.000 +0100 232549

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232549; 
-- drr_id=FC_CSOT_2023-11-04_113000_HF_P1142 -- dsr_id=79662
-- 9 drr eelplus
-- 0 drr_eeminus (1 drr_downstream)
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232549)
-- tous 2038
-- 9 Up 1 Dn 2038 17:38 17:59 OK
UPDATE t_didsonreadresult_drr SET drr_eelminus = 1 WHERE drr_id = 'FC_CSOT_2023-11-04_113000_HF_P1142';
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 232549; -- dsr_id 79662
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79662 AND dsr_dsf_id = 232549;

-- 2023-11-04 12:00:00.000 +0100 232550

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232550; 
-- drr_id=FC_CSOT_2023-11-04_120000_HF_P1152 -- dsr_id=79663
-- 4 drr eelplus
-- 0 drr_eeminus (1 drr_downstream)
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232550)
-- tous 2038
-- 4 Up 1 Dn 2038 12:00 12:20 OK
UPDATE t_didsonreadresult_drr SET drr_eelminus = 1 WHERE drr_id = 'FC_CSOT_2023-11-04_120000_HF_P1152';
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 232550; 
-- 4 dsr_eelplus
-- 0 dsr_eelminus ?
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79663 AND dsr_dsf_id = 232550;

-- 2023-11-04 12:30:00.000 +0100 232551

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232551; 
-- drr_id=FC_CSOT_2023-11-04_123000_HF_P1209 -- dsr_id=79664
-- 2 drr eelplus
-- 0 drr_eeminus (1 drr_downstream)
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232551)
-- tous 2038
-- 2 Up 1 Dn 2038 12:38 12:56 OK
UPDATE t_didsonreadresult_drr SET drr_eelminus = 1 WHERE drr_id = 'FC_CSOT_2023-11-04_123000_HF_P1209';
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 232551; 
-- 4 dsr_eelplus
-- 0 dsr_eelminus 
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79664 AND dsr_dsf_id = 232551;

--2023-11-10 23:00:00.000 +0100 232860

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232860; 
-- drr_id=FC_CSOT_2023-11-10_230000_HF_P1419 -- dsr_id=79784
-- 1 drr eelplus
-- 0 drr_eeminus (1 drr_downstream)
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 232860)
-- tous 2038
-- 2 Up 1 Dn 2038 12:38 12:56 OK
UPDATE t_didsonreadresult_drr SET drr_eelminus = 1 WHERE drr_id = 'FC_CSOT_2023-11-10_230000_HF_P1419';
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 232860; 
-- 4 dsr_eelplus
-- 0 dsr_eelminus 
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79784 AND dsr_dsf_id = 232860;

-- 2023-11-17 19:30:00.000 +0100 233189

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 233189; 
-- drr_id=FC_CSOT_2023-11-17_193000_HF_P1142 -- dsr_id=79835
-- 1 drr eelplus (1 drr_upstream)
-- 1 drr_eeminus (1 drr_downstream)
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 233189)
-- tous 2038
-- 1 Up 1 Dn 2038 time OK
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 233189; 
-- 1 dsr_eelplus
-- 0 dsr_eelminus 
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79835 AND dsr_dsf_id = 233189;

-- 2023-11-22 00:00:00.000 +0100 233390

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsf_id = 233390; 
-- drr_id=FC_CSOT_2023-11-22_000000_HF_P1111 -- dsr_id=79937
-- 0 drr eelplus (0 drr_upstream)
-- 1 drr_eeminus (1 drr_downstream)
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 
(SELECT drr_id FROM t_didsonreadresult_drr WHERE drr_dsf_id = 233390)

-- 0 Up 1 Dn 2038 time OK
SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id = 233390; 
-- 0 dsr_eelplus
-- 0 dsr_eelminus 
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id = 79937 AND dsr_dsf_id = 233390;

-- Fait plus rapidement :
2023-12-03 23:00:00.000 +0100 233964
2023-12-04 18:00:00.000 +0100 234002
2023-12-04 23:29:59.000 +0100 234013
2023-12-05 20:29:59.000 +0100 234055
2023-12-06 00:30:00.000 +0100 234063
2023-12-06 23:00:00.000 +0100 234108
2023-12-10 00:00:00.000 +0100 234254
2023-12-10 05:29:59.000 +0100 234265
2023-12-14 08:00:00.000 +0100 234462
2023-12-14 20:00:00.000 +0100 234486
2023-12-15 08:00:00.000 +0100 234510
2023-12-19 00:00:00.000 +0100 234686
2024-01-04 00:00:00.000 +0100 235454
2024-01-04 19:30:00.000 +0100 235493
2024-02-09 00:30:00.000 +0100 237183
2024-02-09 00:59:59.000 +0100 237184
2024-02-09 01:30:00.000 +0100 237185
2024-02-09 18:59:59.000 +0100 237217
2024-02-11 02:00:00.000 +0100 237279
2024-02-11 02:29:59.000 +0100 237280
2024-02-12 21:30:00.000 +0100 237366
2024-02-14 05:00:00.000 +0100 237429
2024-02-15 22:30:00.000 +0100 237512
2024-02-22 06:00:00.000 +0100 237815
2024-02-24 19:30:00.000 +0100 237938
2024-03-03 22:30:00.000 +0100 238328
2024-04-01 00:00:00.000 +0200 239675
2024-04-02 00:00:00.000 +0200 239723
2024-04-06 00:00:00.000 +0200 239915
2024-04-09 00:59:59.000 +0200 240061
2024-12-01 20:30:00.000 +0100 289959

-- OK trouvé, c'est toujours eel minus en 2023 2024, j'ai corrigé les drr en relançant 
  
UPDATE t_didsonreadresult_drr SET drr_eelminus= dn 
  FROM tempcountfromdsf
  WHERE psf_drr_id=drr_id AND drr_dsr_id in 
  (SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
  WHERE dsf_season='2023-2024'); 

-- et


UPDATE t_didsonread_dsr SET (dsr_eelplus,dsr_eelminus)  = (sub.drr_eelplus,sub.drr_eelminus) from
( SELECT dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE  dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
AND dsr_csotismin
AND dsf_season='2023-2024') sub
WHERE sub.dsf_id=dsr_dsf_id; --31

