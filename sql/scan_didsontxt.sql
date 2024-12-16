/*
scan_didsontxt.sql
AttentiON il faut avoir lancé scan_didson.R
et integration_bd.R (pour intégrer les fichiers excel)
ATTENTION TRAVAILLER SUR UNE COPIE LOCALE. LES CHANGEMNTS DE LA BASE HISTORIQUE
SE SONT FAITS AVEC L'INTERFACE GRAPHIQUE !!!!!!!!
NE PAS CHANGER LES DONNEES HISTORIQUES

POUR MODIFIER LES DONNEES UTILISER DIDSON2.odb dans le dossier workspace/p/didson. Cette interface fonctionne mais attentiON avec l'ascenseur.... 
RESTER CLIQUE POUR N'ENVOYER QU'UNE COMMANDE
*/
STOP ERROR IF ALL LAUNCHED YOU DONT WANT TO DO THAT

SET search_path TO did,public;
--SELECT * FROM t_didsonfiles_dsf;
--SELECT * FROM did.t_poissonsfiletemp_psf;
-- vérificatiON qu'il n'y a pas eu deux enregistrements dans la base
/*
NETTOYAGE SI BUG DANS IMPORT FICHIER DSF 
*/
/*
DELETE FROM did.t_poissonfile_psf WHERE psf_drr_id in 
(SELECT drr_id FROM t_didsonreadresult_drr
	WHERE drr_dsf_id in (SELECT dsf_id FROM t_didsonfiles_dsf where
			dsf_season='2021-2022')
	);

DELETE  FROM t_didsonreadresult_drr
	WHERE drr_dsf_id in (SELECT dsf_id FROM t_didsonfiles_dsf where
			dsf_season='2021-2022');
	
DELETE  FROM t_didsonread_dsr
	WHERE dsr_dsf_id in (SELECT dsf_id FROM t_didsonfiles_dsf where
      dsf_season='2021-2022'); --3594
      
DELETE  FROM t_didsonfiles_dsf
	where
      dsf_season='2021-2022';--9993
*/

ALTER TABLE did.t_didsonfiletemp_dsft ADD CONSTRAINT c_pk_dsft_id PRIMARY KEY (dsft_id);



-- changements spécifiques à l'import 2013"
/*
UPDATE t_didsonfiletemp_dsft SET 
	dsft_filename= substring(dsft_filename,1,16)||'0'||substring(dsft_filename,18,10) 
	WHERE substring(dsft_filename,17,1)='1';--30
*/
-- corrections pre contrainte 2019
/*
 * 
UPDATE did.t_didsonfiletemp_dsft SET (dsft_filename,dsft_id)=('2019-12-15_023000_HF','FC_CSOT_2019-12-15_023000_HF') 
WHERE dsft_id='FC_CSOT_2019-12-15_020000_HF'
AND dsft_upstream=2; --1
 */

-- vérificatiON que le fichier dsf est déjà dans la base
-- la requête qui suit doit renvoyer zéro lignes 
SELECT * FROM t_didsonfiles_dsf 
      FULL OUTER JOIN t_didsonfiletemp_dsft 
      ON dsf_filename=dsft_filename WHERE dsf_id IS NULL; -- doit renvoyer zero lignes
-- vérificatiON que les poissons n'ont pas été rentrés les uns à la suite des autres
SELECT * FROM did.t_poissonsfiletemp_psf WHERE psf_file>1; -- doit renvoyer zero lignes

/*
BEGin;
UPDATE did.t_poissonsfiletemp_psf SET psf_file =1 WHERE psf_file>1;
UPDATE did.t_didsonfiletemp_dsft SET dsft_filename='2019-01-26_040000_HF' WHERE dsft_filename='2019-01-26_040001_HF'; --1
COMMIT; 
*/
SELECT * FROM did.t_didsonfiletemp_dsft; -- doit renvoyer les lignes avec l'année en cours (ou les lignes supplémentaires à ajouter)

/* corrections 2016
SELECT * FROM t_didsonfiles_dsf WHERE dsf_season='2015-2016' ORDER BY dsf_timeinit ;
SELECT dsf_incl,dsf_depth FROM t_didsonfiles_dsf  WHERE dsf_timeinit>'2016-04-27 16:00:00';
UPDATE t_didsonfiles_dsf  SET (dsf_incl,dsf_depth)=(-7,0) WHERE dsf_timeinit>='2016-04-27 16:00:00'; --159
SELECT dsf_timeinit, dsf_incl,dsf_depth FROM t_didsonfiles_dsf  WHERE dsf_season='2015-2016'  AND dsf_position='volet';
UPDATE t_didsonfiles_dsf SET dsf_incl=-7 WHERE dsf_season='2015-2016'  AND dsf_position='volet';
*/


