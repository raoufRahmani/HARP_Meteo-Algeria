rm(list=ls())
library(harp)
library(dplyr)
library(here)
library(ggplot2)
library(Rfa)

setwd("~/LIMA")

template="{DD}/FULLPOS_{YYYY}{MM}{DD}00_00{LDT2}"
template_obs ="{DD}/FULLPOS_AROME_{HH}00"

forcast=read_forecast(start_date = 2022010100,
              end_date = 2022012800,
              fcst_model = "arome",
              parameter = "T2m",
              lead_time = seq(0,72,6),
              by="1d",
              file_path = "~/LIMA/Harp-scores/FULLPOS/Harp/ALADIN",
              file_template = template,
              return_data = T)
forcast


read_grid("~/LIMA/Analyse/AROME/01/FULLPOS_2022010100_0006","T2m")

template="{DD}/FULLPOS_{YYYY}{MM}{DD}00_00{LDT2}"
template_obs ="{DD}/FULLPOS_AROME_{LDT2}00"

forcast=read_forecast(start_date = 20220101,
                      end_date = 20220102,
                      fcst_model = "arome",
                      parameter = c("T2m","Rh2m"),
                      #lead_time = c(0,6) , #seq(0,24,6),
                      by="1d",
                      file_path = "~/LIMA/Analyse/AROME",
                      file_template = template_obs,
                      return_data = T)

forcast


template ="{DD}/FULLPOS_202201{DD}00_00{HH}"
template_obs="{DD}/FULLPOS_ALADIN_{HH}00"

grid=harpIO::read_grid("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY43/01/FULLPOS_2022010100_0000","CLSTEMPERATURE")


setwd("~/LIMA")
template="{DD}/FULLPOS_{YYYY}{MM}{DD}00_00{LDT2}"
template_obs ="{DD}/FULLPOS_AROME_{HH}00"

verif = verify_spatial(start_date = 20220101,
                      end_date = 20220131,
                      det_model = "arome",
                      parameter = "T2m",
                      verif_domain = grid,
                      lead_time =seq(0,48,6) ,
                      lt_unit = "h",
                      by="1d",
                      fc_file_path = "~/LIMA/Harp-scores/FULLPOS/Harp/AROME/AROME_CY43",
                      fc_file_format = "fa",
                      fc_file_template = template,
                      ob_file_path = "~/LIMA/Analyse/AROME",
                      ob_file_template = template_obs,
                      ob_file_format = "fa",
                      sqlite_path="~/LIMA/Harp-scores/R-output/sqlite",
                      sqlite_file="_bias_Cy43",
                      return_data = T)

verif$basic

Aladin=verif$basic %>%
  group_by(leadtime)%>%
  summarise(Bias_ALADIN=mean(bias))


Aladin

#Aladin=verif$basic
verif$basic
#names(Aladin)=c("Bias_ALADIN","RMSE")
###__PLOT_SCORES__####
names(Aladin)

ggplot(data=Aladin)+
  aes(x = leadtime ,y=Bias_ALADIN,color="red")+
  geom_line()+
  scale_color_manual(labels = "AROME_CY43", values =  "red")+
  scale_y_continuous(breaks=seq(-1,1,0.1))+
  scale_x_continuous(breaks=seq(0,72,6))+
  geom_line( y=0 , color="black" )





###_MANUAL_VERIFICATION_BIAIS__########"

ascii_aldin=read.table("~/LIMA/Harp-scores/FULLPOS/Harp/ALADIN/01/t2m_36")
ascci_an=read.table("~/LIMA/ALADIN_An/02/t2m_12")

diff= ascii_aldin - ascci_an

diff=mean(diff$V3)
diff




######################################


tab=read.csv("~/ald.csv",sep=",")
ALADIN=tab %>%
  group_by(leadtime)%>%
  summarise(BIAS=mean(bias),RMSE=mean(sqrt(mse)))
write.csv(ALADIN,"bias_aladin.csv")
getwd()


template="{DD}/FULLPOS_{YYYY}{MM}{DD}{HH}_{HH}{LDT2}"
template_obs ="{DD}/FULLPOS_ALADIN_{LDT2}{HH}"
verif=verify_spatial(start_date = 20220101,
                     end_date = 20220101,
                     det_model = "arome",
                     parameter = "T2m",
                     verif_domain = grid,
                     lead_time =seq(0,72,6) ,
                     lt_unit = "h",
                     by="1d",
                     fc_file_path = "~/LIMA/Harp-scores/FULLPOS/Harp/ALADIN " ,
                     fc_file_format = "fa",
                     fc_file_template = template,
                     ob_file_path = "~/LIMA/ALADIN_An",
                     ob_file_template = template_obs,
                     ob_file_format = "fa",
                     sqlite_path="~/LIMA/Harp-scores/R-output/sqlite",
                     sqlite_file="Cy46",
                     return_data = T)
