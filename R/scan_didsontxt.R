# scan_didsontxt
# fichier de lecture des fichiers d�pouillement, voir fiche recette
# Author: cedric.briand
#############################################

require(stacomirtools)
require(stringr)
require(plyr)
require("safer")
require("getPass")
require('DBI') # mimict sql queries in a data.frame
require('RPostgres') # one can use RODBC, here I'm using direct connection via the sqldf package
setwd("C:/workspace/didson")
if (!exists("userdistant") | !exists("passworddistant")) stop('Il faut configurer Rprofile.site avec les bons mots de passe et user')
pois <- getPass(msg="Main password")
host <- decrypt_string(hostdistant,pois)
user <- decrypt_string(userdistant,pois)
password<- decrypt_string(passworddistant,pois)



####################################
# Lecture des fichers txt provenant du didson.
#####################################
#install.packages("R.utils")

datawd <- "C:/temp/didson/2022-2023/f/"
#datawd<-"F:/projets/devalaison/fichier_txt_pb/"
listoffiles <- list.files(str_c(datawd)) # list of files
listoffiles <- listoffiles[grep(".txt",listoffiles)]
chemins <- str_c(datawd,listoffiles)
progress<-winProgressBar(title = "Chargement des fichiers texte",
		label = "progression %",
		min = 0,
		max = length(chemins), 
		initial = 0,
		width = 400)

#----- chargement des fichiers déjà rentrés pour vérification --------------------------------------

con <- dbConnect(Postgres(), 		
		dbname="didson", 		
		host=host,
		port=5432, 		
		user= user, 		
		password= password)