/* 
corrections 2017
UPDATE t_didsonfiletemp_dsft SET dsft_filename='2017-04-04_183000_HF' WHERE  dsft_filename='2017-04-04_183001_HF'

*/
-- pour vérifier jointure (il doit y avoir des lignes complètes et d'autres non)
SELECT * FROM t_didsonfiles_dsf 
FULL OUTER JOIN t_didsonfiletemp_dsft ON dsf_filename=dsft_filename
WHERE dsf_season IS NULL
ORDER BY dsf_timeinit;

/*runnonce IGNORE ME
ALTER TABLE did.t_didsonfiles_dsf ADD COLUMN dsf_season character varying(30);
UPDATE did.t_didsonfiles_dsf SET dsf_season='2012-2013' WHERE  dsf_timeinit>='2012-09-01 00:00:00' AND dsf_timeinit<='2013-05-01 00:00:00';
UPDATE did.t_didsonfiles_dsf SET dsf_season='2013-2014' WHERE  dsf_timeinit>='2013-09-01 00:00:00' AND dsf_timeinit<='2014-05-01 00:00:00';
UPDATE did.t_didsonfiles_dsf SET dsf_season='2014-2015' WHERE  dsf_timeinit>='2014-09-01 00:00:00' AND dsf_timeinit<='2015-05-01 00:00:00';
SELECT * FROM did.t_didsonfiles_dsf  WHERE dsf_season IS NULL;
ALTER TABLE did.t_didsonfiles_dsf ADD COLUMN dsf_mois integer;
*/

/* runonce
ALTER TABLE did.t_didsonreadresult_drr ADD CONSTRAINT c_pk_drr_id primary key (drr_id);
ALTER TABLE t_didsonreadresult_drr ADD CONSTRAINT c_fk_drr_dsf_id foreign key (drr_dsf_id) references did.t_didsonfiles_dsf(dsf_id);
ALTER TABLE t_didsonreadresult_drr ADD CONSTRAINT c_fk_drr_dsr_id foreign key (drr_dsr_id) references did.t_didsonread_dsr(dsr_id);
ALTER TABLE t_didsonread_dsr ADD COLUMN dsr_csotismin boolean;
DROP TABLE if exists t_didsonreadresult_drr;
ALTER TABLE t_didsonfiletemp_dsft rename to t_didsonreadresult_drr;
ALTER TABLE t_didsonreadresult_drr rename column dsft_id to drr_id;
ALTER TABLE t_didsonreadresult_drr rename column "dsft_unknown" to drr_unknown;
ALTER TABLE t_didsonreadresult_drr rename column dsft_downstream to drr_downstream;
ALTER TABLE t_didsonreadresult_drr rename column dsft_upstream to drr_upstream;
ALTER TABLE t_didsonreadresult_drr rename column dsft_totalfish to drr_totalfish;
ALTER TABLE t_didsonreadresult_drr rename column dsft_windowend_m to drr_windowend_m;
ALTER TABLE t_didsonreadresult_drr rename column dsft_windowstart_m to drr_windowstart_m;
ALTER TABLE t_didsonreadresult_drr rename column dsft_csotminthreshold_db to drr_csotminthreshold_db;
ALTER TABLE t_didsonreadresult_drr rename column "dsft_csotmincluster_cm2" to drr_csotmincluster_cm2;
ALTER TABLE t_didsonreadresult_drr rename column dsft_threshold_db to drr_threshold_db;
ALTER TABLE t_didsonreadresult_drr rename column dsft_intensity_db to drr_intensity_db;
ALTER TABLE t_didsonreadresult_drr rename column dsft_editorid to drr_editorid;
ALTER TABLE t_didsonreadresult_drr rename column dsft_countfilename to drr_countfilename;
ALTER TABLE t_didsonreadresult_drr rename column dsft_upstreammotiON to drr_upstreammotion;
ALTER TABLE t_didsonreadresult_drr rename column dsft_end to drr_end;
ALTER TABLE t_didsonreadresult_drr rename column dsft_start to drr_start;
ALTER TABLE t_didsonreadresult_drr rename column dsft_date to drr_date;
ALTER TABLE t_didsonreadresult_drr rename column dsft_path to drr_path;
ALTER TABLE t_didsonreadresult_drr rename column dsft_filename to drr_filename;
ALTER TABLE t_didsonreadresult_drr ADD COLUMN drr_dsf_id integer;
ALTER TABLE t_didsonreadresult_drr ADD COLUMN drr_dsr_id integer;

create table t_poissonfile_psf AS SELECT * FROM t_poissonsfiletemp_psf --2541
ALTER TABLE t_poissonfile_psf rename column psf_id to psf_drr_id;
ALTER TABLE t_poissonfile_psf ADD COLUMN psf_id serial primary key;
ALTER TABLE did.t_poissonfile_psf ADD CONSTRAINT c_fk_psf_drr_id foreign key (psf_drr_id) references did.t_didsonreadresult_drr(drr_id);

*/


/*
 * Problème d'arrondi sur les horodates en 2022
 * 
 */
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_timeinit !=
 date_trunc('second', dsf_timeinit + INTERVAL '0.5' SECOND)

UPDATE did.t_didsonfiles_dsf SET dsf_timeinit= date_trunc('second', dsf_timeinit + INTERVAL '0.5'SECOND) 
WHERE  dsf_timeinit>='2021-09-01 00:00:00' 
AND dsf_timeinit<='2022-05-01 00:00:00';


*/
-- mise à jour du champ dsf_season
--SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_season IS NULL;


SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_season='2019-2020';
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_season='2017-2018';
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_season='2020-2021';
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_season='2021-2022';
SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_season='2023-2024';
UPDATE did.t_didsonfiles_dsf SET dsf_season='2015-2016' WHERE  dsf_timeinit>='2015-09-01 00:00:00' AND dsf_timeinit<='2016-05-01 00:00:00'; --10608
UPDATE did.t_didsonfiles_dsf SET dsf_season='2016-2017' WHERE  dsf_timeinit>='2016-09-01 00:00:00' AND dsf_timeinit<='2017-05-01 00:00:00'; --9277
UPDATE did.t_didsonfiles_dsf SET dsf_season='2017-2018' WHERE  dsf_timeinit>='2017-09-01 00:00:00' AND dsf_timeinit<='2018-05-01 00:00:00'; --5784
UPDATE did.t_didsonfiles_dsf SET dsf_season='2018-2019' WHERE  dsf_timeinit>='2018-09-01 00:00:00' AND dsf_timeinit<='2019-05-01 00:00:00'; --7602
UPDATE did.t_didsonfiles_dsf SET dsf_season='2019-2020' WHERE  dsf_timeinit>='2019-09-01 00:00:00' AND dsf_timeinit<='2020-05-01 00:00:00'; --9551
UPDATE did.t_didsonfiles_dsf SET dsf_season='2020-2021' WHERE  dsf_timeinit>='2020-09-01 00:00:00' AND dsf_timeinit<='2021-05-01 00:00:00'; --10175
UPDATE did.t_didsonfiles_dsf SET dsf_season='2021-2022' WHERE  dsf_timeinit>='2021-09-01 00:00:00' AND dsf_timeinit<='2022-05-01 00:00:00'; --9993
UPDATE did.t_didsonfiles_dsf SET dsf_season='2022-2023' WHERE  dsf_timeinit>='2022-09-01 00:00:00' AND dsf_timeinit<='2023-05-02 00:00:00'; --8367
UPDATE did.t_didsonfiles_dsf SET dsf_season='2023-2024' WHERE  dsf_timeinit>='2023-09-01 00:00:00' AND dsf_timeinit<='2024-05-02 00:00:00'; --9469

UPDATE did.t_didsonfiles_dsf SET dsf_mois =EXTRACT(month FROM dsf_timeinit);--109909  Insertion des données des tables temporaires 
-- verif qu'elles sont déjà dedans (avant DELETE)


-- verif qu'elles sont déjà dedans (avant DELETE) : doit ne rien renvoyer
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id in
(SELECT psf_id FROM t_poissonsfiletemp_psf);

-- A ne lancer que pour les données supplémentaires (intégrées après coup... changement de nom de table)
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id in
(SELECT psf_id FROM t_poissonsfiletemppb_psf);

-- suppressions au cas ou il y aurait déjà eu des imports
DELETE FROM t_poissonfile_psf WHERE psf_drr_id in
(SELECT psf_id FROM t_poissonsfiletemp_psf);--0

DELETE FROM t_didsonreadresult_drr WHERE drr_id in
(SELECT dsft_id FROM t_didsonfiletemp_dsft) ;--0


/*
INSERTION DES RESULTATS DES TABLES TEMPORAIRES DANS LA BASE
*/

INSERT INTO t_didsonreadresult_drr(
drr_id,drr_unknown,drr_downstream,drr_upstream,drr_totalfish,drr_windowend_m,
drr_windowstart_m,drr_csotminthreshold_db,drr_csotmincluster_cm2,drr_threshold_db,
drr_intensity_db,drr_editorid,drr_countfilename,drr_upstreammotion,drr_end,drr_start,
drr_date,drr_path,drr_filename
) SELECT 
dsft_id,dsft_unknown,dsft_downstream,dsft_upstream,dsft_totalfish,dsft_windowend_m,
dsft_windowstart_m,dsft_csotminthreshold_db,dsft_csotmincluster_cm2,dsft_threshold_db,
dsft_intensity_db,dsft_editorid,dsft_countfilename,dsft_upstreammotion,dsft_end,dsft_start,
dsft_date,dsft_path,dsft_filename
 FROM 
t_didsonfiletemp_dsft;--1323 # 2014 902 2015 951 2016 1421 2017 477 2018 (+34+4+38(jour) 2018) 848 2019 690 2020 985 2021 811 2022 780 2023 903 2024

-- !!!! a ne lancer que pour les données supplémentaires
INSERT INTO t_didsonreadresult_drr(
drr_id,drr_unknown,drr_downstream,drr_upstream,drr_totalfish,drr_windowend_m,
drr_windowstart_m,drr_csotminthreshold_db,drr_csotmincluster_cm2,drr_threshold_db,
drr_intensity_db,drr_editorid,drr_countfilename,drr_upstreammotion,drr_end,drr_start,
drr_date,drr_path,drr_filename
) SELECT 
dsft_id,dsft_unknown,dsft_downstream,dsft_upstream,dsft_totalfish,dsft_windowend_m,
dsft_windowstart_m,dsft_csotminthreshold_db,dsft_csotmincluster_cm2,dsft_threshold_db,
dsft_intensity_db,dsft_editorid,dsft_countfilename,dsft_upstreammotion,dsft_end,dsft_start,
dsft_date,dsft_path,dsft_filename
 FROM 
did.t_didsonfiletemppb_dsft
--WHERE dsft_id !='FC_CSOT_2023-01-28_000000_HF_P1049';
 --2 (2019) 20(2022)



INSERT INTO t_poissonfile_psf
(psf_drr_id,psf_comment,psf_n,psf_q,psf_move,psf_motion,psf_species,psf_roll,psf_tilt,
psf_pan,psf_longitude_unit,psf_longitude4,psf_longitude3,psf_longitude2,psf_longitude1,
psf_latitude_unit,psf_latitude4,psf_latitude3,psf_latitude2,psf_latitude1,psf_date,psf_time,
psf_aspect,psf_ldr,psf_dr_cm,psf_l_cm,psf_theta,psf_radius_m,psf_dir,psf_frame,psf_total,psf_file)
 SELECT 
 psf_id,psf_comment,psf_n,psf_q,psf_move,psf_motion,psf_species,psf_roll,psf_tilt,
psf_pan,psf_longitude_unit,psf_longitude4,psf_longitude3,psf_longitude2,psf_longitude1,
psf_latitude_unit,psf_latitude4,psf_latitude3,psf_latitude2,psf_latitude1,psf_date,psf_time,
psf_aspect,psf_ldr,psf_dr_cm,psf_l_cm,psf_theta,psf_radius_m,psf_dir,psf_frame,psf_total,psf_file
 FROM did.t_poissonsfiletemp_psf;--3429 --1972 -- 2303 --4744 --2031 --1314 (+44+4+87(jour) 2018) 1742 2019 1432 2020 2044 2021 1942 2022 2429 2023 2079 2024

 
 
 
-- a ne lancer que pour les données supplémentaires
INSERT INTO t_poissonfile_psf
(psf_drr_id,psf_comment,psf_n,psf_q,psf_move,psf_motion,psf_species,psf_roll,psf_tilt,
psf_pan,psf_longitude_unit,psf_longitude4,psf_longitude3,psf_longitude2,psf_longitude1,
psf_latitude_unit,psf_latitude4,psf_latitude3,psf_latitude2,psf_latitude1,psf_date,psf_time,
psf_aspect,psf_ldr,psf_dr_cm,psf_l_cm,psf_theta,psf_radius_m,psf_dir,psf_frame,psf_total,psf_file)
 SELECT 
 psf_id,psf_comment,psf_n,psf_q,psf_move,psf_motion,psf_species,psf_roll,psf_tilt,
psf_pan,psf_longitude_unit,psf_longitude4,psf_longitude3,psf_longitude2,psf_longitude1,
psf_latitude_unit,psf_latitude4,psf_latitude3,psf_latitude2,psf_latitude1,psf_date,psf_time,
psf_aspect,psf_ldr,psf_dr_cm,psf_l_cm,psf_theta,psf_radius_m,psf_dir,psf_frame,psf_total,psf_file
 FROM did.t_poissonsfiletemppb_psf; --3 (2019) 66(2022)

/*
Attention si le nombre de lignes renvoyé est indentique à l'année dernière, 
tu as oublié t'intégrer le fichier t_didsonfile_dsf il faut lancer le programme
integration_bd.R en vérifiant que les identifiants sqldf de connexion pointent bien vers la bonne base
*/

SELECT count(*) FROM t_didsonfiles_dsf  dsf JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename;--1322 --2455 -- 3518 --4940 -5660 --6195 --6234--7082 -- 7774 -- 8759 --9570 -- 10372 --11290

/*
##################################
creation des drr_dsf_id : ON joint les fichiers texte de lecture didson aux fichiers de la base
##################################

##########################
RECHERCHE DES FICHIERS DOUBLES
sera règlé plus loin par la fixatiON d'un csotismin
donc ne pas s'affoler sur cette requete ON traite ce cas plus loin
###########################
*/
SELECT * FROM (
SELECT dsf_id,dsf_season, dsf_timeinit,dsr_csotismin, dsr_id,drr_id,drr_dsf_id,drr_dsr_id,dsr_reader,dsr_csotdb, drr_threshold_db,dsr_eelplus,dsr_eelminus,drr_totalfish,drr_upstream,drr_downstream,drr_filename,
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr 
FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
ORDER BY countdsr, dsf_id desc) sub
WHERE dsf_season='2023-2024'
AND countdrr>1
; --128 2015 4 2016 8 2017 44 2018 0 2019 0 2020 0 2021 0 2022 4 2023 32 2024


/*
2016
Après avoir travaillé je sais que les fichiers poissON sont que pour les csot 2.1 pour le cas suivant
UPDATE t_didsonread_dsr SET dsr_csotismin=TRUE WHERE dsr_id=35182;
UPDATE t_didsonread_dsr SET dsr_csotismin=TRUE WHERE dsr_id=35030;

*/
/*
##########################
MISE A JOUR DES LIENS
cette procédure ne devrait plus être aussi fastidieuse une fois que seront renseignés les utilisateurs dans les lectures
des fichiers didson.
###########################
*/
-- ci dessous certains fichiers n'ont pas encore le drr_dsr_id renseigné.
-- SELECT * FROM t_didsonreadresult_drr WHERE drr_dsr_id IS NULL;--1037 2015 1421 2016 849 2019 811 2022
/*
recherche des fichiers avec plusieurs lecteurs
le script donne un count drr et un count dsr
normalement une double lecture correspond à 4 lignes 

SELECT * FROM (
SELECT dsf_id,dsr_id,dsr_csotismin,drr_id,drr_dsf_id,drr_dsr_id,dsr_reader,dsr_csotdb, drr_threshold_db,dsr_eelplus,dsr_eelminus,drr_totalfish,drr_upstream,drr_downstream,drr_filename,
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr 
FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
WHERE dsf_season='2020-2021'
ORDER BY countdsr, dsf_id desc) toto
WHERE countdsr>1 or countdrr>1;
*/
/*
2016
-------------------
deux fichiers avec même horaire, même lecteur même csot
SELECT * FROM t_didsonfiles_dsf  WHERE dsf_id=99167;
SELECT *  FROM t_didsonread_dsr dsr WHERE dsr_dsf_id=99167;
SELECT * FROM t_didsonreadresult_drr WHERE drr_id='FC_CSOT_2016-04-09_013000_HF_P1642'
-- les résultats sont les mêmes j'en supprime un des deux
DELETE FROM t_poissonfile_psf WHERE psf_drr_id='FC_CSOT_2016-04-09_013000_HF_P1639' ;--1
DELETE FROM t_didsonreadresult_drr WHERE drr_id='FC_CSOT_2016-04-09_013000_HF_P1639' ;--1
*/

/* 
Le fait d'avoir plusieurs fichiers pose évidemment des problèmes de jointure
Ci dessous une requete sans trop d'intérêt qui donne les problèmes
Il y en a beaucoup qui ne sont pas bons, mais le champ drr_totalfish ne semble pas très bien renseigné !
C'est corrigé plus loin
*/
*/
SELECT drr_id,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus AS total,drr_totalfish,drr_upstream,drr_downstream
FROM t_didsonfiles_dsf  dsf JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
WHERE drr_totalfish!=(dsr_eelplus-dsr_eelminus)
AND dsf_season='2023-2024'
ORDER BY drr_id; --319  -- 12 2016-2017 --5 2017-2018 --6 2018-2019 --5 2019-2020 --17 2020-2021 13 2021-2022 98 2022-2023 195 2023-2024
*/

/*
Etape 0 mise a jour des dsf_id....
Facile car clé primaire sur drr_id, à partir du nom du ficher drr_id (FC_CSOT...) or récupère le dsf_id et on les mets dans t_didsonreadresult_drr
*/

--UPDATE t_didsonreadresult_drr SET drr_dsr_id=NULL;

WITH dsf_drr AS 
(
SELECT dsf_id,drr_id FROM   t_didsonfiles_dsf  dsf 
JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
AND dsf_season='2023-2024'
)
UPDATE t_didsonreadresult_drr SET drr_dsf_id=dsf_drr.dsf_id FROM dsf_drr
WHERE dsf_drr.drr_id=t_didsonreadresult_drr.drr_id 
AND drr_dsf_id IS NULL
;--1306	--2205 -- 3182 --5  --1420 (2016) --716 (2017) --477 2018 (+34 +4 + 38 2018) 848 2019 -- 690 + 2 2020 833 2022 902 2023

/*
MISE A JOUR DES dsr_id
Etape 1 recherche des relations 1 a 1
Il n'est pas possible de mettre un partitiON by dans une clause WHERE d'ou la requête un peu compliquée
comptage des dsf_id, et SELECTiON de ceux ou il n'y a qu'un dsf_id
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ATTENTION METTRE A JOUR LA DATE (SAISON)!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

*/



UPDATE t_didsonreadresult_drr SET (drr_dsr_id, drr_dsf_id)=(dsr_id, dsf_id) FROM 
(
	SELECT dsf_id,dsr_id,drr_id FROM  t_didsonfiles_dsf  dsf 
	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
	JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
	WHERE dsf_id in (
	SELECT dsf_id FROM (
	SELECT dsf_id,
	count (*) OVER (PARTITION BY drr_id)
	FROM   t_didsonfiles_dsf  dsf 	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
					JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
					WHERE dsf_season='2023-2024')sub
	WHERE count=1)
) uqr	
WHERE uqr.drr_id=t_didsonreadresult_drr.drr_id 
AND drr_dsr_id IS NULL
;
--1095	--868 --1418(2016) -- 712 (2017) --456 (2018) (+33 +4 + 37 2018) 847 2019 690 +2  
-- 2020 985 2021 811 2022 778 (+20) 2023 885 (2024)

/* pb 2014
SELECT * FROM t_didsonreadresult_drr WHERE drr_dsr_id=23746
SELECT * FROM t_didsonfiles_dsf WHERE dsf_id in (SELECT dsr_dsf_id FROM t_didsonread_dsr WHERE dsr_id=23746)
DELETE FROM t_poissonfile_psf WHERE psf_drr_id='FC_CSOT_2014-02-11_040000_HF_P0905';
DELETE FROM t_didsonreadresult_drr WHERE drr_id='FC_CSOT_2014-02-11_040000_HF_P0905';

DELETE FROM t_poissonfile_psf WHERE psf_drr_id='FC_CSOT_2014-03-28_000000_HF_P1012';
DELETE FROM t_didsonreadresult_drr WHERE drr_id='FC_CSOT_2014-03-28_000000_HF_P1012';

DELETE FROM t_poissonfile_psf WHERE psf_drr_id='FC_CSOT_2013-11-06_233000_HF_P1408';
DELETE FROM t_didsonreadresult_drr WHERE drr_id='FC_CSOT_2013-11-06_233000_HF_P1408';
*/

/* pb 2015

SELECT drr.*
FROM   t_didsonfiles_dsf  dsf 	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
					JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
 WHERE dsf_timeinit>='2014-09-01 00:00:00' AND dsf_timeinit<='2015-05-01 00:00:00'

-- temp 2015
-- il faut que je réaffecte gerard2 à la place de gerard pour les lectures doubles
-- ci dessous une requête qui doublonne les lignes mais montre que les données avec relecture sont toutes drr_csotminthreshold_db=0
 SELECT * FROM (
SELECT dsf_id,
dsf_timeinit,
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
JOIN t_didsonreadresult_drr drr ON (drr_filename)=(dsf_filename)
) sub
WHERE  countdsf=2
AND dsf_timeinit>='2014-09-01 00:00:00' 
AND dsf_timeinit<='2015-05-01 00:00:00'
ORDER BY dsf_id, dsr_id,drr_csotminthreshold_db

UPDATE t_didsonreadresult_drr SET drr_editorid='gerard2' WHERE drr_id in
(SELECT drr_id FROM (
SELECT dsf_id,
dsf_timeinit,
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
count (*) OVER (PARTITION BY dsr_id) AS countdsr,
count (*) OVER (PARTITION BY dsf_id) AS countdsf  
FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
) sub
WHERE  countdsf=2
AND dsf_season='2014-2015'
AND drr_csotminthreshold_db=0);--25


 Ci dessous c'est parce que je suis déjà passé une fois que j'ai des valeurs manquantes
 en gros maintenant tout le monde a un dsf, un dsr dans le fichier drr mais il y a des doublons pour les utilisateurs
 deux lignes pour 'gerard' alors qu'il faudrait 'gerard2' et 'gerard'


SELECT * FROM (
SELECT dsf_id,
dsf_timeinit,
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
count (*) OVER (PARTITION BY dsr_id) AS countdsr,
count (*) OVER (PARTITION BY dsf_id) AS countdsf  
FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
) sub
WHERE  countdsf=2
AND dsf_season='2014-2015'
ORDER BY dsf_id, dsr_id,drr_csotminthreshold_db




UPDATE t_didsonread_dsr SET dsr_reader='Gerard2' WHERE dsr_id in
(SELECT dsr_id FROM (
SELECT dsf_id,
dsf_timeinit,
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
count (*) OVER (PARTITION BY dsr_id) AS countdsr,
count (*) OVER (PARTITION BY dsf_id) AS countdsf  
FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
) sub
WHERE  countdsf=2
AND dsf_season='2014-2015'
AND drr_csotminthreshold_db=0);--25

pb 2018-2019

ERREUR: la valeur d'une clé dupliquée rompt la contrainte unique « c_uk_drr_dsr_id »
État SQL :23505
Détail :La clé « (drr_dsr_id)=(48366) » existe déjà.


WITH testUPDATEAS (

	SELECT dsf_id,dsr_id,drr_id FROM  t_didsonfiles_dsf  dsf 
	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
	JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
	WHERE dsf_id in (
	SELECT dsf_id FROM (
	SELECT dsf_id,
	count (*) OVER (PARTITION BY drr_id)
	FROM   t_didsonfiles_dsf  dsf 	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
					JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
					WHERE dsf_season='2018-2019')sub
	WHERE count=1))
 
SELECT * FROM testUPDATEWHERE dsr_id=48366

SELECT * FROM  t_didsonreadresult_drr WHERE drr_id like '%FC_CSOT_2018-12-25_213000_HF%';
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1452';
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1713';
SELECT * FROM t_poissonfile_psf WHERE psf_drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1713';
DELETE FROM t_poissonfile_psf WHERE psf_drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1713'; --1
DELETE FROM t_didsonreadresult_drr WHERE drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1713';
-- un nom changé qui joint pas
SELECT * FROM  did.t_didsonfiles_dsf WHERE dsf_filename='2019-01-26_040000_HF';
BEGIN;
UPDATE did.t_didsonfiles_dsf SET dsf_filename='2019-01-26_040001_HF'  WHERE dsf_filename='2019-01-26_040000_HF' ;--1
COMMIT;

-- pb 2024-2025



  SELECT * FROM  t_didsonfiles_dsf  dsf 
  JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
  JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
  WHERE dsf_id in (
  SELECT dsf_id FROM (
  SELECT dsf_id,
  count (*) OVER (PARTITION BY drr_id)
  FROM   t_didsonfiles_dsf  dsf   JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
          JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
          WHERE dsf_season='2023-2024')sub
  WHERE count=1 AND dsr_id=79855)
  
WITH testUPDATE AS (

  SELECT dsf_id,dsr_id,drr_id FROM  t_didsonfiles_dsf  dsf 
  JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
  JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
  WHERE dsf_id in (
  SELECT dsf_id FROM (
  SELECT dsf_id,
  count (*) OVER (PARTITION BY drr_id)
  FROM   t_didsonfiles_dsf  dsf   JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
          JOIN t_didsonreadresult_drr drr ON drr_filename=dsf_filename
          WHERE dsf_season='2023-2024')sub
  WHERE count=1)),
  duplicatedsr as (
     SELECT *, count (*) OVER (PARTITION BY dsr_id)  FROM testUPDATE WHERE  dsr_id=79855
  )
SELECT * from duplicatedsr where count>1
  
Deux fichiers de la meme anguille à 45 cm et 50 cm je garde la 50

DELETE FROM t_poissonfile_psf WHERE psf_drr_id = 'FC_2023-11-18_220000_HF_P0911';

DELETE FROM t_didsonreadresult_drr WHERE drr_id = 'FC_2023-11-18_220000_HF_P0911';

*/


/*
Etape 2 recherche des relations 1 a 1 en fonction du csotdb
Les requêtes ci dessous ne modifient que les fichiers dont le drr_dsr_id est NULL
drr_csotminthreshold_db est nul et il faut qu'il soit 0 pour tous les fichiers de l'année
*/

		
SELECT * FROM t_didsonreadresult_drr where
	drr_id in (
	SELECT drr_id FROM t_didsonfiles_dsf 
	JOIN t_didsonreadresult_drr ON drr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024'
	) AND drr_csotminthreshold_db IS NULL; 

UPDATE t_didsonreadresult_drr SET drr_csotminthreshold_db=0 WHERE drr_csotminthreshold_db IS NULL AND
	drr_id in (
	SELECT drr_id FROM t_didsonfiles_dsf 
	JOIN t_didsonreadresult_drr ON drr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024'
	); --98 --3 -- 67 --37 (2016) --36 (2017) --26 3(2018) -- 8 2 2020 0 2021 29 2022 1 2023 29 2024


-- ci dessous j'ai viré un fichier qui avait pas DSR	
SELECT dsf_filename, dsr.* FROM t_didsonread_dsr dsr
join t_didsonfiles_dsf  dsf on dsf_id=dsr_dsf_id
WHERE dsr_csotdb IS NULL and
 dsr_id in (
	SELECT dsr_id FROM t_didsonfiles_dsf 
	JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024'
	); --2019 ---317 2020 804 2021 138 2022 7 2023 79 2024 112
-- ci dessous deux fois des fichiers avec dsr_csot NULL (pas possible)
-- SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id=133245
-- DELETE FROM t_didsonread_dsr WHERE dsr_id = 46820	
-- SELECT * FROM t_didsonread_dsr WHERE dsr_dsf_id=131016
-- UPDATE t_didsonread_dsr SET dsr_complete=TRUE WHERE dsr_id=47629; --1

UPDATE t_didsonread_dsr SET dsr_csotdb=0 WHERE dsr_csotdb IS NULL and
 dsr_id in (
	SELECT dsr_id FROM t_didsonfiles_dsf 
	JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024' AND dsr_complete
	);

; --122 --4 (2016) --19 (2017)--30 (2018) --1(2018) 371 2019 801 + 0 2020 138 2021 7 2022 79 (0) 2023 107 2024
-- maintenant j'ai des csotdb partout et je peux faire la jointure à la fois sur csotdb et dsf_id
-- parmis ceux qui ne se sont pas vu adressé de dsr, lesquels ont le même nom de fichier de dépouillement drr_filename et le même csotdb
SELECT *  FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
WHERE drr_dsr_id IS NULL
AND dsf_season='2023-2024'
ORDER BY dsf_id; --2 (2016) 3 (2017) 21 (2018) 0 (2019) 0 (2020) 0 (2021) 0 (2022) 1 (0)(2023)

/*
ci dessous la requète met à jour les memes lignes que ci dessus
2020 modificatiON de la syntaxe, ça ne passe plus avec des sous requêtes
*/


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
WHERE drr_dsr_id IS NULL
AND dsf_season='2023-2024'),
dbr AS (  -- double rows
SELECT * FROM sub
WHERE  countdsr=1 -- un seul fichier texte
)

