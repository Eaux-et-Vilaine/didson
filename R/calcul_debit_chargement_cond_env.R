# Calcul de débit au barrage 
# ce script charge les données à partir de SIVA, recalcule les débits à partir
# des coefficients calés par Woimant et Briand (2015). Il créee ensuite la table
# t_env_env_temp et il faut lancer didson_database.sql pour traiter les données
# et modifier les problèmes d'heures.
# Author: cedric.briand
###############################################################################


###############################
# STEP 0 CHARGEMENT DES PACKAGES ET FONCTIONS
################################
load_library=function(necessary) {
  if(!all(necessary %in% installed.packages()[, 'Package']))
    install.packages(necessary[!necessary %in% installed.packages()[, 'Package']], dep = T)
  for(i in 1:length(necessary))
    library(necessary[i], character.only = TRUE)
}

load_library("stringr")
load_library("safer")
load_library("getPass")
load_library("pool")
library(SIVA)

CY<-2022
label<-2022# season is CY-1 - CY
rouille="#87472D"
turquoise="#008080"
orange="#FF8040"
grisbleu="#42428F"
load_library('lubridate')
load_library('RPostgres') # one can use RODBC, here I'm using direct connection via the sqldf package
load_library('sqldf') # mimict sql queries in a data.frame #citation("sqldf")
# loading RPostgresSQL ensures that postgres is used as a default driver by sqldf
# setting options to access postgres using sqldf
load_library('plyr')# join fuction
load_library('ggplot2')# join fuction
load_library('gpclib') # to calculate polygons intersections
load_library('reshape2')
load_library('dplyr')	
load_library('stringr')
load_library('vcd')

if (!exists("mainpass")) pois <- getPass(msg="Main password") else pois <- mainpass

if (!exists("mainpass")) mainpass <- getPass::getPass(msg = "main password")
if (!exists("hostmysql")) {
  hostmysql. <- getPass::getPass(msg = "Saisir host mysql")
  # ci dessous pour ne pas redemander au prochain tour
  hostmysql <- encrypt_string(string = hostmysql., key = mainpass)
} else {
  hostmysql. <- decrypt_string(string = hostmysql, key = mainpass)
}
if (!exists("pwdmysql")) {
  pwdmysql. <- getPass::getPass(msg = "Saisir password mysql")
  pwdmysql <- encrypt_string(string = pwdmysql., key = mainpass)
}  else {
  # pass should be loaded
  pwdmysql. <- decrypt_string(string = pwdmysql, key = mainpass)
}
if (!exists("umysql")) {
  umysql. <- getPass::getPass(msg = "Saisir user mysql")
  umysql <- encrypt_string(string = umysql., key = mainpass)
} else {
  umysql. <- decrypt_string(string = umysql, key = mainpass)
}
if (!exists("hostdistant")) {
  hostdistant. <- getPass::getPass(msg = "Saisir host distant didson")
  hostdistant <- encrypt_string(string = hostdistant., key = mainpass)
} else {
  hostdistant. <- decrypt_string(string = hostdistant, key = mainpass)
}
if (!exists("passworddistant")) {
  passworddistant. <- getPass::getPass(msg = "Saisir password didson")
  passworddistant <- encrypt_string(string = passworddistant., key = mainpass)
} else {
  passworddistant. <- decrypt_string(string = passworddistant, key = mainpass)
}
if (!exists("userdistant")) {
  userdistant. <- getPass::getPass(msg = "Saisir user didson")
  userdistant <- encrypt_string(string = userdistant., key = mainpass)
} else {
  userdistant. <- decrypt_string(string = userdistant, key = mainpass)
}


# attention il faut avaoir définit mainpass <- "xxxxx"

poolsiva <- pool::dbPool(
    drv = RMariaDB::MariaDB(),
    dbname = "archive_IAV",
    host = hostmysql.,
    username = umysql.,
    password = pwdmysql.,
    port=3306
)
pooldidson <- pool::dbPool(
    drv = Postgres(),
    dbname = "didson",
    host = hostdistant.,
    user = userdistant.,
    password = passworddistant.,
    port=5432
)


# end if params$work_with_db
setwd("C:/workspace/didson/R")
datawd<-"C:/workspace/didson/data/" 
datawdy<-str_c(datawd,CY,"/")
imgwd<-"C:/workspace/didson/image/"
imgwdy<-str_c(imgwd,CY,"/")

