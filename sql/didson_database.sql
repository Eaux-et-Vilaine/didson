--create schema did;
--CREATE EXTENSION tablefunc;
-- set search_path to did,public
drop table if exists did.tr_filestatus_fls cascade;
create table did.tr_filestatus_fls
(
fls_id integer primary key,
fls_label character varying (12),
fls_comment text);
insert into did.tr_filestatus_fls values(0,'OK', 'Enregistrement normal');
insert into did.tr_filestatus_fls values(1,'Acquisition', 'Problème d''acquisition');
insert into did.tr_filestatus_fls values(2,'Ecriture', 'Problème d''écriture');
insert into did.tr_filestatus_fls values(3,'Qualité', 'Le fichier existe mais est de mauvaise qualité, ex :perte du fichier père, il ne reste que l''extraction');

drop table if exists did.t_didsonfiles_dsf cascade;
create table did.t_didsonfiles_dsf(
dsf_id serial primary key,
dsf_timeinit timestamp not null,
dsf_timeend timestamp not null,
dsf_position character varying(6),
dsf_incl numeric,
dsf_distancestart numeric,
dsf_depth numeric,
dsf_fls_id integer,
dsf_readok boolean,
dsf_filename character varying(30),

constraint c_ck_dsf_timeend check (dsf_timeend>dsf_timeinit),
constraint c_ck_dsf_postion check (dsf_position='volet' or dsf_position='vanne'),
constraint c_ck_dsf_incl check(dsf_incl<20 and dsf_incl>-20),
constraint c_ck_dsf_distancestart check (dsf_distancestart>1 and dsf_distancestart<15),
constraint c_ck_dsf_depth check (dsf_depth>-10 and dsf_depth<2.5),
constraint c_uk_dsf_filename unique(dsf_filename),
constraint c_fk_dfs_fls_id foreign key (dsf_fls_id) references did.tr_filestatus_fls(fls_id));


comment on column did.t_didsonfiles_dsf.dsf_incl is 'inclination of the didson in degrees';
comment on column did.t_didsonfiles_dsf.dsf_position is 'position of the didson according to the water column';
comment on column did.t_didsonfiles_dsf.dsf_distancestart is 'distance of the beginning of the recording windows from the didson';
comment on column did.t_didsonfiles_dsf.dsf_readok is 'was the file read and in good CSOT conditions';
comment on column did.t_didsonfiles_dsf.dsf_filename is 'the name of the file is generated from the date with a trigger when inserting new row';
comment on column did.t_didsonfiles_dsf.dsf_depth is 'depth of the didson at Arzal, NGF';
comment on column did.t_didsonfiles_dsf.dsf_fls_id is 'file status, check reference table tr_filestatus_fls for details';
alter table did.t_didsonread_dsr add constraint c_nn_dsr_reader check (dsr_reader is not null);
alter table did.t_didsonread_dsr add constraint c_values_dsr_reader check (dsr_reader='Brice' or dsr_reader='Gerard' or dsr_reader='Brice et Gerard');

-- changement 2021
ALTER TABLE did.t_didsonfiles_dsf ADD COLUMN dsf_periode TEXT;
COMMENT ON COLUMN did.t_didsonfiles_dsf.dsf_periode IS 'Period where didson is consistently placed over a period of time.'
--SELECT * FROM did.t_didsonfiles_dsf WHERE dsf_periode IS NOT NULL;


-- changements manuels 06/2013
/*
select * from did.t_didsonfiles_dsf where dsf_position='volet';
update did.t_didsonfiles_dsf set dsf_depth=-0.45 where dsf_position='volet';
update did.t_didsonfiles_dsf set dsf_depth=-6.92 where dsf_position='vanne' and dsf_timeinit< '2012-12-17 15:30:00';
update did.t_didsonfiles_dsf set dsf_depth=-6.82 where dsf_position='vanne' and dsf_timeinit>= '2012-12-17 15:30:00';
*/

