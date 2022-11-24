/*
scan_didsontxt.sql
Attention il faut avoir lancé scan_didson.R
et integration_bd.R (pour intégrer les fichiers excel)
ATTENTION TRAVAILLER SUR UNE COPIE LOCALE. LES CHANGEMNTS DE LA BASE HISTORIQUE
SE SONT FAITS AVEC L'INTERFACE GRAPHIQUE !!!!!!!!
NE PAS CHANGER LES DONNEES HISTORIQUES

POUR MODIFIER LES DONNEES UTILISER DIDSON2.odb dans le dossier workspace/p/didson. Cette interface fonctionne mais attention avec l'ascenseur.... 
RESTER CLIQUE POUR N'ENVOYER QU'UNE COMMANDE
*/


set search_path to did,public;
--select * from t_didsonfiles_dsf;
--select * from did.t_poissonsfiletemp_psf;
-- vérification qu'il n'y a pas eu deux enregistrements dans la base
/*
NETTOYAGE SI BUG DANS IMPORT FICHIER DSF 
*/
/*
delete from did.t_poissonfile_psf where psf_drr_id in 
(select drr_id from t_didsonreadresult_drr
	where drr_dsf_id in (select dsf_id from t_didsonfiles_dsf where
			dsf_season='2020-2021')
	);

delete  from t_didsonreadresult_drr
	where drr_dsf_id in (select dsf_id from t_didsonfiles_dsf where
			dsf_season='2020-2021');
	
delete  from t_didsonread_dsr
	where dsr_dsf_id in (select dsf_id from t_didsonfiles_dsf where
      dsf_season='2020-2021'); --3594
      
delete  from t_didsonfiles_dsf
	where
      dsf_season='2020-2021';--10175
*/

alter table did.t_didsonfiletemp_dsft add constraint c_pk_dsft_id primary key (dsft_id);



-- changements spécifiques à l'import 2013"
/*
update t_didsonfiletemp_dsft set 
	dsft_filename= substring(dsft_filename,1,16)||'0'||substring(dsft_filename,18,10) 
	where substring(dsft_filename,17,1)='1';--30
*/
-- corrections pre contrainte 2019
/*
 * 
UPDATE did.t_didsonfiletemp_dsft SET (dsft_filename,dsft_id)=('2019-12-15_023000_HF','FC_CSOT_2019-12-15_023000_HF') 
WHERE dsft_id='FC_CSOT_2019-12-15_020000_HF'
AND dsft_upstream=2; --1
 */

-- vérification que le fichier dsf est déjà dans la base
-- la requête qui suit doit renvoyer zéro lignes 
select * from t_didsonfiles_dsf 
full outer join t_didsonfiletemp_dsft on dsf_filename=dsft_filename where dsf_id is null; -- doit renvoyer zero lignes
-- vérification que les poissons n'ont pas été rentrés les uns à la suite des autres
select * from did.t_poissonsfiletemp_psf where psf_file>1; -- doit renvoyer zero lignes

/*
BEGin;
update did.t_poissonsfiletemp_psf SET psf_file =1 where psf_file>1;
UPDATE did.t_didsonfiletemp_dsft set dsft_filename='2019-01-26_040000_HF' where dsft_filename='2019-01-26_040001_HF'; --1
COMMIT; 
*/
select * from did.t_didsonfiletemp_dsft -- doit renvoyer les lignes avec l'année en cours (ou les lignes supplémentaires à ajouter)

/* corrections 2016
select * from t_didsonfiles_dsf where dsf_season='2015-2016' order by dsf_timeinit ;
select dsf_incl,dsf_depth from t_didsonfiles_dsf  where dsf_timeinit>'2016-04-27 16:00:00';
update t_didsonfiles_dsf  set (dsf_incl,dsf_depth)=(-7,0) where dsf_timeinit>='2016-04-27 16:00:00'; --159
select dsf_timeinit, dsf_incl,dsf_depth from t_didsonfiles_dsf  where dsf_season='2015-2016'  and dsf_position='volet';
update t_didsonfiles_dsf set dsf_incl=-7 where dsf_season='2015-2016'  and dsf_position='volet';
*/