Sys.setenv(TZ='GMT') # pour prendre en compte le format des heures au barrage


###############################
# STEP 1 CHARGEMENT DES DONNEES DANS SIVA
################################
#########################################################
# Fonction de chargement principal, va chercher dans siva, applique
# une méthode d'arrondi pour les données qui ne sont pas au pas de temps
# changer les dates de début et de fin pour changer la période
###############################################################

debit_barrage <-
    SIVA::load_debit_barrage (
        debut =   as.POSIXct(strptime(str_c(CY-1,"-09-01 00:00:00"),format="%Y-%m-%d %H:%M:%S")),
        fin = as.POSIXct(strptime(str_c(CY,"-05-01 00:00:00"),format="%Y-%m-%d %H:%M:%S")),
        con=poolsiva)
poolClose(poolsiva)
if (!params$work_with_db){
  load(file=str_c("C:/temp/debit_barrage.Rdata"))
}
debit_barrage <- traitement_siva(debit_barrage)
Q12345 <- debit_total(param, param0 = param, debit_barrage)
Q12345$tot_vol <- debit_barrage$tot_vol # volume total au barrage d'Arzal





###############################
# STEP 2 TRAITEMENT DES DONNEES ABERRANTES
################################
dat <- debit_barrage
dat$day<-yday(dat$horodate)
dat$week<-week(dat$horodate)



q <- quantile(dat$niveaumer,c(0.005,0.995),na.rm=TRUE)
dat$depasse <- dat$niveaumer>q[2]|dat$niveaumer<q[1]
dat$diffniveaumer[2:nrow(dat)]<- dat$niveaumer[2:nrow(dat)]-dat$niveaumer[1:(nrow(dat)-1)]
sum(abs(dat$diffniveaumer)>0.6,na.rm=TRUE)

png(file=str_c(imgwdy,"niveaumer",label,".png"),width=600,height=480)
ggplot(dat)+
    geom_point(aes(x=horodate,y=niveaumer))+
    geom_point(aes(x=horodate,y=niveaumer),col="red", 
        data =subset(dat,abs(dat$diffniveaumer)>0.6 & dat$niveaumer< -0.5))
dev.off()

# 2020-2021
dat$niveaumer[dat$niveaumer==-4] <-NA
dat$niveauvilaine[dat$niveauvilaine==-1] <-NA
dat$niveaumerb[dat$niveaumerb==-4] <-NA
dat$niveauvilaineb[dat$niveauvilaineb==-1] <-NA

# 2019-2020
#dat[abs(dat$diffniveaumer)>0.6 & dat$niveaumer< -0.5 & !is.na(dat$diffniveaumer),"niveaumer"]<- -0.5

# identify points using plotly and ggplot
# SOLUTION 1
#library(plotly)
#g <- ggplot(dat)+geom_point(aes(x=horodate,y=niveaumer,col=dmw))+
#		scale_colour_manual("modif",values=c("TRUE"=rouille,"FALSE"=grisbleu))
#ggplotly(g)
# SOLUTION 2 # attention marche pas sur ggplot
getdatefromlocator <- function(){
  myloc <- locator()
  times <- structure(myloc$x,class=c('POSIXt','POSIXct'))
  return(times)
} 
plot(dat$horodate, dat$niveauvilaineb)
getdatefromlocator()

# SOLUTION 3 
#identify(dat$horodate,dat$niveauvilaineb, labels=row.names(dat)) 



dat$diffniveauvilaineb[2:nrow(dat)]<- dat$niveauvilaineb[2:nrow(dat)]-dat$niveauvilaineb[1:(nrow(dat)-1)]
sum(abs(dat$diffniveauvilaine)>0.25, na.rm=TRUE)
g <- ggplot(dat)+geom_point(aes(x=horodate,y=niveauvilaineb), col="orange")
print(g)		