--SELECT * FROM dbr -- (décommenter pour voir le résultat avant le update)
UPDATE t_didsonreadresult_drr SET drr_dsr_id=dsr_id FROM dbr
WHERE dbr.drr_id=t_didsonreadresult_drr.drr_id 
AND t_didsonreadresult_drr.drr_dsr_id IS NULL
;--200 --20 -- 36 --2+1 rows 2016 -- 3 2017 --21 2018 (+1 2018) 0 + 0 2019 0 2020 0 2022 1 (0) 2023 5 (2024)

/*
Etape 3
Vérifier si il a quelque chose en lançant la partie interne (dans la parenthèse à partir du from)
si il n'y a rien, ignorer cette étape , si quelque chose il faudra sans doute passer en sous-requete
*/
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
AND dsf_season='2023-2024'
ORDER BY dsf_id
) 
UPDATE t_didsonreadresult_drr SET drr_dsr_id=dsr_id FROM dbr
WHERE dbr.drr_id=t_didsonreadresult_drr.drr_id ;--11--0 -- 0(2016) --0 2018 --0 2019 --0 2020 0 2022 0 2023 0 2024


/*
Pareil ignorer si il n'y a rien, si quelque chose il faudra sans doute passer en sous-requete (ré-écrire la requete avec des with)
*/
UPDATE t_didsonreadresult_drr SET (drr_dsr_id)=(dsr_id) FROM (
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
AND drr_editorid='brice'
AND dsr_reader='Brice'
AND dsf_season='2023-2024'
ORDER BY dsf_id
) dbr -- double rows
WHERE dbr.drr_id=t_didsonreadresult_drr.drr_id ;--11	--0	--0(2016) --0 2018 --0 2019 --0 2020 0 2022 0 2024

/*
UPDATE t_didsonreadresult_drr SET (drr_dsr_id)=(dsr_id) FROM (

SELECT * FROM (
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
WHERE drr_dsr_id IS NULL) sub
WHERE  countdsr=1 -- un seul fichier texte
) dbr -- double rows
WHERE dbr.drr_id=t_didsonreadresult_drr.drr_id ;--1	
*/

/*
Si la requête de vérif en dessous renvoit zéro lignes, le travail est terminé
ignorer les étapes suivantes
*/

