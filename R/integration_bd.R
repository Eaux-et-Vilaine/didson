load_package <- function(x)
{
  if (!is.character(x)) stop("Package should be a string")
  if (!require(x,character.only = TRUE))
  {
    install.packages(x, lib=.libPaths()[1],repos="http://cran.us.r-project.org", dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}
load_package("RODBC")
load_package("stacomirtools")
load_package("stringr")
load_package("plyr")
load_package("lubridate")
load_package("safer")
load_package("getPass")
load_package("DBI")
load_package('RPostgres') # one can use RODBC, here I'm using direct connection via the sqldf package
setwd("C:/workspace/didson/")
load_package("SIVA")
#install.packages("xlsx")
-#install.packages("D:/temp/didson/2022-2023/SIVA_0.1.4.3.tar.gz")
load_package("xlsx")

if (!exists("userdistant") |
    !exists("passworddistant"))
    stop('Il faut configurer Rprofile.site avec les bons mots de passe et user')
pois <- getPass(msg = "Main password")
host <- decrypt_string(hostdistant, pois)
user <- decrypt_string(userdistant, pois)
password <- decrypt_string(passworddistant, pois)
Sys.timezone()
#Sys.setenv(TZ='GMT')
datawd <- "C:/temp/didson/2023-2024/"
#######################################################################
## essai de connection à la base didson
#req<-new("RequeteODBC")
#req@baseODBC<-c("didson_distant",passworddistant,userdistant)
#req@sql<-"select * from   did.t_didsonfiles_dsf"
#re<-connect(req)
#odbcCloseAll()
#req
## fin de l'essai
# écriture dans la base
## création du fichier de structure

# récupération du fichier excel


xls.file <- str_c(datawd, "depouillement_2023_TOTAL.xlsx")
file.exists(xls.file)
ta <- xlsx::read.xlsx(
    xls.file ,
    sheetName = "depouillement",
    colIndex = 1:19,
    as.data.frame = TRUE,
    header = TRUE,
    colClasses =
        c(
            rep("POSIXct", 2),
            "character",
            rep("numeric", 4),
            "logical",
            "character",
            #"character", # to fix when format is 1970 see below erreur 2023
            rep("POSIXct",2),
            "character",
            rep("numeric", 2),
            rep("character", 2),
            rep("numeric", 2),
            "character"
        )
)
# read.xlsx convertit tout en GMT car il n'y a pas de tz dans excel
# Il faut donc remettre les données à la main
attributes (ta$dsf_timeinit) #GMT OK
attributes (ta$dsf_timeend) # GMT OK
# erreur en 2023 le format ne passait pas
#ta$dsr_readinit <- openxlsx::convertToDateTime(ta$dsr_readinit, origin = "1900-01-01")
ta$dsr_readinit
ta$dsr_readend 
head(ta$dsf_timeinit)
#head(as.POSIXct(format(ta$dsf_timeinit), tz="Europe/Paris"))
#ta$dsf_timeinit <- as.POSIXct(format(ta$dsf_timeinit), tz="Europe/Paris")
#ta$dsf_timeend <- as.POSIXct(format(ta$dsf_timeend), tz="Europe/Paris")
ta$dsr_readinit <- as.POSIXct(format(ta$dsr_readinit), tz="Europe/Paris")
ta$dsr_readend <- as.POSIXct(format(ta$dsr_readend), tz="Europe/Paris")

# vérifier que le nom du fichier correspond bien à la date
View(head(ta))

# pas de sauvegarde
# nrow(ta)
#colnames(ta)
ta <- killfactor(ta)
# est ce qu'il y a des echogrammes ?
ta[(ta$dsr_csotdb == "echo" & !is.na(ta$dsr_csotdb)), ]
ta <- ta[!(ta$dsr_csotdb == "echo" & !is.na(ta$dsr_csotdb)), ]

ta <- ta[!is.na(ta$dsf_filename), ]
ta <- ta[!is.na(ta$dsf_incl), ]
ta$dsf_readok <- TRUE
ta$dsf_readok[is.na(ta$dsr_eelplus)] <- FALSE
# nrow(ta)
# 2015 10630
# 2016 9511
# 2017 5810
# 2018 9705
# 2019 7681 ?
# 2020 9552
# 2021
# 2022 9995
# 2023 9482

#####################################################
# t_didsonfiles_dsf
# POUR NETTOYAGE EN CASCADE VOIR
# SI SUPPRESSION NECESSAIRES
# voir scan_didsontxt.sql
#####################################################
dsf <- ta[, grep("dsf", colnames(ta))]
dsf[is.na(dsf$dsf_filename), ]



table(dsf$dsf_distancestart) # 5 9482
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
# Pour dsf je selectionne les données uniques (parfois plusieurs lectures pour un fichier) dans dsr , plus loin, on gardera ces doublons
dupl <- dsf$dsf_filename[duplicated(dsf$dsf_filename)]
# 2015 10608
# 2016 7
# 2018 1
# 2019 0
# 2022 0
# 2023 11
#stopifnot(is.null(dupl))
dsf <- dsf[!duplicated(dsf$dsf_filename), ]
# 2015 8886
# 2016 9504
# 2018 7681
# 2019 9552
# 2023 9471
#str(dsf)
#dsf<-prepare_for_sql(dsf) # quote character et POSIXt>> character
#str(dsf)
summary(dsf$dsf_incl)


# ATTENTION AU CHANGEMENT D'HEURE, CERTAINS FICHIERS N'EXISTENT PAS
# Le format a été converti en tz=Europe/Paris
# Pour retrouver les lignes avant la conversion de GMT en CET on peut lancer :

# Ci dessous je corrige le problème en forcant en CET ce qui transforme en
# NA les données sur 4 lignes (1 complète 02:00 à 2:30, deux à moitié) 

#dsf$dsf_timeend <- lubridate::force_tz(dsf$dsf_timeend, tzone = "CET")
#dsf$dsf_timeinit <- lubridate::force_tz(dsf$dsf_timeinit, tzone = "CET")
#dsf <- dsf[!is.na(dsf$dsf_timeinit),]
#dsf[dsf$dsf_timeinit=='2022-03-27 01:30:00' ,"dsf_timeend"]<-'2022-03-27 03:00:00'



   

dsf[dsf$dsf_timeend <= dsf$dsf_timeinit,]
dsf[is.na(dsf$dsf_timeinit),]
dsf <- dsf[!is.na(dsf$dsf_timeinit),]

dsf$dsf_position <- tolower(dsf$dsf_position)


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
con <- dbConnect(Postgres(), 		
    dbname="didson", 		
    host=host,
    port=5432, 		
    user= user, 		
    password= password)
# DO THIS, OVERWRITE DOES NOT RAISE ERROR AND THEN NOTHING IS WRITTEN
DBI::dbExecute(con, "DROP TABLE IF exists temp_dsf")
dsf$dsf_timeinit <- format(dsf$dsf_timeinit)
dsf$dsf_timeend <- format(dsf$dsf_timeend)
DBI::dbWriteTable(con, "temp_dsf",dsf)
DBI::dbExecute(con, statement =
    "insert into did.t_didsonfiles_dsf(
        dsf_timeinit,
        dsf_timeend,
        dsf_position,
        dsf_incl,
        dsf_distancestart,
        dsf_depth,
        dsf_fls_id,
        dsf_readok,
        dsf_filename)
        select 
				dsf_timeinit::timestamp,
        dsf_timeend::timestamp,
        dsf_position,
        dsf_incl,
        dsf_distancestart,
        dsf_depth,
        dsf_fls_id,
        dsf_readok,
        dsf_filename
 from temp_dsf"
) # 9993 # 8373 # 9471



## pb d'encrassement des lentilles+ turbidite
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=3 where dsf_timeinit>='2013-12-30 09:00:00' and
#				dsf_timeend<='2014-01-06 17:00:00'")
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=1 where dsf_timeinit>='2013-12-18 10:00:00' and
#				dsf_timeend<='2013-12-18 15:30:00'")
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=1 where dsf_timeinit>='2013-12-23 21:00:00' and
#				dsf_timeend<='2013-12-24 11:30:00'")
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=2 where dsf_fls_id=3 and dsf_timeinit>='2013-10-01'")
## cable arraché
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=1 where dsf_timeinit>='2014-01-29 23:30:00' and
#				dsf_timeend<='2014-02-05 16:00:00'")
## plantage bizarre du rotateur
#sqldf("update did.t_didsonfiles_dsf set dsf_fls_id=1 where dsf_timeinit>='2014-04-02 16:00:00' and
#				dsf_timeend<='2014-04-06 11:30:00'")

######################""
# INTEGRATION DE LA TABLE DSR
#####################
dsr <-
    ta[, c(match("dsf_filename", colnames(ta)), grep("dsr", colnames(ta)))]#3365 # 8374 # 9482
colnames(dsr)


# Tests : il peut y avoir des champs textes dans les dates
attributes(dsr$dsr_readend)
attributes(dsr$dsr_readinit)
#dsr$dsr_readend <-  lubridate::force_tz(dsr$dsr_readend,  tz = "CET")
#dsr$dsr_readinit <- lubridate::force_tz(dsr$dsr_readinit, tz = "CET")



Hmisc::describe(dsr)
table(dsr$dsr_csotdb)
dsr$dsr_csotdb <- as.numeric(gsub(",", ".", dsr$dsr_csotdb))
#dsr$dsr_eelplus<-as.numeric(dsr$dsr_eelplus)
#dsr$dsr_eelminus<-as.numeric(dsr$dsr_eelminus)
dsr$dsr_eelminus[is.na(dsr$dsr_eelminus)] <- 0
dsr$dsr_eelplus[is.na(dsr$dsr_eelplus)] <- 0
dsr$dsr_complete <- as.logical(as.numeric(dsr$dsr_complete))
dsr$dsr_complete[is.na(dsr$dsr_complete)] <- FALSE
#dsr[is.na(dsr$dsr_reader),"dsr_readinit"]
dsr <-
    dsr[!is.na(dsr$dsr_reader), ] # J'utilise dsr_reader .... vérifier quand même ci dessus
sum(dsr$dsr_reader == "")
sum(dsr$dsr_reader == " ")
dsr[dsr$dsr_reader == " ", ]
dsr <- dsr[!dsr$dsr_reader == " ", ]
dsr <- dsr[!dsr$dsr_reader == "", ]
dsr$dsr_reader <-
    str_c(toupper(substring(dsr$dsr_reader, 1, 1)), substring(dsr$dsr_reader, 2, 50))
unique(dsr$dsr_reader)
table(dsr$dsr_reader)
#Brice Gerard
#740   2370
#198   1590
#689   1359
#1014  1388
#3432   162
#3569   452
#70     3124
#1182   1827 
dsf <- DBI::dbGetQuery(con,"select * from   did.t_didsonfiles_dsf")
dsf <- dsf[, c("dsf_id", "dsf_filename")]


dsr <- merge(dsf, dsr, by = "dsf_filename")
dsr <- chnames(dsr, "dsf_id", "dsr_dsf_id")
#vérif
head(dsr[, c(
    "dsr_dsf_id",
    "dsr_readinit",
    "dsr_readend",
    "dsr_reader",
    "dsr_eelplus",
    "dsr_eelminus",
    "dsr_csotdb",
    "dsr_complete",
    "dsr_muletscore",
    "dsr_fryscore",
    "dsr_comment"
)])
DBI::dbExecute(con, "DROP TABLE IF EXISTS temp_dsr")
dsr$dsr_readinit <- format(dsr$dsr_readinit)
dsr$dsr_readend <- format(dsr$dsr_readend)
DBI::dbWriteTable(con, "temp_dsr",dsr,overwrite = TRUE)
DBI::dbExecute(con, statement =

    "insert into did.t_didsonread_dsr(
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
        dsr_readinit::timestamp,
        dsr_readend::timestamp,
        dsr_reader,
        dsr_eelplus,
        dsr_eelminus,
        dsr_csotdb::numeric,
        dsr_complete,
        dsr_muletscore,
        dsr_fryscore,
        dsr_comment from temp_dsr"
) # 4021 #3194 # 3009

DBI::dbExecute(con, statement =
        
        "update did.t_didsonread_dsr set
        dsr_readinit=temp_dsr.dsr_readinit::timestamp FROM temp_dsr
        WHERE (t_didsonread_dsr.dsr_dsf_id, t_didsonread_dsr.dsr_readend::timestamp)=(temp_dsr.dsr_dsf_id,temp_dsr.dsr_readend::timestamp)"
) # 4021 #3194