lo<-loess(niveauvilaine~day,data=dat,span=0.1)
dat$p[!is.na(dat$niveauvilaine)]<-predict(lo)
#
#
#dat$pb <- abs(dat$diffniveauvilaineb-dat$p)>0.3
#sum(dat$pb)
#
#
#png(file=str_c(imgwdy,"niveauvilaineb1",label,".png"),width=600,height=480)
#ggplot(dat)+
#    geom_point(aes(x=horodate,y=niveauvilaineb))+
#    geom_point(aes(x=horodate,y=niveauvilaine),col="green", data =subset(dat,cond1))+
#    geom_point(aes(x=horodate,y=niveauvilaineb),col="red", data =subset(dat,cond1))
#dev.off()
#
#dat[cond1,"niveauvilaineb"] <- dat[cond1, "p"]
#
#png(file=str_c(imgwdy,"niveauvilaineb2",label,".png"),width=600,height=480)
#ggplot(dat)+
#    geom_point(aes(x=horodate,y=niveauvilaineb))+
#    geom_point(aes(x=horodate,y=niveauvilaine),col="green", data =subset(dat,cond1))+
#    geom_point(aes(x=horodate,y=niveauvilaineb),col="red", data =subset(dat,cond1))
#dev.off()

# CORRECTION DES NIVEAUX MER
#dat$diffniveaumerb[2:nrow(dat)]<- dat$niveaumerb[2:nrow(dat)]-dat$niveaumerb[1:(nrow(dat)-1)]
#cond1 <- abs(dat$diffniveaumerb)>0.15 &
#    as.Date(dat$horodate)%in%c(ymd("2021-02-18"), ymd("2021-01-05")) &
#    dat$niveaumerb< -0.8

#png(file=str_c(imgwdy,"niveaumerb1",label,".png"),width=600,height=480)
#ggplot(dat)+
#    geom_point(aes(x=horodate,y=niveaumerb))+
#    geom_point(aes(x=horodate,y=niveaumer),col="green", data =subset(dat,cond1))+
#    geom_point(aes(x=horodate,y=niveaumerb),col="red", data =subset(dat,cond1))
#dev.off()
#
#dat[cond1,"niveaumerb"] <- 0
#
#png(file=str_c(imgwdy,"niveaumerb2",label,".png"),width=600,height=480)
#ggplot(dat)+
#    geom_point(aes(x=horodate,y=niveaumerb))+
#    geom_point(aes(x=horodate,y=niveaumer),col="green", data =subset(dat,cond1))+
#    geom_point(aes(x=horodate,y=niveaumerb),col="red", data =subset(dat,cond1))
#dev.off()






# en rouge variation de plus de 25 cm en 10 min

png(file=str_c(imgwdy,"niveauvilaine",label,".png"),width=600,height=480)
ggplot(dat)+
    geom_point(aes(x=horodate,y=niveauvilaineb),col=rouille)+
    geom_point(aes(x=horodate,y=niveauvilaineb),col="red", data =subset(dat,abs(dat$diffniveauvilaine)>0.25))+
    scale_colour_manual("modif",values=c(rouille,grisbleu))+
    geom_line(aes(x=horodate,y=p),col="white")+
    xlab("date")+
    ylab("Niveau Vilaine passe (m) NGF")+
    theme_bw()
dev.off()


# remplacement par des valeurs proches
(w <- which(is.na(dat$niveauvilaineb)))
while(length(w>0)){
  dat[w,"niveauvilaineb"]<-dat[w-1,"niveauvilaineb"]
  w <- which(is.na(dat$niveauvilaineb))
  cat(w,"\n")
}

(w <- which(is.na(dat$niveaumerb)))
while(length(w>0)){
  dat[w,"niveaumerb"]<-dat[w-1,"niveaumerb"]
  w <- which(is.na(dat$niveaumerb))
  cat(w, "\n")}





#identify(dat$horodate,dat$niveauvilaineb, labels=row.names(dat),tolerance = 0.25) 
#
#dat$niveauvilaine[6008:6011]
#dat$niveauvilaineb[c(9750:9900)]
#######################################'#########################
#####################################


#change 2016-2017
#dat$niveauvilaine[dat$horodate<'2016-11-03 23:00:00' & 
#				dat$horodate>'2016-11-03 00:00:00'& dat$niveauvilaine<1.5 ]  <-  1.99 

# change 2017-2018

#dat$niveauvilaine[dat$horodate<'2018-03-23 00:00:00' & dat$horodate>'2018-03-22 00:00:00'
#& dat$niveauvilaine<1.7]<-1.95 