--delete from did.t_didsonread_dsr
drop table if exists did.t_didsonread_dsr CASCADE;
create table did.t_didsonread_dsr(
dsr_id serial primary key,
dsr_dsf_id integer,
dsr_readinit timestamp,
dsr_readend timestamp,
dsr_reader character varying(30),
dsr_eelplus integer,
dsr_eelminus integer,
dsr_csotdb numeric,
dsr_complete boolean,
dsr_muletscore integer,
dsr_fryscore integer,
dsr_comment text,
CONSTRAINT c_fk_dsr_dsf_id foreign key (dsr_dsf_id) references did.t_didsonfiles_dsf(dsf_id),-- cle étrangère
constraint c_ck_dsr_reader check(dsr_reader='Brice' or dsr_reader='Gerard' or dsr_reader='Cedric' or dsr_reader='Brice et Gerard'),
constraint c_ck_dsr_eelplus check (dsr_eelplus>=0),
constraint c_ck_dsr_eelminus check (dsr_eelminus>=0),
constraint c_uk_dsr_dsf_id_csotdb_read unique(dsr_reader,dsr_dsf_id,dsr_csotdb));
comment on column did.t_didsonread_dsr.dsr_eelplus is 'number of eel going with the current (downstream)';
comment on column did.t_didsonread_dsr.dsr_csotdb is 'CSOT noise extraction (value min threshold in db)';
comment on column did.t_didsonread_dsr.dsr_muletscore is 'scoring of the annoyance created by mulet school for the reader from 0 (little) to 5 (a lot)';
comment on column did.t_didsonread_dsr.dsr_fryscore is 'scoring of the annoyance created by small fishes (fry)for the reader from 0 (little) to 5 (a lot)';
comment on column did.t_didsonread_dsr.dsr_complete is 'is the reading of the file completed';

alter table did.t_didsonread_dsr drop CONSTRAINT c_ck_dsr_reader ;
alter table did.t_didsonread_dsr add CONSTRAINT c_ck_dsr_reader 
CHECK (dsr_reader::text = 'Brice'::text 
OR dsr_reader::text = 'Gerard'::text 
OR dsr_reader::text = 'Cedric'::text 
OR dsr_reader::text = 'Brice et Gerard'::text
OR dsr_reader::text = 'Gerard2'::text
OR dsr_reader::text = 'Brice2'::text);


drop table if exists did.t_fishsequence_fsq;
create table did.t_fishsequence_fsq(
fsq_dsr_id integer ,
fsq_id serial primary key,
fsq_time time,
fsq_comment text,
CONSTRAINT c_fk_fsq_dsr_id foreign key (fsq_dsr_id) references did.t_didsonread_dsr(dsr_id) ON DELETE CASCADE
);
comment on table did.t_fishsequence_fsq is 'table containing dubious eels';

drop view if exists did.v_fish;
create view did.v_fish as select * from did.t_didsonfiles_dsf 
join did.t_didsonread_dsr on dsr_dsf_id=dsf_id
join did.t_fishsequence_fsq on fsq_dsr_id=dsr_id;

/*
VARIABLES ENVIRONNEMENTALES
Creation de la table des variables environnementales, 
creation d'une table temporaire pour me debarrasser des doublons (changement d'heure)
La table est crée par le script <calcul_debit_chargement_cond_env.R>
Les données de la table correspondent aux champs recalculés, les données 
initiales de SIVA ne sont pas gardées, les graphique de recalcul du débit et comparaison
Les données de températures abérrantes ont été écartées de l'analyse.
*/


ALTER TABLE did.t_env_env_temp ALTER COLUMN "env_time" type  timestamp without time zone;


/*
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- ATTENTION CHANGER LES HEURES CI DESSOUS? DANS LA FONCTION !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*/
/*
Comme le barrage est décallés de 1h il faut ajouter une heure jusqu'à une heure du changement d'heure,
la valeur suivante sera bonne
ex 28 octobre 2012 01:00 ordi=>28 octobre 2012 00:00 barrage
 28 octobre 2012 03:00 ordi=>28 octobre 2012 03:00 barrage
 # 2012-2013
# Passage à l'heure d'hiver Dimanche 28 octobre 2012 02h00
# Passage à l'heure  d'été  Dimanche 31 mars 2013 02h00
#http://www.horlogeparlante.com/historique.html?city=2988507
# 2013-2014
# Passage à l'heure d'hiver Dimanche 27 octobre 2013 02h00
--'2012-10-28 00:00:00' or $1 > TIMESTAMP '2013-03-31 01:00:00'

Année : 2014
Passage à l'heure d'été le Dimanche 30 Mars 2014 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 26 Octobre 2014 - 02 h 00 (GMT + 1 h ) CET
Année : 2015
Passage à l'heure d'été le Dimanche 29 Mars 2015 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 25 Octobre 2015 - 02 h 00 (GMT + 1 h ) CET
Année : 2016
Passage à l'heure d'été le Dimanche 27 Mars 2016 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 30 Octobre 2016 - 02 h 00 (GMT + 1 h ) CET
Année : 2017
Passage à l'heure d'été le Dimanche 26 Mars 2017 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 29 Octobre 2017 - 02 h 00 (GMT + 1 h ) CET
Année : 2018
Passage à l'heure d'été le Dimanche 25 Mars 2018 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 28 Octobre 2018 - 02 h 00 (GMT + 1 h ) CET
Année : 2019
Passage à l'heure d'été le Dimanche 31 Mars 2019 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 27 Octobre 2019 - 02 h 00 (GMT + 1 h ) CET
Année : 2020
Passage à l'heure d'été le Dimanche 29 Mars 2020 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 25 Octobre 2020 - 02 h 00 (GMT + 1 h ) CET
Année : 2021
Passage à l'heure d'été le Dimanche 28 Mars 2021 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 31 Octobre 2021 - 02 h 00 (GMT + 1 h ) CET
Année : 2022
Passage à l'heure d'été le Dimanche 27 Mars 2022 - 03 h 00 (GMT + 2 h ) CEST
Retour à l'heure normale le Dimanche 30 Octobre 2022 - 02 h 00 (GMT + 1 h ) CET

*/