/* 
corrections 2017
update t_didsonfiletemp_dsft set dsft_filename='2017-04-04_183000_HF' where  dsft_filename='2017-04-04_183001_HF'

*/
-- pour vérifier jointure (il doit y avoir des lignes complètes et d'autres non)
select * from t_didsonfiles_dsf 
full outer join t_didsonfiletemp_dsft on dsf_filename=dsft_filename
where dsf_season is null
order by dsf_timeinit;

/*runnonce IGNORE ME
alter table did.t_didsonfiles_dsf add column dsf_season character varying(30);
update did.t_didsonfiles_dsf set dsf_season='2012-2013' where  dsf_timeinit>='2012-09-01 00:00:00' and dsf_timeinit<='2013-05-01 00:00:00';
update did.t_didsonfiles_dsf set dsf_season='2013-2014' where  dsf_timeinit>='2013-09-01 00:00:00' and dsf_timeinit<='2014-05-01 00:00:00';
update did.t_didsonfiles_dsf set dsf_season='2014-2015' where  dsf_timeinit>='2014-09-01 00:00:00' and dsf_timeinit<='2015-05-01 00:00:00';
select * from did.t_didsonfiles_dsf  where dsf_season is null;
alter table did.t_didsonfiles_dsf add column dsf_mois integer;
*/

/* runonce
alter table did.t_didsonreadresult_drr add constraint c_pk_drr_id primary key (drr_id);
alter table t_didsonreadresult_drr add constraint c_fk_drr_dsf_id foreign key (drr_dsf_id) references did.t_didsonfiles_dsf(dsf_id);
alter table t_didsonreadresult_drr add constraint c_fk_drr_dsr_id foreign key (drr_dsr_id) references did.t_didsonread_dsr(dsr_id);
alter table t_didsonread_dsr add column dsr_csotismin boolean;
drop table if exists t_didsonreadresult_drr;
alter table t_didsonfiletemp_dsft rename to t_didsonreadresult_drr;
alter table t_didsonreadresult_drr rename column dsft_id to drr_id;
alter table t_didsonreadresult_drr rename column "dsft_unknown" to drr_unknown;
alter table t_didsonreadresult_drr rename column dsft_downstream to drr_downstream;
alter table t_didsonreadresult_drr rename column dsft_upstream to drr_upstream;
alter table t_didsonreadresult_drr rename column dsft_totalfish to drr_totalfish;
alter table t_didsonreadresult_drr rename column dsft_windowend_m to drr_windowend_m;
alter table t_didsonreadresult_drr rename column dsft_windowstart_m to drr_windowstart_m;
alter table t_didsonreadresult_drr rename column dsft_csotminthreshold_db to drr_csotminthreshold_db;
alter table t_didsonreadresult_drr rename column "dsft_csotmincluster_cm2" to drr_csotmincluster_cm2;
alter table t_didsonreadresult_drr rename column dsft_threshold_db to drr_threshold_db;
alter table t_didsonreadresult_drr rename column dsft_intensity_db to drr_intensity_db;
alter table t_didsonreadresult_drr rename column dsft_editorid to drr_editorid;
alter table t_didsonreadresult_drr rename column dsft_countfilename to drr_countfilename;
alter table t_didsonreadresult_drr rename column dsft_upstreammotion to drr_upstreammotion;
alter table t_didsonreadresult_drr rename column dsft_end to drr_end;
alter table t_didsonreadresult_drr rename column dsft_start to drr_start;
alter table t_didsonreadresult_drr rename column dsft_date to drr_date;
alter table t_didsonreadresult_drr rename column dsft_path to drr_path;
alter table t_didsonreadresult_drr rename column dsft_filename to drr_filename;
alter table t_didsonreadresult_drr add column drr_dsf_id integer;
alter table t_didsonreadresult_drr add column drr_dsr_id integer;

create table t_poissonfile_psf as select * from t_poissonsfiletemp_psf --2541
alter table t_poissonfile_psf rename column psf_id to psf_drr_id;
alter table t_poissonfile_psf add column psf_id serial primary key;
alter table did.t_poissonfile_psf add constraint c_fk_psf_drr_id foreign key (psf_drr_id) references did.t_didsonreadresult_drr(drr_id);

*/
-- mise à jour du champ dsf_season
--select * from did.t_didsonfiles_dsf where dsf_season is null;
select * from did.t_didsonfiles_dsf where dsf_season='2019-2020';
select * from did.t_didsonfiles_dsf where dsf_season='2017-2018';
select * from did.t_didsonfiles_dsf where dsf_season='2020-2021';
update did.t_didsonfiles_dsf set dsf_season='2015-2016' where  dsf_timeinit>='2015-09-01 00:00:00' and dsf_timeinit<='2016-05-01 00:00:00'; --10608
update did.t_didsonfiles_dsf set dsf_season='2016-2017' where  dsf_timeinit>='2016-09-01 00:00:00' and dsf_timeinit<='2017-05-01 00:00:00'; --9277
update did.t_didsonfiles_dsf set dsf_season='2017-2018' where  dsf_timeinit>='2017-09-01 00:00:00' and dsf_timeinit<='2018-05-01 00:00:00'; --5784
update did.t_didsonfiles_dsf set dsf_season='2018-2019' where  dsf_timeinit>='2018-09-01 00:00:00' and dsf_timeinit<='2019-05-01 00:00:00'; --7602
update did.t_didsonfiles_dsf set dsf_season='2019-2020' where  dsf_timeinit>='2019-09-01 00:00:00' and dsf_timeinit<='2020-05-01 00:00:00'; --9551
update did.t_didsonfiles_dsf set dsf_season='2020-2021' where  dsf_timeinit>='2020-09-01 00:00:00' and dsf_timeinit<='2021-05-01 00:00:00'; --10175
update did.t_didsonfiles_dsf set dsf_mois =extract(month from dsf_timeinit); --82074-- Insertion des données des tables temporaires 
-- verif qu'elles sont déjà dedans (avant delete)


-- verif qu'elles sont déjà dedans (avant delete) : doit ne rien renvoyer
select * from t_poissonfile_psf where psf_drr_id in
(select psf_id from t_poissonsfiletemp_psf);

-- A ne lancer que pour les données supplémentaires (intégrées après coup... changement de nom de table)
select * from t_poissonfile_psf where psf_drr_id in
(select psf_id from t_poissonsfiletemppb_psf);

-- suppressions au cas ou il y aurait déjà eu des imports
delete from t_poissonfile_psf where psf_drr_id in
(select psf_id from t_poissonsfiletemp_psf);--0

delete from t_didsonreadresult_drr where drr_id in
(select dsft_id from t_didsonfiletemp_dsft) ;--0


/*
INSERTION DES RESULTATS DES TABLES TEMPORAIRES DANS LA BASE
*/

insert into t_didsonreadresult_drr(
drr_id,drr_unknown,drr_downstream,drr_upstream,drr_totalfish,drr_windowend_m,
drr_windowstart_m,drr_csotminthreshold_db,drr_csotmincluster_cm2,drr_threshold_db,
drr_intensity_db,drr_editorid,drr_countfilename,drr_upstreammotion,drr_end,drr_start,
drr_date,drr_path,drr_filename
) select 
dsft_id,dsft_unknown,dsft_downstream,dsft_upstream,dsft_totalfish,dsft_windowend_m,
dsft_windowstart_m,dsft_csotminthreshold_db,dsft_csotmincluster_cm2,dsft_threshold_db,
dsft_intensity_db,dsft_editorid,dsft_countfilename,dsft_upstreammotion,dsft_end,dsft_start,
dsft_date,dsft_path,dsft_filename
 from 
t_didsonfiletemp_dsft;--1323 # 2014 902 2015 951 2016 1421 2017 477 2018 (+34+4+38(jour) 2018) 848 2019 690 2020 985 2021

-- a ne lancer que pour les données supplémentaires
insert into t_didsonreadresult_drr(
drr_id,drr_unknown,drr_downstream,drr_upstream,drr_totalfish,drr_windowend_m,
drr_windowstart_m,drr_csotminthreshold_db,drr_csotmincluster_cm2,drr_threshold_db,
drr_intensity_db,drr_editorid,drr_countfilename,drr_upstreammotion,drr_end,drr_start,
drr_date,drr_path,drr_filename
) select 
dsft_id,dsft_unknown,dsft_downstream,dsft_upstream,dsft_totalfish,dsft_windowend_m,
dsft_windowstart_m,dsft_csotminthreshold_db,dsft_csotmincluster_cm2,dsft_threshold_db,
dsft_intensity_db,dsft_editorid,dsft_countfilename,dsft_upstreammotion,dsft_end,dsft_start,
dsft_date,dsft_path,dsft_filename
 from 
t_didsonfiletemppb_dsft; --2 (2019)



insert into t_poissonfile_psf
(psf_drr_id,psf_comment,psf_n,psf_q,psf_move,psf_motion,psf_species,psf_roll,psf_tilt,
psf_pan,psf_longitude_unit,psf_longitude4,psf_longitude3,psf_longitude2,psf_longitude1,
psf_latitude_unit,psf_latitude4,psf_latitude3,psf_latitude2,psf_latitude1,psf_date,psf_time,
psf_aspect,psf_ldr,psf_dr_cm,psf_l_cm,psf_theta,psf_radius_m,psf_dir,psf_frame,psf_total,psf_file)
 select 
 psf_id,psf_comment,psf_n,psf_q,psf_move,psf_motion,psf_species,psf_roll,psf_tilt,
psf_pan,psf_longitude_unit,psf_longitude4,psf_longitude3,psf_longitude2,psf_longitude1,
psf_latitude_unit,psf_latitude4,psf_latitude3,psf_latitude2,psf_latitude1,psf_date,psf_time,
psf_aspect,psf_ldr,psf_dr_cm,psf_l_cm,psf_theta,psf_radius_m,psf_dir,psf_frame,psf_total,psf_file
 from t_poissonsfiletemp_psf;--3429 --1972 -- 2303 --4744 --2031 --1314 (+44+4+87(jour) 2018) 1742 2019 1432 2020 2044 2021

-- a ne lancer que pour les données supplémentaires
insert into t_poissonfile_psf
(psf_drr_id,psf_comment,psf_n,psf_q,psf_move,psf_motion,psf_species,psf_roll,psf_tilt,
psf_pan,psf_longitude_unit,psf_longitude4,psf_longitude3,psf_longitude2,psf_longitude1,
psf_latitude_unit,psf_latitude4,psf_latitude3,psf_latitude2,psf_latitude1,psf_date,psf_time,
psf_aspect,psf_ldr,psf_dr_cm,psf_l_cm,psf_theta,psf_radius_m,psf_dir,psf_frame,psf_total,psf_file)
 select 
 psf_id,psf_comment,psf_n,psf_q,psf_move,psf_motion,psf_species,psf_roll,psf_tilt,
psf_pan,psf_longitude_unit,psf_longitude4,psf_longitude3,psf_longitude2,psf_longitude1,
psf_latitude_unit,psf_latitude4,psf_latitude3,psf_latitude2,psf_latitude1,psf_date,psf_time,
psf_aspect,psf_ldr,psf_dr_cm,psf_l_cm,psf_theta,psf_radius_m,psf_dir,psf_frame,psf_total,psf_file
 from t_poissonsfiletemppb_psf; --3 (2019)

/*
Attention si le nombre de lignes renvoyé est indentique à l'année dernière, 
tu as oublié t'intégrer le fichier t_didsonfile_dsf il faut lancer le programme
integration_bd.R en vérifiant que les identifiants sqldf de connexion pointent bien vers la bonne base
*/

select count(*) from t_didsonfiles_dsf  dsf join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on drr_filename=dsf_filename;--1322 --2455 -- 3518 --4940 -5660 --6195 --6234--7082 -- 7774 -- 8759

/*
##################################
creation des drr_dsf_id : on joint les fichiers texte de lecture didson aux fichiers de la base
##################################

##########################
RECHERCHE DES FICHIERS DOUBLES
sera règlé plus loin par la fixation d'un csotismin
donc ne pas s'affoler sur cette requete on traite ce cas plus loin
###########################
*/
select * from (
select dsf_id,dsf_season, dsf_timeinit,dsr_csotismin, dsr_id,drr_id,drr_dsf_id,drr_dsr_id,dsr_reader,dsr_csotdb, drr_threshold_db,dsr_eelplus,dsr_eelminus,drr_totalfish,drr_upstream,drr_downstream,drr_filename,
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr 
from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on drr_filename=dsf_filename
order by countdsr, dsf_id desc) sub
where dsf_season='2020-2021'
and countdrr>1
; --128 2015 4 2016 8 2017 44 2018 0 2019 0 2020 0 2021


/*
2016
Après avoir travaillé je sais que les fichiers poisson sont que pour les csot 2.1 pour le cas suivant
update t_didsonread_dsr set dsr_csotismin=TRUE where dsr_id=35182;
update t_didsonread_dsr set dsr_csotismin=TRUE where dsr_id=35030;

*/
/*
##########################
MISE A JOUR DES LIENS
cette procédure ne devrait plus être aussi fastidieuse une fois que seront renseignés les utilisateurs dans les lectures
des fichiers didson.
###########################
*/
-- ci dessous certains fichiers n'ont pas encore le drr_dsr_id renseigné.
-- select * from t_didsonreadresult_drr where drr_dsr_id is null;--1037 2015 1421 2016 849 2019
/*
recherche des fichiers avec plusieurs lecteurs
le script donne un count drr et un count dsr
normalement une double lecture correspond à 4 lignes 

select * from (
select dsf_id,dsr_id,dsr_csotismin,drr_id,drr_dsf_id,drr_dsr_id,dsr_reader,dsr_csotdb, drr_threshold_db,dsr_eelplus,dsr_eelminus,drr_totalfish,drr_upstream,drr_downstream,drr_filename,
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr 
from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on drr_filename=dsf_filename
where dsf_season='2020-2021'
order by countdsr, dsf_id desc) toto
where countdsr>1 or countdrr>1;
*/
/*
2016
-------------------
deux fichiers avec même horaire, même lecteur même csot
select * from t_didsonfiles_dsf  where dsf_id=99167;
select *  from t_didsonread_dsr dsr where dsr_dsf_id=99167;
select * from t_didsonreadresult_drr where drr_id='FC_CSOT_2016-04-09_013000_HF_P1642'
-- les résultats sont les mêmes j'en supprime un des deux
delete from t_poissonfile_psf where psf_drr_id='FC_CSOT_2016-04-09_013000_HF_P1639' ;--1
delete from t_didsonreadresult_drr where drr_id='FC_CSOT_2016-04-09_013000_HF_P1639' ;--1
*/

/* 
Le fait d'avoir plusieurs fichiers pose évidemment des problèmes de jointure
Ci dessous une requete sans trop d'intérêt qui donne les problèmes
Il y en a beaucoup qui ne sont pas bons, mais le champ drr_totalfish ne semble pas très bien renseigné !
C'est corrigé plus loin
*/
*/
select drr_id,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus as total,drr_totalfish,drr_upstream,drr_downstream
from t_didsonfiles_dsf  dsf join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on drr_filename=dsf_filename
where drr_totalfish!=(dsr_eelplus-dsr_eelminus)
and dsf_season='2020-2021'
order by drr_id; --319  -- 12 2016-2017 --5 2017-2018 --6 2018-2019 --5 2019-2020 --17 2020-2021
*/

/*
Etape 0 mise a jour des dsf_id....
Facile car clé primaire sur drr_id
*/

--update t_didsonreadresult_drr set drr_dsr_id=NULL;

WITH dsf_drr AS 
(
select dsf_id,drr_id from   t_didsonfiles_dsf  dsf 
join t_didsonreadresult_drr drr on drr_filename=dsf_filename
and dsf_season='2020-2021'
)
update t_didsonreadresult_drr set drr_dsf_id=dsf_drr.dsf_id from dsf_drr
where dsf_drr.drr_id=t_didsonreadresult_drr.drr_id 
and drr_dsf_id is NULL
;--1306	--2205 -- 3182 --5  --1420 (2016) --716 (2017) --477 2018 (+34 +4 + 38 2018) 848 2019 -- 690 + 2 2020

/*
MISE A JOUR DES dsr_id
Etape 1 recherche des relations 1 a 1
Il n'est pas possible de mettre un partition by dans une clause where d'ou la requête un peu compliquée
comptage des dsf_id, et selection de ceux ou il n'y a qu'un dsf_id
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ATTENTION METTRE A JOUR LA DATE (SAISON)!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

*/

update t_didsonreadresult_drr set drr_dsr_id=dsr_id from 
(
	select dsf_id,dsr_id,drr_id from  t_didsonfiles_dsf  dsf 
	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
	join t_didsonreadresult_drr drr on drr_filename=dsf_filename
	where dsf_id in (
	select dsf_id from (
	select dsf_id,
	count (*) over (partition by drr_id)
	from   t_didsonfiles_dsf  dsf 	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
					join t_didsonreadresult_drr drr on drr_filename=dsf_filename
					where dsf_season='2020-2021')sub
	where count=1)
) uqr	
where uqr.drr_id=t_didsonreadresult_drr.drr_id 
and drr_dsr_id is NULL
;--1095	--868 --1418(2016) -- 712 (2017) --456 (2018) (+33 +4 + 37 2018) 847 2019 690 +2  2020 985 2021

/* pb 2014
select * from t_didsonreadresult_drr where drr_dsr_id=23746
select * from t_didsonfiles_dsf where dsf_id in (select dsr_dsf_id from t_didsonread_dsr where dsr_id=23746)
delete from t_poissonfile_psf where psf_drr_id='FC_CSOT_2014-02-11_040000_HF_P0905';
delete from t_didsonreadresult_drr where drr_id='FC_CSOT_2014-02-11_040000_HF_P0905';

delete from t_poissonfile_psf where psf_drr_id='FC_CSOT_2014-03-28_000000_HF_P1012';
delete from t_didsonreadresult_drr where drr_id='FC_CSOT_2014-03-28_000000_HF_P1012';

delete from t_poissonfile_psf where psf_drr_id='FC_CSOT_2013-11-06_233000_HF_P1408';
delete from t_didsonreadresult_drr where drr_id='FC_CSOT_2013-11-06_233000_HF_P1408';
*/

/* pb 2015

select drr.*
from   t_didsonfiles_dsf  dsf 	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
					join t_didsonreadresult_drr drr on drr_filename=dsf_filename
 where dsf_timeinit>='2014-09-01 00:00:00' and dsf_timeinit<='2015-05-01 00:00:00'

-- temp 2015
-- il faut que je réaffecte gerard2 à la place de gerard pour les lectures doubles
-- ci dessous une requête qui doublonne les lignes mais montre que les données avec relecture sont toutes drr_csotminthreshold_db=0
 select * from (
select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename)=(dsf_filename)
) sub
where  countdsf=2
and dsf_timeinit>='2014-09-01 00:00:00' 
and dsf_timeinit<='2015-05-01 00:00:00'
order by dsf_id, dsr_id,drr_csotminthreshold_db

update t_didsonreadresult_drr set drr_editorid='gerard2' where drr_id in
(select drr_id from (
select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr,
count (*) over (partition by dsf_id) as countdsf  
from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
) sub
where  countdsf=2
and dsf_season='2014-2015'
and drr_csotminthreshold_db=0);--25


 Ci dessous c'est parce que je suis déjà passé une fois que j'ai des valeurs manquantes
 en gros maintenant tout le monde a un dsf, un dsr dans le fichier drr mais il y a des doublons pour les utilisateurs
 deux lignes pour 'gerard' alors qu'il faudrait 'gerard2' et 'gerard'


select * from (
select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr,
count (*) over (partition by dsf_id) as countdsf  
from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
) sub
where  countdsf=2
and dsf_season='2014-2015'
order by dsf_id, dsr_id,drr_csotminthreshold_db




update t_didsonread_dsr set dsr_reader='Gerard2' where dsr_id in
(select dsr_id from (
select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr,
count (*) over (partition by dsf_id) as countdsf  
from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
) sub
where  countdsf=2
and dsf_season='2014-2015'
and drr_csotminthreshold_db=0);--25

pb 2018-2019

ERREUR: la valeur d'une clé dupliquée rompt la contrainte unique « c_uk_drr_dsr_id »
État SQL :23505
Détail :La clé « (drr_dsr_id)=(48366) » existe déjà.


WITH testupdate as (

	select dsf_id,dsr_id,drr_id from  t_didsonfiles_dsf  dsf 
	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
	join t_didsonreadresult_drr drr on drr_filename=dsf_filename
	where dsf_id in (
	select dsf_id from (
	select dsf_id,
	count (*) over (partition by drr_id)
	from   t_didsonfiles_dsf  dsf 	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
					join t_didsonreadresult_drr drr on drr_filename=dsf_filename
					where dsf_season='2018-2019')sub
	where count=1))
 
select * from testupdate where dsr_id=48366

SELECT * FROM  t_didsonreadresult_drr where drr_id like '%FC_CSOT_2018-12-25_213000_HF%';
SELECT * from t_poissonfile_psf where psf_drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1452';
SELECT * from t_poissonfile_psf where psf_drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1713';
SELECT * from t_poissonfile_psf where psf_drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1713';
DELETE from t_poissonfile_psf where psf_drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1713'; --1
DELETE FROM t_didsonreadresult_drr where drr_id = 'FC_CSOT_2018-12-25_213000_HF_P1713';
-- un nom changé qui joint pas
SELECT * FROM  did.t_didsonfiles_dsf where dsf_filename='2019-01-26_040000_HF';
BEGIN;
UPDATE did.t_didsonfiles_dsf set dsf_filename='2019-01-26_040001_HF'  WHERE dsf_filename='2019-01-26_040000_HF' ;--1
COMMIT;
*/


/*
Etape 2 recherche des relations 1 a 1 en fonction du csotdb
Les requêtes ci dessous ne modifient que les fichiers dont le drr_dsr_id est null
drr_csotminthreshold_db est nul et il faut qu'il soit 0 pour tous les fichiers de l'année
*/

		
select * from t_didsonreadresult_drr where
	drr_id in (
	select drr_id from t_didsonfiles_dsf 
	join t_didsonreadresult_drr on drr_dsf_id=dsf_id 
	where dsf_season='2020-2021'
	); 

update t_didsonreadresult_drr set drr_csotminthreshold_db=0 where drr_csotminthreshold_db is null and
	drr_id in (
	select drr_id from t_didsonfiles_dsf 
	join t_didsonreadresult_drr on drr_dsf_id=dsf_id 
	where dsf_season='2020-2021'
	); --98 --3 -- 67 --37 (2016) --36 (2017) --26 3(2018) -- 8 2 2020 0 2021

-- ci dessous j'ai viré un fichier qui avait pas DSR	
select * from t_didsonread_dsr
where dsr_csotdb is null and
 dsr_id in (
	select dsr_id from t_didsonfiles_dsf 
	join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2020-2021'
	); --2019 ---317 2020 804 2021 138
-- ci dessous deux fois des fichiers avec dsr_csot null (pas possible)
-- select * from t_didsonread_dsr where dsr_dsf_id=133245
-- delete from t_didsonread_dsr where dsr_id = 46820	
-- select * from t_didsonread_dsr where dsr_dsf_id=131016
-- update t_didsonread_dsr set dsr_complete=TRUE where dsr_id=47629; --1

update t_didsonread_dsr set dsr_csotdb=0 where dsr_csotdb is null and
 dsr_id in (
	select dsr_id from t_didsonfiles_dsf 
	join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2020-2021' and dsr_complete
	);

; --122 --4 (2016) --19 (2017)--30 (2018) --1(2018) 371 2019 801 + 0 2020 138 2021
-- maintenant j'ai des csotdb partout et je peux faire la jointure à la fois sur csotdb et dsf_id
-- parmis ceux qui ne se sont pas vu adressé de dsr, lesquels ont le même nom de fichier de dépouillement drr_filename et le même csotdb
select *  from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
where drr_dsr_id is null
and dsf_season='2020-2021'
order by dsf_id; --2 (2016) 3 (2017) 21 (2018) 0 (2019) 0 (2020) 0 (2021)

/*
ci dessous la requète met à jour les memes lignes que ci dessus
2020 modification de la syntaxe, ça ne passe plus avec des sous requêtes
*/


WITH sub AS (
select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
where drr_dsr_id is null
and dsf_season='2017-2018'),
dbr AS (  -- double rows
select * from sub
where  countdsr=1 -- un seul fichier texte
)

-- select * from dbr -- (décommenter pour voir le résultat avant le update)
update t_didsonreadresult_drr set drr_dsr_id=dsr_id from dbr
where dbr.drr_id=t_didsonreadresult_drr.drr_id 
and t_didsonreadresult_drr.drr_dsr_id is null
;--200 --20 -- 36 --2+1 rows 2016 -- 3 2017 --21 2018 (+1 2018) 0 + 0 2019 0 2020

/*
Etape 3
Vérifier si il a quelque chose en lançant la partie interne (dans la parenthèse à partir du from)
si il n'y a rien, ignorer cette étape , si quelque chose il faudra sans doute passer en sous-requete
*/

update t_didsonreadresult_drr set (drr_dsr_id)=(dsr_id) from (
select dsf_id,
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
count (*) over (partition by dsf_id) as countdsf,
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
where drr_dsr_id is null
and drr_editorid='gerard'
and dsr_reader='Gerard'
and dsf_season='2020-2021'
order by dsf_id
) dbr 
where dbr.drr_id=t_didsonreadresult_drr.drr_id ;--11--0 -- 0(2016) --0 2018 --0 2019 --0 2020


/*
Pareil ignorer si il n'y a rien, si quelque chose il faudra sans doute passer en sous-requete (ré-écrire la requete avec des with)
*/
update t_didsonreadresult_drr set (drr_dsr_id)=(dsr_id) from (
select dsf_id,
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
count (*) over (partition by dsf_id) as countdsf,
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
where drr_dsr_id is null
and drr_editorid='brice'
and dsr_reader='Brice'
and dsf_season='2020-2021'
order by dsf_id
) dbr -- double rows
where dbr.drr_id=t_didsonreadresult_drr.drr_id ;--11	--0	--0(2016) --0 2018 --0 2019 --0 2020

/*
update t_didsonreadresult_drr set (drr_dsr_id)=(dsr_id) from (

select * from (
select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
where drr_dsr_id is null) sub
where  countdsr=1 -- un seul fichier texte
) dbr -- double rows
where dbr.drr_id=t_didsonreadresult_drr.drr_id ;--1	
*/

/*
Si la requête de vérif en dessous renvoit zéro lignes, le travail est terminé
ignorer les étapes suivantes
*/

select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename,drr_csotminthreshold_db)=(dsf_filename,dsr_csotdb)
where drr_dsr_id is null
and dsf_season='2020-2021'
order by dsf_id; -- 0 lignes