plot(dat$horodate,dat$volet1)
plot(dat$horodate,dat$volet2)
plot(dat$horodate,dat$volet3) 
plot(dat$horodate,dat$volet4)
plot(dat$horodate,dat$volet5)
dat$deltav5[2:nrow(dat)] <- diff(dat$volet5)
with(subset(dat,dat$volet5>3.8 & dat$volet5<4.030 & abs(deltav5)<0.2), points(horodate, volet5, col="red"))
dat$volet5[dat$volet5>3.8 & dat$volet5<4.030 & abs(dat$deltav5)<0.2] <- 4.030
# pas de problèmes en 2020
# correction 2012
#plot(dat$horodate,dat$volet3) 
#dat$volet1[dat$volet1> 4.030] <- 4.030 
#dat$volet1[dat$volet1<1.380] <- 1.380 
#dat$volet2[dat$volet2> 4.030] <- 4.030 
#dat$volet2[dat$volet2<1.380] <- 1.380
#dat$volet3[dat$volet3> 4.030] <- 4.030 
#dat$volet3[dat$volet3<1.380] <- 1.380
#dat$volet4[dat$volet4> 4.030] <- 4.030 
#dat$volet4[dat$volet4<1.380] <- 1.380
#dat$volet5[dat$volet5> 4.030] <- 4.030 
#dat$volet5[dat$volet5<1.380] <- 1.380
#sum(criterev <- as.Date(dat$horodate)>=ymd("2012-09-09")& as.Date(dat$horodate)<=ymd("2012-09-18") & dat$volet5<4.030 & dat$volet5>3.4)
#dat$volet5[criterev] <- 4.030
#sum(criterev <-  dat$volet3<4.030 & dat$volet3>3.5)
#dat$volet3[criterev] <- 4.030
#sum(criterev <- as.Date( dat$volet3<4.030 & dat$volet3>3.4)
#dat$volet3[criterev] <- 4.030
#dat$niveaumer[dat$horodate>'2012-10-09 13:23:33' & dat$horodate<'2012-10-14 04:07:54' ] <- NA
#sum(criterev <-  dat$volet5<4.030 & dat$volet5>1.380 )
#dat$volet5[criterev] <- 4.030
#dat$horodate[dat$volet1<1.38]
#dat$volet3[dat$volet3>4.030]<-4.030
#dat$volet3[dat$volet3<1.380]<-4.030
#dat$volet3[dat$volet3<4.030 & dat$volet3>2.5]<-4.030
#dat$volet3[dat$horodate<dmy(29092017)]<-4.030
#dat$volet3[dat$horodate>dmy(10122017)&dat$horodate<dmy(13012018)&dat$volet3<4.030&dat$volet3>2.5]<-4.030
#dat$volet4[dat$volet4<1.380]<-4.030
#dat$volet5[dat$volet5>4.030]<-4.030
#dat$volet5[dat$volet5<1.380]<-4.030
#dat$volet5[dat$volet5<4.030&dat$volet5>2.5&dat$horodate< 1449300151]<-4.030
#dat$volet5[dat$volet5<4.030&dat$volet5>1.380&dat$horodate< 1450366222&dat$horodate> 1449177142]<-4.030
#dat$volet5[dat$volet5<4.030&dat$volet5>3.6]<-4.030
#dat$volet5[dat$volet5<4.030&dat$volet5>3.8&dat$horodate<1413361029&dat$horodate>1412217677]<-4.030
#dat$volet5[dat$volet5<4.030&dat$volet5>3.6&dat$horodate<1422752847&dat$horodate>1413401863]<-4.030
#dat$volet5[dat$volet5<4.030&dat$volet5>3.8&dat$horodate<1430756309&dat$horodate>1422671179]<-4.030
#dat$volet4[as.Date(dat$horodate)==ymd("2013-11-08")]
# dat[23708,"volet1"]<-4.03;dat[23708,"volet2"]<-4.03;dat[23708,"volet3"]<-4.03;dat[23708,"volet4"]<-4.03
save(dat,file=str_c(datawdy,"dat.Rdata"))
write.table(dat,file=str_c(datawdy,"dat.csv"),sep=";",row.names=FALSE)
load(file=str_c(datawdy,"dat.Rdata"))

###################################################################


# ATTENTION IL FAUT VERIFIER SI LE DEBIT A ETE RECALCULE... SI CE N'EST PAS LE CAS
# LANCER TOUT LE SCRIPT CI-DESSOUS



