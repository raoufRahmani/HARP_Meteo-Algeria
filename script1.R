obs=read.csv("~/LIMA/obs/0101/allsyn.csv",header = F)
names(obs)=c('iden','stat','aa','mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb')
head(obs)

obs=obs %>%
  mutate(vaiddate=as.Date(paste0(aa,"/",formatC(mm,width = 2,flag = "0"),"/",formatC(dd,width = 2,flag = "0"),"/"), format ="%Y/%m/%d"))
head(obs)



####_INTERPOLATION_options__########
opt=interpolate_opts(stations = stat,
                     method="nearest",
                     clim_file = "~/LIMA/Harp-scores/clim/AROME_bdap_m01",
                     clim_file_format = "fa",
                     clim_param = "SURFGEOPOTENTIEL",correct_t2m = F)

both=read_forecast(start_date = 20220101,
                   end_date = 20220131,
                   fcst_model = c("arome43" ,"arome46"),
                   parameter=c("T2m" ,"Rh2m","S10m","T850","T500"),
                   lead_time = seq(0,18,6),
                   file_path = list( arome43="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY43",
                                     arome46="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY46"),
                   file_template=list(arome43="{YYYY}{MM}{DD}/FULLPOS_{YYYY}{MM}{DD}00_00{LDT2}",
                                      arome46="{YYYY}{MM}{DD}/PFAL03ALGE01+00{LDT2}"),
                   file_format = "fa",
                   transformation = "interpolate",
                   transformation_opts = opt,
                   vertical_coordinate = "height",
                   by = "1d",
                   return_data = TRUE)
tab=inner_join(both$arome43,both$arome46)
tab
save.image(file = "~/LIMA/Harp-scores/HarpProject/Cy43-46-obs.RData")
table(tab$parameter)
obs
#names(obs)=c('SID','station','Year','Month','Day','lead_time','lat','lon','Obs_S10m','Obs_Ds10m','Obs_T2m','Obs_Rh2m','Obs_Mslp','Obs_Neb',"validdate")
names(obs)=c('SID','station','Year','Month','Day','lead_time','lat','lon','S10m','Ds10m','T2m','Rh2m','Mslp','Neb',"fcdate")

###_Transform_Data_Structure_########
Obs=obs %>%
  pivot_longer(cols =c("S10m","T2m","Rh2m") , names_to = "parameter",names_prefix = "obs",values_to = "Obs")

Obs=Obs[,c("fcdate","lead_time","SID","station","lat","lon","parameter","Obs")]
head(Obs)
table(Obs$parameter)
str(Obs)
##_Join_Obs_With_Forecast__####
finale_tab=inner_join(tab,Obs)
finale_tab
table(finale_tab$parameter)
finale=finale_tab%>%
  mutate(Obs=ifelse(parameter=="Rh2m",Obs/100,Obs))%>%
  mutate(arome43_det=ifelse(parameter=="T2m",arome43_det-273.15,arome43_det))%>%
  mutate(arome46_det=ifelse(parameter=="T2m",arome46_det-273.15,arome46_det))
finale=finale%>%
  mutate(diff43=Obs - arome43_det , diff46= Obs - arome46_det)
scores=finale %>%
  group_by(c(parameter,lead_time))%>%
  #group_by(lead_time)%>%
  summarize(Scores43=mean(diff43),Scores46=mean(diff46))
scores

t=finale%>%
  filter(parameter=="T2m")
scores_t=t %>%
  group_by(lead_time)%>%
  summarize(scores_46_T2m=mean(diff46) ,scores_43_T2m=mean(diff43))

scores_t

ggplot(scores_t)+
  geom_line(aes(x=lead_time , y=scores_46_T2m))+
  geom_line(aes(x=lead_time , y=scores_43_T2m),color="red")
read_obs_convert()
#####___Brouillon_Pour_test__################"""

opt=interpolate_opts(stations = stat,
                     method="nearest",
                     clim_file = "~/LIMA/Harp-scores/clim/AROME_bdap_m01",
                     clim_file_format = "fa",
                     clim_param = "SURFGEOPOTENTIEL",
                     correct_t2m = T)

Cy46 = read_forecast(start_date = 20220101,
                   end_date = 20220102,
                   fcst_model = "arome" ,
                   parameter=c("T2m",'Rh2m'), #, "Rh2m","S10m","T850","T500"),
                   lead_time = seq(0,48,6),
                   file_path = "~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY46",
                   file_template="{YYYY}{MM}{DD}/PFAL03ALGE01+00{LDT2}",
                   file_format = "fa",
                   transformation = "interpolate",
                   transformation_opts = opt,
                   #vertical_coordinate = "NA",
                   by = "1d",
                   return_data = TRUE)

a=read_grid("~/LIMA/Harp-scores/clim/AROME_bdap_m01","SURFIND.TERREMER")
plot_field(a)
#############################################################################
library(harp)

a=read_obs_convert(start_date = 20190217,
                   end_date = 20190217,by = "3h",return_data = T,
                   obs_path = "~/LIMA/obs/0101/01/00/alg",obsfile_template =  "vobs20190217{HH}")

b=a$synop
b
##
v=validdate
str(validdate$validdate)
validdate$validdate=as.POSIXct(validdate$validdate,format="%Y-%m-%d %H:%M:%S")
validdate             

date=Obs%>%
  mutate(fcdate=paste0(validdate," ",formatC(lead_time,width = 2,flag = "0"),":00:00"))
date
date$fcdate=as.POSIXct(date$fcdate,format="%Y-%m-%d %H:%M:%S")
date







