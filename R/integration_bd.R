require(RODBC)
require(stacomirtools)
require(stringr)
require(plyr)
require(lubridate)
require("safer")
require("getPass")
require('sqldf') # mimict sql queries in a data.frame
require('RPostgres') # one can use RODBC, here I'm using direct connection via the sqldf package
setwd("C:/workspace/p/didson/")
source("rapport/Tablesiva_classes.R")

if (!exists("userdistant") | !exists("passworddistant")) stop('Il faut configurer Rprofile.site avec les bons mots de passe et user')
pois <- getPass(msg="Main password")
host <- decrypt_string(hostdistant,pois)
user <- decrypt_string(userdistant,pois)
password<- decrypt_string(passworddistant,pois)
options(sqldf.RPostgreSQL.user = user, 
		sqldf.RPostgreSQL.password = password,
		sqldf.RPostgreSQL.dbname = "didson",
		sqldf.RPostgreSQL.host = host,
		sqldf.RPostgreSQL.port = 5432)
Sys.timezone()
#Sys.setenv(TZ='GMT')
#datawd<-"//srv-01/data/Migrateur/Devalaison/2017-2018/Depouillement//"
datawd <- "C:/temp/depouillement/"
#######################################################################
## essai de connection ? la base didson
#req<-new("RequeteODBC")
#req@baseODBC<-c("didson_distant",passworddistant,userdistant)
#req@sql<-"select * from   did.t_didsonfiles_dsf"
#re<-connect(req)
#odbcCloseAll()
#req
## fin de l'essai
# ?criture dans la base
## cr?ation du fichier de structure

# r?cup?ration du fichier excel
library("XLConnect")
xls.file<-str_c(datawd,"depouillement_2020_total_cor.xlsx")
file.exists(xls.file)
wb = loadWorkbook(xls.file, create = FALSE)
ta<-readWorksheet ( wb , "depouillement" , startRow=0 , startCol=1 ,  endCol=19 ,
		header = TRUE ,colTypes=
				c(		rep("character",3),
						rep("numeric",4),
						"logical",
						rep("character",4),
						rep("numeric",2),
						rep("character",2),
						rep("numeric",2),
						"character"))
# pas de sauvegarde
# nrow(ta)
#colnames(ta)
ta<-killfactor(ta)
# est ce qu'il y a des echogrammes ?
ta[(ta$dsr_csotdb=="echo"&!is.na(ta$dsr_csotdb)),] 
ta<-ta[!(ta$dsr_csotdb=="echo"&!is.na(ta$dsr_csotdb)),] 
# nrow(ta)

# 2015 10630 
# 2016 9511
# 2017 5810
# 2018 9705
# 2019 7681 ?
# 2020 9552
ta<-ta[!is.na(ta$dsf_filename),] 

#####################################################
# t_didsonfiles_dsf
# POUR NETTOYAGE EN CASCADE VOIR 
# SI SUPPRESSION NECESSAIRES
# voir scan_didsontxt.sql
#####################################################
dsf <- ta[,grep("dsf",colnames(ta))]#3365
dsf[is.na(dsf$dsf_filename),]

dsf$dsf_readok=as.logical(as.numeric(dsf$dsf_readok))
dsf$dsf_readok[is.na(dsf$dsf_readok)]<-FALSE

table(dsf$dsf_distancestart) # 10091
# 2015 correction

#-7 3.75    5   =>  3.75    5 
# 136 1500 5449 =>  1500 5585 
# 2016
# 5 8516
# 2018 
# 5 7435
# 2019
# 5 
# 5621 
# je selectionne les donn?es uniques (parfois plusieurs lectures pour un fichier)
dupl <- dsf$dsf_filename[duplicated(dsf$dsf_filename)] 
# 2015 10608 
# 2016 7
# 2018 1
# 2019 0
#stopifnot(is.null(dupl))
dsf <- dsf[!duplicated(dsf$dsf_filename),]
# 2015 8886
# 2016 9504
# 2018 7681
# 2019 9552
#str(dsf)
#dsf<-prepare_for_sql(dsf) # quote character et POSIXt>> character
#str(dsf)
summary(dsf$dsf_incl)
# ATTENTION AU CHANGEMENT D'HEURE, LES FICHIERS N'EXISTENT PAS, ET LE TEST CI DESSOUS RENVOIT UN PB
# il faut supprimer la ligne de changement d'heure
dsf$dsf_timeend<-as.POSIXct(strptime(dsf$dsf_timeend,format="%Y-%m-%d %H:%M:%S",tz="CET"),tz="CET")
dsf$dsf_timeinit<-as.POSIXct(strptime(dsf$dsf_timeinit,format="%Y-%m-%d %H:%M:%S",tz="CET"),tz="CET")


