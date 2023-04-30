library(harp)
library(dplyr)
library(ggplot2)
library(RSQLite)
rm(list=ls())


a=read_obs_convert(
  start_date = 20190220,
  end_date = 20190220,
  obs_path = "/home/wchikhi/PROJECTS/Harp/harpData/inst/vobs",
  by = "1h",
  obs_format = "vobs",
  obsfile_template = "vobs",
  return_data = T
  
)
a
stat1 = a$synop %>%
   filter(SID==1001)

names(stat1)
obs=read.table("~/LIMA/obs/01/01/00/alg/synop_alg_202201010000.text-ref")
obs
names(obs)=c('SID','stat','aa', 'mm','dd','hh','lat','lon','Sm10','D10m','T2m','RH2m','Pmsl','CCtot')

obs= obs %>%
  mutate(validdate=paste0(aa,formatC(mm,width=2,flag="0"),formatC(dd,width = 2, flag="0"),formatC(hh,width = 2 , flag="0")))
head(obs)
obs=obs[,-(2:6)]
head(obs)



#write a sqlite 

db <- dbConnect(SQLite(), dbname="~/Test.sqlite")

dbWriteTable(db,name = "obs",obs)
dbDisconnect(db)



dbListTables(mine)
mine <- dbConnect(SQLite(), dbname="~/Test.sqlite")
a=dbReadTable(mine,"obs")
a


#

library(harp)
library(harpPoint)
forecast=read_forecast(start_date = 20220101,
                       end_date = 20220101,
                       fcst_model = "arome",
                       parameter = "T2m",
                       by = "1d",
                       lead_time = seq(0,12,6),
                       file_path = "~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY46",
                       file_format = "fa",
                       file_template = "{DD}/PFAL03ALGE01+00{LDT2}",
                       return_data = T
                       )
forecast

harpPoint:: 



  
  


