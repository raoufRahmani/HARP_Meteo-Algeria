library(dplyr)
library(openxlsx)
library(harp)
rm(list=ls())
w=createWorkbook()

######################"""

start=20220101
end=20220102
leadtime=seq(0,48,6)
ech=seq(0,48,6)
BIAS_AROME=data_frame(leadtime)

show_harp_parameters()

a=Rfa::FAopen("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY43/01/FULLPOS_2022010100_0000")
a$list
vent_zonal=as_harp_parameter("CLSVENT.ZONAL","CLSVENT.ZONAL",level_type = "surf")
######################"

parametre="T500"

#########################

grid=harpIO::read_grid("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY43/20220101/FULLPOS_2022010100_0000","CLSTEMPERATURE")

###______GENERATE_NAMES__#########

Bias43=paste0("bias_",parametre,"_43")
Bias46=paste0("bias_",parametre,"_46")
rmse43=paste0("rmse_",parametre,"_43")
rmse46=paste0("rmse_",parametre,"_46")
mse43=paste0("mse_",parametre,"_43")
mse46=paste0("mse_",parametre,"_46")
sqlitename43=paste0(parametre,"43")
sqlitename46=paste0(parametre,"46")

######################################
template="{YYYY}{MM}{DD}/FULLPOS_{YYYY}{MM}{DD}00_00{LDT2}"
template_obs ="{YYYY}{MM}{DD}/FULLPOS_AROME_{HH}00"

AROME43=verify_spatial(
  start_date = start,
  end_date = end,
  det_model="AROME",
  by = "1d",
  lead_time =ech,
  lt_unit = "h",
  parameter = parametre,   # c("S10m") , #,"RH2m","Pmsl","S10m","T850","T500"),
  verif_domain = grid ,
  fc_file_path = "/home/wchikhi/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY43",
  fc_file_template = template,
  fc_file_format = "fa",
  ob_file_path = "/home/wchikhi/LIMA/Analyse",
  ob_file_template= template_obs,
  ob_file_format = "fa",
  sqlite_path="~/LIMA/Harp-scores/R-output/sqlite",
  sqlite_file = sqlitename43)

Bias_43=AROME43$basic %>%
  mutate(rmse=sqrt(mse))%>%
  group_by(leadtime)%>% 
  summarise(Bias_43=mean(bias),RMSE_43=mean(rmse),MSE_43=mean(mse))

Bias_43
names(Bias_43)=c("leadtime",Bias43,rmse43,mse43)


wkshett43=paste0(parametre,"43",sep='')
addWorksheet(w,wkshett43)
writeData(w,wkshett43,AROME43)

##############""" 46 

template="{YYYY}{MM}{DD}/PFAL03ALGE01+00{LDT2}"
template_obs ="{YYYY}{MM}{DD}/FULLPOS_AROME_{HH}00"
AROME46=verify_spatial(
  start_date = start,
  end_date = end,
  det_model="AROME",
  by = "1d",
  lead_time = ech,
  lt_unit = "h",
  parameter = parametre , #,"RH2m","Pmsl","S10m","T850","T500"),
  verif_domain = grid ,
  fc_file_path = "/home/wchikhi/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY46",
  fc_file_template = template,
  fc_file_format = "fa",
  ob_file_path = "/home/wchikhi/LIMA/Analyse",
  ob_file_template= template_obs,
  ob_file_format = "fa",
  sqlite_file = sqlitename46,
  sqlite_path="~/LIMA/Harp-scores/R-output/sqlite")

wkshett46=paste0(parametre,"46",sep='')
addWorksheet(w,wkshett46)
writeData(w,wkshett46,AROME46,colNames = T,rowNames = T)

Bias_46=AROME46$basic %>%
  mutate(rmse=sqrt(mse))%>%
  group_by(leadtime)%>%
  summarise(Bias_46=mean(bias),RMSE_46=mean(rmse),MSE_46=mean(mse))
names(Bias_46)=c("leadtime",Bias46,mse46,rmse46)
Bias_46
BIAS_AROME=inner_join(BIAS_AROME,Bias_46,by="leadtime")
BIAS_AROME=inner_join(BIAS_AROME,Bias_43,by="leadtime")
BIAS_AROME

##__SAVE_EXCEL_APRES_FIN_DE__TOUT_PAR__##
saveWorkbook(w,"~/LIMA/Harp-scores/R-output/xlsx/T850-Scores43-46.xlsx",overwrite = T)
write.csv(BIAS_AROME,"~/LIMA/T850_Bias_arome.csv")
table=read.csv("~/LIMA/Bias_arome.csv")
tableau=inner_join(table,BIAS_AROME)
write.csv("~/LIMA/Bias_arome.csv")



###plot

ggplot(data=BIAS_AROME)+
  geom_line(mapping = aes(x=leadtime,y=bias_T850_43,color="43"))+
  geom_line(aes(x=leadtime,y=bias_T850_46,color="46"))+
  labs(x="Years",y="Température Max Saisonniére", color = "Légende : ")+
  geom_line(aes(x=leadtime,y=0))+
  #scale_color_manual(labels = c("Winter", "Summer","Autumn","Spring"), values = c("blue", "red","green","yellow")) +
 theme(legend.position = "top",)  