dsf[dsf$dsf_timeend<=dsf$dsf_timeinit, ]
dsf$dsf_position<-tolower(dsf$dsf_position)
#pour 2019#dsf<-dsf[rownames(dsf)!="7974",]
#dsf$dsf_timeend<-as.character(dsf$dsf_timeend)
#dsf$dsf_timeinit<-as.character(dsf$dsf_timeinit)

#sqldf("alter table did.t_didsonfiles_dsf drop CONSTRAINT c_ck_dsf_incl")
#sqldf("alter table did.t_didsonfiles_dsf add CONSTRAINT c_ck_dsf_incl CHECK (dsf_incl < 40::numeric AND dsf_incl > (-80)::numeric)")
#sqldf("delete from did.t_didsonfiles_dsf where dsf_id>=30000")
#sqldf("delete from did.t_didsonread_dsr where dsr_dsf_id>=80000")
#sqldf("select max( dsf_id) from did.t_didsonfiles_dsf") 
#sqldf("SELECT * FROM did.t_didsonfiles_dsf 
# 2016 100219
# 2017  110504
# 2019  142458
#sqldf("select max( dsr_id) from did.t_didsonread_dsr") 
# 2016 36058
#2017 38169
sqldf("insert into did.t_didsonfiles_dsf(
dsf_timeinit,      
dsf_timeend,
dsf_position,     
dsf_incl,
dsf_distancestart,
dsf_depth,        
dsf_fls_id,
dsf_readok,
dsf_filename)
select * from dsf")
## pb d'encrassement des lentilles+ turbidite
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=3 where dsf_timeinit>='2013-12-30 09:00:00' and
#				dsf_timeend<='2014-01-06 17:00:00'")
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=1 where dsf_timeinit>='2013-12-18 10:00:00' and
#				dsf_timeend<='2013-12-18 15:30:00'")
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=1 where dsf_timeinit>='2013-12-23 21:00:00' and
#				dsf_timeend<='2013-12-24 11:30:00'")
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=2 where dsf_fls_id=3 and dsf_timeinit>='2013-10-01'")
## cable arrach?
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=1 where dsf_timeinit>='2014-01-29 23:30:00' and
#				dsf_timeend<='2014-02-05 16:00:00'")
## plantage bizarre du rotateur
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=1 where dsf_timeinit>='2014-04-02 16:00:00' and
#				dsf_timeend<='2014-04-06 11:30:00'")

######################""
# INTEGRATION DE LA TABLE DSR
#####################
dsr<-ta[,c(match("dsf_filename",colnames(ta)),grep("dsr",colnames(ta)))]#3365
colnames(dsr)


# Tests : il peut y avoir des champs textes dans les dates 
dsr_readend1 <- parse_date_time(dsr$dsr_readend,"%y-%m-%d %H:%M:%S",tz="CET")
dsr[which(is.na(dsr_readend1)&!is.na(dsr$dsr_readend)),]
dsr_readinit1 <- parse_date_time(dsr$dsr_readinit,"%y-%m-%d %H:%M:%S",tz="CET")
dsr[which(is.na(dsr_readinit1)&!is.na(dsr$dsr_readinit)),]

dsr$dsr_readend <- parse_date_time(dsr$dsr_readend,"%y-%m-%d %H:%M:%S", tz="CET")
dsr$dsr_readinit <- parse_date_time(dsr$dsr_readinit,"%y-%m-%d %H:%M:%S", tz="CET")