DROP FUNCTION IF EXISTS did.adjust_time(TIMESTAMP) cascade;
CREATE OR REPLACE FUNCTION did.adjust_time(TIMESTAMP) 
RETURNS TIMESTAMP AS $$ 
  SELECT case when $1 < TIMESTAMP '2021-10-28 03:00:00' or $1 > TIMESTAMP '2022-03-27 02:00:00' 
  then $1 + INTERVAL '1 hour'
  else $1 end
$$ LANGUAGE SQL;
select * from did.t_env_env_temp limit 10;
select * from did.t_env_env_temp WHERE env_time='2021-10-28 03:00:00';
select * from did.t_env_env_temp WHERE env_time='2021-10-28 02:00:00';
select * from did.t_env_env_temp WHERE env_time='2021-10-28 04:00:00';

-----------------------------------------
-- SCRIPT INTEGRATION DES DONNEES ANNUELLES DIDSON
---------------------------------------------



-- attention ne lancer qu'une fois
update did.t_env_env_temp set env_time =did.adjust_time(env_time);--38846 2013 34702 2014--34846 --34990 --34846(2017-2018) --52558 (2018-2019) --34990(2019-2020)
/*drop table if exists did.t_env_env cascade;
create table did.t_env_env as select distinct on (env_time) * from did.t_env_env_temp;
alter table did.t_env_env add constraint c_uk_env_time unique (env_time);
select * from did.t_env_env;
alter table did.t_env_env add column env_debitmoycran numeric;
alter table did.t_env_env add column env_qvolet1 numeric;
alter table did.t_env_env add column env_qvolet2 numeric;
alter table did.t_env_env add column env_qvolet3 numeric;
alter table did.t_env_env add column env_qvolet4 numeric;
alter table did.t_env_env add column env_qvolet5 numeric;
alter table did.t_env_env rename column env_debitvilaine_estime to env_debitvilaine ;
alter table did.t_env_env rename column env_voltot to env_volumetotal;
alter table did.t_env_env add column env_debitvolet numeric;
alter table did.t_env_env add column env_debitsiphon numeric;
alter table did.t_env_env add column env_debitvanne numeric;
alter table did.t_env_env rename column env_debitmoycran to env_debitmoyencran
alter table did.t_env_env rename column env_volbarrage to env_volvanne
TODO attention les données historiques contiennent des éléments sur les débits Vilaine calculés par le barrage
Relancer le script
*/



-- vérifier que les dates se suivent avant de faire l'insertion
select max(env_time) from did.t_env_env ;
select min(env_time) from did.t_env_env ;
select min(env_time) FROM did.t_env_env_temp;
select max(env_time) FROM did.t_env_env_temp;
-- supression des dates en commun
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- bien réfléchir avant de lancer cette ligne ou l'autre
-- une erreur ci dessous peut aussi être due à un doublon !
/*
delete from did.t_env_env where env_time>=(select min(env_time) from did.t_env_env_temp);
delete from did.t_env_env_temp where env_time<=(select max(env_time) from did.t_env_env);
delete from did.t_env_env where env_time<=(select max(env_time) from did.t_env_env_temp); --32810
delete from did.t_env_env where env_time>=(select min(env_time) from did.t_env_env_temp) AND env_time<=(select max(env_time) from did.t_env_env_temp);
*/
select * from did.t_env_env ORDER BY env_time;
--insert into did.t_env_env select * from did.t_env_env_temp;--34702