SELECT dsf_id,
dsr_id,
drr_id,
drr_dsr_id,
dsr_reader,
drr_editorid,
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
WHERE drr_dsr_id IS NULL
AND dsf_season='2023-2024'
ORDER BY dsf_id; -- 0 lignes



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
drr_filename,
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename)=(dsf_filename)
WHERE drr_dsr_id IS NULL
AND dsf_season='2023-2024'
),
dbr AS (
SELECT * FROM sub
WHERE  countdsr=1 -- un seul fichier texte
AND dsr_csotismin
) -- double ROWS
UPDATE t_didsonreadresult_drr SET drr_dsr_id=dsr_id FROM dbr
WHERE dbr.drr_id=t_didsonreadresult_drr.drr_id
;--0--0--0 (2017)--0 (2018) 
--1 2019 (après changement du nom du fichier eg 0001') 0 + 0 2020 1 2023 0 2024

/*
Etape 4
ON VERIFIE SI IL RESTE DES drr_dsr_id nON affectés. 
Il s'agit de doubles comptages
JOINTURE SUR
drr_filename <--> dsf_filename (nom du fichier)
pour lequel drr_dsr_id reste nul.
*/

SELECT * FROM t_didsonreadresult_drr WHERE drr_dsr_id IS NULL ORDER BY drr_dsf_id; --27  1 2017 24 2018  --0 2019 --0 2020 --0 2021 --0 2023 12 2024


-- TODO si besoin passer en sous requète, la syntaxe ne marche plus, voir script précédent
-- J'ai fait à la brutos en 2023 
 -- UPDATE t_didsonreadresult_drr SET drr_dsr_id=77538 where  drr_dsr_id IS null; --1 
/*
UPDATE t_didsonreadresult_drr SET (drr_dsr_id)=(dsr_id) FROM (
SELECT dsf_id,
dsr_id,
drr_id,
drr_dsr_id,
dsr_reader,
dsr_csotdb,
drr_csotminthreshold_db,
drr_intensity_db,
dsr_eelplus,
dsr_eelminus,
drr_totalfish,
drr_upstream,
drr_downstream,
drr_filename,
count (*) OVER (PARTITION BY drr_id) AS countdrr,
count (*) OVER (PARTITION BY dsr_id) AS countdsr FROM   t_didsonfiles_dsf  dsf 
JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
JOIN t_didsonreadresult_drr drr ON (drr_filename)=(dsf_filename)
WHERE drr_dsr_id IS NULL
AND dsf_season='2023-2024'
) dbr -- double rows
WHERE dbr.drr_id=t_didsonreadresult_drr.drr_id ;--6 -- 0 (2016) --1 2017 --0 2018
*/

/*
Etape 5

*/

SELECT * FROM  t_didsonfiles_dsf  dsf JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id WHERE dsf_id in 
(SELECT drr_dsf_id FROM t_didsonreadresult_drr WHERE drr_dsr_id IS NULL )
AND dsf_season='2023-2024';--0 --0 2016 --0 2017 --0 2018 --0 2020 --0 2021 --0 2023 22 2024

SELECT * FROM  t_didsonfiles_dsf  dsf  WHERE dsf_id in 
(SELECT drr_dsf_id FROM t_didsonreadresult_drr WHERE drr_dsr_id IS NULL); -- 0(2016) 0 (2017) si zéro ça veut dire que tous les drr_dsr_id sont affectés
-- mais pas forcément qu'ils sont justes (voir plus loin)

-- contrainte
--ALTER TABLE did.t_didsonreadresult_drr ADD CONSTRAINT c_uk_drr_dsr_id unique (drr_dsr_id);


-- recherche des fichiers avec plus d'une jointure entre drr_dsr_id et dsr_id
SELECT * FROM did.t_didsonreadresult_drr WHERE drr_dsr_id in (
  SELECT drr_dsr_id FROM (
    SELECT count(drr_dsr_id),drr_dsr_id FROM did.t_didsonread_dsr
    				JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
    				group by drr_dsr_id) sub
    				WHERE count>1)
            AND drr_dsf_id in (SELECT dsf_id FROM t_didsonfiles_dsf WHERE dsf_season='2023-2024')				
ORDER BY drr_filename;--0 (2016)


/*
SELECTION DES FICHIERS AVEC MEILLEUR CSOT
*/
-- juste pour voir le dsr
/*
select t_didsonread_dsr.* FROM  t_didsonfiles_dsf 
	LEFT JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
 WHERE dsf_season='2023-2024'
 */
 -- ON COMMENCE PAR METTRE FALSE A TOUT LE MONDE

UPDATE t_didsonread_dsr SET dsr_csotismin=FALSE WHERE dsr_id in
(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id WHERE dsf_season='2023-2024'); 
--4200 --3110 (2016) 1780 (2017) 2161 2018 3366 2019 2402 2020 3594 2021 4201 2022 3194 2023 3194 2024 3009

 -- CEUX POUR LESQUELS IL N'Y A QU'UNE SEULE LECTURE SON MIN
 
UPDATE t_didsonread_dsr SET dsr_csotismin=TRUE WHERE dsr_id in (
SELECT dsr_id from(
	SELECT count (*) OVER (PARTITION BY dsf_id) c,
	dsr_id from
	t_didsonfiles_dsf  dsf 	
	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
	 WHERE dsf_season='2023-2024'
	ORDER BY dsr_id) sub
WHERE c=1); 
--3557 -6814 -- 9723 lignes pour lesquelles il n'y a qu'une valeur --3072 (2016) 
--1767 (2017) -- 2110 2018 --3364 (2019) --2402 (2020) -- 3597 (2021) -- 4021 (2022) 3192 (2023) 2987 (2023-2024)


-- CI DESSOUS ON MET A JOUR LES FICHIERS QUI ONT LE PLUS PETIT CSOT POUR LES FICHIERS DOUBLES (QUI SONT TOUS FALSE APRES L'ETAPE PRECEDENTE)
-- le SELECT min over partitiON by SELECTionne un enregistrement avec dsr_dsf_id et dsr_csotdb correspondant au CSOT le plus base
-- ON fait ensuite le UPDATEen SELECTionnant à la fois le csot et le dsf_id dans le pivot (sub.dsr_csotdb,sub.dsr_dsf_id)

UPDATE t_didsonread_dsr SET dsr_csotismin=TRUE WHERE dsr_id in
 (SELECT dsr_id FROM t_didsonread_dsr JOIN 
	(SELECT distinct  dsr_dsf_id,  min(dsr_csotdb) OVER (PARTITION BY dsr_dsf_id) AS dsr_csotdb
	FROM t_didsonread_dsr 
	WHERE dsr_csotismin=FALSE
	AND dsr_id in (SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id WHERE dsf_season='2023-2024')
	) sub 
	ON (sub.dsr_csotdb,sub.dsr_dsf_id)=(t_didsonread_dsr.dsr_csotdb,t_didsonread_dsr.dsr_dsf_id));
--329 --475 --378 --19 (2016) --6 (2017) --25 2018 --1 2019 --0 2020  --0 2021 0--2022 --1 2023 0 2023-2024


/*
CERTAINS FICHIERS ONT ETE LUS DEUX FOIS AU MEME CSOT MAIS GERARD EST TOUJOURS LE MEILLEUR !
COMPTE TENU DES MODIFICATIONS MANUELLES NE PLUS LANCER CA


UPDATE t_didsonread_dsr SET dsr_csotismin=FALSE WHERE dsr_id in 
(SELECT dsr_id FROM (
--==============================================
SELECT * FROM t_didsonread_dsr 
	WHERE dsr_dsf_id in (
		SELECT dsf_id FROM (
			SELECT dsf_id,
			count(dsf_id) c FROM t_didsonfiles_dsf 
			JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
			WHERE dsr_csotismin=TRUE 
			group by dsf_id
			) sub
		WHERE c>1)
	AND dsr_csotismin
	AND dsr_reader!='Gerard'
ORDER BY dsr_dsf_id
--==============================================
)subsub) --88 -- 393
*/
--verif qu'il n'y a plus de problème
-- si il reste des problèmes mettre à la main un FALSE pour certaines lignes (voir exemple ci-dessous)
SELECT * FROM t_didsonread_dsr 
	WHERE dsr_dsf_id in (
		SELECT dsf_id FROM (
			SELECT dsf_id,
			count(dsf_id) c FROM t_didsonfiles_dsf 
			JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
			WHERE dsr_csotismin=TRUE 
			group by dsf_id
			) sub
		WHERE c>1)
	AND dsr_csotismin
ORDER BY dsr_dsf_id
;-- 0 lignes --0 lignes (2016) --0 2017 --0 2018 0 2022 0 2023-2024
-- ATTENTION SI IL Y DES LIGNES DES AUTRES ANNEES C'EST QUE LE SCRIPT A CREE UN PB SUR LES ANNEES PRECEDENTES
-- NORMALEMENT CA NE DEVRAIT PLUS ARRIVER, LES ERREURS NE DOIVENT APPARAITRE QUE POUR L'ANNEE EN COURS

/* en 2018 j'ai  des problèmes après avoir réintégré les derniers fichiers de jour.
A chaque fois j'ai deux lignes marquées drs_csotismin=t mais pour certains fichers qui sont 2.1 ou 2.8  alors qu'il y a 0
Je mets dsr_csotismin = FALSE pour les lignes differentes de 0

with doublons AS (
SELECT * FROM t_didsonread_dsr 
	WHERE dsr_dsf_id in (
		SELECT dsf_id FROM (
			SELECT dsf_id,
			count(dsf_id) c FROM t_didsonfiles_dsf 
			JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
			WHERE dsr_csotismin=TRUE 
			group by dsf_id
			) sub
		WHERE c>1)
	AND dsr_csotismin
ORDER BY dsr_dsf_id)
-- SELECT * FROM doublons WHERE dsr_csotdb>0
UPDATE t_didsonread_dsr SET dsr_csotismin=FALSE WHERE dsr_id in (SELECT dsr_id FROM doublons WHERE dsr_csotdb>0); --25
*/

/* 2016-2017

UPDATE did.t_didsonread_dsr SET dsr_csotismin= FALSE WHERE dsr_id in (36565,36567,36569,36572)
UPDATE did.t_didsonread_dsr SET dsr_csotismin= FALSE WHERE dsr_id in (36543,36875)

*/


/*
Mise à jour de l'espèce pour les lamproies
*/
/*
CI DESSOUS NE PAS LANCER, LES LAMPROIES SONT RENSEIGNEES DANS LE FICHIER POISSON DIRECTEMENT !!!
SELECT * FROM t_didsonfiles_dsf  dsf 	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
					JOIN t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
					JOIN t_poissonfile_psf ON psf_drr_id=drr_id
					WHERE (dsr_comment like '%lamproie%'
					or dsr_comment like '%Lamproie%')
					AND dsf_season='2015-2016'; 2016 --

UPDATE t_poissonfile_psf SET psf_species='2014' WHERE psf_id in 
(SELECT psf_id FROM t_didsonfiles_dsf  dsf 	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
					JOIN t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
					JOIN t_poissonfile_psf ON psf_drr_id=drr_id
					WHERE (dsr_comment like '%lamproie%'
					or dsr_comment like '%Lamproie%')
					AND dsf_timeinit>'2013-03-01 00:00:00');--358
*/
/*
2013					
UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species IS NULL;--2801
UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species='';--2801
SELECT count(*),  psf_species FROM t_poissonfile_psf WHERE psf_date>='2013-09-01 00:00:00' AND psf_date<='2014-05-01 00:00:00'group by psf_species ; --2732 (2038) et 614 (2014)
UPDATE t_poissonfile_psf SET psf_species='2014' WHERE psf_species='lamproie';
SELECT * FROM t_poissonfile_psf WHERE psf_species='Backsliding';
SELECT * FROM t_poissonfile_psf WHERE psf_species='1';
UPDATE t_poissonfile_psf SET (psf_species,psf_motion,psf_move,psf_q,psf_n)=('2038','Backsliding','<-->',3,1) WHERE psf_id=27030;
UPDATE t_poissonfile_psf SET (psf_species,psf_longitude_unit)=('2014',NULL) WHERE psf_id=27197;
*/
/* 2014
UPDATE t_poissonfile_psf SET (psf_species,psf_motion,psf_move,psf_q,psf_n)=(NULL,'Hanging','In',4,1) WHERE psf_id=43352;
UPDATE t_poissonfile_psf SET (psf_species,psf_motion,psf_move,psf_q,psf_n)=(NULL,'Hanging','In',2,1) WHERE psf_id=43547;
UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species !='2014';--4708
*/
/*
2015
SELECT distinct psf_species FROM t_poissonfile_psf
SELECT * FROM t_poissonfile_psf WHERE psf_species='anging';
UPDATE t_poissonfile_psf SET (psf_species,psf_motion,psf_move,psf_q,psf_n)=('','Hanging','In',4,1) WHERE psf_id=47152;--1
SELECT * FROM t_poissonfile_psf WHERE psf_species='unning';
UPDATE t_poissonfile_psf SET (psf_species,psf_motion,psf_move,psf_q,psf_n)=('','Running','In',2,1) WHERE psf_id=47130;
UPDATE t_poissonfile_psf SET (psf_species,psf_motion,psf_move,psf_q,psf_n)=('','Running','In',5,1) WHERE psf_id=47145;
UPDATE t_poissonfile_psf SET (psf_species,psf_motion,psf_move,psf_q,psf_n)=('','Running','In',5,1) WHERE psf_id=47150;

SELECT * FROM t_poissonfile_psf WHERE psf_species='';
UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species !='2014'; -- 6858
UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species IS NULL; -- 6
UPDATE t_poissonfile_psf SET psf_species='2038'  WHERE psf_species!='2014' AND psf_species!='2038';--33
*/
/*
2016
SELECT distinct psf_species FROM t_poissonfile_psf
UPDATE t_poissonfile_psf SET psf_species='2014' WHERE psf_species ='2104';--3
SELECT * FROM t_poissonfile_psf WHERE psf_species='';
UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species=''; -- 10816 --87
*/
-- A LA FIN DU TRAITEMENT / CORRECTION CI DESSOUS IL NE DOIT RESTER QUE TROIS ESPECES 2038 2238 (SILURE)
--SELECT DISTINCT(psf_comment) FROM did.t_poissonfile_psf;
SELECT count(*), psf_species FROM t_poissonfile_psf GROUP BY psf_species;
select * from t_poissonfile_psf  where psf_species ='0.00'

/*
1984	2014
21107	2038
4	    2238 
*/


UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species=''; -- 2023 (2017) --1203 (2018) (+41+4 2018) --1737 2019 --1430 + 3 2020 1937 2022 1691 2023-2024



--2020
/*
SELECT * FROM t_poissonfile_psf WHERE psf_species='In'; => un décalage de colonne, corrigé à la main
UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species='2238';
SELECT * FROM t_poissonfiletemps_psft WHER
*/

--2019


--2018
/*
UPDATE t_poissonfile_psf SET psf_species='2038' WHERE psf_species='2048';
*/
/*
TEST 2015 pas de lignes
*/
/*
UPDATE t_didsonread_dsr SET dsr_csotismin=FALSE WHERE dsr_id in (
SELECT dsr_id FROM 
(
SELECT dsr_id,
row_number()  OVER (PARTITION BY dsf_id) AS num
FROM did.v_ddde
 ORDER BY dsr_readinit asc
 ) 
sub WHERE num=2
AND dsr_id IS not NULL);--3 de plus
-- la validité du résultat est testée dans R avec stopifnot(length(which(duplicated(ddde$dsf_id)))==0)
*/
/* 
##########################
RECHERCHE D'INCOHERENCES ENTRE LE FICHIERS TEXTE POISSONS ET LE FICHIER DE LA BASE
###########################
*/




SELECT count(*) FROM t_didsonfiles_dsf  dsf 	JOIN  t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
					JOIN t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id;
					--2117 --4629 (2016) --5345 (2017) --5860 (2018) --6746 (2019)  --7438 (2020) 
					--8423 (2021) --9234 (2022) --10033 (2023) -- 10924 (2024)


/*
2013
SELECT * FROM t_poissonfile_psf WHERE psf_move='out'; --1
UPDATE t_poissonfile_psf SET psf_move='Out' WHERE psf_move='out';
UPDATE t_poissonfile_psf SET psf_move='In' WHERE psf_move='in';
SELECT * FROM t_poissonfile_psf WHERE psf_move='4'
*/


					
/*
CORRECTIONS D'ERREURS DE CODAGE
*/		


SELECT psf_move, count(*) FROM did.t_poissonfile_psf group by psf_move ;
SELECT psf_motion, count(*) FROM did.t_poissonfile_psf group by psf_motion ;
SELECT distinct psf_comment FROM did.t_poissonfile_psf ;
-- ATTENTION NE PAS HESITER A CORRIGER LES Mo:Out


/* 2016
SELECT * FROM  did.t_poissonfile_psf WHERE psf_move='3';
UPDATE did.t_poissonfile_psf SET psf_move ='Out' WHERE psf_move='Out ModificatiON 2016';
UPDATE did.t_poissonfile_psf SET psf_move ='InOut' WHERE psf_move='InOut ';
UPDATE did.t_poissonfile_psf SET psf_move ='In' WHERE psf_move='In ';
UPDATE did.t_poissonfile_psf SET psf_move ='Out' WHERE psf_move='Out ';
UPDATE did.t_poissonfile_psf SET psf_move ='Out' WHERE psf_move=' Out ';
UPDATE did.t_poissonfile_psf SET psf_move ='<-->' WHERE psf_move='<--> ';
SELECT * FROM did.t_poissonfile_psf WHERE psf_move='3';
UPDATE did.t_poissonfile_psf SET psf_move='Out' WHERE psf_move='3';
/*
2013
SELECT * FROM did.t_poissonfile_psf  WHERE psf_move IS NULL;
UPDATE did.t_poissonfile_psf SET psf_move='<-->' WHERE psf_move IS NULL;
UPDATE did.t_poissonfile_psf SET  (psf_species,psf_longitude_unit)=(2014,'m') WHERE psf_longitude_unit='2014'	

UPDATE did.t_poissonfile_psf SET psf_motion='Running' WHERE psf_motiON IS NULL;
UPDATE	did.t_poissonfile_psf SET psf_move='Out' WHERE psf_move='out';
UPDATE	did.t_poissonfile_psf SET psf_move=NULL WHERE psf_move='4';
-- 1er dec à 19h00 pour backsliding hors période du 5/12 au 14/12
UPDATE	did.t_poissonfile_psf SET psf_move=NULL WHERE psf_move='4';
*/
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, ';', ':'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'Ot', 'Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'OUt', 'Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'oUT', 'Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'out', 'Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'MO:Out', 'Mo:Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'mo:Out', 'Mo:Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'MO:OUT', 'Mo:Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'Mo:Ou', 'Mo:Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'Mo:Outt', 'Mo:Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'mO/oUT', 'Mo:Out'));
UPDATE did.t_poissonfile_psf SET psf_comment=(SELECT regexp_replace(psf_comment, 'Mo:OutT', 'Mo:Out'));

-- normalement il ne doit y avoir que deux catégories....
SELECT count(*), psf_dir FROM did.t_poissonfile_psf group by psf_dir;
UPDATE did.t_poissonfile_psf SET psf_dir=(SELECT regexp_replace(psf_dir, 'UP', 'Up'));

-- SELECT * FROM did.t_poissonfile_psf ;
SELECT psf_move,psf_id FROM did.t_poissonfile_psf WHERE psf_comment like '%Mo:Out%' AND psf_move='<-->';--0
UPDATE did.t_poissonfile_psf SET psf_move='Out' WHERE psf_comment like '%Mo:Out%' AND psf_move='<-->'; --0 --1 2016
SELECT distinct psf_move FROM did.t_poissonfile_psf WHERE psf_comment like '%Mo:Out%' ; -- In
UPDATE did.t_poissonfile_psf SET psf_move='InOut' WHERE psf_comment like '%Mo:Out%' AND psf_move='In';--732 --1025
SELECT * FROM did.t_poissonfile_psf WHERE psf_move='InOut';
--SELECT * FROM t_poissonfile_psf WHERE psf_comment like '%contre%';-- contre courant deux lignes
--UPDATE t_poissonfile_psf SET psf_motion='Hanging' WHERE psf_comment like '%contre%';
SELECT * FROM did.t_didsonfiles_dsf  dsf 	JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
				JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
				JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
				WHERE psf_species!='2014';--15756 lignes
*/
/*
2013
-- correctiON d'une erreur dans un fichier				
SELECT * FROM t_poissonfile_psf WHERE psf_motion='<-->';
UPDATE t_poissonfile_psf  SET (psf_motion,psf_move,psf_q)=('Running','<-->',3) WHERE psf_id=37071;
*/

/*2024
 * 
 * select * from t_poissonfile_psf  where psf_move ='3'
 * J'ai rajouté <--> et décalé vers la droite
 * select * from t_poissonfile_psf  where psf_drr_id like 'FC_CSOT_2023-01-17_180000_HF_P1646'
 * 1 correction manuelle
 * */
 */

/*
PROBLEMES D'ADEQUATION ENTRE LE windowstart du DRR et le distance_start du fichier
*/
SELECT dsf_distancestart,drr_windowstart_m,dsf_incl,psf_tilt FROM did.t_didsonfiles_dsf  dsf 	JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
		JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
		JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
		WHERE psf_species!='2014'
		AND drr_windowstart_m!=dsf_distancestart; --exactement inverse... 44 lignes 0lignes 2014 0 lignes 2015
		-- 0 lignes 2016 0 lignes 2017 0 lignes 2018 0 lignes 2019 0 2020 0 2021 0 2022 0 2023 0 2024
/*
PROBLEMES D'ADEQUATION ENTRE LES dates du DRR et la date du fichier
*/		
SELECT psf_id, dsf_timeinit, 
    date(dsf_timeinit),
    psf_date, 
    psf_time 
    FROM did.t_didsonfiles_dsf  dsf 	JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
		JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
		JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
		WHERE psf_species!='2014'
		AND date(dsf_timeinit)::text!=psf_date; 
		-- deux lignes en 2012 0 lignes 0 lignes(2017) 7 lignes 2018 mais le lendemain... 
		--0 2019 0 2020 0 2021 109 2022 (pb arrondi de dates) 0 2023 0 (2023-2024)
    -- correction manuelle 2022-12-01 17:49:13 psf_id 81107 (décalage de ligne)
    -- correction manuelle 2024-03-17 00:00:00 psf_id 85166 (décalage de ligne)

   --SELECT * FROM did.t_poissonfile_psf WHERE psf_id = 85166
   SELECT *
    FROM did.t_didsonfiles_dsf  dsf   JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
    JOIN did.t_didsonreadresult_drr drr ON  drr_dsr_id=dsr_id
    JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
    WHERE psf_species!='2014'
    AND date(dsf_timeinit)::text!=psf_date; -- 0 lignes après le changement en 2023-2024

/*  
-- En 2023 - 2024 j'ai 18 lignes qui font chier, ou la date ne correspond plus au fichier du didson (décalage).
--  J'arrive à les identifier avec la requete ci-dessous, dsf_timeinit > newtime evite aussi les problèmes d'arrondi.

  WITH settime AS (
  SELECT (substring(dsf_filename,1,10)||' '||substring(dsf_filename,12,2)||':'||substring(dsf_filename,14,2)||':'||substring(dsf_filename,16,2))::timestamp AS newtime, * 
    FROM did.t_didsonfiles_dsf WHERE dsf_season='2023-2024')
    SELECT * FROM settime WHERE dsf_timeinit > newtime AND dsf_id >=238954
    ORDER BY dsf_timeinit
    
  WITH settime AS (
  SELECT (substring(dsf_filename,1,10)||' '||substring(dsf_filename,12,2)||':'||substring(dsf_filename,14,2)||':'||substring(dsf_filename,16,2))::timestamp AS newtime, * 
    FROM did.t_didsonfiles_dsf WHERE dsf_season='2023-2024'),
  tochange AS (  
  SELECT 
  dsf_id,
  newtime AS new_dsf_timeinit,
  newtime + (30 * interval '1 minute') AS new_dsf_timeend,
  dsf_timeinit,
  dsf_timeend
  FROM settime WHERE dsf_timeinit > newtime AND dsf_id >=238954
   ORDER BY dsf_timeinit)
  UPDATE did.t_didsonfiles_dsf SET 
  dsf_timeinit = new_dsf_timeinit,
  dsf_timeend = new_dsf_timeend
  FROM tochange WHERE tochange.dsf_id = t_didsonfiles_dsf.dsf_id; --18
*/    

/*
PROBLEMES D'ADEQUATION ENTRE LES horodates du DRR et l'horodate du fichier
*/		
SELECT psf_id,
    dsf_timeinit,
    dsf_timeend,
    dsf_filename,
    psf_date,
    psf_time,
    psf_date||' '||psf_time AS drr_timestamp,     
    drr_filename,
    drr_path,
    psf_drr_id 
    FROM did.t_didsonfiles_dsf  dsf 	
		JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
		JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
		JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
		WHERE psf_species!='2014'
		AND date_trunc('minute', (psf_date||' '||psf_time)::timestamp) < dsf_timeinit
		or date_trunc('minute', (psf_date||' '||psf_time)::timestamp) > dsf_timeend
		ORDER BY dsf_filename; -- 0 (après correction) 2020  --0 2021 --0 2022 0 (2023-2024 après correction) 

-- deux lignes corrigées à la main en 2019 pb changement d'heure donc horaire décalé de 30 mon
	
/*
 * 2023
 * 
 * Il y a bien un poisson compté, l'heure est mise à 01:00:00 c'est faut je corrige  21:31:00
 
 **/		
		
		

		
-- utiliser l'interface pour supprimer les lignes en trop crées par les répétitions de fichiers
-- clic sur la ligne et supprimer l'enregistrement, il est répété. Il en reste qu'un qui est quelques secondes après la fin
-- penser à corriger les comptages totaux dans t_didsonreadresult_drr
-- il reste 11 lignes en 2016 et une en 2013
/*
SELECT * FROM did.t_poissonfile_psf WHERE psf_drr_id ='FC_CSOT_2019-03-07_223000_HF_P1409'
BEGIN;
DELETE FROM did.t_poissonfile_psf  WHERE psf_id=62164;--1
COMMIT;
*/
/*
VérificatiON et recalcul des nombres de Up et Down dans psf => drr => dsr
ATTENTION drr_upstream correspond au nombre de poissons totaux, y compris les lamproies
IL PEUT ETRE DIFFERENT DE DRR_EELPLUS
Ci DESSOUS ON RECOMPTE LES ANGUILLES DU FICHIER POISSON ET ON MET LES DONNEES
DANS LA TABLE DU DESSUS (DRR)
*/


/*
PREMIERE ETAPE : VERIF DES FICHIERS TOTAUX
IL s'AGIT DE L'ENSMBLE DES POISSONS, LAMPROIES ET ANGUILLES
*/
--SELECT * FROM t_poissonfile_psf;
SELECT distinct on(psf_dir) psf_dir FROM t_poissonfile_psf;
--UPDATE t_poissonfile_psf SET psf_dir='Dn' WHERE psf_dir='??';--2 -- 0 2016 --0 2017 
--UPDATE t_poissonfile_psf SET psf_dir='Up' WHERE psf_dir='UP'; --2 2022

/*
 * 2023
 *
 *   SELECT * FROM t_poissonfile_psf WHERE psf_dir='158' => correction manuelle du meme poisson  qu'avant décalage de lignes FC_CSOT_2022-12-01_173000_HF_P1106
 */


with countfromdsf as(				
	SELECT case when up.psf_drr_id IS not NULL then	up.psf_drr_id
	else dn.psf_drr_id end AS psf_drr_id, -- il faut que je récupère l'id, 
	--et si je prends la ligne dn alors que c'est up je n'ai plus rien, 
	--donc je regarde que je n'ai pas une case vide, et si c'est le cas c'est un dn
	up, 
	dn FROM (
	SELECT  psf_drr_id, count(*) AS up  FROM t_poissonfile_psf WHERE psf_dir='Up'  group by   psf_drr_id, psf_dir) up
	FULL OUTER join
	(SELECT  psf_drr_id, count(*) AS dn FROM t_poissonfile_psf WHERE psf_dir='Dn' group by   psf_drr_id, psf_dir) dn
	ON up.psf_drr_id=dn.psf_drr_id
	)
SELECT * FROM countfromdsf FULL OUTER JOIN t_didsonreadresult_drr drr ON psf_drr_id=drr_id
WHERE drr_upstream!=up; -- Il faut modifier les entrées si des lignes exsitent --0 2016 
--0 2017 --0 2018  --0 2019 2=>0 (2020) 0 2021 -- 2 (2022) 0 (2023-2024)

/* 2022
UPDATE t_didsonreadresult_drr SET (drr_upstream,drr_downstream)=(17,0) WHERE drr_id='FC_CSOT_2021-12-30_040000_HF_P1359';
UPDATE t_didsonreadresult_drr SET (drr_upstream,drr_downstream)=(31,0) WHERE drr_id='FC_CSOT_2021-12-30_053000_HF_P1505';
UPDATE t_didsonreadresult_drr SET (drr_upstream,drr_downstream)=(31,0) WHERE drr_id='FC_CSOT_2021-12-30_053000_HF_P1505';
SELECT * FROM t_poissonfile_psf where psf_drr_id like 'FC_CSOT_2023-01-28_00000%'; deux fois le même poisson
DELETE FROM t_poissonfile_psf where psf_id = 83380; --1
***/



with countfromdsf as(				
SELECT case when up.psf_drr_id IS not NULL then	up.psf_drr_id
	else dn.psf_drr_id end AS psf_drr_id,
	up, 
	dn FROM (
SELECT  psf_drr_id, count(*) AS up  FROM t_poissonfile_psf WHERE psf_dir='Up' group by   psf_drr_id, psf_dir) up
FULL OUTER join
(SELECT  psf_drr_id, count(*) AS dn FROM t_poissonfile_psf WHERE psf_dir='Dn'  group by   psf_drr_id, psf_dir) dn
ON up.psf_drr_id=dn.psf_drr_id)
SELECT * FROM countfromdsf FULL OUTER JOIN t_didsonreadresult_drr drr ON psf_drr_id=drr_id
WHERE drr_downstream!=dn; --0 pas de problème  (2016 un problème en avril 2015) 
--0 2017 0 2020 -- 0 2021 -- 0 2022 --0 2023-2024


/* 2016
UPDATE t_didsonreadresult_drr SET drr_downstream=1 WHERE drr_id='FC_CSOT_2015-04-13_083000_HF_P1703';
*/

/*
DEUXIEME ETAPE : VERIF DES COMPTAGES D'ANGUILLE (ETAPE D'APRES)
NE PAS LANCER LORS DU PREMIER TRAITEMENT (les comptages sont générés ci-dessous)
*/

with countfromdsf as(				
	SELECT case when up.psf_drr_id IS not NULL then	up.psf_drr_id
	else dn.psf_drr_id end AS psf_drr_id, -- il faut que je récupère l'id, 
	--et si je prends la ligne dn alors que c'est up je n'ai plus rien, 
	--donc je regarde que je n'ai pas une case vide, et si c'est le cas c'est un dn
	up, 
	dn FROM (
	SELECT  psf_drr_id, count(*) AS up  FROM t_poissonfile_psf WHERE psf_dir='Up' AND psf_species='2038' group by   psf_drr_id, psf_dir) up
	FULL OUTER join
	(SELECT  psf_drr_id, count(*) AS dn FROM t_poissonfile_psf WHERE psf_dir='Dn'AND psf_species='2038' group by   psf_drr_id, psf_dir) dn
	ON up.psf_drr_id=dn.psf_drr_id
	)
SELECT * FROM countfromdsf FULL OUTER JOIN t_didsonreadresult_drr drr ON psf_drr_id=drr_id
WHERE drr_eelplus!=up; -- Il faut modifier les entrées si des lignes exsitent



with countfromdsf as(				
SELECT case when up.psf_drr_id IS not NULL then	up.psf_drr_id
	else dn.psf_drr_id end AS psf_drr_id,
	up, 
	dn FROM (
SELECT  psf_drr_id, count(*) AS up  FROM t_poissonfile_psf WHERE psf_dir='Up' AND psf_species='2038' group by   psf_drr_id, psf_dir) up
FULL OUTER join
(SELECT  psf_drr_id, count(*) AS dn FROM t_poissonfile_psf WHERE psf_dir='Dn' AND psf_species='2038'  group by   psf_drr_id, psf_dir) dn
ON up.psf_drr_id=dn.psf_drr_id)
SELECT * FROM countfromdsf FULL OUTER JOIN t_didsonreadresult_drr drr ON psf_drr_id=drr_id
WHERE drr_eelminus!=dn; --0 pas de problème



-- il faut rajouter une colonne pour le comptage d'anguilles seulement

/* RUNONCE
ALTER TABLE t_didsonreadresult_drr ADD COLUMN drr_eelplus numeric;
ALTER TABLE t_didsonreadresult_drr ADD COLUMN drr_eelminus numeric;
UPDATE t_didsonreadresult_drr SET drr_eelplus =0;
UPDATE t_didsonreadresult_drr SET drr_eelminus=0;
*/

--je passe par une table temporaire
DROP TABLE IF EXISTS tempcountfromdsf;

CREATE TABLE tempcountfromdsf AS (
  SELECT
    CASE
      WHEN up.psf_drr_id IS NOT NULL THEN up.psf_drr_id
      ELSE dn.psf_drr_id
    END AS psf_drr_id,
    up,
    dn
  FROM
    (
      SELECT
        psf_drr_id,
        count(*) AS up
      FROM
        t_poissonfile_psf
      WHERE
        psf_dir = 'Up'
        AND psf_species = '2038'
      GROUP BY
        psf_drr_id,
        psf_dir
    ) up
  FULL OUTER JOIN
(
      SELECT
        psf_drr_id,
        count(*) AS dn
      FROM
        t_poissonfile_psf
      WHERE
        psf_dir = 'Dn'
        AND psf_species = '2038'
      GROUP BY
        psf_drr_id,
        psf_dir
    ) dn
ON
    up.psf_drr_id = dn.psf_drr_id
);--1272 -- 3090 --5114 (2017) 5628 (2018) 6514 (2019) 7202 (2020) 8182 (2021) 
-- 8989 (2022) 10508 (2023-2024)
-- SELECT * FROM tempcountfromdsf;

-- On commence par remettre à zéro
UPDATE t_didsonreadresult_drr SET drr_eelplus =0 WHERE drr_dsr_id in 
	(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024'); 
	--1420 (2016) --716 2017 -- 553 (2018) --848 (2019) 692 (2020) 8182 (2021)
	-- 811 (2022) 890 (2023-2024)
	
-- ci dessous il peut y avoir moins de lignes, correspond aux lamproies
UPDATE t_didsonreadresult_drr SET drr_eelplus= up 
	FROM tempcountfromdsf
	WHERE psf_drr_id=drr_id
	AND drr_dsr_id in 
	(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024');
	--1381 (2016) => 1336 après changement lamproies 714 2017 552 (2018) 848 (2019) 
	-- 6891 (2020) 981 (2021) 807 (2022) 761 (2023-2024)
	
UPDATE t_didsonreadresult_drr SET drr_eelminus=0 WHERE drr_dsr_id in 
	(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024'); 
	-- 1420 (2016) 716 (2017) 553 (2018) 848 (2019) 
	-- 692 (2020) 985 (2021) 811 (2022) 890 (2023)
	
UPDATE t_didsonreadresult_drr SET drr_eelminus= dn 
	FROM tempcountfromdsf
	WHERE psf_drr_id=drr_id AND drr_dsr_id in 
	(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024'); 
	--1336 (2016) 714 552 (2018) 848 (2019) 
	--691 (2020) 980 (2021) 811 (2022) 761 (2023)
	
UPDATE t_didsonreadresult_drr SET drr_eelminus=0 WHERE drr_eelminus IS NULL AND drr_dsr_id in 
	(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024');
	--1062 --1062 --991 (2016) --477 (2017) 479(2018) 636 (2019)
	-- 632 (2020) 807 (2021) 659 (2022) 722 (2023-2024)
	
UPDATE t_didsonreadresult_drr SET drr_eelplus=0 WHERE drr_eelplus IS NULL AND drr_dsr_id in 
	(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2023-2024');
	
	--115--187 --93 (2016) -- 83 (2017) -- 25 (2018) 109 (2019) 
	--32 (2020) 98 (2021) 90 (2022) 19 (2023-2024)


/*
SELECT * FROM t_didsonreadresult_drr LEFT join
	tempcountfromdsf
	ON psf_drr_id=drr_id
	WHERE drr_dsr_id in 
	(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2017-2018')
	except
SELECT * FROM t_didsonreadresult_drr  join
	tempcountfromdsf
	ON psf_drr_id=drr_id
	WHERE drr_dsr_id in 
	(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id 
	WHERE dsf_season='2017-2018')
	

	;
PROBLEMES D'ADEQUATION DRR DSR !!!!!
Petit tableau de comparaisON des données provenant d'excel et de celles provenant des fichiers textes 
=> corrections manuelles sur interface
ICI J'ai corrigé pour 2015-2016 puis les changements manuels en fin de saisON font que les dsr et drr diffèrente

*/
SELECT dsf_id,
dsf_timeinit, 
dsf_filename, 
dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
dsr_eelplus,
drr_eelplus,
dsr_eelminus,
drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
AND dsr_csotismin
ORDER BY dsf_timeinit; -- Il ne doit plus y avoir de ligne 


/*
2016
UPDATE t_didsonreadresult_drr SET (drr_totalfish,drr_upstream,drr_eelplus, drr_downstream, drr_eelminus) = (4,4,4,0,0) WHERE drr_id ='FC_CSOT_2016-03-28_223000_HF_P1338';
*/
/*
2017
SELECT * FROM did.t_didsonread_dsr WHERE dsr_dsf_id=103011
UPDATE t_didsonread_dsr SET dsr_eelminus = 1 WHERE dsr_id=36510; -- instead of 0
*/
/*
2018

UPDATE t_didsonread_dsr SET (dsr_eelplus,dsr_eelminus)  = (sub.drr_eelplus,sub.drr_eelminus) from
( SELECT dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
AND dsf_season='2017-2018'
AND dsr_csotismin) sub
WHERE sub.dsf_id=dsr_dsf_id --8



SELECT * FROM did.t_poissonfile_psf WHERE psf_date::date >= '2018-01-01' AND psf_date::date < '2018-01-06' ORDER BY psf_date;
SELECT * FROM 
t_didsonfiles_dsf 
LEFT join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
LEFT JOIN t_poissonfile_psf ON psf_drr_id=drr_id
WHERE dsf_id=131115
*/

/*2019

UPDATE t_didsonread_dsr SET (dsr_eelplus,dsr_eelminus)  = (sub.drr_eelplus,sub.drr_eelminus) from
( SELECT dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
AND dsf_season='2019-2020'
AND dsr_csotismin) sub
WHERE sub.dsf_id=dsr_dsf_id

2020 

SELECT * FROM did.t_poissonfile_psf WHERE psf_date::date >= '2019-11-02' AND psf_time >'23:00:00' AND psf_date::date < '2019-11-03'  
AND psf_time <'23:30:00' ORDER BY psf_date;

with nosilure2019 AS (
SELECT * FROM did.t_poissonfile_psf WHERE psf_date::date >= '2019-09-01' AND psf_species = '2238'
)
UPDATE did.t_poissonfile_psf 
SET psf_species='2038' 
FROM
nosilure2019 
WHERE nosilure2019.psf_id=t_poissonfile_psf.psf_id;--8

UPDATE t_didsonread_dsr SET (dsr_eelplus,dsr_eelminus)  = (sub.drr_eelplus,sub.drr_eelminus) from
( SELECT dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
AND dsf_season='2019-2020'
AND dsr_csotismin) sub
WHERE sub.dsf_id=dsr_dsf_id;--5 + 1 (pb relecture)

2021

with pb_its_a_silure AS (
SELECT dsf_id,dsf_timeinit, dsf_filename, dsr_id,dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
AND dsr_csotismin)
UPDATE did.t_didsonread_dsr dsr SET dsr_eelminus=0 FROM pb_its_a_silure WHERE dsr.dsr_id = pb_its_a_silure.dsr_id
; --1


2023

SELECT * FROM t_didsonread_dsr where dsr_dsf_id = 230931; --correction dsr_eelplus 1 -> 0 
UPDATE did.t_didsonreadresult_drr
  SET drr_eelplus=2,drr_eelminus=0
  WHERE drr_id='FC_2023-01-28_000000_HF_P1111'
UPDATE did.t_didsonread_dsr
  SET dsr_eelplus=3, dsr_eelminus=0
  WHERE dsr_dsf_id=234296;
UPDATE did.t_didsonread_dsr
  SET dsr_eelplus=3, dsr_eelminus=0
  WHERE dsr_dsf_id=234414;
UPDATE did.t_didsonread_dsr
  SET dsr_eelplus=3, dsr_eelminus=0
  WHERE dsr_dsf_id=234414;
UPDATE did.t_didsonread_dsr
  SET dsr_eelplus=2, dsr_eelminus=0
  WHERE dsr_dsf_id=235392;
UPDATE did.t_didsonread_dsr
  SET dsr_eelplus=0, dsr_eelminus=0
  WHERE dsr_dsf_id=237414;  -- silure
UPDATE did.t_didsonread_dsr
  SET dsr_eelplus=0, dsr_eelminus=0
  WHERE dsr_dsf_id=237997;  -- silure  
  
VérificatiON des fichiers nON importés
GROSSE VERIFICATION PAR AN, POUR REMETTRE LES FICHIERS DROITS
*/

SELECT dsr_id,  dsr_csotismin, drr_id, dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus>0 AND drr_eelplus IS NULL
AND (dsf_season='2023-2024' )
ORDER BY dsf_timeinit;

/*
 2023-2024
SELECT * FROM did.t_didsonreadresult_drr WHERE drr_filename like '2024-02-08_203000_HF'
UPDATE did.t_didsonreadresult_drr SET drr_dsr_id = 81367 WHERE drr_filename = '2024-02-08_203000_HF';
SELECT * FROM did.t_didsonreadresult_drr WHERE drr_filename like '2024-02-08_213000_HF'
UPDATE did.t_didsonreadresult_drr SET drr_dsr_id = 81370 WHERE drr_filename = '2024-02-08_213000_HF';
SELECT * FROM did.t_didsonreadresult_drr WHERE drr_filename like '2024-02-09_013000_HF'
UPDATE did.t_didsonreadresult_drr SET drr_dsr_id = 81379 WHERE drr_filename = '2024-02-09_013000_HF';
UPDATE did.t_didsonreadresult_drr SET drr_dsr_id = 81385 WHERE drr_filename = '2024-02-09_193000_HF';
SELECT * FROM did.t_didsonreadresult_drr WHERE drr_filename like '%2024-02-09_203000_HF%'; -- Le ficher FC a disparu ...
DELETE FROM did.t_didsonread_dsr WHERE dsr_id = 80182;
UPDATE did.t_didsonreadresult_drr SET drr_dsr_id = 81384 WHERE drr_filename ='FC_2024-02-09_193000_HF'; -- le dsr 
UPDATE did.t_didsonreadresult_drr SET drr_dsr_id = 81387 WHERE drr_filename = '2024-02-09_203000_HF';
UPDATE did.t_didsonreadresult_drr SET drr_dsr_id = 81389 WHERE drr_filename = '2024-02-09_210000_HF';
*/

/*
2016
UPDATE t_didsonread_dsr SET dsr_eelplus=0 WHERE dsr_id=34843;
"2016-02-27_010000_HF"
UPDATE t_didsonread_dsr SET dsr_csotismin=FALSE WHERE dsr_id=33583;
UPDATE t_didsonread_dsr SET dsr_pertefichiertxt=TRUE WHERE dsr_id=33583;  
UPDATE t_didsonread_dsr SET dsr_csotismin=TRUE WHERE dsr_id=35030;

modif manuelle et cochage de "dsr_pertefichiertxt"
"2016-03-09_230000_HF"
modif manuelle du csotismin
modif manuelle et cochage de "dsr_pertedefichier"
*/

/*2017
UPDATE t_didsonread_dsr SET dsr_eelplus =0
Deux corrections manuelles de fichiers fait pour le meme cstot pour lequel j'ai mis 2.9, c'était pas une bonne idée, j'ai supprimé les lignes à problème 27/11/16 20:00 et 2030
*/

/*2020
 * t_didsonread_dsr SET dsr_eelplus =0
 * 
 UPDATE did.t_didsonread_dsr SET dsr_eelplus =0 WHERE dsr_id in (53402,53403,53427);--3
 
 * 
 */



SELECT dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, dsr_id,drr_id, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus+dsr_eelminus>0 AND drr_eelminus IS NULL
AND dsf_season='2023-2024'
ORDER BY dsf_timeinit;



/*2019
BEGIN;
UPDATE t_didsonread_dsr SET dsr_eelminus=0 WHERE dsr_id=48527;
COMMIT;

--*************************************
-- en 2012-2013 beaucoup de problèmes
-- les fichiers ont été relus en début de saisON et il n'y a pas eu de doublons sur les fichiers poissons
-- ie seuls les bON comptages ont été gardés.
-- j'ai rajouté une colonne pour indiquer la perte du fichier
--*************************************
SELECT dsf_timeinit, dsf_filename, coalesce(dsr_eelplus,0)+coalesce(dsr_eelminus,0)-coalesce(drr_eelplus,0)-coalesce(drr_eelminus,0)  AS diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus+dsr_eelminus>0 AND drr_eelplus IS NULL
AND dsf_season='2012-2013'
AND dsr_pertefichiertxt IS FALSE
AND dsr_csotismin
ORDER BY dsf_timeinit;--5 lignes encore

*/



/*
APRES VERIF MANUELLE, ON PEUT REPRENDRE CE QUI EST DANS LES FICHIERS TEXTES !
*/
/*
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus) =(drr_eelplus,drr_eelminus)
FROM t_didsonreadresult_drr
WHERE drr_dsr_id=dsr_id; --1303 --2117--3095
*/
-- RECHERCHE DES INCOHERENCES ENTRE LES COMPTES DSR ET DRR
-- LES CORRECTIONS SONT FAITES SUR L'INTERFACE GRAPHIQUE


SELECT * from(
SELECT dsf_id,drr_dsf_id,drr_dsr_id,drr_id,dsr_csotismin,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus AS dsr_total,
drr_upstream,drr_downstream,drr_eelplus, drr_eelminus,drr_eelplus-drr_eelminus AS drr_total
FROM t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN t_didsonreadresult_drr drr ON drr_dsr_id=dsr_id) sub
WHERE drr_total!=dsr_total; -- 15 lignes dont une en 2013 => 0 lignes après correctiON 0 après correctiON 
--2019 =>0 lignes après correctiON 2020 0 lignes 2021
--2022 7 lignes corrigées (voir ce dessous)

/*
2023
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(6,1) WHERE dsr_id=76894;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(1,0) WHERE dsr_id=77077;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(1,0) WHERE dsr_id=79162;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(1,1) WHERE dsr_id=79260; -- verif manu
UPDATE t_didsonreadresult_drr SET (drr_totalfish, drr_upstream, drr_downstream, drr_eelplus, drr_eelminus)=(2,1,1,1,1) WHERE drr_dsr_id=79260; -- verif manu
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(7,0) WHERE dsr_id=79313; -- lpm
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,0) WHERE dsr_id=79379; --lpm
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,0) WHERE dsr_id=79406; 
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(1,0) WHERE dsr_id=79407;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(3,1) WHERE dsr_id=80069;
correction avec interface (utiliser la case avec le nombre de lignes pour se déplacer)
*/


/*
2019
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(1,0) WHERE dsr_id=47635;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=48370;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=49255;
*/
/*
Une correctiON manuelle 2017
*/
/*
2022
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=73159;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=73436;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=73440;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=73499;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(10,1) WHERE dsr_id=73968;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=75887;
UPDATE t_didsonread_dsr SET (dsr_eelplus, dsr_eelminus)=(2,0) WHERE dsr_id=76023;
*/





/* 
il manque les fichiers pour lesquels il y a des comptages mais pas de correspondance
je passe par un LEFT join
*/

SELECT * from(
SELECT dsf_filename, drr_dsr_id,drr_id,dsr_csotismin,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus AS dsr_total,
drr_upstream,drr_downstream,drr_eelplus, drr_eelminus,drr_eelplus-drr_eelminus AS drr_total
FROM t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
LEFT JOIN t_didsonreadresult_drr drr ON drr_dsr_id=dsr_id) sub
WHERE dsr_total>0 AND drr_total IS NULL
AND dsr_csotismin;



SELECT distinct ON (dsf_timeinit) * FROM did.t_didsonfiles_dsf  dsf 	JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
				JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
				JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
				WHERE psf_species!='2014'
				AND dsr_csotismin
		    AND dsf_season = '2023-2024';



-- ENSEMBLE DES POISSONS COMPTES (DANS LES TABLES POISSONS (DRR)) DANS LES FICHIERS CORRESPONDANT A CSOTISMIN
SELECT dsf_season,sum(drr_eelplus)+sum(drr_eelminus) count FROM t_didsonfiles_dsf 
	JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
	LEFT JOIN t_didsonreadresult_drr
	ON drr_dsr_id=dsr_id
	--WHERE dsr_csotismin
    --AND dsr_pertefichiertxt IS FALSE
	group by dsf_season
	ORDER BY dsf_season; 
/*
2012-2013 2615
2013-2014 1999
2014-2015 1937
2015-2016 4071 ->3809 (2017) > 3808 (2021)
2016-2017 2020
2017-2018 1425
2018-2019 1739=> 1736
2019-2020	1434
2020-2021 1985
2021-2022 1937
2022-2023 1582
2023-2024 1690
*/
-- ENSEMBLE DES POISSONS COMPTES (DANS LES TABLES POISSONS (DRR)) Y COMPRIS LES COMPTAGES MULTIPLES
SELECT dsf_season,sum(drr_eelplus)+sum(drr_eelminus) FROM t_didsonfiles_dsf 
	LEFT JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id  
	LEFT JOIN t_didsonreadresult_drr ON drr_dsr_id=dsr_id
	group by dsf_season
	ORDER BY dsf_season;  --2729 --1938 --2006(comptés deux fois par brice et gérard) --2152
/*
"2012-2013";2726
"2013-2014";2012
"2014-2015";2007
"2015-2016";4071 => 3809 => 3808
"2016-2017";2023
"2017-2018";1439
"2018-2019";1739 => 1736 
"2019-2020"	1434
2020-2021 1985
2021-2022 1937
2022-2023 1582
2023-2024 1690
*/
-- ENSEMBLE DES POISSONS COMPTES (DANS LES TABLES EXCEL (DSR)) Y COMPRIS LES COMPTAGES MULTIPLES
-- ET AUSSI AVANT QU'ON PASSE EN LAMPROIES
SELECT dsf_season,sum(dsr_eelplus) + sum(dsr_eelminus) 
FROM  t_didsonfiles_dsf 
	LEFT JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
	group by dsf_season
	ORDER BY dsf_season; 
/*
"2012-2013";3070
"2013-2014";2012
"2014-2015";2007
"2015-2016";4079 (reste 4079 car je  n'ai pas modifié les DSR) 3817 (2017) 3816 (2021)
"2016-2017";2023
"2017-2018";1352==>1441
"2018-2019";1739==>1736
"2019-2020";1434
2020-2021 1985
2021-2022 1937
2022-2023 1582
2023-2024 1691
*/



-- ENSEMBLE DES POISSONS COMPTES (DANS LES TABLES EXCEL (DSR)) POUR LES CSOTISMIN
SELECT dsf_season,sum(dsr_eelplus) + sum(dsr_eelminus) 
FROM  t_didsonfiles_dsf 
	LEFT JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
	WHERE dsr_csotismin
	AND dsr_pertefichiertxt IS FALSE
	group by dsf_season
	ORDER BY dsf_season;  
/*
dsf_season;count
2012-2013;2615
2013-2014;1999
2014-2015;1937
2015-2016;3808
2016-2017;2020
2017-2018;1338 => 1425
2018-2019;1739 ==> 1736
2019-2020;1434
2020-2021 1985
2021-2022 1937
2022-2023 1581
2023-2024 1685

*/

-- ENSEMBLE DES lignes du fichier poisson correspondant à CSOTISMIN
SELECT dsf_season,count(*) 
FROM  t_didsonfiles_dsf 
	JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
	JOIN t_didsonreadresult_drr ON drr_dsr_id=dsr_id
	JOIN t_poissonfile_psf ON psf_drr_id=drr_id
	WHERE dsr_csotismin
	AND dsr_pertefichiertxt IS FALSE
	AND psf_species='2038'
	group by dsf_season
	ORDER BY dsf_season; 
/*
"2012-2013";2615
"2013-2014";1999
"2014-2015";1937
"2015-2016";4071->3809=> 3808
"2016-2017";2020
"2017-2018";1338 => 1425
"2018-2019";1739 =>1736
"2019-2020";1434
2020-2021 1985
2021-2022 1937
2022-2023 1581
2023-2024 1685
*/

/* ci dessous la requête est lancée pour permettre de voir les jours ou il n'y a pas le même nombre
de données
A lancer lors le programme plante avec
Error:  chunk 3 (label = d3ej) 
Error : nrow(dddp) == sum(colSums(ddde[, c("drr_eelplus", "drr_eelminus")],  .... n'est pas TRUE
*/

SELECT sub1.dsf_timeinit , count_psf, count_drr from(
SELECT dsf_timeinit ,count(*)  AS count_psf
FROM  t_didsonfiles_dsf 
	JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
	JOIN t_didsonreadresult_drr ON drr_dsr_id=dsr_id
	JOIN t_poissonfile_psf ON psf_drr_id=drr_id
	WHERE dsr_csotismin
	AND dsr_pertefichiertxt IS FALSE
	AND psf_species='2038'
	group by dsf_timeinit)sub1
	LEFT JOIN (
SELECT dsf_timeinit,sum(dsr_eelplus) + sum(dsr_eelminus) AS count_drr
FROM  t_didsonfiles_dsf 
	LEFT JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id
	WHERE dsr_csotismin
	AND dsr_pertefichiertxt IS FALSE	
	group by dsf_timeinit )sub2
	ON sub1.dsf_timeinit=sub2.dsf_timeinit
	WHERE count_psf!=count_drr
ORDER BY sub1.dsf_timeinit;

-- SELECT dsf_timeinit,dsr_eelplus, dsr_eelminus FROM v_ddde WHERE dsf_timeinit::date='2015-04-18' AND (dsr_eelplus>0 or dsr_eelminus>0)
-- SELECT dsf_timeinit,count (*) FROM  v_dddp WHERE dsf_timeinit::date='2015-04-18' group by dsf_timeinit ORDER BY dsf_timeinit

/*
Recherche de problèmes d'adéquatiON entre dddp et ddde
*/
SELECT * FROM (
SELECT drr_id,dsf_season FROM v_ddde except 
SELECT drr_id,dsf_season FROM v_dddpall WHERE (drr_eelplus>0 or drr_eelminus>0) )sub
WHERE dsf_season='2016-2017'
AND drr_id not in(SELECT psf_drr_id FROM t_poissonfile_psf WHERE psf_species='2014');
SELECT distinct psf_species FROM t_poissonfile_psf ;
/*
2014
2038
2238
*/

SELECT drr_id FROM v_ddde except (SELECT drr_id FROM v_dddpall); -- rien


SELECT * FROM t_poissonfile_psf WHERE psf_species!='2014' AND psf_species!='2038'; --213 2238

--3343
SELECT count(*) FROM did.t_poissonfile_psf WHERE psf_species='2038' AND  psf_dir='Up'; 
--6171 --9583 --12345 (2018) --15276 (2020) --17063 (2021) 18844 (2022) 21949 (2023-2024)



SELECT count(*) FROM did.t_didsonfiles_dsf  dsf 	
				JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
				JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
				JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
				WHERE psf_species!='2014'
				AND  psf_species!='2338'
				AND dsr_csotismin; --6701 --10624 --13720 --15546 --16977 --18965 --20902 --22483 --24365 (2023-2024)
-- lamproies
SELECT count(*) FROM did.t_didsonfiles_dsf  dsf 	
				JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
				JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
				JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
				WHERE psf_species='2014'
				AND dsr_csotismin; --2592 --657 -- 799 --1614 --1896 --1898 --1899 --1957 --1962 --2874 (2023) 3020 (2023-2024)

SELECT count(*),  psf_species FROM t_poissonfile_psf group by psf_species
/* (2020)
count;psf_species
17183;2038
1921;2014
3;2238
(2021)
1979  2014
19170 2038
4 2238
(2022)
1984  2014
21107 2038
4 2238
(2023)
2896  2014
22689 2038
4 2238
(2023-2024)
3074  2014
24380 2038
213 2238
*/

-- anguilles qui  ne sont pas dans les fichiers drr
SELECT * FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id WHERE (dsr_eelplus>0 or dsr_eelminus>0) and
dsr_id not in (SELECT drr_dsr_id FROM t_didsonreadresult_drr) AND dsr_csotismin ORDER BY dsf_timeinit;
-- 0 2018 --0 2019 --0 2020 --0 2022 --0 2023 --0 (2023-2024)


SELECT * FROM t_didsonread_dsr RIGHT JOIN t_didsonreadresult_drr ON drr_dsr_id=dsr_id 
WHERE dsr_eelplus != drr_eelplus
or dsr_eelminus !=drr_eelminus --0 2018 --0 2020 --0 2022 --0 2023 --0 (2023-2024)
/* Je n'ose pas lancer celui-là
UPDATE t_didsonread_dsr SET (dsr_eelplus,dsr_eelminus)=(0,0) WHERE dsr_id in 
(SELECT dsr_id FROM t_didsonfiles_dsf JOIN t_didsonread_dsr ON dsr_dsf_id=dsf_id WHERE (dsr_eelplus>0 or dsr_eelminus>0) and
dsr_id not in (SELECT drr_dsr_id FROM t_didsonreadresult_drr) AND dsr_csotismin ORDER BY dsf_timeinit);
*/

SELECT sum(dsr_eelplus) FROM (SELECT * FROM t_didsonread_dsr  WHERE (dsr_eelplus>0 or dsr_eelminus>0) AND dsr_csotismin and
dsr_id not in (SELECT drr_dsr_id FROM t_didsonreadresult_drr)) sub; --0 (2018) NULL (2020) NULL 2022


-- tous les fichiers qui ne sont pas CSOTISMIN
SELECT * FROM t_didsonread_dsr 
JOIN t_didsonreadresult_drr
ON drr_dsr_id=dsr_id WHERE dsr_csotismin=FALSE; 




/*
Doublons dans dsf_id
*/
SELECT * FROM did.v_ddde WHERE dsf_id in (7027,7029,7031,7033,7035,7037,7039,7041,7049,7050,7051,7064) ;




/*
------------------------------------------------
problèmes de lamproies en fin de saison 2015-2016
-------------------------------------------------
*/



SELECT count(*),psf_dir FROM did.t_didsonfiles_dsf  dsf 	
				JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
				JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
				JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
				WHERE psf_species='2038'
				AND dsr_csotismin
				AND dsf_season='2015-2016'
				AND psf_date>'2016-04-08' 
				AND psf_l_cm>70
				AND psf_q<5
				group by psf_dir; 

SELECT * FROM did.t_didsonfiles_dsf  dsf 	
				JOIN  did.t_didsonread_dsr dsr ON dsr_dsf_id=dsf_id
				JOIN did.t_didsonreadresult_drr drr ON 	drr_dsr_id=dsr_id
				JOIN did.t_poissonfile_psf ON psf_drr_id=drr_id
				JOIN did.
				WHERE psf_species='2038'
				AND dsr_csotismin
				AND dsf_season='2015-2016'
				AND psf_date>'2016-04-01' 
				AND psf_l_cm>70
				AND psf_q<5; 

/*
Quelles sont les anguilles de plus de 60 qui passent après le 15 mars et surtout
est qu'elles passent pour un petit delta ?
*/

SELECT  count(*),psf_dir FROM (
SELECT *, niveauvilaine30-niveaumer30 AS delta FROM did.v_dddpeall 
				WHERE psf_species='2038'
				AND dsr_csotismin
				AND dsf_season='2015-2016'
				AND psf_date>'2016-03-15' 
				AND psf_l_cm>60
				) sub
WHERE delta<0.5				
group by psf_dir; 


/*
presque toutes les lamproies passent à <0.5
*/

SELECT  count(*),
case when delta<0.5 then '<0.5m'
when delta>0.5 AND delta<1 then '0.5-1m'
else '>1m' end AS delta_cat
 FROM (
SELECT *, niveauvilaine30-niveaumer30 AS delta FROM did.v_dddpeall 
				WHERE psf_species='2014'
				AND dsr_csotismin
				AND dsf_season='2015-2016'				
				AND psf_l_cm>60
				) sub
			
group by delta_cat; 


-- 261 lamproies transformées en anguille en 205-2016
UPDATE did.t_poissonfile_psf SET (psf_comment,psf_species)=
(coalesce(psf_comment,'')||'Changement 2015-2016, toute ang >60 cm avec delta<0.5 delta et > 1503 devient lamproie','2014') 
WHERE psf_id in (
SELECT  psf_id FROM (
SELECT *, niveauvilaine30-niveaumer30 AS delta FROM did.v_dddpeall 
				WHERE psf_species='2038'
				AND dsr_csotismin
				AND dsf_season='2015-2016'
				AND psf_date>'2016-03-15' 
				AND psf_l_cm>60
				) sub
WHERE delta<0.5	);--261			


-- après avoir relancé les count FROM psf (voir partie)... DROP TABLE if exists tempcountfromdsf; ...
-- ON remet les dsf propre

SELECT sum(diff) from
	(SELECT dsr_id, dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
	dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
	t_didsonfiles_dsf join
	t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
	JOIN 
	t_didsonreadresult_drr ON drr_dsr_id=dsr_id
	WHERE dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
	AND dsf_season='2015-2016'
	AND dsf_timeinit>'2016-03-15 00:00:00' 
	AND dsr_csotismin)sub;--261 (il y en a bien 261 a modifier)

UPDATE t_didsonread_dsr SET (dsr_eelplus,dsr_eelminus) = (drr_eelplus, drr_eelminus) 
FROM (
SELECT dsr_id, dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  AS diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus FROM 
t_didsonfiles_dsf join
t_didsonread_dsr  ON dsr_dsf_id=dsf_id 
JOIN 
t_didsonreadresult_drr ON drr_dsr_id=dsr_id
WHERE dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
AND dsf_season='2015-2016'
AND dsf_timeinit>'2016-03-15 00:00:00' 
AND dsr_csotismin)sub
WHERE sub.dsr_id=t_didsonread_dsr.dsr_id; --95 rows

/*
problèmes de temps d'enregistrement
*/



 UPDATE did.t_didsonread_dsr SET dsr_readend='2016-03-01 16:07:00' WHERE dsr_id=34698;
 UPDATE did.t_didsonread_dsr SET dsr_readend='2016-01-14 12:18:00"' WHERE dsr_id=33824;
  UPDATE did.t_didsonread_dsr SET dsr_readend='2015-11-25 13:30:00' WHERE dsr_id=33006;
  UPDATE did.t_didsonread_dsr SET dsr_readend='2016-06-30 16:44:00' WHERE dsr_id=35726;
  UPDATE did.t_didsonread_dsr SET dsr_readend='2015-12-11 12:32:00' WHERE dsr_id=33331;
  --------------------------
 with depouillement AS (
	SELECT dsf_timeinit,dsr_id, EXTRACT('month' FROM dsf_timeinit) 
	AS mois,dsr_reader, dsf_position,dsr_readinit,dsr_readend, dsr_readend-dsr_readinit AS temps_lecture , dsr_id
	FROM did.t_didsonread_dsr JOIN did.t_didsonfiles_dsf ON dsf_id=dsr_dsf_id
	 WHERE dsf_timeinit>'2022-09-01 00:00:00' AND dsf_timeinit<'2023-05-01 00:00:00')
 SELECT * FROM depouillement WHERE temps_lecture<interval '00:00:00';
 -----------------------------
 

/*
File status manquants
0	OK	Enregistrement normal
1	Acquisition	Problème d'acquisition
2	Ecriture	Problème d'écriture
3	Qualité	Le fichier existe mais est de mauvaise qualité, ex :perte du fichier père, il ne reste que l'extraction, lecture impossible du fait du colmatage de la lentille
*/

-- vérification des fls_id
SELECT count(*), dsf_fls_id FROM did.t_didsonfiles_dsf WHERE dsf_season='2021-2022' GROUP BY dsf_fls_id;

/*
count dsf_id
(2021)
8136 NULL	
718	1
697	3
(2022)
8788  0
1082  1
4 3
119 2
*/

UPDATE did.t_didsonfiles_dsf SET dsf_fls_id=0 WHERE dsf_fls_id IS NULL AND dsf_season='2021-2022'; --8136