library(harp)
library(openxlsx)
library(tidyverse)
library(Rfa)
library(Rgrib2)
rm(list=ls())
stat1=read.csv("~/station.csv")
stat=stat[,-1]
stations=read.csv("~/Documents/station_all.csv",dec=".")
stat=stations[,c("Identifiant.WIGOS","Eléva.Station")]
names(stat)=c("SID","elev")
str(stat)
stat=left_join(stat1,stat)
stat$elev=as.numeric(stat$elev)
opt=interpolate_opts(stations = stat,
                     method="nearest",
                     clim_file = "~/LIMA/Harp-scores/clim/AROME_bdap_m01",
                     clim_file_format = "fa",
                     clim_param = "SURFGEOPOTENTIEL",correct_t2m = T)

stat$elev=stat$elev
head(stat)
surfgeo=read_grid("~/LIMA/Harp-scores/clim/AROME_bdap_m01","SURFGEOPOTENTIEL")
plot_field(surfgeo)
forecast1=forecast
                  
forecast=read_forecast(start_date = 20220101,
                  end_date = 20220101,
                  fcst_model = "arome" ,
                  parameter=c("T2m") ,#,"Rh2m","S10m","T850"),
                  lead_time = seq(0,18,6),
                  file_path = "~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY46",
                  file_template="{YYYY}{MM}{DD}/PFAL03ALGE01+00{LDT2}",
                  file_format = "fa",
                  transformation = "interpolate",
                  transformation_opts = opt,
                  vertical_coordinate = "height",
                  by = "1d",
                  return_data = TRUE)
#      output_file_opts = sqlite_opts(path = "~"))


forecast
forecast$arome$arome_det
arome=forecast$arome
forecast_old=forecast
arome
obs=read.table("~/LIMA/obs/01/00/alg/synop_alg_202202010000.text")
head(obs)
str(obs)
names(obs)=c('iden','stat','aa',   'mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb')

head(forecast)
rm(forecast)

forecast=read_forecast(start_date = 20220101,
                       end_date = 20220101,
                       fcst_model = "arome" ,
                       parameter=c("T850"),
                       lead_time = 0, #seq(0,48,6),
                       file_path = "~/LIMA/Harp-scores/GRIB",
                       file_template="grib_2022020100_0000",
                       file_format = "grib",
                       transformation = "interpolate",
                       transformation_opts = interpolate_opts(correct_t2m = F),
                       vertical_coordinate = "pressure",
                       by = "1d",
                       return_data = TRUE,
                       output_file_opts = sqlite_opts(path = "~"))

head(forecast)

par=as_harp_parameter("t","t",level=0,level_type = "unknown")

a=read_det_interpolate(start_date = 2022020100,
                     end_date = 2022020100,
                     det_model = "arome" ,
                     parameter=c("2t"),
                     lead_time = seq(0,18,3),
              #       vertical_coordinate = "pressure",
                     correct_t2m = T,
                     file_path = "/onm/dem/home/wchikhi/FULLPOS/GRIB",
                     file_template="grib_{YYYY}{MM}{DD}00_00{LDT2}",
                     file_format = "grib",
                     stations = stat,
                     interpolation_method = "nearest",
                     return_data = T,
                     sqlite_path = "~/RUN"
                     )
write.csv(stat,"~/station.csv")
a
a$forecast
a$forecast=a$forecast-273.15
a$forecast

t2m=obs[,c("iden","lon","lat","t2m")]
names(t2m)=c("SID","lon","lat","obs_t2m")

head(t2m)

scores=left_join(a,t2m)
str(scores)
scores=scores %>%
  mutate(diff=a$forecast - obs_t2m)
scores
table(a$SID)
as.tibble(stat)
library(dplyr)

t=scores%>%
  filter(parameter=="2t")

head(t)

ggplot(data=scores)+
  geom_line(aes(x=))