###############################
# STEP 3 CALCUL DES DEBITS
################################
# Calcul du débit journalier
Q12345 <- debit_total(param, param0 = param, dat)
Q12345$tot_vol <- dat$tot_vol # volume total au barrage d'Arzal
Qj <- debit_journalier(debit_barrage=dat, type = "recalcule")
Q2j <- debit_journalier(debit_barrage=dat, type = "barrage_volume")
Q3j <- debit_journalier(debit_barrage=dat, type = "barrage_debit")

stopifnot(nrow(Qj) == nrow(Q2j))
stopifnot(nrow(Q2j) == nrow(Q3j))
QV <- bind_cols(Qj, Q2j %>% select(-date), Q3j %>% select(-date))   

mQ <-
    reshape2::melt(
        Q12345[, c("horodate",
                "qvanne1",
                "qvanne2",
                "qvanne3",
                "qvanne4",
                "qvanne5")],
        id.vars = "horodate",
        value.name = "Qvanne",
        variable.name = "vanne"
    )
mcond <-
    reshape2::melt(Q12345[, c("horodate",
                "typecalc1",
                "typecalc2",
                "typecalc3",
                "typecalc4",
                "typecalc5")], value.name = "typecalc", id.vars = "horodate")
mQ$vanne <- as.character(mQ$vanne)
mQ$vanne <- gsub("qvanne", "", mQ$vanne)
mQ12345 <- cbind(mQ, "typecalc" = mcond[, 3]) # melted object


png(file=str_c(imgwdy,"debits_inst",label,".png"),width=600,height=480)
ggplot(mQ12345,aes(x=horodate,y=Qvanne,col=typecalc))+geom_jitter(size=0.6)+
    scale_colour_manual("Formule",values=c(
            "canal ifsw (libre)"="red","canal ifsw (noye)"="orange","hmer>hvilaine"=rouille,"orifice noye (ifws) sup1.5"=turquoise,"orifice noye (ifws) inf1.5"="turquoise","vanne fermee"="grey10"))+
    facet_wrap(~vanne)+
    theme(legend.justification=c(1,0), legend.position=c(1,0))
dev.off()

     


####################################
# GRAPHIQUE DE COMPARAISON DES DEBITS ET DEBITS DE CRAN
#####################################
#Qj$Qtot_vol[Qj$Qtot_vol>2000]<-NA # problème pour 2008-2009
png(file=str_c(imgwdy,"debits_ajustes",label,".png"),width=600,height=480)
plot(Q3j$date,Q3j$debit_moyen_cran,type="l",col=rouille,ylab="Debit (m3/s)",xlab="Date",ylim=c(0,max(c(Qj$debit_moyen_recalcule,Q3j$debit_barQ),na.rm=TRUE)))
points(Qj$date,Qj$debit_moyen_recalcule,type="l",col=grisbleu)
points(Q3j$date,Q3j$debit_barQ,col="black",type="l",lty=2)
legend("topleft",legend=iconv(c("Cran","Débit recalculé","Débit automate Barrage"),"UTF8"),col=c(rouille,"blue","black"),lty=c(1,1,2))
dev.off()


#png(file=str_c(imgwdy,"debits_ajustes_zoom",label,".png"),width=600,height=480)
#plot(Qj$date,Qj$debit_moyen_cran,type="l",col=rouille,ylab="Debit (m3/s)",xlab="Date",ylim=c(0,700))
#points(Qj$date,Qj$debitvilainecalcule,type="l",col=grisbleu)
#points(Qj$date,Qj$Qtot_vol,col="black",type="l",lty=2)
#legend("topleft",legend=iconv(c("Cran","Débit recalculé","Débit automate Barrage"),"UTF8"),col=c(rouille,"blue","black"),lty=c(1,1,2))
#dev.off()

