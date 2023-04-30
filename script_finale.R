library(tidyverse)
library(harp)

###_Prepare_the_Observation_files__######

obs=read.csv("~/LIMA/obs/0101/allsyn.csv",header = F)
names(obs)=c('iden','stat','aa','mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb')
head(obs)
obs=obs %>%
  mutate(vaiddate=as.POSIXct(paste0(aa,"-",formatC(mm,width = 2,flag = "0"),"-",
                                    formatC(dd,width = 2,flag = "0")," ",formatC(hh,width = 2,flag = "0"),":00:00"),
                            tz="UTC", format="%Y-%m-%d %H:%M:%S"))
obs$validdate
str(obs)
names(obs)=c('SID','station','Year','Month','Day','lead_time','lat','lon','S10m','Ds10m','T2m','Rh2m','Mslp','Neb',"validdate")

Obs=obs %>%
  pivot_longer(cols =c("S10m","T2m","Rh2m") , names_to = "parameter",names_prefix = "obs",values_to = "Obs")

Obs=Obs[,c("validdate","lead_time","SID","station","lat","lon","parameter","Obs")]

head(Obs)
### write an sqlite file for Observations 
library(RSQLite)
conn <- dbConnect(RSQLite::SQLite(), "~/")
a=tibble::as_tibble(forecast$arome)
a
str(a)
dbWriteTable(conn, "cars_data",a)



##_Read_Stations_List##############"""""
stat1=stat
stat=read.csv2("~/station.csv",sep=",",header=T, dec=".")
str(stat)
stat

####_INTERPOLATION_options__########

opt=interpolate_opts(stations = stat ,
                     method="nearest",
                     clim_file = "~/LIMA/Harp-scores/clim/AROME_bdap_m01",
                     clim_file_format = "fa",
                #     clim_param = c("SURFIND.TERREMER"),
                     correct_t2m = T,
                     use_mask = F)
###_Add_a_Surf_Terre_Mer_Index_au Stations D'obs
##1:Terre -- 0:Mer

#####___read_forecast__###################
sqlitedir="~/LIMA/Harp-scores/R-output/sqlite/"
forecast=read_forecast(start_date = 20220101,
                   end_date = 20220131,
                   fcst_model = c("arome43" ,"arome46"),
                   parameter=c("T2m","Rh2m","S10m"),
                   lead_time = seq(0,48,6),
                   file_path = list( arome43="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY43",
                                     arome46="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY46"),
                   file_template=list(arome43="{YYYY}{MM}{DD}/FULLPOS_{YYYY}{MM}{DD}00_00{LDT2}",
                                      arome46="{YYYY}{MM}{DD}/PFAL03ALGE01+00{LDT2}"),
                   file_format = "fa",
                   transformation = "interpolate",
                   file_format_opts = harpIO:::fa_opts(fa_type="arome",rotate_wind=TRUE),
                   transformation_opts = opt,
                   by = "1d",
                   output_file_opts = sqlite_opts(path=sqlitedir,remove_model_elev=TRUE),
                   return_data = TRUE)
####_Join_the_two_forecast_in_one_table

stat
forecast=both
table=inner_join(forecast$arome43,forecast$arome46)
table
Obs
##_Join_forecasts_with_obs_by_validdate_and_parameter__####
###verify the structure of the two files columns :
str(Obs)
str(table)

Obs=arrange(Obs,validdate)

##__change_Date_format_if_needed__####

#Obs$validdate=as.POSIXct(Obs$validdate,format="%Y-%m-%d %H:%M:%S")
#table$validdate=as.POSIXct(table$validdate,format="%Y-%m-%d %H:%M:%S")

##___JOINING____######
####extract_just_needed___###

table=table[,c("validdate","SID","lead_time","lat","lon","parameter","arome43_det","arome46_det")]
#Obs=Obs[,c("validdate","SID","lead_time","lat","lon","parameter","Obs")]
Obs=Obs[,c("validdate","SID","parameter","Obs")]
head(table)
head(Obs)
tab=inner_join(table,Obs,by=c("SID","validdate","parameter"))
tab
####_convert_the_t2m_and_Rh2m_units__#####

tab=tab %>%
  mutate(Obs=ifelse(parameter=="Rh2m",Obs/100,Obs))%>%
  mutate(arome43_det=ifelse(parameter=="T2m",arome43_det-273.15,arome43_det))%>%
  mutate(arome46_det=ifelse(parameter=="T2m",arome46_det-273.15,arome46_det))

tab

###_create_2_columns_for_the_differences__############

tab=tab %>%
  mutate(diff_43 = Obs - arome43_det , diff_46 = Obs - arome46_det)

tab


#### temperature 

temp=filter(tab, parameter=="T2m")


scores_temp=temp %>%
  group_by(SID ) %>%
  group_by(lead_time)%>%
  summarize(Bias_43=mean(diff_43),Bias_46=mean(diff_46))
scores_temp

# library(ggplot2)
# ggplot(data= scores_temp)+
#   geom_line(aes(x=lead_time , y = Temp43,color="Cy43"))+
#   geom_line(aes(x=lead_time , y = Temp46,color="Cy46"))+
# 
#   labs(x="Years",y="Temperature", color = "Légende : ")+
#   geom_line(aes(x=lead_time,y=0))+
#   scale_color_manual(labels = c("Cy43", "Cy46"), values = c("red", "blue")) +
#   theme(legend.position = "bottom",)







df <- scores_temp %>%
  dplyr::select(lead_time,Temp43,Temp46) %>%
  gather(key = "variable", value = "value", -lead_time)
head(df)
ggplot(df, aes(x = lead_time, y = value)) + 
  geom_line(aes(color = variable, linetype = variable)) + 
  scale_color_manual(values = c("red", "blue","red","blue"))+
  scale_linetype_manual(values = c("solid", "solid","dashed","dashed"))+
  scale_x_continuous(breaks=seq(0,48,6))+
  labs(title="   Scores aux Observations
       - Temperature a 2m : Nombre de stations:68
       - Jan 2022" , y="Temperature ", x="leadtime", caption="Source: Météo-Algérie")+
  theme(plot.title = element_text(size=15, 
                                  face="bold", 
                                  family="American Typewriter",
                                  color="black",
                                  hjust=0.5,
                                  lineheight=1.2),  # title
        legend.position = "bottom")
tab
#################################"
test=dbConnect(SQLite(),"~/LIMA/Harp-scores/obs/Database/Jan2022.sqlite")
dbListTables(test)
test_syn=dbReadTable(test,"SYNOP")
test_syn
str(obs)

Temperature=forecast%>%
  filter(parameter=="T2m")
  
class(forecast)
joined=join_to_fcst(Temperature,test_syn,force_join = T)

joined$arome43
##_ add fields to Fullpos _########### 
library(Rfa)
a=Rfa::FAdec("~/LIMA/Harp-scores/clim/AROME_bdap_m01", "SURFIND.TERREMER")
fa=Rfa::FAopen("~/LIMA/Harp-scores/clim/AROME_bdap_m01")
new=FAenc(fa,fieldname = "LSM  ",a)

Rfa::Fa

plot_field(read_grid("~/LIMA/Harp-scores/clim/AROME_bdap_m01","LSMAA"))

grib_opts()

stat=mutate(stat,lsm=1)

save.image("/media/wchikhi/Disque_Dure/Harp/HarpObs.RData")