# Je vais le virer ensuite
#temp<-sqldf("select * from did.t_didsonread_dsr limit 10")
#colnames(temp)
#temp<-sqldf("select  count(*), dsr_csotdb  from did.t_didsonread_dsr group by dsr_csotdb")
#require(Hmisc)
Hmisc::describe(dsr)
table(dsr$dsr_csotdb)
dsr$dsr_csotdb<-as.numeric(gsub(",",".",dsr$dsr_csotdb))
#dsr$dsr_eelplus<-as.numeric(dsr$dsr_eelplus)
#dsr$dsr_eelminus<-as.numeric(dsr$dsr_eelminus)
dsr$dsr_eelminus[is.na(dsr$dsr_eelminus)] <- 0
dsr$dsr_eelplus[is.na(dsr$dsr_eelplus)] <- 0
dsr$dsr_complete <- as.logical(as.numeric(dsr$dsr_complete))
dsr$dsr_complete[is.na(dsr$dsr_complete)] <- FALSE
#dsr[is.na(dsr$dsr_reader),"dsr_readinit"]
dsr <- dsr[!is.na(dsr$dsr_reader),] # J'utilise dsr_reader .... v?rifier quand m?me ci dessus
sum(dsr$dsr_reader=="")
sum(dsr$dsr_reader==" ")
dsr[dsr$dsr_reader==" ",]
dsr<-dsr[!dsr$dsr_reader==" ",]
dsr<-dsr[!dsr$dsr_reader=="",]
dsr$dsr_reader<-str_c(toupper(substring(dsr$dsr_reader,1,1)),substring(dsr$dsr_reader,2,50))
unique(dsr$dsr_reader)
table(dsr$dsr_reader)
  #Brice Gerard 
  #740   2370 
  #198   1590
  #689   1359
  #1014  1388
  #3432   162 

dsf <- sqldf("select * from   did.t_didsonfiles_dsf")
dsf <- dsf[,c("dsf_id","dsf_filename")]


dsr <- merge(dsf,dsr,by="dsf_filename")
dsr <- chnames(dsr,"dsf_id","dsr_dsf_id")
#v?rif
head(dsr[,c("dsr_dsf_id", 
						"dsr_readinit", 
						"dsr_readend", 
						"dsr_reader", 
						"dsr_eelplus", 
						"dsr_eelminus", 
						"dsr_csotdb", 
						"dsr_complete", 
						"dsr_muletscore", 
						"dsr_fryscore",
						"dsr_comment")])

sqldf("insert into did.t_didsonread_dsr(
				dsr_dsf_id, 
				dsr_readinit, 
				dsr_readend, 
				dsr_reader, 
				dsr_eelplus, 
				dsr_eelminus, 
				dsr_csotdb, 
				dsr_complete, 
				dsr_muletscore, 
				dsr_fryscore,
				dsr_comment)
				select dsr_dsf_id, 
				dsr_readinit, 
				dsr_readend, 
				dsr_reader, 
				dsr_eelplus, 
				dsr_eelminus, 
				dsr_csotdb, 
				dsr_complete, 
				dsr_muletscore, 
				dsr_fryscore,
				dsr_comment from dsr")

#dsr[dsr$dsr_dsf_id==103107,]


# -- 2018 rajout de fichiers apr?s la fin de la saison
# les fichiers manquants vont de  ? 
#drr_filename
#2017-12-23_193000_HF
#2017-12-23_203000_HF
#2017-12-23_220000_HF
#2017-12-24_030000_HF
#2017-12-24_040000_HF
#2017-12-24_063000_HF
#2017-12-24_073000_HF
#2017-12-24_213000_HF
#2017-12-25_000000_HF
#2017-12-25_013000_HF
#2017-12-25_020000_HF
#2017-12-25_033000_HF
#2017-12-25_040000_HF
#2017-12-25_060000_HF
#2017-12-25_063000_HF
#2017-12-25_073000_HF
#2017-12-26_043000_HF
#2017-12-26_050000_HF
#2017-12-26_203000_HF
#2017-12-27_000000_HF
#2017-12-27_003000_HF
#2017-12-27_010000_HF
#2017-12-27_013000_HF
#2017-12-27_070000_HF


# r?cup?ration du fichier excel
library("XLConnect")
xls.file<-str_c(datawd,"depouillement_2017_supplementaire.xlsx")
file.exists(xls.file)
wb = loadWorkbook(xls.file, create = FALSE)
ta<-readWorksheet ( wb , "depouillement" , startRow=0 , startCol=1 ,  endCol=19 ,
	header = TRUE ,colTypes=
		c(		rep("character",3),
			rep("numeric",4),
			"logical",
			rep("character",4),
			rep("numeric",2),
			rep("character",2),
			rep("numeric",2),
			"character"))