insert into did.t_env_env(env_time,
env_volet1,
env_volet2,
env_volet3,
env_volet4,
env_volet5,
env_vanne1,
env_vanne2,
env_vanne3,
env_vanne4,
env_vanne5,
env_niveauvilaine,
env_niveaumer,
--env_tempamont,
--env_tempaval,
--env_tempamont1,
--env_tempair,
env_debitvilaine,
env_debitmoyencran,
env_debitvanne,
env_debitvolet,
env_debitpasse,
env_debitsiphon,
env_volumetotal,
env_volvanne,
env_volvolet,
env_volpasse,
env_volsiphon,
env_qvanne1,
env_qvanne2,
env_qvanne3,
env_qvanne4,
env_qvanne5,
env_qvolet1,
env_qvolet2,
env_qvolet3,
env_qvolet4,
env_qvolet5) select distinct on (env_time) env_time,
env_volet1,
env_volet2,
env_volet3,
env_volet4,
env_volet5,
env_vanne1,
env_vanne2,
env_vanne3,
env_vanne4,
env_vanne5,
env_niveauvilaine,
env_niveaumer,
--env_tempamont,
--env_tempaval,
--env_tempamont1,
--env_tempair,
env_debitvilaine,
env_debitmoyencran,
env_debitvanne,
env_debitvolet,
env_debitpasse,
env_debitsiphon,
env_volumetotal,
env_volvanne,
env_volvolet,
env_volpasse,
env_volsiphon,
env_qvanne1,
env_qvanne2,
env_qvanne3,
env_qvanne4,
env_qvanne5,
env_qvolet1,
env_qvolet2,
env_qvolet3,
env_qvolet4,
env_qvolet5
 from did.t_env_env_temp;
 -- 34846(212-2013 refait2020) 
 -- 34846 2013-2014 (refait 2021) 
 -- 34696 --2015
  -- 34978 34840 (2016-2017)
  --  34834 (2017-2018) 
  -- 35274 (2018 restant) 
  --52552 2019 
  -- 34990 2020
  -- 34846 2021
   --335782022
 
 /*
  * select  env_qvolet4, env_volet4 from did.t_env_env where env_time='2013-11-08 00:30:00'
  */
---------------------------
-- Données journalières
----------------------------
/*
drop table if exists did.t_envjour_enj;
create table did.t_envjour_enj(
enj_id serial primary key,
enj_date date ,
enj_turb numeric);
*/
--delete from did.t_envjour_enj where enj_date >='2013-09-01';--242
/*
copy did.t_envjour_enj(enj_date,enj_turb) from 'C:/Users/admin-mig/Desktop/data/turbidite_2016.csv' with csv header delimiter as ';' NULL as '';-- 2014 242
copy did.t_envjour_enj(enj_date,enj_turb) from 'F:/workspace/pdata/didson/rapport/data/2016/turbidite2016.csv' with csv header delimiter as ';' NULL as '';-- 2016 244
-- CI DESSUS 2016 PLUS BESOIN, C'EST DANS LE SCRIPT R QUI VA CHERCHER DIRECTEMENT DANS LA TABLE b_ferel_mesure
*/
 
 
 /*
DELETE FROM  did.t_envjour_enj WHERE enj_id=1655;
ALTER TABLE did.t_envjour_enj ADD CONSTRAINT c_uk_enj_date UNIQUE(enj_date);
  */
 

select * from did.debitjour;
select * from did.t_envjour_enj ORDER BY enj_date;
INSERT INTO did.t_envjour_enj(enj_date,enj_turb,deb_qtotalj)  
SELECT date, turbidite, debit_moyen_recalcule  FROM did.debitjour
WHERE date > (SELECT max(enj_date) FROM did.t_envjour_enj); 
--243 
--242
--239 (2022-2023)


--select max(enj_date) from did.t_envjour_enj 
--select * from did.t_envjour_enj WHERE enj_date>='2018-01-01' AND enj_date <'2020-01-01' ORDER BY enj_date;

--delete from did.t_envjour_enj where deb_qtotalj is null and enj_date>='2015-09-01';
--delete from did.t_envjour_enj 
--alter table did.t_envjour_enj add column deb_qtotalj numeric;
--update did.t_envjour_enj set deb_qtotalj=debitvilainecalcule from did.debitjour where enj_date=date; --228 --213 --221 (2016-2017) 237 (2017-2018) 235 (2019)

/*
FIN DE SCRIPT VARIABLES ENVIRONNEMENTALES
*/

/*
REPERAGE DES FICHIERS A PB
script detection_fichiers_problemes.R
*/
/*
select * from did.fichierstronques t join t_didsonfiles_dsf dsf on t.dsf_filename=dsf.dsf_filename


update did.t_didsonfiles_dsf set dsf_depth=-6.92 where dsf_timeinit>'2012-11-01 00:00:00' ; -- requete a ajuster
*/
/*

LANCEMENT DES VUES

*/


DROP FUNCTION IF EXISTS did.round_time_30(TIMESTAMP);
CREATE OR REPLACE FUNCTION did.round_time_30(TIMESTAMP) 
RETURNS TIMESTAMP AS $$ 
  SELECT case when date_part('minute',$1)>=30 then  date_trunc('hour', $1) + INTERVAL '30 min'
  else date_trunc('hour', $1) end
$$ LANGUAGE SQL;