head(obs)
stat=obs[,c("V1","V2","V7","V8")]
head(stat)
names(stat)=c("SID","Station","lat","lon")
a=read_grid("~/LIMA/Harp-scores/GRIB/GRIBPFAL03ALGE01+0000","t",vertical_coordinate = "height")

plot_field(a[[1]])
a=read_det_interpolate(start_date = 2022010100,
                       end_date = 2022010100,
                       det_model = "arome" ,
                       parameter="t2m",
                       lead_time = seq(0,6,6),
                       stations = stat,
                       file_path = "~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY43",
                       file_template="{YYYY}{MM}{DD}/PFAL03ALGE01+00{LDT2}",
                       file_format = "fa",
                       clim_file = "~/LIMA/Harp-scores/clim/AROME_bdap_m01",
                       clim_format = "fa",correct_t2m = F,by = "1d",keep_model_t2m = T,
                       interpolation_method ="nearest",return_data = T)
                     





aplot_field(forecast %>% 
             filter(parameter == "T2m"),fcst_model ="arome",plot_col = "arome_det",lead_time = 06)

################################################################################

library(DBI)
on <- dbConnect(drv=RSQLite::SQLite(), dbname="~/FCTABLE_2t_202202_00.sqlite")
dbListTables(on)
t=dbReadTable(on,"FC")
t
a=Rfa::FAopen("~/LIMA/Harp-scores/clim/AROME_bdap_m01")
a$list$name
read_grid("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY46/01/PFAL03ALGE01+0000"
          ,parameter = "t2m",transformation = "interpolate",transformation_opts = opt)


opt=interpolate_opts(stations = stat,
                     method="nearest",
                     clim_file = "~/LIMA/Harp-scores/clim/AROME_bdap_m01",
                     clim_file_format = "fa",
                     clim_param = "SURFGEOPOTENTIEL")


a=read_grid("~/LIMA/Harp-scores/clim/AROME_bdap_m01","SURFGEOPOTENTIEL")
plot_field(a)
####
a=read_grid("~/LIMA/Harp-scores/clim/PGD_ARO_SFX.fa","SFX.ZS")
plot_field(a)

température=forecast1 %>%
  filter(parameter=="T2m")
temp=température$arome
str(temp)
temp$fcdate=as.Date(temp$fcdate)
temp=temp[,c("fcdate","lead_time","SID","lon","lat","arome_det")]
head(temp)

######################################
obs=read.csv("~/LIMA/obs/0101/allsyn.csv",header = F)
names(obs)=c('iden','stat','aa','mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb')
head(obs)

obs=obs %>%
  mutate(vaiddate=as.Date(paste0(aa,"/",formatC(mm,width = 2,flag = "0"),"/",formatC(dd,width = 2,flag = "0"),"/"), format ="%Y/%m/%d"))
head(obs)
names(obs)=c('SID','station','Year','Month','Day','Hour','lat','lon','Obs_S10m','Obs_Ds10m','Obs_T2m','Obs_Rh2m','Obs_Mslp','Obs_Neb',"validdate")
head(obs)
t2m_obs=obs[,c("validdate","Hour","SID","lon","lat","Obs_T2m")]
names(t2m_obs)=c("fcdate","lead_time","SID","lon","lat","Obs_T2m")
head(t2m_obs)
#t2m_obs$SID=as.integer(t2m_obs$SID)
str(t2m_obs)
t2m=inner_join(temp,t2m_obs)
t2m = t2m %>%
  mutate(arome_det = arome_det -273.15)
t2m = t2m %>%
  mutate(diff=arome_det - Obs_T2m)
t2m_scores = t2m  %>%
  group_by(lead_time) %>%
  summarise(T2m=mean(diff))
t2m_scores

write.csv2(t2m_scores,"~/LIMA/scores/46_t2m_obs.csv")
##



levels(obs$SID)





save.image("~/LIMA/Harp-scores/HarpProject/image.RData")