# pas de sauvegarde
# 9705 lignes # nrow(ta)
colnames(ta)
ta<-killfactor(ta)
ta[(ta$dsr_csotdb=="echo"&!is.na(ta$dsr_csotdb)),] 
ta<-ta[!(ta$dsr_csotdb=="echo"&!is.na(ta$dsr_csotdb)),] 
# 2015 10630 
# 2016 9511
# 2017 5810
ta<-ta[!is.na(ta$dsf_filename),]

######################""
# INTEGRATION DE LA TABLE DSR
#####################
dsr<-ta[,c(match("dsf_filename",colnames(ta)),grep("dsr",colnames(ta)))]#3365
colnames(dsr)


# Tests : il peut y avoir des champs textes dans les dates 
dsr_readend1<-parse_date_time(dsr$dsr_readend,"%y-%m-%d %H:%M:%S",tz="CET")
dsr[which(is.na(dsr_readend1)&!is.na(dsr$dsr_readend)),]
dsr_readinit1<-parse_date_time(dsr$dsr_readinit,"%y-%m-%d %H:%M:%S",tz="CET")
dsr[which(is.na(dsr_readinit1)&!is.na(dsr$dsr_readinit)),]

dsr$dsr_readend<-parse_date_time(dsr$dsr_readend,"%y-%m-%d %H:%M:%S",tz="CET")
dsr$dsr_readinit<-parse_date_time(dsr$dsr_readinit,"%y-%m-%d %H:%M:%S",tz="CET")

# Je vais le virer ensuite
#temp<-sqldf("select * from did.t_didsonread_dsr limit 10")
#colnames(temp)
#temp<-sqldf("select  count(*), dsr_csotdb  from did.t_didsonread_dsr group by dsr_csotdb")
#require(Hmisc)
describe(dsr)
table(dsr$dsr_csotdb)
dsr$dsr_csotdb<-as.numeric(gsub(",",".",dsr$dsr_csotdb))
#dsr$dsr_eelplus<-as.numeric(dsr$dsr_eelplus)
#dsr$dsr_eelminus<-as.numeric(dsr$dsr_eelminus)
dsr$dsr_eelminus[is.na(dsr$dsr_eelminus)]<-0
dsr$dsr_eelplus[is.na(dsr$dsr_eelplus)]<-0
dsr$dsr_complete<-as.logical(as.numeric(dsr$dsr_complete))
dsr$dsr_complete[is.na(dsr$dsr_complete)]<-FALSE
#dsr[is.na(dsr$dsr_reader),"dsr_readinit"]
dsr<-dsr[!is.na(dsr$dsr_reader),] # J'utilise dsr_reader .... v?rifier quand m?me ci dessus
sum(dsr$dsr_reader=="")
sum(dsr$dsr_reader==" ")
dsr[dsr$dsr_reader==" ",]
dsr<-dsr[!dsr$dsr_reader==" ",]
dsr<-dsr[!dsr$dsr_reader=="",]
dsr$dsr_reader<-str_c(toupper(substring(dsr$dsr_reader,1,1)),substring(dsr$dsr_reader,2,50))
unique(dsr$dsr_reader)
table(dsr$dsr_reader)
#Brice Gerard 
#740   2370 
#198   1590
#689   1359
#862   2504 

dsf<-sqldf("select * from   did.t_didsonfiles_dsf")
dsf<-dsf[,c("dsf_id","dsf_filename")]


dsr<-merge(dsf,dsr,by="dsf_filename")
dsr<-chnames(dsr,"dsf_id","dsr_dsf_id")
#v?rif
head(dsr[,c("dsr_dsf_id", 
			"dsr_readinit", 
			"dsr_readend", 
			"dsr_reader", 
			"dsr_eelplus", 
			"dsr_eelminus", 
			"dsr_csotdb", 
			"dsr_complete", 
			"dsr_muletscore", 
			"dsr_fryscore",
			"dsr_comment")])

sqldf("insert into did.t_didsonread_dsr(
		dsr_dsf_id, 
		dsr_readinit, 
		dsr_readend, 
		dsr_reader, 
		dsr_eelplus, 
		dsr_eelminus, 
		dsr_csotdb, 
		dsr_complete, 
		dsr_muletscore, 
		dsr_fryscore,
		dsr_comment)
		select dsr_dsf_id, 
		dsr_readinit, 
		dsr_readend, 
		dsr_reader, 
		dsr_eelplus, 
		dsr_eelminus, 
		dsr_csotdb, 
		dsr_complete, 
		dsr_muletscore, 
		dsr_fryscore,
		dsr_comment from dsr")
