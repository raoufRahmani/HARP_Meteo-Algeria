library(tidyverse)
library(harp)
library(ggplot2)
library(RSQLite)

header=c('iden','stat','aa','mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb','elev')

###_Prepare_the_Observation_files__######

#obs=read.csv("~/LIMA/obs/0101/allsyn.csv",header = F)
#names(obs)=c('iden','stat','aa','mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb')
#obs=read_table("/home/wchikhi/LIMA/obs/0101/all_Synops/syn_sp_dz.txt",col_names = header,na = "NA",progress = T)
obs=read_csv("/home/wchikhi/LIMA/obs/0101/all_Synops/syn_sp_dz.csv",na = "NA", progress = T)
head(obs)
obs=obs %>%
  mutate(vaiddate=as.POSIXct(paste0(aa,"-",formatC(mm,width = 2,flag = "0"),"-",
                                    formatC(dd,width = 2,flag = "0")," ",formatC(hh,width = 2,flag = "0"),":00:00"),
                             tz="UTC", format="%Y-%m-%d %H:%M:%S"))


str(obs)
names(obs)=c('SID','station','Year','Month','Day','lead_time','lat','lon','S10m','D10m','T2m','Rh2m','Pmsl','CCtot','elev',"validdate")
## _add elevation_ 
# stat=read.csv2("~/Documents/station_all.csv",sep=",",header=T, dec=".")
# 
# names(stat)=c("Station","SID","elev","Elev.Baro","Lat","lon","Obs")
# str(stat)
# stat=stat[,c("SID","elev")]
# stat
# obs=left_join(obs,stat)
# obs

#obs=obs[,c("SID","validdate","CCtot","D10m","S10m","T2m","RH2m","Pmsl","lat","lon")]
obs=obs[,c("validdate","SID","lat","lon","elev","CCtot","D10m","S10m","T2m","Rh2m","Pmsl")]
length(table(obs$SID))


filter(stat,SID=="60360")

## Convert to K and % 

obs = obs %>%
  mutate(T2m = T2m + 273.15 , 
         Rh2m = Rh2m / 100 )

obs

Obs=obs %>%
  pivot_longer(cols =c("S10m","T2m","Rh2m") , names_to = "parameter",names_prefix = "obs",values_to = "Obs")

Obs
Obs=Obs[,c("validdate","SID","lat","lon","parameter","Obs")]

head(obs)

synop_params_harp <- data.frame(
  parameter = c( "SID",
                 "validdate",
                 "lat",
                 "lon",
                 "CCtot",
                 "D10m",
                 "S10m",
                 "T2m",
                 "Rh2m",
                 "Pmsl"
  ),
  accum_hours= c( NA,
                  NA,
                  NA,
                  NA,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0
  ),
  units =     c( NA,
                 NA,
                 NA,
                 NA,
                 "oktas",
                 "degrees",
                 "m/s",
                 "K",
                 "fraction",
                 "hPa"
  ),stringsAsFactors=FALSE
)
synop_params_harp

tableee=list(SYNOP=as.tibble(obs),
                     SYNOP_params=as.tibble(synop_params_harp))

tableee
summary(obs)
#write a sqlite 

db <- dbConnect(SQLite(), dbname="~/LIMA/Harp-scores/obs/Database/OBSTABLE_2022.sqlite",overwite)

dbWriteTable(db,name = "SYNOP",as.tibble(obs),overwrite= T)
dbWriteTable(db,name = "SYNOP_params",as.tibble(synop_params_harp),overwrite=T)

dbDisconnect(db)

###_Test_my_table__##
# 
# test=dbConnect(SQLite(),"/home/wchikhi/PROJECTS/Harp/harp-training-2022/data/data/OBSTABLE/OBSTABLE_2018.sqlite")
# dbListTables(test)
# test_syn=dbReadTable(test,"SYNOP_params")
# test_syn
# 
#
# mine <- dbConnect(SQLite(), dbname="~/LIMA/Harp-scores/obs/Database/Jan2022.sqlite",overwite)
# dbListTables(mine)
# mine=dbReadTable(mine,"SYNOP")
# mine
# test_syn
# 
# dbListTables(db)
# mine <- dbConnect(SQLite(), dbname="~/Test.sqlite")
# a=dbReadTable(mine,"obs")
# a
#
#
####_idir_exemlpe_##
# 
# idir=dbConnect(SQLite(),"~/PROJECTS/Harp/idir/FCTABLE_T2m_202107_00.sqlite")
# dbListTables(idir)
# idir_syn=dbReadTable(idir,"FC")
# idir_syn