drop view if exists did.v_env CASCADE;
create view did.v_env as
select round_time,
avg(env_debitvilaine) as debitvilaine30,
avg(env_debitmoyencran) as debit_moyen_cran30,
sum(env_volumetotal) as volbarrage30,
sum(env_volvanne) as volvanne30,
sum(env_volpasse) as volpasse30,
sum(env_volsiphon) as volsiphon30,
sum(env_volvolet) as volvolet30,
avg(env_niveauvilaine) as niveauvilaine30,
avg(env_niveaumer) as niveaumer30,
avg(env_hvanne_tot) as env_hvanne_tot30,
avg(env_nvolet_tot) as env_nvolet_tot30,
sum(env_qvanne1*600) as env_volvanne1_30,
sum(env_qvanne2*600) as env_volvanne2_30,
sum(env_qvanne3*600) as env_volvanne3_30,
sum(env_qvanne4*600) as env_volvanne4_30,
sum(env_qvanne5*600) as env_volvanne5_30,
sum(env_qvolet1*600) as env_volvolet1_30,
sum(env_qvolet2*600) as env_volvolet2_30,
sum(env_qvolet3*600) as env_volvolet3_30,
sum(env_qvolet4*600) as env_volvolet4_30,
sum(env_qvolet5*600) as env_volvolet5_30
 from (
select did.round_time_30(env_time) as round_time, 
env_debitvilaine, 
env_debitmoyencran,
env_volumetotal,
env_niveauvilaine,
env_niveaumer,
env_volvanne,
env_volpasse,
env_volvolet,
env_volsiphon,
env_vanne1+env_vanne2+env_vanne3+env_vanne5+env_vanne4 as env_hvanne_tot,
(env_volet1<4.03)::integer+(env_volet2<4.03)::integer+(env_volet3<4.03)::integer+(env_volet4<4.03)::integer+(env_volet5<4.03)::integer as env_nvolet_tot,
env_qvanne1,
env_qvanne2,
env_qvanne3,
env_qvanne4,
env_qvanne5,
env_qvolet1,
env_qvolet2,
env_qvolet3,
env_qvolet4,
env_qvolet5

from  did.t_env_env) sub
group by round_time
order by round_time;



drop view if exists did.v_fctvanne4 CASCADE;
create view did.v_fctvanne4 as
select round_time,sum(bvo4)>0 as volet4,sum(bva4)>0 as vanne4, avg(hva4) as hvanne4 from (
select did.round_time_30(env_time) as round_time, 
case when env_volet4<4.03 then 1 else 0 end as bvo4,
case when env_vanne4>0 then 1 else 0 end as bva4,
env_vanne4 as hva4
from  did.t_env_env) sub
group by round_time
order by round_time;


drop view if exists did.v_fctvanne1235;
create view did.v_fctvanne1235 as
select round_time,
sum(bvo5)>0 as volet5,
sum(bva5)>0 as vanne5, 
sum(bvo3)>0 as volet3,
sum(bva3)>0 as vanne3, 
sum(bvo2)>0 as volet2,
sum(bva2)>0 as vanne2, 
sum(bvo1)>0 as volet1,
sum(bva1)>0 as vanne1 
from (
select did.round_time_30(env_time) as round_time, 
case when env_volet5<4.03 then 1 else 0 end as bvo5,
case when env_vanne5>0 then 1 else 0 end as bva5,
case when env_volet3<4.03 then 1 else 0 end as bvo3,
case when env_vanne3>0 then 1 else 0 end as bva3, 
case when env_volet2<4.03 then 1 else 0 end as bvo2,
case when env_vanne2>0 then 1 else 0 end as bva2, 
case when env_volet1<4.03 then 1 else 0 end as bvo1,
case when env_vanne1>0 then 1 else 0 end as bva1  
from  did.t_env_env) sub
group by round_time
order by round_time;


/*alter table did.t_didsonread_dsr add ;
select * from did.t_didsonread_dsr where dsr_dsf_id=696;
select * from did.t_didsonfiles_dsf where dsf_id=696;


dsr_dsf_id||dsr_csotdb doit être unique du fait de la contrainte 
*/

drop view if exists did.v_lecture cascade;
create view did.v_lecture as (
SELECT * FROM (
SELECT * FROM crosstab('select dsf_id_csot, dsf_filename,dsf_timeinit,dsf_position,dsr_reader,dsr_eelplus from 
					(SELECT cast(dsr_dsf_id as text)||''_''||cast(dsr_csotdb as text) as dsf_id_csot,
					dsf_filename,
					dsf_timeinit,
					dsf_position,
					dsr_reader,
					dsr_eelplus 
					  from did.t_didsonread_dsr
					  join did.t_didsonfiles_dsf on dsr_dsf_id=dsf_id) sub
				       order by 1,2',
			        'select distinct on (dsr_reader) dsr_reader from did.t_didsonread_dsr'
				)
AS ct(dsf_id_csot text,  dsf_filename character varying(30),dsf_timeinit timestamp,dsf_position character varying(6) ,brice numeric, brice_et_gerard numeric,gerard numeric)
) AS crosst
ORDER BY dsf_timeinit);