####################################
# GRAPHIQUE DES CONDITIONS DE DEBIT
#####################################
c1<-as.data.frame(table(Q12345$typecalc1))
c2<-as.data.frame(table(Q12345$typecalc2))
c3<-as.data.frame(table(Q12345$typecalc3))
c4<-as.data.frame(table(Q12345$typecalc4))
c5<-as.data.frame(table(Q12345$typecalc5))
#unique(c(as.character(c1$Var1),as.character(c2$Var1),as.character(c3$Var1),as.character(c4$Var1),as.character(c5$Var1)))
c0<-data.frame("Var1"=c("canal ifsw (libre)","canal ifsw (noye)","hmer>hvilaine","orifice noye (ifws) sup1.5","orifice noye (ifws) inf1.5","vanne fermee"))
rowvarcat <- c("vanne1","vanne2","vanne3","vanne4","vanne5")
columnvarcat <- c("cl","cn","m>v","n1.5","ni1.5","f")
names=c("Vanne", "Type debit")
# Il manque parfois certaines valeurs un rbind ne marche pas alors
# Un merge à plusieurs colonnes se fait bien en sql ci-dessous
temp<-t(sqldf::sqldf('select c1."Freq",c2."Freq",c3."Freq",c4."Freq",c5."Freq"
            from c0 full outer join c1 on c1."Var1"=c0."Var1" 
            full outer join c2 on c2."Var1"=c0."Var1"
            full outer join c3 on c3."Var1"=c0."Var1"
            full outer join c4 on c4."Var1"=c0."Var1"
            full outer join c5 on c5."Var1"=c0."Var1"
            ', drv="SQLite"))
rownames(temp) <- rowvarcat
colnames(temp) <- columnvarcat
temp[is.na(temp)]<-0
conditions_vannes <- as.table(
    temp)				
values <- c(conditions_vannes)

#dimnames(conditions_vannes)[[1]]<-
#dimnames(conditions_vannes)[[2]]<-
proportions <- round(prop.table(conditions_vannes , 2 )*100)
dims <- c(5,6) #columns then rows
TABS <- structure( values, .Dim = as.integer(dims), .Dimnames = structure( list(rowvarcat,columnvarcat ),
        .Names = c(names) ) , class = "table") 

PROPORTIONS <- structure( c(proportions), .Dim = as.integer(dims), .Dimnames = structure( list(rowvarcat,columnvarcat ),
        .Names = c(names) ) , class = "table") 

TABSPROPORTIONS <- structure( c(paste(proportions,"%","\n", "(",values,")",sep="")), .Dim = as.integer(dims), .Dimnames = structure( list(rowvarcat,columnvarcat ),
        .Names = c(names) ) , class = "table") 
png(file=str_c(imgwdy,"conditions_vannes",label,".png"),width=600,height=480)
mosaic(TABS, pop=FALSE,main="Conditions debit",direction=c("v","h"))
labeling_cells(text=TABSPROPORTIONS , clip=FALSE)(TABS )
dev.off()



#############
#Débits des volets
############

mQvo<-Q12345[, c("horodate",
            "qvolet1",
            "qvolet2",
            "qvolet3",
            "qvolet4",
            "qvolet5")] %>%
    melt(id.vars="horodate",value.name="Qvolet",variable.name ="volet")
mQvo$volet<-as.character(mQvo$volet)
mQvo$volet<-gsub("Qvolet","",mQvo$volet)
mQvo$Qvolet[mQvo$Qvolet==0]<-NA

Q12345$Qvolet <- rowSums(Q12345[, c(
            "qvolet1",
            "qvolet2",
            "qvolet3",
            "qvolet4",
            "qvolet5")]) * 600

png(file=str_c(imgwdy,"debitvolet",label,".png"),width=600,height=480)
ggplot(mQvo,aes(x=horodate,y=Qvolet,colour=Qvolet))+geom_point(size=1.5)+theme_bw()+
    scale_colour_gradient( low="yellow",high="red")+
    facet_wrap(~volet)+
    theme(
        panel.background = element_rect(fill = "white"),
        panel.grid.minor = element_line(linetype = "dotted"),
        legend.position = "none",
        strip.background =element_rect(fill=grisbleu),
        strip.text=element_text(colour="white")
    )+
    ylab(expression(paste(italic("Debit volet "),(m^3*s^-1))))+
    xlab("Mois")
dev.off()



###################################################################
# IMPORT DES DONNES DE TURBIDITE
###################################################################
# utilise la classe Tabkesiva pour une seule table

ta <- new("tablesiva",
    table="b_ferel_mesure",
    nom="turbidite",
    tag=	as.integer(9042),
    debut=as.POSIXct(strptime(str_c(CY-1,"-09-01 00:00:00"),format="%Y-%m-%d %H:%M:%S")),
    fin=as.POSIXct(strptime(str_c(CY,"-05-01 00:00:00"),format="%Y-%m-%d %H:%M:%S"))
)
tur <- loaddb(ta)@rawdata
tur$date <- as.Date(tur$Horodate)




stopifnot(nrow(Qj)==nrow(debj))
#dev.off()
debitjour <- cbind(Qj,"debitvoletcalcule"=debj$debitvoletcalcule)
#nrow(debitjour)
debitjour=left_join(debitjour, tur[,c("date","turbidite")])
#nrow(debitjour)
#colnames(debitjour)

#debitjour est une table temporaire.

sqldf("drop table if exists did.debitjour")
sqldf("create table did.debitjour as select * from debitjour")

Q12345$volvannecalcule<-Q12345$Qvanne*600
Q12345$volvilaine<-rowSums(Q12345[,c("volvannecalcule","volvoletcalcule","tot_vol_passe","tot_vol_siphon")])
Q12345$Qvilaine<-Q12345$volvilaine/600
Q12345$Qvolet<-Q12345$volvoletcalcule/600
Q12345$Qpasse<-Q12345$tot_vol_passe/600
Q12345$Qsiphon<-Q12345$tot_vol_siphon/600

sqldf("drop table if exists did.t_env_env_temp")
sqldf("create table did.t_env_env_temp(
        env_id serial primary key,
        env_time timestamp without time zone,
        env_volet1 numeric,
        env_volet2 numeric,
        env_volet3 numeric,
        env_volet4 numeric,
        env_volet5 numeric,
        env_vanne1 numeric,
        env_vanne2 numeric,
        env_vanne3 numeric,
        env_vanne4 numeric,
        env_vanne5 numeric,
        env_niveauvilaine numeric,
        env_niveaumer numeric,
        env_debitvilaine numeric,
        env_debitmoyencran numeric,				
        env_debitvanne numeric,
        env_debitvolet numeric,
        env_debitpasse numeric,
        env_debitsiphon numeric,
        env_volumetotal numeric,				
        env_volvanne numeric,
        env_volvolet numeric,
        env_volpasse numeric,
        env_volsiphon numeric,
        env_qvanne1 numeric,
        env_qvanne2 numeric,
        env_qvanne3 numeric,
        env_qvanne4 numeric,
        env_qvanne5 numeric,
        env_qvolet1 numeric,
        env_qvolet2 numeric,
        env_qvolet3 numeric,
        env_qvolet4 numeric,
        env_qvolet5 numeric
        )");
stopifnot(nrow(dat)==nrow(Q12345))
stopifnot(nrow(Qvo12345)==nrow(Q12345))
datexp<-cbind(
    dat[,c("horodate",
            "volet1",
            "volet2",             
            "volet3",      
            "volet4",           
            "volet5",            
            "vanne1",            
            "vanne2",       
            "vanne3",           
            "vanne4",             
            "vanne5",
            "niveauvilaine",
            "niveaumer")],
    Q12345[c("Qvilaine",# env_debitvilaine =débit correspondant à débit volet recaculé +vanne recalculé+passe+siphon
            "debit_moyen_cran",
            "Qvanne", # env_debitvanne
            "Qvolet", # env_debitvolet
            "Qpasse",#env_debitpasse
            "Qsiphon",#env_debitsipon
            "volvilaine", # env_volumetotal
            "volvannecalcule", #env_volvanne
            "volvoletcalcule",	# env_volvolet
            "tot_vol_passe",# env_volpasse	
            "tot_vol_siphon",# env_volsiphon
            "qvanne1",
            "qvanne2",
            "qvanne3",
            "qvanne4",
            "qvanne5")],
    Qvo12345[c("Qvolet1",
            "Qvolet2",
            "Qvolet3",
            "Qvolet4",
            "Qvolet5"
        )])
sqldf("
        insert into did.t_env_env_temp(
        env_time,
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
        env_qvanne1 ,
        env_qvanne2 ,
        env_qvanne3 ,
        env_qvanne4 ,
        env_qvanne5 ,
        env_qvolet1 ,
        env_qvolet2 ,
        env_qvolet3 ,
        env_qvolet4 ,
        env_qvolet5 
        ) select * from datexp"	)

##########################################################
# ===========>voir ligne 170 script  didson_database.sql
# INTERGRATION DES DONNEES DE did.t_env_env_temp DANS t_env_env ;
# PUIS INTEGRATION DE debitjour dans did.t_envjour_enj
##########################################################