drr_id <- dbGetQuery(con, "select drr_id from did.t_didsonreadresult_drr 
join did.t_didsonfiles_dsf on drr_dsf_id=dsf_id where dsf_timeinit>'2013-09-01'")
fichiers_dans_la_base <- vector() # vecteur vide qui stockera les valeurs de fichiers deja rentres
#i=155
#000000000000000000000000000000000000000 loop
for (i in 1:length(chemins)){
	result<-list()
	setWinProgressBar(progress,i,label=listoffiles[i])      
# ouverture de la connection
	con  <- file(chemins[i], open = "r")
# la fonction readLines renvoit un vecteur charact�re, un �l�ment par ligne
	re<- readLines(con,warn = FALSE)
	close(con) # je referme la connexion
	
	# background substraction in some files, removing it
	if (length(grep("Background Subtraction ENABLED",re))>0){
		re<-re[-((grep("Background Subtraction ENABLED",re)-1):grep("Factor A",re))]
	}
	poissons_start<-which(re=="*** Manual Marking (Manual Sizing:  Q = Quality, N = Repeat Count) ***")+4
	poissons_end<-which(re=="*** Source File Key ***")-3
	# probleme de format de fichier
	if (length(poissons_end)==0) {
		poissons_end<-which(re=="END")-1
	}
	# certains fichiers n'ont pas de poissons, �a ne sert � rien de les charger...;
	if (poissons_end>=poissons_start) {
#==================================================
# I Extraction des donn�es concernant le r�sum� du fichier
#==================================================	
# Total correspond aux quatre premieres lignes.
		total<-killfactor(data.frame("count"=sapply(strsplit(re[1:4],"="),"[[",1),
						"number"=as.numeric(sapply(strsplit(re[1:4],"="),"[[",2))))
		total2<-killfactor(as.data.frame(t(total[,2,drop=FALSE])))
		colnames(total2)<-total$count
		result[["total"]]<-total2
# Une liste est un vecteur de mode liste, on peut utiliser c( pour concatener.
# comme le format diff�re entre chaque ligne, il faut l'harmoniser...
#==================================================
# II Extraction des données concernant l'Image
#==================================================
		
		if (length(grep("CSOT Min Cluster",re)) == 1) {
			didson<-c(strsplit(re[6],"="),
					strsplit(re[7],": "),
					strsplit(re[8],"="),
					strsplit(re[9],"="),
					strsplit(re[10],"="),
					strsplit(re[11],"="),
					strsplit(re[12],"="),
					strsplit(re[14],"="),
					strsplit(re[15],"="))
		} else {
			didson<-c(strsplit(re[6],"="),
					strsplit(re[7],": "),
					strsplit(re[8],"="),
					strsplit(re[9],"="),
					strsplit(re[10],"="),
					list(c("CSOT Min Cluster",NA)), # some files don't have a CSOT
					list(c("CSOT Min Threshold",NA)),
					strsplit(re[11],"="),
					strsplit(re[12],"=")
			)
		}
# il peut y avoir des lignes avec un seul élément, ce qui fait planter la ligne d'après,
# les lignes à un élément deviennent des lignes à 2.
#didson[[which(sapply(didson,function(X) length(X))==1)]]<-
#		c(didson[[which(sapply(didson,function(X) length(X))==1)]],"?")
		didson <- data.frame("parm"=gsub("\\s","",sapply(didson,"[[",1)),
				"value"=gsub("\\s","",sapply(didson,"[[",2)))
		didson<-killfactor(didson)	
		didson$parm[c(4,5,7)]<-str_c(didson$parm[c(4,5,7)],"_db")
		didson$parm[6]<-str_c(didson$parm[6],"_cm^2")
		didson$value[c(4,5,7)]<-as.numeric(gsub("dB","",didson$value[c(4,5,7)]))/10
		didson$value[6]<-gsub("cm\\^2","",didson$value[6])
		didson$value[6]<-gsub("cm\\^2","",didson$value[6])
		didson$parm[c(8,9)]<-str_c(didson$parm[c(8,9)],"_m")
		didson$value[c(8,9)]<-gsub("m","",didson$value[c(8,9)])	
		didson2<-killfactor(as.data.frame(t(didson)[2,,drop=FALSE]))
		colnames(didson2)<-didson$parm
		didson2[,c(4:9)]<-as.numeric(didson2[,c(4:9)])
		result[["didson"]]<-didson2
		
#==================================================
# III Extraction des données de *** Manual Marking.... ***
#==================================================
# A partir de maintenant, la référence des lignes va dépendre du nombre de poissons dans 
# le tableau, il faut aller chercher les références des lignes
		poissons<-re[poissons_start:poissons_end]
		di<-matrix(NA,nrow=length(poissons),ncol=31) 
		for (k in 1:length(poissons)){
			li<-strsplit(poissons[k]," ")[[1]][strsplit(poissons[k]," ")[[1]]!=""]
			# missing species field
			if  (length(li)>=26){
				if(li[26]%in%c("Running","Backsliding","Hanging","Tethered","Milling")) li<-c(li[1:25],"",li[26:length(li)])
			}
			if (length(li)>31) li[31]<-paste(li[31:length(li)],collapse=" ")
			di[k,1:min(31,length(li))]<-li[1:min(31,length(li))]
		}
		colnames(di)<-c("File","total","frame","dir","radius_m","theta","l_cm","dr_cm","ldr","aspect","time","date",
				"latitude1","latitude2","latitude3","latitude4","latitude_unit","longitude1","longitude2","longitude3","longitude4","longitude_unit","pan","tilt","roll","species","motion","move","q","n","comment")
		di<-killfactor(as.data.frame(di))	
#transformation des nombres en numeriques
		di[,c(1:3,5:8,23:25,29:30)]<-apply(di[,c(1:3,5:8,23:25,29:30)],2,function(X) as.numeric(X))
		di<-di[!is.na(di$File),]
		result[["poissons"]]<-di
		# Some files have been manually corrected but not the sums.
		if(result$total[1,1]!=nrow(result$poissons)) print(str_c("fichier : ",listoffiles[i]," le nombre de poissons ne correspond pas au total, correction manuelle \n"))
		
		result[["total"]][1,1]=sum(di$dir=="Up")-sum(di$dir!="Up") # Total Fish
		result[["total"]][1,2]=sum(di$dir=="Up") # Upstream
		result[["total"]][1,3]=sum(di$dir!="Up") # Downstream
#==================================================
# IV Extraction des donn�es de *** source file key ***
#==================================================
 # certains fichiers n'ont plus les infos de *** source file key ***   
if (length(re)>=poissons_end+8){
		filekey<-re[(poissons_end+5):(poissons_end+8)]
		# gsub("\\s","" enl�ve tous les espaces qu'ils soient \t tabulation ou blanc
		# regexpr recherche la positon d'un caract�re
		path<-gsub("\\s","",substr(filekey[1],regexpr("Source File Name:",filekey[1])[1]+17,nchar(filekey[1])))
		source_file_date<-gsub("\\s","",substr(filekey[2],regexpr("Source File Date:",filekey[2])[1]+20,nchar(filekey[1])))
		source_file_start<-gsub("\\s","",substr(filekey[3],regexpr("Source File Start:",filekey[3])[1]+20,nchar(filekey[1])))
		source_file_end<-gsub("\\s","",substr(filekey[4],regexpr("Source File End:",filekey[4])[1]+20,nchar(filekey[1])))
	} else {
		path <- ""
		source_file_date<-""
		source_file_start<-""
		source_file_end<-""
	}
		
		# on va chercher la date du dison... le nom du fichier correspond � cette date plus les caract�res jusqu'� la fin
		# le probl�me c'est que le nom qui est dans source file key peut �tre le faux quand l'option 
# merge append open file to existing file est coch�e
if (regexpr("FC_CSOT",didson[2,2])==-1) num=regexpr("FC_",didson[2,2])[1]+3 else num=regexpr("FC_CSOT_",didson[2,2])[1]+8
# certains fichiers n'ont pas d'heure...
if (grepl("_HF_",didson[2,2])==0){
	name<-substr(didson[2,2],num,regexpr("_HF",didson[2,2])+2)
} else {
	name<-substr(didson[2,2],num,regexpr("_HF_",didson[2,2])+2)
}
	

		name<-gsub(".txt","",name)
		result[["filekey"]]<-data.frame(
				"filename"=name,
				"path"=path,
				"date"=source_file_date,
				"start"=source_file_start,
				"end"=source_file_end
		)

		t_didsonfiletemp_dsft<-	cbind(result[["filekey"]],
				result[["didson"]],
				result[["total"]])
		rownames(t_didsonfiletemp_dsft)<-i
		cf<-t_didsonfiletemp_dsft$CountFileName
		id<-substr(cf,regexpr("FC",cf),nchar(cf)-4)
		t_didsonfiletemp_dsft$id<-id
		t_poissonsfile_psf<-result[["poissons"]]
		t_poissonsfile_psf$id<-id
		# Teste si le nom du fichier est d�j� dans la base, renverra une alerte en fin de boucle pour tous les noms de fichiers
		if (t_didsonfiletemp_dsft$id%in%drr_id$drr_id) fichiers_dans_la_base<- c(fichiers_dans_la_base,listoffiles[i])
		# en fin de boucle empilement des fichiers		
		if (i==1){
			all_t_poissonsfiletemp_psf<-t_poissonsfile_psf
			all_t_didsonfiletemp_dsft<-t_didsonfiletemp_dsft
		} else{		
			all_t_poissonsfiletemp_psf<-rbind(all_t_poissonsfiletemp_psf,t_poissonsfile_psf)
			all_t_didsonfiletemp_dsft<-rbind(all_t_didsonfiletemp_dsft,t_didsonfiletemp_dsft)		
		}
	} # end if poissons_end>=poissons_start
}
if (length(fichiers_dans_la_base)>0) {
	print("Attention les fichiers suivants ont déjà été rentrés !!! \n")
	print (fichiers_dans_la_base)
} 


close(progress)


# -- fin de  lecture des fichers txt provenant du didson.------------------------------------------




# Intégration des données dans la base ------------------------------------------------------------



colnames(all_t_poissonsfiletemp_psf) <-
  tolower(gsub("\\s", "", str_c(
    "psf_", colnames(all_t_poissonsfiletemp_psf)
  )))
colnames(all_t_didsonfiletemp_dsft) <-
  tolower(gsub("\\s", "", str_c(
    "dsft_", colnames(all_t_didsonfiletemp_dsft)
  )))
colnames(all_t_didsonfiletemp_dsft)[11] <- "dsft_csotmincluster_cm2"
colnames(all_t_didsonfiletemp_dsft)[18] <- "dsft_unknown"
stopifnot(sum(duplicated(all_t_didsonfiletemp_dsft$dsft_id)) == 0)
#all_t_didsonfiletemp_dsft[duplicated(all_t_didsonfiletemp_dsft$dsft_id),]
#Creation des tables temporaires.

con <- dbConnect(Postgres(), 		
    dbname="didson", 		
    host=host,
    port=5432, 		
    user= user, 		
    password= password)
#DBI::dbExecute(con, "drop table if exists did.t_didsonfiletemp_dsft")
tt <- DBI::Id(schema = "did",    table = "t_didsonfiletemp_dsft")
DBI::dbWriteTable(con, name=tt,  value = all_t_didsonfiletemp_dsft, overwrite = TRUE)
ttp <- DBI::Id(schema = "did",    table = "t_poissonsfiletemp_psf")
DBI::dbWriteTable(con, name=ttp,  value = all_t_poissonsfiletemp_psf, overwrite = TRUE)



# Mise à jour des tables finales.
# fait un insert into à partir des données des tables temporaires
# Mais lancer l'ensemble du script sql scan_didsonfile.sql


######################################################
# bout de script pour fichiers manquants (A ne lancer que pour ajouter les fichiers supplémentaires si erreur
########################################################


con <- dbConnect(Postgres(), 		
    dbname="didson", 		
    host=host,
    port=5432, 		
    user= user, 		
    password= password)
#DBI::dbExecute(con, "drop table if exists did.t_didsonfiletemppb_dsft")
tt <- DBI::Id(schema = "did",    table = "t_didsonfiletemppb_dsft")
DBI::dbWriteTable(con, name=tt,  value = all_t_didsonfiletemp_dsft, overwrite = TRUE)
ttp <- DBI::Id(schema = "did",    table = "t_poissonsfiletemppb_psf")
DBI::dbWriteTable(con, name=ttp,  value = all_t_poissonsfiletemp_psf, overwrite = TRUE)