/*

Vue didsonlectures
*/



drop view if exists v_didsonlectures;
create view v_didsonlectures as 
select v_lecture.*,debitvilaine30,volbarrage30, volet4,vanne4,fct1.*,hvanne4 from did.v_lecture 
full outer join did.v_env on v_env.round_time=dsf_timeinit
full outer join did.v_fctvanne4 fct on fct.round_time=v_env.round_time
full outer join did.v_fctvanne1235 fct1 on fct1.round_time=v_env.round_time
order by dsf_timeinit, round_time;



drop view if exists did.v_dddp;
create view did.v_dddp as (

select * from did.t_didsonfiles_dsf  dsf 	
				left join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				left join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				left join did.t_poissonfile_psf on psf_drr_id=drr_id
				where psf_species!='2014' AND psf_species!='2238'
				and dsr_csotismin);

-- vue avec les lamproies

drop view if exists did.v_dddpall;
create view did.v_dddpall as (

select * from did.t_didsonfiles_dsf  dsf 	
				left join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				left join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				left join did.t_poissonfile_psf on psf_drr_id=drr_id
				and dsr_csotismin);

drop view if exists did.v_ddd cascade;
create view did.v_ddd as (

select * from did.t_didsonfiles_dsf  dsf 	
				left join  did.t_didsonread_dsr dsr on dsr_dsf_id=dsf_id
				left join did.t_didsonreadresult_drr drr on 	drr_dsr_id=dsr_id
				where dsr_csotismin or dsr_csotismin is null);				


drop view if exists did.v_dddpeall;
create view did.v_dddpeall as 
select v_dddpall.*,debitvilaine30,
volbarrage30,niveauvilaine30,
niveaumer30, 
volvanne30,volpasse30,
volsiphon30,volvolet30,
volet4,vanne4,
env_hvanne_tot30,
env_nvolet_tot30,
fct1.*,hvanne4, 
env_volvanne1_30,
env_volvanne2_30,
env_volvanne3_30,
env_volvanne4_30,
env_volvanne5_30,
env_volvolet1_30,
env_volvolet2_30,
env_volvolet3_30,
env_volvolet4_30,
env_volvolet5_30,
enj_turb ,
deb_qtotalj
from did.v_dddpall 
full outer join did.v_env on v_env.round_time=dsf_timeinit
full outer join did.v_fctvanne4 fct on fct.round_time=v_env.round_time
full outer join did.v_fctvanne1235 fct1 on fct1.round_time=v_env.round_time
left join did.t_envjour_enj on date(fct1.round_time)=enj_date
order by dsf_timeinit, round_time;

drop view if exists did.v_dddpe;
create view did.v_dddpe as 
select v_dddp.*,debitvilaine30,
volbarrage30,niveauvilaine30,
niveaumer30, 
volvanne30,volpasse30,
volsiphon30,volvolet30,
volet4,vanne4,
env_hvanne_tot30,
env_nvolet_tot30,
fct1.*,hvanne4, 
env_volvanne1_30,
env_volvanne2_30,
env_volvanne3_30,
env_volvanne4_30,
env_volvanne5_30,
env_volvolet1_30,
env_volvolet2_30,
env_volvolet3_30,
env_volvolet4_30,
env_volvolet5_30,
enj_turb ,
deb_qtotalj from did.v_dddp 
full outer join did.v_env on v_env.round_time=dsf_timeinit
full outer join did.v_fctvanne4 fct on fct.round_time=v_env.round_time
full outer join did.v_fctvanne1235 fct1 on fct1.round_time=v_env.round_time
left join did.t_envjour_enj on date(fct1.round_time)=enj_date
order by dsf_timeinit, round_time;


drop view if exists did.v_ddde;
create view did.v_ddde as 
select v_ddd.*,debitvilaine30,
volbarrage30,niveauvilaine30,
niveaumer30, 
volvanne30,volpasse30,
volsiphon30,volvolet30,
env_hvanne_tot30,
env_nvolet_tot30,
 volet4,vanne4,fct1.*,
hvanne4, 
env_volvanne1_30,
env_volvanne2_30,
env_volvanne3_30,
env_volvanne4_30,
env_volvanne5_30,
env_volvolet1_30,
env_volvolet2_30,
env_volvolet3_30,
env_volvolet4_30,
env_volvolet5_30,
enj_turb ,
deb_qtotalj from did.v_ddd
full outer join did.v_env on v_env.round_time=dsf_timeinit
full outer join did.v_fctvanne4 fct on fct.round_time=v_env.round_time
full outer join did.v_fctvanne1235 fct1 on fct1.round_time=v_env.round_time
left join did.t_envjour_enj on date(fct1.round_time)=enj_date
order by round_time;