WITH sub AS (
select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename)=(dsf_filename)
where drr_dsr_id is null
and dsf_season='2020-2021'),
dbr AS (
select * from sub
where  countdsr=1 -- un seul fichier texte
) -- double rows
update t_didsonreadresult_drr set drr_dsr_id=dsr_id from dbr
where dbr.drr_id=t_didsonreadresult_drr.drr_id ;--0--0--0 (2017)--0 (2018) --1 2019 (après changement du nom du fichier eg 0001') 0 + 0 2020
/*
Etape 4
ON VERIFIE SI IL RESTE DES drr_dsr_id non affectés. 
Il s'agit de doubles comptages
JOINTURE SUR
drr_filename <--> dsf_filename (nom du fichier)
pour lequel drr_dsr_id reste nul.
*/

select * from t_didsonreadresult_drr where drr_dsr_id is null order by drr_dsf_id; --27  1 2017 24 2018  --0 2019 --0 2020 --0 2021

-- TODO si besoin passer en sous requète, la syntaxe ne marche plus, voir script précédent

update t_didsonreadresult_drr set (drr_dsr_id)=(dsr_id) from (
select dsf_id,
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
count (*) over (partition by drr_id) as countdrr,
count (*) over (partition by dsr_id) as countdsr from   t_didsonfiles_dsf  dsf 
join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
join t_didsonreadresult_drr drr on (drr_filename)=(dsf_filename)
where drr_dsr_id is null
and dsf_season='2020-2021'
) dbr -- double rows
where dbr.drr_id=t_didsonreadresult_drr.drr_id ;--6 -- 0 (2016) --1 2017 --0 2018

/*
Etape 5

*/

select * from  t_didsonfiles_dsf  dsf join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id where dsf_id in 
(select drr_dsf_id from t_didsonreadresult_drr where drr_dsr_id is null )
and dsf_season='2020-2021';--0 --0 2016 --0 2017 --0 2018 --0 2020 --0 2021

select * from  t_didsonfiles_dsf  dsf  where dsf_id in 
(select drr_dsf_id from t_didsonreadresult_drr where drr_dsr_id is null); -- 0(2016) 0 (2017) si zéro ça veut dire que tous les drr_dsr_id sont affectés
-- mais pas forcément qu'ils sont justes (voir plus loin)

-- contrainte
--alter table did.t_didsonreadresult_drr add constraint c_uk_drr_dsr_id unique (drr_dsr_id);


-- recherche des fichiers avec plus d'une jointure entre drr_dsr_id et dsr_id
select * from did.t_didsonreadresult_drr where drr_dsr_id in (
  select drr_dsr_id from (
    select count(drr_dsr_id),drr_dsr_id from did.t_didsonread_dsr
    				join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
    				group by drr_dsr_id) sub
    				where count>1)
            and drr_dsf_id in (select dsf_id from t_didsonfiles_dsf where dsf_season='2020-2021')				
order by drr_filename;--0 (2016)


/*
SELECTION DES FICHIERS AVEC MEILLEUR CSOT
*/



 -- ON COMMENCE PAR METTRE FALSE A TOUT LE MONDE

update t_didsonread_dsr set dsr_csotismin=FALSE where dsr_id in
(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id where dsf_season='2020-2021'); 
--4200 --3110 (2016) 1780 (2017) 2161 2018 3366 2019 2402 2020 3594 2021

 -- CEUX POUR LESQUELS IL N'Y A QU'UNE SEULE LECTURE SON MIN
 
update t_didsonread_dsr set dsr_csotismin=TRUE where dsr_id in (
select dsr_id from(
	select count (*) over (partition by dsf_id) c,
	dsr_id from
	t_didsonfiles_dsf  dsf 	
	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
	 where dsf_season='2020-2021'
	order by dsr_id) sub
where c=1); 
--3557 -6814 -- 9723 lignes pour lesquelles il n'y a qu'une valeur --3072 (2016) 
--1767 (2017) -- 2110 2018 --3364 (2019) --2402 (2020) -- 3597 (2021)


-- CI DESSOUS ON MET A JOUR LES FICHIERS QUI ONT LE PLUS PETIT CSOT POUR LES FICHIERS DOUBLES (QUI SONT TOUS FALSE APRES L'ETAPE PRECEDENTE)
-- le select min over partition by selectionne un enregistrement avec dsr_dsf_id et dsr_csotdb correspondant au CSOT le plus base
-- on fait ensuite le update en selectionnant à la fois le csot et le dsf_id dans le pivot (sub.dsr_csotdb,sub.dsr_dsf_id)

update t_didsonread_dsr set dsr_csotismin=TRUE where dsr_id in
 (select dsr_id from t_didsonread_dsr join 
	(select distinct  dsr_dsf_id,  min(dsr_csotdb) over (partition by dsr_dsf_id) as dsr_csotdb
	from t_didsonread_dsr 
	where dsr_csotismin=FALSE
	and dsr_id in (select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id where dsf_season='2020-2021')
	) sub 
	on (sub.dsr_csotdb,sub.dsr_dsf_id)=(t_didsonread_dsr.dsr_csotdb,t_didsonread_dsr.dsr_dsf_id));
--329 --475 --378 --19 (2016) --6 (2017) --25 2018 --1 2019 --0 2020  --0 2021


/*
CERTAINS FICHIERS ONT ETE LUS DEUX FOIS AU MEME CSOT MAIS GERARD EST TOUJOURS LE MEILLEUR !
COMPTE TENU DES MODIFICATIONS MANUELLES NE PLUS LANCER CA


update t_didsonread_dsr set dsr_csotismin=FALSE where dsr_id in 
(select dsr_id from (
--==============================================
select * from t_didsonread_dsr 
	where dsr_dsf_id in (
		select dsf_id from (
			select dsf_id,
			count(dsf_id) c from t_didsonfiles_dsf 
			join t_didsonread_dsr on dsr_dsf_id=dsf_id 
			where dsr_csotismin=TRUE 
			group by dsf_id
			) sub
		where c>1)
	and dsr_csotismin
	and dsr_reader!='Gerard'
order by dsr_dsf_id
--==============================================
)subsub) --88 -- 393
*/
--verif qu'il n'y a plus de problème
-- si il reste des problèmes mettre à la main un FALSE pour certaines lignes (voir exemple ci-dessous)
select * from t_didsonread_dsr 
	where dsr_dsf_id in (
		select dsf_id from (
			select dsf_id,
			count(dsf_id) c from t_didsonfiles_dsf 
			join t_didsonread_dsr on dsr_dsf_id=dsf_id 
			where dsr_csotismin=TRUE 
			group by dsf_id
			) sub
		where c>1)
	and dsr_csotismin
order by dsr_dsf_id
;-- 0 lignes --0 lignes (2016) --0 2017 --0 2018
-- ATTENTION SI IL Y DES LIGNES DES AUTRES ANNEES C'EST QUE LE SCRIPT A CREE UN PB SUR LES ANNEES PRECEDENTES
-- NORMALEMENT CA NE DEVRAIT PLUS ARRIVER, LES ERREURS NE DOIVENT APPARAITRE QUE POUR L'ANNEE EN COURS

/* en 2018 j'ai  des problèmes après avoir réintégré les derniers fichiers de jour.
A chaque fois j'ai deux lignes marquées drs_csotismin=t mais pour certains fichers qui sont 2.1 ou 2.8  alors qu'il y a 0
Je mets dsr_csotismin = FALSE pour les lignes differentes de 0

with doublons as (
select * from t_didsonread_dsr 
	where dsr_dsf_id in (
		select dsf_id from (
			select dsf_id,
			count(dsf_id) c from t_didsonfiles_dsf 
			join t_didsonread_dsr on dsr_dsf_id=dsf_id 
			where dsr_csotismin=TRUE 
			group by dsf_id
			) sub
		where c>1)
	and dsr_csotismin
order by dsr_dsf_id)
-- select * from doublons where dsr_csotdb>0
update t_didsonread_dsr set dsr_csotismin=FALSE where dsr_id in (select dsr_id from doublons where dsr_csotdb>0); --25
*/

/* 2016-2017

UPDATE did.t_didsonread_dsr set dsr_csotismin= FALSE where dsr_id in (36565,36567,36569,36572)
UPDATE did.t_didsonread_dsr set dsr_csotismin= FALSE where dsr_id in (36543,36875)

*/


/*
Mise à jour de l'espèce pour les lamproies
*/
/*
CI DESSOUS NE PAS LANCER, LES LAMPROIES SONT RENSEIGNEES DANS LE FICHIER POISSON DIRECTEMENT !!!
select * from t_didsonfiles_dsf  dsf 	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
					join t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
					join t_poissonfile_psf on psf_drr_id=drr_id
					where (dsr_comment like '%lamproie%'
					or dsr_comment like '%Lamproie%')
					and dsf_season='2015-2016'; 2016 --

update t_poissonfile_psf set psf_species='2014' where psf_id in 
(select psf_id from t_didsonfiles_dsf  dsf 	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
					join t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
					join t_poissonfile_psf on psf_drr_id=drr_id
					where (dsr_comment like '%lamproie%'
					or dsr_comment like '%Lamproie%')
					and dsf_timeinit>'2013-03-01 00:00:00');--358
*/
/*
2013					
update t_poissonfile_psf set psf_species='2038' where psf_species is null;--2801
update t_poissonfile_psf set psf_species='2038' where psf_species='';--2801
select count(*),  psf_species from t_poissonfile_psf where psf_date>='2013-09-01 00:00:00' and psf_date<='2014-05-01 00:00:00'group by psf_species ; --2732 (2038) et 614 (2014)
update t_poissonfile_psf set psf_species='2014' where psf_species='lamproie';
select * from t_poissonfile_psf where psf_species='Backsliding';
select * from t_poissonfile_psf where psf_species='1';
update t_poissonfile_psf set (psf_species,psf_motion,psf_move,psf_q,psf_n)=('2038','Backsliding','<-->',3,1) where psf_id=27030;
update t_poissonfile_psf set (psf_species,psf_longitude_unit)=('2014',NULL) where psf_id=27197;
*/
/* 2014
update t_poissonfile_psf set (psf_species,psf_motion,psf_move,psf_q,psf_n)=(NULL,'Hanging','In',4,1) where psf_id=43352;
update t_poissonfile_psf set (psf_species,psf_motion,psf_move,psf_q,psf_n)=(NULL,'Hanging','In',2,1) where psf_id=43547;
update t_poissonfile_psf set psf_species='2038' where psf_species !='2014';--4708
*/
/*
2015
select distinct psf_species from t_poissonfile_psf
select * from t_poissonfile_psf where psf_species='anging';
update t_poissonfile_psf set (psf_species,psf_motion,psf_move,psf_q,psf_n)=('','Hanging','In',4,1) where psf_id=47152;--1
select * from t_poissonfile_psf where psf_species='unning';
update t_poissonfile_psf set (psf_species,psf_motion,psf_move,psf_q,psf_n)=('','Running','In',2,1) where psf_id=47130;
update t_poissonfile_psf set (psf_species,psf_motion,psf_move,psf_q,psf_n)=('','Running','In',5,1) where psf_id=47145;
update t_poissonfile_psf set (psf_species,psf_motion,psf_move,psf_q,psf_n)=('','Running','In',5,1) where psf_id=47150;

select * from t_poissonfile_psf where psf_species='';
update t_poissonfile_psf set psf_species='2038' where psf_species !='2014'; -- 6858
update t_poissonfile_psf set psf_species='2038' where psf_species is null; -- 6
update t_poissonfile_psf set psf_species='2038'  where psf_species!='2014' and psf_species!='2038';--33
*/
/*
2016
select distinct psf_species from t_poissonfile_psf
update t_poissonfile_psf set psf_species='2014' where psf_species ='2104';--3
select * from t_poissonfile_psf where psf_species='';
update t_poissonfile_psf set psf_species='2038' where psf_species=''; -- 10816 --87
*/
-- A LA FIN DU TRAITEMENT / CORRECTION CI DESSOUS IL NE DOIT RESTER QUE TROIS ESPECES 2038 2238 (SILURE)
--select DISTINCT(psf_comment) FROM did.t_poissonfile_psf;
select count(*), psf_species FROM t_poissonfile_psf GROUP BY psf_species;
/*
1979	2014
17185	2038
11	    2238 => 4 (supprimés)
*/


update t_poissonfile_psf set psf_species='2038' where psf_species=''; -- 2023 (2017) --1203 (2018) (+41+4 2018) --1737 2019 --1430 + 3 2020



--2020
/*
select * from t_poissonfile_psf where psf_species='In'; => un décalage de colonne, corrigé à la main
update t_poissonfile_psf set psf_species='2038' where psf_species='2238';
SELECT * FROM t_poissonfiletemps_psft WHER
*/

--2019


--2018
/*
update t_poissonfile_psf set psf_species='2038' where psf_species='2048';
*/
/*
TEST 2015 pas de lignes
*/
/*
update t_didsonread_dsr set dsr_csotismin=FALSE where dsr_id in (
select dsr_id from 
(
select dsr_id,
row_number()  over (partition by dsf_id) as num
from did.v_ddde
 order by dsr_readinit asc
 ) 
sub where num=2
and dsr_id is not null);--3 de plus
-- la validité du résultat est testée dans R avec stopifnot(length(which(duplicated(ddde$dsf_id)))==0)
*/
/* 
##########################
RECHERCHE D'INCOHERENCES ENTRE LE FICHIERS TEXTE POISSONS ET LE FICHIER DE LA BASE
###########################
*/




select count(*) from t_didsonfiles_dsf  dsf 	join  t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
					join t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id;
					--2117 --4629 (2016) --5345 (2017) --5860 (2018) --6746 (2019)  --7438 (2020) --8423 (2021)


/*
2013
select * from t_poissonfile_psf where psf_move='out'; --1
update t_poissonfile_psf set psf_move='Out' where psf_move='out';
update t_poissonfile_psf set psf_move='In' where psf_move='in';
select * from t_poissonfile_psf where psf_move='4'
*/


					
/*
CORRECTIONS D'ERREURS DE CODAGE
*/		


select psf_move, count(*) from did.t_poissonfile_psf group by psf_move ;
select psf_motion, count(*) from did.t_poissonfile_psf group by psf_motion ;
select distinct psf_comment from did.t_poissonfile_psf ;



/* 2016
select * from  did.t_poissonfile_psf where psf_move='3';
update did.t_poissonfile_psf set psf_move ='Out' where psf_move='Out Modification 2016';
update did.t_poissonfile_psf set psf_move ='InOut' where psf_move='InOut ';
update did.t_poissonfile_psf set psf_move ='In' where psf_move='In ';
update did.t_poissonfile_psf set psf_move ='Out' where psf_move='Out ';
update did.t_poissonfile_psf set psf_move ='Out' where psf_move=' Out ';
update did.t_poissonfile_psf set psf_move ='<-->' where psf_move='<--> ';
select * from did.t_poissonfile_psf where psf_move='3';
update did.t_poissonfile_psf set psf_move='Out' where psf_move='3';
/*
2013
select * from did.t_poissonfile_psf  where psf_move is null;
update did.t_poissonfile_psf set psf_move='<-->' where psf_move is null;
update did.t_poissonfile_psf set  (psf_species,psf_longitude_unit)=(2014,'m') where psf_longitude_unit='2014'	

update did.t_poissonfile_psf set psf_motion='Running' where psf_motion is null;
update 	did.t_poissonfile_psf set psf_move='Out' where psf_move='out';
update 	did.t_poissonfile_psf set psf_move=NULL where psf_move='4';
-- 1er dec à 19h00 pour backsliding hors période du 5/12 au 14/12
update 	did.t_poissonfile_psf set psf_move=NULL where psf_move='4';
*/
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, ';', ':'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'Ot', 'Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'OUt', 'Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'oUT', 'Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'out', 'Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'MO:Out', 'Mo:Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'mo:Out', 'Mo:Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'MO:OUT', 'Mo:Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'Mo:Ou', 'Mo:Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'Mo:Outt', 'Mo:Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'mO/oUT', 'Mo:Out'));
update did.t_poissonfile_psf set psf_comment=(select regexp_replace(psf_comment, 'Mo:OutT', 'Mo:Out'));

-- normalement il ne doit y avoir que deux catégories....
select count(*), psf_dir from did.t_poissonfile_psf group by psf_dir;
update did.t_poissonfile_psf set psf_dir=(select regexp_replace(psf_dir, 'UP', 'Up'));

-- select * from did.t_poissonfile_psf ;
select psf_move,psf_id from did.t_poissonfile_psf where psf_comment like '%Mo:Out%' and psf_move='<-->';--0
update did.t_poissonfile_psf set psf_move='Out' where psf_comment like '%Mo:Out%' and psf_move='<-->'; --0 --1 2016
select distinct psf_move from did.t_poissonfile_psf where psf_comment like '%Mo:Out%' ; -- In
update did.t_poissonfile_psf set psf_move='InOut' where psf_comment like '%Mo:Out%' and psf_move='In';--732 --1025
select * from did.t_poissonfile_psf where psf_move='InOut';
--select * from t_poissonfile_psf where psf_comment like '%contre%';-- contre courant deux lignes
--update t_poissonfile_psf set psf_motion='Hanging' where psf_comment like '%contre%';
select * from did.t_didsonfiles_dsf  dsf 	join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				join did.t_poissonfile_psf on psf_drr_id=drr_id
				where psf_species!='2014';--15756 lignes
*/
/*
2013
-- correction d'une erreur dans un fichier				
select * from t_poissonfile_psf where psf_motion='<-->';
update t_poissonfile_psf  set (psf_motion,psf_move,psf_q)=('Running','<-->',3) where psf_id=37071;
*/

/*
PROBLEMES D'ADEQUATION ENTRE LE windowstart du DRR et le distance_start du fichier
*/
select dsf_distancestart,drr_windowstart_m,dsf_incl,psf_tilt from did.t_didsonfiles_dsf  dsf 	join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
		join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
		join did.t_poissonfile_psf on psf_drr_id=drr_id
		where psf_species!='2014'
		and drr_windowstart_m!=dsf_distancestart; --exactement inverse... 44 lignes 0lignes 2014 0 lignes 2015 0 lignes 2016 0 lignes 2017 0 lignes 2018 0 lignes 2019 0 2020 0 2021
/*
PROBLEMES D'ADEQUATION ENTRE LES dates du DRR et la date du fichier
*/		
select psf_id,date(dsf_timeinit),psf_date from did.t_didsonfiles_dsf  dsf 	join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
		join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
		join did.t_poissonfile_psf on psf_drr_id=drr_id
		where psf_species!='2014'
		and date(dsf_timeinit)::text!=psf_date; 
		-- deux lignes en 2012 0 lignes 0 lignes(2017) 7 lignes 2018 mais le lendemain... 0 2019 0 2020 0 2021

/*
PROBLEMES D'ADEQUATION ENTRE LES horodates du DRR et l'horodate du fichier
*/		
select psf_id,dsf_timeinit,dsf_timeend,dsf_filename,psf_date||' '||psf_time drr_timestamp, drr_filename,drr_path,psf_drr_id from did.t_didsonfiles_dsf  dsf 	
		join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
		join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
		join did.t_poissonfile_psf on psf_drr_id=drr_id
		where psf_species!='2014'
		and date_trunc('minute', (psf_date||' '||psf_time)::timestamp) < dsf_timeinit
		or date_trunc('minute', (psf_date||' '||psf_time)::timestamp) > dsf_timeend
		order by dsf_filename; -- 0 (après correction) 2020  --0 2021

-- deux lignes corrigées à la main en 2019 pb changement d'heure donc horaire décalé de 30 mon
	
-- utiliser l'interface pour supprimer les lignes en trop crées par les répétitions de fichiers
-- clic sur la ligne et supprimer l'enregistrement, il est répété. Il en reste qu'un qui est quelques secondes après la fin
-- penser à corriger les comptages totaux dans t_didsonreadresult_drr
-- il reste 11 lignes en 2016 et une en 2013
/*
SELECT * FROM did.t_poissonfile_psf where psf_drr_id ='FC_CSOT_2019-03-07_223000_HF_P1409'
BEGIN;
DELETE FROM did.t_poissonfile_psf  WHERE psf_id=62164;--1
COMMIT;
*/
/*
Vérification et recalcul des nombres de Up et Down dans psf => drr => dsr
ATTENTION drr_upstream correspond au nombre de poissons totaux, y compris les lamproies
IL PEUT ETRE DIFFERENT DE DRR_EELPLUS
Ci DESSOUS ON RECOMPTE LES ANGUILLES DU FICHIER POISSON ET ON MET LES DONNEES
DANS LA TABLE DU DESSUS (DRR)
*/


/*
PREMIERE ETAPE : VERIF DES FICHIERS TOTAUX
IL s'AGIT DE L'ENSMBLE DES POISSONS, LAMPROIES ET ANGUILLES
*/
--select * from t_poissonfile_psf;
select distinct on(psf_dir) psf_dir from t_poissonfile_psf;
--update t_poissonfile_psf set psf_dir='Dn' where psf_dir='??';--2 -- 0 2016 --0 2017 

with countfromdsf as(				
	select case when up.psf_drr_id is not null then	up.psf_drr_id
	else dn.psf_drr_id end as psf_drr_id, -- il faut que je récupère l'id, 
	--et si je prends la ligne dn alors que c'est up je n'ai plus rien, 
	--donc je regarde que je n'ai pas une case vide, et si c'est le cas c'est un dn
	up, 
	dn from (
	select  psf_drr_id, count(*) as up  from t_poissonfile_psf where psf_dir='Up'  group by   psf_drr_id, psf_dir) up
	full outer join
	(select  psf_drr_id, count(*) as dn from t_poissonfile_psf where psf_dir='Dn'group by   psf_drr_id, psf_dir) dn
	on up.psf_drr_id=dn.psf_drr_id
	)
select * from countfromdsf full outer join t_didsonreadresult_drr drr on psf_drr_id=drr_id
where drr_upstream!=up; -- Il faut modifier les entrées si des lignes exsitent --0 2016 --0 2017 --0 2018  --0 2019 2=>0 (2020) 0 2021



with countfromdsf as(				
select case when up.psf_drr_id is not null then	up.psf_drr_id
	else dn.psf_drr_id end as psf_drr_id,
	up, 
	dn from (
select  psf_drr_id, count(*) as up  from t_poissonfile_psf where psf_dir='Up' group by   psf_drr_id, psf_dir) up
full outer join
(select  psf_drr_id, count(*) as dn from t_poissonfile_psf where psf_dir='Dn'  group by   psf_drr_id, psf_dir) dn
on up.psf_drr_id=dn.psf_drr_id)
select * from countfromdsf full outer join t_didsonreadresult_drr drr on psf_drr_id=drr_id
where drr_downstream!=dn; --0 pas de problème  (2016 un problème en avril 2015) --0 2017 0 2020 -- 0 2021


/* 2016
update t_didsonreadresult_drr set drr_downstream=1 where drr_id='FC_CSOT_2015-04-13_083000_HF_P1703';
*/

/*
DEUXIEME ETAPE : VERIF DES COMPTAGES D'ANGUILLE (ETAPE D'APRES)
NE PAS LANCER LORS DU PREMIER TRAITEMENT (les comptages sont générés ci-dessous)
*/

with countfromdsf as(				
	select case when up.psf_drr_id is not null then	up.psf_drr_id
	else dn.psf_drr_id end as psf_drr_id, -- il faut que je récupère l'id, 
	--et si je prends la ligne dn alors que c'est up je n'ai plus rien, 
	--donc je regarde que je n'ai pas une case vide, et si c'est le cas c'est un dn
	up, 
	dn from (
	select  psf_drr_id, count(*) as up  from t_poissonfile_psf where psf_dir='Up' and psf_species='2038' group by   psf_drr_id, psf_dir) up
	full outer join
	(select  psf_drr_id, count(*) as dn from t_poissonfile_psf where psf_dir='Dn'and psf_species='2038' group by   psf_drr_id, psf_dir) dn
	on up.psf_drr_id=dn.psf_drr_id
	)
select * from countfromdsf full outer join t_didsonreadresult_drr drr on psf_drr_id=drr_id
where drr_eelplus!=up; -- Il faut modifier les entrées si des lignes exsitent



with countfromdsf as(				
select case when up.psf_drr_id is not null then	up.psf_drr_id
	else dn.psf_drr_id end as psf_drr_id,
	up, 
	dn from (
select  psf_drr_id, count(*) as up  from t_poissonfile_psf where psf_dir='Up' and psf_species='2038' group by   psf_drr_id, psf_dir) up
full outer join
(select  psf_drr_id, count(*) as dn from t_poissonfile_psf where psf_dir='Dn' and psf_species='2038'  group by   psf_drr_id, psf_dir) dn
on up.psf_drr_id=dn.psf_drr_id)
select * from countfromdsf full outer join t_didsonreadresult_drr drr on psf_drr_id=drr_id
where drr_eelminus!=dn; --0 pas de problème



-- il faut rajouter une colonne pour le comptage d'anguilles seulement

/* RUNONCE
alter table t_didsonreadresult_drr add column drr_eelplus numeric;
alter table t_didsonreadresult_drr add column drr_eelminus numeric;
update t_didsonreadresult_drr set drr_eelplus =0;
update t_didsonreadresult_drr set drr_eelminus=0;
*/

--je passe par une table temporaire
drop table if exists tempcountfromdsf;
create table tempcountfromdsf as (select case when up.psf_drr_id is not null then	up.psf_drr_id
	else dn.psf_drr_id end as psf_drr_id,
	up, 
	dn from (
select  psf_drr_id, count(*) as up  from t_poissonfile_psf where psf_dir='Up' and psf_species='2038' group by   psf_drr_id, psf_dir) up
full outer join
(select  psf_drr_id, count(*) as dn from t_poissonfile_psf where psf_dir='Dn' and psf_species='2038' group by   psf_drr_id, psf_dir) dn
on up.psf_drr_id=dn.psf_drr_id);--1272 -- 3090 --5114 (2017) 5628 (2018) 6514 (2019) 7202 (2020) 8182 (2021)
-- select * from tempcountfromdsf;

-- On commence par remettre à zéro
update t_didsonreadresult_drr set drr_eelplus =0 where drr_dsr_id in 
	(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2020-2021'); --1420 (2016) --716 2017 -- 553 (2018) --848 (2019) 692 (2020) 8182 (2021)
	
-- ci dessous il peut y avoir moins de lignes, correspond aux lamproies
update t_didsonreadresult_drr set drr_eelplus= up 
	from tempcountfromdsf
	where psf_drr_id=drr_id
	and drr_dsr_id in 
	(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2020-2021');--1381 (2016) => 1336 après changement lamproies 714 2017 552 (2018) 848 (2019) 6891 (2020) 981 (2021)
update t_didsonreadresult_drr set drr_eelminus=0 where drr_dsr_id in 
	(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2020-2021'); -- 1420 (2016) 716 (2017) 553 (2018) 848 (2019) 692 (2020) 985 (2021)
update t_didsonreadresult_drr set drr_eelminus= dn 
	from tempcountfromdsf
	where psf_drr_id=drr_id and drr_dsr_id in 
	(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2020-2021'); --1336 (2016) 714 552 (2018) 848 (2019) 691 (2020) 980 (2021)
	
drop table tempcountfromdsf;
update t_didsonreadresult_drr set drr_eelminus=0 where drr_eelminus is null and drr_dsr_id in 
	(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2020-2021');--1062 --1062 --991 (2016) --477 (2017) 479(2018) 636 (2019) 632 (2020) 807 (2021)
update t_didsonreadresult_drr set drr_eelplus=0 where drr_eelplus is null and drr_dsr_id in 
	(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2020-2021');--115--187 --93 (2016) -- 83 (2017) -- 25 (2018) 109 (2019) 32 (2020) 98 (2021)


/*
select * from t_didsonreadresult_drr left join
	tempcountfromdsf
	on psf_drr_id=drr_id
	where drr_dsr_id in 
	(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2017-2018')
	except
select * from t_didsonreadresult_drr  join
	tempcountfromdsf
	on psf_drr_id=drr_id
	where drr_dsr_id in 
	(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id 
	where dsf_season='2017-2018')
	

	;
PROBLEMES D'ADEQUATION DRR DSR !!!!!
Petit tableau de comparaison des données provenant d'excel et de celles provenant des fichiers textes 
=> corrections manuelles sur interface
ICI J'ai corrigé pour 2015-2016 puis les changements manuels en fin de saison font que les dsr et drr diffèrente

*/
select dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
and dsr_csotismin
order by dsf_timeinit; -- Il ne doit plus y avoir de ligne 


/*
2016
update t_didsonreadresult_drr set (drr_totalfish,drr_upstream,drr_eelplus, drr_downstream, drr_eelminus) = (4,4,4,0,0) where drr_id ='FC_CSOT_2016-03-28_223000_HF_P1338';
*/
/*
2017
select * from did.t_didsonread_dsr where dsr_dsf_id=103011
update t_didsonread_dsr set dsr_eelminus = 1 where dsr_id=36510; -- instead of 0
*/
/*
2018

update t_didsonread_dsr set (dsr_eelplus,dsr_eelminus)  = (sub.drr_eelplus,sub.drr_eelminus) from
( select dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
and dsf_season='2017-2018'
and dsr_csotismin) sub
where sub.dsf_id=dsr_dsf_id --8



select * from did.t_poissonfile_psf where psf_date::date >= '2018-01-01' and psf_date::date < '2018-01-06' order by psf_date;
select * from 
t_didsonfiles_dsf 
left join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
left join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
left join t_poissonfile_psf on psf_drr_id=drr_id
where dsf_id=131115
*/

/*2019

update t_didsonread_dsr set (dsr_eelplus,dsr_eelminus)  = (sub.drr_eelplus,sub.drr_eelminus) from
( select dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
and dsf_season='2019-2020'
and dsr_csotismin) sub
where sub.dsf_id=dsr_dsf_id

2020 

SELECT * FROM did.t_poissonfile_psf where psf_date::date >= '2019-11-02' and psf_time >'23:00:00' and psf_date::date < '2019-11-03'  
and psf_time <'23:30:00' order by psf_date;

with nosilure2019 AS (
SELECT * FROM did.t_poissonfile_psf where psf_date::date >= '2019-09-01' and psf_species = '2238'
)
UPDATE did.t_poissonfile_psf 
set psf_species='2038' 
FROM
nosilure2019 
WHERE nosilure2019.psf_id=t_poissonfile_psf.psf_id;--8

update t_didsonread_dsr set (dsr_eelplus,dsr_eelminus)  = (sub.drr_eelplus,sub.drr_eelminus) from
( select dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
and dsf_season='2019-2020'
and dsr_csotismin) sub
where sub.dsf_id=dsr_dsf_id;--5 + 1 (pb relecture)

2021

with pb_its_a_silure AS (
select dsf_id,dsf_timeinit, dsf_filename, dsr_id,dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
and dsr_csotismin)
UPDATE did.t_didsonread_dsr dsr set dsr_eelminus=0 FROM pb_its_a_silure where dsr.dsr_id = pb_its_a_silure.dsr_id
; --1


Vérification des fichiers non importés
GROSSE VERIFICATION PAR AN, POUR REMETTRE LES FICHIERS DROITS
*/

select dsr_id, dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
left join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus>0 and drr_eelplus is null
and (dsf_season='2020-2021' )
order by dsf_timeinit;
*/

/*
2016
update t_didsonread_dsr set dsr_eelplus=0 where dsr_id=34843;
"2016-02-27_010000_HF"
update t_didsonread_dsr set dsr_csotismin=FALSE where dsr_id=33583;
update t_didsonread_dsr set dsr_pertefichiertxt=TRUE where dsr_id=33583;  
update t_didsonread_dsr set dsr_csotismin=TRUE where dsr_id=35030;

modif manuelle et cochage de "dsr_pertefichiertxt"
"2016-03-09_230000_HF"
modif manuelle du csotismin
modif manuelle et cochage de "dsr_pertedefichier"
*/

/*2017
update t_didsonread_dsr set dsr_eelplus =0
Deux corrections manuelles de fichiers fait pour le meme cstot pour lequel j'ai mis 2.9, c'était pas une bonne idée, j'ai supprimé les lignes à problème 27/11/16 20:00 et 2030
*/

/*2020
 * t_didsonread_dsr set dsr_eelplus =0
 * 
 UPDATE did.t_didsonread_dsr set dsr_eelplus =0 WHERE dsr_id in (53402,53403,53427);--3
 
 * 
 */

select dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, dsr_id,drr_id, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
left join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus+dsr_eelminus>0 and drr_eelminus is null
and dsf_season='2020-2021'
order by dsf_timeinit;



/*2019
BEGIN;
UPDATE t_didsonread_dsr set dsr_eelminus=0 where dsr_id=48527;
COMMIT;

--*************************************
-- en 2012-2013 beaucoup de problèmes
-- les fichiers ont été relus en début de saison et il n'y a pas eu de doublons sur les fichiers poissons
-- ie seuls les bon comptages ont été gardés.
-- j'ai rajouté une colonne pour indiquer la perte du fichier
--*************************************
select dsf_timeinit, dsf_filename, coalesce(dsr_eelplus,0)+coalesce(dsr_eelminus,0)-coalesce(drr_eelplus,0)-coalesce(drr_eelminus,0)  as diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
left join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus+dsr_eelminus>0 and drr_eelplus is null
and dsf_season='2012-2013'
and dsr_pertefichiertxt is FALSE
and dsr_csotismin
order by dsf_timeinit;--5 lignes encore

*/



/*
APRES VERIF MANUELLE, ON PEUT REPRENDRE CE QUI EST DANS LES FICHIERS TEXTES !
*/
/*
update t_didsonread_dsr set (dsr_eelplus, dsr_eelminus) =(drr_eelplus,drr_eelminus)
from t_didsonreadresult_drr
where drr_dsr_id=dsr_id; --1303 --2117--3095
*/
-- RECHERCHE DES INCOHERENCES ENTRE LES COMPTES DSR ET DRR
-- LES CORRECTIONS SONT FAITES SUR L'INTERFACE GRAPHIQUE


select * from(
select dsf_id,drr_dsf_id,drr_dsr_id,drr_id,dsr_csotismin,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus as dsr_total,
drr_upstream,drr_downstream,drr_eelplus, drr_eelminus,drr_eelplus-drr_eelminus as drr_total
from t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
left join t_didsonreadresult_drr drr on drr_dsr_id=dsr_id) sub
where drr_total!=dsr_total; -- 15 lignes dont une en 2013 => 0 lignes après correction 0 après correction 
--2019 =>0 lignes après correction 2020 0 lignes 2021

/*
2019
UPDATE t_didsonread_dsr set (dsr_eelplus, dsr_eelminus)=(1,0) WHERE dsr_id=47635;
UPDATE t_didsonread_dsr set (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=48370;
UPDATE t_didsonread_dsr set (dsr_eelplus, dsr_eelminus)=(0,1) WHERE dsr_id=49255;
*/
/*
Une correction manuelle 2017
*/

/* 
il manque les fichiers pour lesquels il y a des comptages mais pas de correspondance
je passe par un left join
*/

select * from(
select dsf_filename, drr_dsr_id,drr_id,dsr_csotismin,dsr_eelplus, dsr_eelminus,dsr_eelplus-dsr_eelminus as dsr_total,
drr_upstream,drr_downstream,drr_eelplus, drr_eelminus,drr_eelplus-drr_eelminus as drr_total
from t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
left join t_didsonreadresult_drr drr on drr_dsr_id=dsr_id) sub
where dsr_total>0 and drr_total is null
and dsr_csotismin;



select distinct on (dsf_timeinit) * from did.t_didsonfiles_dsf  dsf 	join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				join did.t_poissonfile_psf on psf_drr_id=drr_id
				where psf_species!='2014'
				and dsr_csotismin;



-- ENSEMBLE DES POISSONS COMPTES (DANS LES TABLES POISSONS (DRR)) DANS LES FICHIERS CORRESPONDANT A CSOTISMIN
select dsf_season,sum(drr_eelplus)+sum(drr_eelminus) from t_didsonfiles_dsf 
	join t_didsonread_dsr on dsr_dsf_id=dsf_id
	left join t_didsonreadresult_drr
	on drr_dsr_id=dsr_id where dsr_csotismin
	and dsr_pertefichiertxt is FALSE
	group by dsf_season
	order by dsf_season; 
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
*/
-- ENSEMBLE DES POISSONS COMPTES (DANS LES TABLES POISSONS (DRR)) Y COMPRIS LES COMPTAGES MULTIPLES
select dsf_season,sum(drr_eelplus)+sum(drr_eelminus) from t_didsonfiles_dsf 
	left join t_didsonread_dsr on dsr_dsf_id=dsf_id  
	left join t_didsonreadresult_drr on drr_dsr_id=dsr_id
	group by dsf_season
	order by dsf_season;  --2729 --1938 --2006(comptés deux fois par brice et gérard) --2152
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
*/
-- ENSEMBLE DES POISSONS COMPTES (DANS LES TABLES EXCEL (DSR)) Y COMPRIS LES COMPTAGES MULTIPLES
-- ET AUSSI AVANT QU'ON PASSE EN LAMPROIES
select dsf_season,sum(dsr_eelplus) + sum(dsr_eelminus) 
from  t_didsonfiles_dsf 
	left join t_didsonread_dsr on dsr_dsf_id=dsf_id
	group by dsf_season
	order by dsf_season; 
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
*/
-- ENSEMBLE DES POISSONS COMPTES (DANS LES TABLES EXCEL (DSR)) POUR LES CSOTISMIN
select dsf_season,sum(dsr_eelplus) + sum(dsr_eelminus) 
from  t_didsonfiles_dsf 
	left join t_didsonread_dsr on dsr_dsf_id=dsf_id
	where dsr_csotismin
	and dsr_pertefichiertxt is FALSE
	group by dsf_season
	order by dsf_season;  
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


*/

-- ENSEMBLE DES lignes du fichier poisson correspondant à CSOTISMIN
select dsf_season,count(*) 
from  t_didsonfiles_dsf 
	join t_didsonread_dsr on dsr_dsf_id=dsf_id
	join t_didsonreadresult_drr on drr_dsr_id=dsr_id
	join t_poissonfile_psf on psf_drr_id=drr_id
	where dsr_csotismin
	and dsr_pertefichiertxt is FALSE
	and psf_species='2038'
	group by dsf_season
	order by dsf_season; 
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
*/

/* ci dessous la requête est lancée pour permettre de voir les jours ou il n'y a pas le même nombre
de données
A lancer lors le programme plante avec
Error:  chunk 3 (label = d3ej) 
Error : nrow(dddp) == sum(colSums(ddde[, c("drr_eelplus", "drr_eelminus")],  .... n'est pas TRUE
*/

select sub1.dsf_timeinit , count_psf, count_drr from(
select dsf_timeinit ,count(*)  as count_psf
from  t_didsonfiles_dsf 
	join t_didsonread_dsr on dsr_dsf_id=dsf_id
	join t_didsonreadresult_drr on drr_dsr_id=dsr_id
	join t_poissonfile_psf on psf_drr_id=drr_id
	where dsr_csotismin
	and dsr_pertefichiertxt is FALSE
	and psf_species='2038'
	group by dsf_timeinit)sub1
	left join (
select dsf_timeinit,sum(dsr_eelplus) + sum(dsr_eelminus) as count_drr
from  t_didsonfiles_dsf 
	left join t_didsonread_dsr on dsr_dsf_id=dsf_id
	where dsr_csotismin
	and dsr_pertefichiertxt is FALSE	
	group by dsf_timeinit )sub2
	on sub1.dsf_timeinit=sub2.dsf_timeinit
	where count_psf!=count_drr
order by sub1.dsf_timeinit;

-- select dsf_timeinit,dsr_eelplus, dsr_eelminus from v_ddde where dsf_timeinit::date='2015-04-18' and (dsr_eelplus>0 or dsr_eelminus>0)
-- select dsf_timeinit,count (*) from  v_dddp where dsf_timeinit::date='2015-04-18' group by dsf_timeinit order by dsf_timeinit

/*
Recherche de problèmes d'adéquation entre dddp et ddde
*/
select * from (
select drr_id,dsf_season from v_ddde except 
select drr_id,dsf_season from v_dddpall where (drr_eelplus>0 or drr_eelminus>0) )sub
where dsf_season='2016-2017'
and drr_id not in(select psf_drr_id from t_poissonfile_psf where psf_species='2014');
select distinct psf_species from t_poissonfile_psf ;


select drr_id from v_ddde except (select drr_id from v_dddpall);


select * from t_poissonfile_psf where psf_species!='2014' and psf_species!='2038';

--3343
select count(*) from did.t_poissonfile_psf where psf_species='2038' and  psf_dir='Up'  --6171 --9583 --12345 (2018) --15276 (2020) --17063 (2021)
select count(*) from did.t_didsonfiles_dsf  dsf 	
				join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				join did.t_poissonfile_psf on psf_drr_id=drr_id
				where psf_species!='2014'
				and dsr_csotismin; --6701 --10624 --13720 --15546 --16977 --18965
-- lamproies
select count(*) from did.t_didsonfiles_dsf  dsf 	
				join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				join did.t_poissonfile_psf on psf_drr_id=drr_id
				where psf_species='2014'
				and dsr_csotismin; --2592 --657 -- 799 --1614 --1896 --1898 --1899 --1957

select count(*),  psf_species from t_poissonfile_psf group by psf_species
/* (2020)
count;psf_species
17183;2038
1921;2014
3;2238
(2021)
1979  2014
19170 2038
4 2238
*/

-- anguilles qui  ne sont pas dans les fichiers drr
select * from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id where (dsr_eelplus>0 or dsr_eelminus>0) and
dsr_id not in (select drr_dsr_id from t_didsonreadresult_drr) and dsr_csotismin order by dsf_timeinit;-- 0 2018 --0 2019 --0 2020


select * from t_didsonread_dsr right join t_didsonreadresult_drr on drr_dsr_id=dsr_id 
where dsr_eelplus != drr_eelplus
or dsr_eelminus !=drr_eelminus --0 2018 --0 2020
/* Je n'ose pas lancer celui-là
update t_didsonread_dsr set (dsr_eelplus,dsr_eelminus)=(0,0) where dsr_id in 
(select dsr_id from t_didsonfiles_dsf join t_didsonread_dsr on dsr_dsf_id=dsf_id where (dsr_eelplus>0 or dsr_eelminus>0) and
dsr_id not in (select drr_dsr_id from t_didsonreadresult_drr) and dsr_csotismin order by dsf_timeinit);
*/

select sum(dsr_eelplus) from (select * from t_didsonread_dsr  where (dsr_eelplus>0 or dsr_eelminus>0) and dsr_csotismin and
dsr_id not in (select drr_dsr_id from t_didsonreadresult_drr)) sub; --0 (2018) NULL (2020)

select * from t_didsonread_dsr 
join t_didsonreadresult_drr
on drr_dsr_id=dsr_id where dsr_csotismin=FALSE; 




/*
Doublons dans dsf_id
*/
select * from did.v_ddde where dsf_id in (7027,7029,7031,7033,7035,7037,7039,7041,7049,7050,7051,7064) ;




/*
------------------------------------------------
problèmes de lamproies en fin de saison 2015-2016
-------------------------------------------------
*/



select count(*),psf_dir from did.t_didsonfiles_dsf  dsf 	
				join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				join did.t_poissonfile_psf on psf_drr_id=drr_id
				where psf_species='2038'
				and dsr_csotismin
				and dsf_season='2015-2016'
				and psf_date>'2016-04-08' 
				and psf_l_cm>70
				and psf_q<5
				group by psf_dir; 

select * from did.t_didsonfiles_dsf  dsf 	
				join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				join did.t_poissonfile_psf on psf_drr_id=drr_id
				join did.
				where psf_species='2038'
				and dsr_csotismin
				and dsf_season='2015-2016'
				and psf_date>'2016-04-01' 
				and psf_l_cm>70
				and psf_q<5; 

/*
Quelles sont les anguilles de plus de 60 qui passent après le 15 mars et surtout
est qu'elles passent pour un petit delta ?
*/

select  count(*),psf_dir from (
select *, niveauvilaine30-niveaumer30 as delta from did.v_dddpeall 
				where psf_species='2038'
				and dsr_csotismin
				and dsf_season='2015-2016'
				and psf_date>'2016-03-15' 
				and psf_l_cm>60
				) sub
where delta<0.5				
group by psf_dir; 


/*
presque toutes les lamproies passent à <0.5
*/

select  count(*),
case when delta<0.5 then '<0.5m'
when delta>0.5 and delta<1 then '0.5-1m'
else '>1m' end as delta_cat
 from (
select *, niveauvilaine30-niveaumer30 as delta from did.v_dddpeall 
				where psf_species='2014'
				and dsr_csotismin
				and dsf_season='2015-2016'				
				and psf_l_cm>60
				) sub
			
group by delta_cat; 


-- 261 lamproies transformées en anguille en 205-2016
update did.t_poissonfile_psf set (psf_comment,psf_species)=
(coalesce(psf_comment,'')||'Changement 2015-2016, toute ang >60 cm avec delta<0.5 delta et > 1503 devient lamproie','2014') 
where psf_id in (
select  psf_id from (
select *, niveauvilaine30-niveaumer30 as delta from did.v_dddpeall 
				where psf_species='2038'
				and dsr_csotismin
				and dsf_season='2015-2016'
				and psf_date>'2016-03-15' 
				and psf_l_cm>60
				) sub
where delta<0.5	);--261			


-- après avoir relancé les count from psf (voir partie)... drop table if exists tempcountfromdsf; ...
-- on remet les dsf propre

select sum(diff) from
	(select dsr_id, dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, 
	dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
	t_didsonfiles_dsf join
	t_didsonread_dsr  on dsr_dsf_id=dsf_id 
	join 
	t_didsonreadresult_drr on drr_dsr_id=dsr_id
	where dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
	and dsf_season='2015-2016'
	and dsf_timeinit>'2016-03-15 00:00:00' 
	and dsr_csotismin)sub;--261 (il y en a bien 261 a modifier)

update t_didsonread_dsr set (dsr_eelplus,dsr_eelminus) = (drr_eelplus, drr_eelminus) 
from (
select dsr_id, dsf_id,dsf_timeinit, dsf_filename, dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus  as diff, 
dsr_eelplus,drr_eelplus,dsr_eelminus,drr_eelminus from 
t_didsonfiles_dsf join
t_didsonread_dsr  on dsr_dsf_id=dsf_id 
join 
t_didsonreadresult_drr on drr_dsr_id=dsr_id
where dsr_eelplus+dsr_eelminus-drr_eelplus-drr_eelminus!=0
and dsf_season='2015-2016'
and dsf_timeinit>'2016-03-15 00:00:00' 
and dsr_csotismin)sub
where sub.dsr_id=t_didsonread_dsr.dsr_id; --95 rows

/*
problèmes de temps d'enregistrement
*/



 update did.t_didsonread_dsr set dsr_readend='2016-03-01 16:07:00' where dsr_id=34698;
 update did.t_didsonread_dsr set dsr_readend='2016-01-14 12:18:00"' where dsr_id=33824;
  update did.t_didsonread_dsr set dsr_readend='2015-11-25 13:30:00' where dsr_id=33006;
  update did.t_didsonread_dsr set dsr_readend='2016-06-30 16:44:00' where dsr_id=35726;
  update did.t_didsonread_dsr set dsr_readend='2015-12-11 12:32:00' where dsr_id=33331;
  --------------------------
 with depouillement as (
	select dsf_timeinit,dsr_id,extract('month' from dsf_timeinit) 
	as mois,dsr_reader, dsf_position,dsr_readinit,dsr_readend, dsr_readend-dsr_readinit as temps_lecture , dsr_id
	from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id
	 where dsf_timeinit>'2015-09-01 00:00:00' and dsf_timeinit<'2016-05-01 00:00:00')
 select * from depouillement where temps_lecture<interval '00:00:00';
 -----------------------------
 

/*
File status manquants
0	OK	Enregistrement normal
1	Acquisition	Problème d'acquisition
2	Ecriture	Problème d'écriture
3	Qualité	Le fichier existe mais est de mauvaise qualité, ex :perte du fichier père, il ne reste que l'extraction, lecture impossible du fait du colmatage de la lentille
*/


SELECT count(*), dsf_fls_id FROM did.t_didsonfiles_dsf WHERE dsf_season='2020-2021' GROUP BY dsf_fls_id;

/*
count dsf_id
8136 NULL	
718	1
697	3
*/

UPDATE did.t_didsonfiles_dsf SET dsf_fls_id=0 WHERE dsf_fls_id IS NULL AND dsf_season='2020-2021'; --8136