select * from did.v_ddde
/*
Sommes journalières, comprends les turbidités
dj données journalières
*/
drop view if exists did.v_dddedj;
create view did.v_dddedj as (
select enj_date,
	enj_turb,
	debitvilainej,
	debitcranj,
	volbarragej,
	volvannej,
	volsiphonj,
	volvoletj,
	deb_qtotalj,
	debit4j,
	sum_eel_plus,
	sum_eel_minus
	from did.t_envjour_enj 
	join 
(select
date,
avg(env_debitvilaine) as debitvilainej,
avg(env_debitmoyencran) as debitcranj,
sum(env_volumetotal) as volbarragej,
sum(env_volvanne) as volvannej,
sum(env_volpasse) as volpassej,
sum(env_volsiphon) as volsiphonj,
sum(env_volvolet) as volvoletj,
avg(env_qvanne4+env_qvolet4) as debit4j --144 --sum(env_qvanne4*600+env_qvolet4*600)/86400
	 from (
	select date(env_time) as date, 
	env_debitmoyencran,
	env_debitvilaine, 
	env_volumetotal,
	env_niveauvilaine,
	env_niveaumer,
	env_volvanne,
	env_volpasse,
	env_volvolet,
	env_volsiphon,
	env_qvanne4,
	env_qvolet4
	from  did.t_env_env
	) as e
group by date) as ej
on ej.date=t_envjour_enj.enj_date
join (select 
sum(drr_eelplus) as sum_eel_plus,
sum(drr_eelminus) as sum_eel_minus,
date2
from ( select date(dsf_timeinit) as date2,
	drr_eelplus,
	drr_eelminus from did.v_ddd) v_d3
group by date2) v_d3j	
on date=date2
order by date);



select distinct dsf_fls_id from did.t_didsonfiles_dsf
/*
delete from did.t_fishsequence_fsq;
delete from did.t_didsonread_dsr;
delete from did.t_didsonfiles_dsf;
*/


/*
Requètes variées pour la base de données
*/

select * from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id;
select dsf_timeinit,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, dsr_readend-dsr_readinit as temps_lecture from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id;

with depouillement as (select dsf_timeinit,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
select * from depouillement order by temps_lecture;



/*
runonce 2017
select * from did.t_didsonread_dsr  where dsr_id=37968;
update did.t_didsonread_dsr set dsr_readend='2017-08-31 13:52:00' where dsr_id=37968;
select * from did.t_didsonread_dsr  where dsr_id=37969;
update did.t_didsonread_dsr set dsr_readend='2017-08-31 13:56:00' where dsr_id=37969;
select * from did.t_didsonread_dsr  where dsr_id=31694;
update did.t_didsonread_dsr set dsr_readend='2015-03-10 14:01:00' where dsr_id=31694;
select * from did.t_didsonread_dsr  where dsr_id=27759;
update did.t_didsonread_dsr set dsr_readend= '2014-02-11 17:13:00' where dsr_id=27759;
begin;
update did.t_didsonread_dsr set dsr_readend=dsr_readinit+interval '5 minute' where dsr_id in (
select dsr_id from (
	select dsr_id, 
	dsr_readend-dsr_readinit as temps_lecture 
	from did.t_didsonread_dsr  
	) sub
	where temps_lecture< interval '0 minute');
commit;
select * from did.t_didsonread_dsr  where dsr_id=37373;
update did.t_didsonread_dsr set dsr_readend='2017-04-18 10:20:00' where dsr_id=37373;
*/
with depouillement as (select dsf_timeinit,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
select * from depouillement order by dsf_timeinit

with depouillement as (select dsf_timeinit,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
select justify_hours(sum(temps_lecture)) from depouillement 

with depouillement as (select dsf_timeinit, dsf_season,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
select dsf_season, mois,justify_hours(sum(temps_lecture)) from depouillement  group by dsf_season, mois order by dsf_season, mois

with depouillement as (select dsf_timeinit,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
select mois,dsr_reader,sum(temps_lecture) from depouillement group by mois,dsr_reader order by dsr_reader, mois

create view did.v_depouillement as (
select dsf_timeinit,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id);



update did.t_didsonfiles_dsf set dsf_readok=TRUE where dsf_id in (
select dsf_id from did.t_didsonread_dsr join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id where dsf_timeinit>'2013-01-01- 00:00:00'
and dsf_readok=FALSE);--626



select * from did.t_didsonfiles_dsf  where dsf_id is null
select * from did.t_didsonfiles_dsf  where dsf_timeinit='2014-03-21'
select * from did.t_didsonfiles_dsf  where dsf_timeend='2014-03-30 00:00:00'
select * from did.v_ddd  where dsf_timeinit='2014-03-21'
select * from did.v_ddde  where dsf_timeinit='2014-03-21'

/* 
En 2013-2014, brice a fait une erreur sur les inclinaisons, correction après saisie dans la base de données, attention
les données ont aussi été corrigées dans excel, pour les 
*/
update did.t_didsonfiles_dsf set (dsf_incl,dsf_distancestart)=(-40,2.92) where dsf_id in (
select dsf_id from (
select *,extract('minutes' from dsf_timeinit) min from did.t_didsonfiles_dsf where dsf_timeinit>='2013-12-23 14:00:00' and dsf_timeinit<'2013-12-24 11:30:00' order by dsf_timeinit
)sub where min=30);


-- correction des altitudes de tous les enregistrements.
update did.t_didsonfiles_dsf set dsf_depth=dsf_depth+1.48 where dsf_id in (
select dsf_id   from did.t_didsonfiles_dsf where dsf_depth>-2.5 );--7065



with depouillement as (
select dsf_timeinit, dsf_season,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture,
dsr_readinit,
dsr_readend
from did.t_didsonread_dsr 
join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
SELECT * FROM depouillement WHERE dsf_season='2018-2019'
AND temps_lecture >'10:00:00'

UPDATE did.t_didsonread_dsr SET dsr_readend='2019-03-06 12:33:00' WHERE dsr_id=49372;
UPDATE did.t_didsonread_dsr SET dsr_readend='2019-03-06 14:48:00' WHERE dsr_id=49408;
UPDATE did.t_didsonread_dsr SET dsr_readend='2019-12-02 14:08:00' WHERE dsr_id=50043;

with depouillement as (
select dsf_timeinit, dsf_season,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture,
dsr_readinit,
dsr_readend
from did.t_didsonread_dsr 
join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
SELECT * FROM depouillement WHERE dsf_season='2019-2020'
AND temps_lecture >'10:00:00'



UPDATE did.t_didsonread_dsr SET dsr_readend='2020-02-26 18:03' WHERE dsr_id=52334;
UPDATE did.t_didsonread_dsr SET dsr_readend='2020-03-05 11:26:00' WHERE dsr_id=52391;
UPDATE did.t_didsonread_dsr SET dsr_readinit='2020-03-05 11:34:00' WHERE dsr_id=52392;
SELECT * FROM did.t_didsonread_dsr  WHERE dsr_id=52391;

with depouillement as (
select dsf_timeinit, dsf_season,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture,
dsr_readinit,
dsr_readend
from did.t_didsonread_dsr 
join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
SELECT * FROM depouillement WHERE dsf_season='2019-2020'
AND temps_lecture >'0:30:00'


with depouillement as (
select dsf_timeinit, dsf_season,dsr_id,extract('month' from dsf_timeinit) as mois,dsr_reader, dsf_position, 
dsr_readend-dsr_readinit as temps_lecture,
dsr_readinit,
dsr_readend
from did.t_didsonread_dsr 
join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id)
SELECT * FROM depouillement WHERE dsf_season='2019-2020'
AND temps_lecture <'0:00:00'

UPDATE did.t_didsonread_dsr SET dsr_readend='2020-02-20 15:33' WHERE dsr_id=51787;
UPDATE did.t_didsonread_dsr SET dsr_readend='2020-02-24 14:27' WHERE dsr_id=51809;
UPDATE did.t_didsonread_dsr SET dsr_readend='2020-03-02 09:27' WHERE dsr_id=52278;
UPDATE did.t_didsonread_dsr SET dsr_readinit='2020-03-11 12:42' WHERE dsr_id=52834;
UPDATE did.t_didsonread_dsr SET dsr_readend='2020-04-02 12:28' WHERE dsr_id=53074;
UPDATE did.t_didsonread_dsr SET dsr_readend='2020-01-29 12:37' WHERE dsr_id=51531;
UPDATE did.t_didsonread_dsr SET dsr_readinit='2020-01-29 12:18' WHERE dsr_id=51531;
begin;
update did.t_didsonread_dsr set dsr_readend=dsr_readinit+interval '5 minute' where dsr_id in (
select dsr_id from (
	select dsr_id, 
	dsr_readend-dsr_readinit as temps_lecture 
	from did.t_didsonread_dsr 
	join did.t_didsonfiles_dsf on dsf_id=dsr_dsf_id
	) sub
	where temps_lecture< interval '0 minute' AND dsf_season='2019-2020'

	);
commit;

