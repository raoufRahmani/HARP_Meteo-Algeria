library(harp)
library(Rfa)
library(here)
library(ggplot2)

setwd("~/LIMA/")
rm(list=ls())

############################################
#
#                 ALADIN
#
############################################


template ="{DD}/FULLPOS_202201{DD}00_00{HH}"

template_obs="{DD}/FULLPOS_ALADIN_{HH}00"

grid=harpIO::read_grid("~/LIMA/Harp-scores/FULLPOS/Harp/ALADIN/01/FULLPOS_2022010100_0000","CLSTEMPERATURE")

as.geofield("~/LIMA/ALADIN_An/01/FULLPOS_ALADIN_0000",domain = grid)

verif=verify_spatial(
    start_date = 20220101,
    end_date = 20220131,
    parameter = c("t2m") , #,"RH2m","Pmsl","S10m","T850","T500"),
    det_model="ALADIN",
    lead_time = 0,
    lt_unit = "h",
    by = "6h",
    verif_domain = grid ,
    fc_file_path = "~/LIMA/Harp-scores/FULLPOS/Harp/ALADIN",
    fc_file_template = template,
    fc_file_format = "fa",
    ob_file_path = "~/LIMA/ALADIN_An",
    ob_file_template= template_obs,
    ob_file_format = "fa",
    sqlite_path="~/LIMA") 


shiny_plot_spatial_verif()
##__Calculer__Les__scores_mensuels__############

Aladin=verif$basic %>%
  group_by(fctime)%>%
  summarise(Bias_ALADIN=mean(bias),RMSE=mean(mse))

###__PLOT_SCORES__####
names(Aladin)

ggplot(data=Aladin)+
  aes(x = fctime ,y=Bias_ALADIN,color="red")+
  geom_line()+
  scale_color_manual(labels = "ALADIN", values =  "red")+
  scale_y_continuous(breaks=seq(-1,1,0.1))+
  scale_x_continuous(breaks=seq(0,21,3))+
  geom_line(y=0,color="black")




############################################
#
#                 AROME_CY46
#
############################################

template = "{DD}/PFAL03ALGE01+00{HH}"

template_obs="{DD}/FULLPOS_AROME_{HH}00"

grid=harpIO::read_grid("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy46/01/PFAL03ALGE01+0000","CLSTEMPERATURE")

as.geofield("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy46/01/PFAL03ALGE01+0000",domain = grid)

show_harp_parameters()
verif46=verify_spatial(
  start_date = 20220101,
  end_date = 20220131,
  parameter = "RH2m",  #c("t2m","Pmsl","S10m","T850","T500"),
  det_model=c("AROME_46"),
  lead_time = 0,
  lt_unit = "h",
  by = "6h",
  verif_domain = grid ,
  fc_file_path = list(
    AROME_46="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy46"),
  fc_file_template = list(
    AROME_46=template),
  fc_file_format = "fa",
  ob_file_path = "~/LIMA/Analyse",
  ob_file_template= template_obs,
  ob_file_format = "fa",
  sqlite_path="~/LIMA/Harp-scores/R-output/sqlite/",
  sqlite_file="Cy46")

shiny_plot_spatial_verif(start_dir = "~/LIMA/Harp-scores/R-output/sqlite/")


##__Calculer__Les__scores_mensuels__############

bias46=verif46$basic %>%
  group_by(fctime)%>%
  summarise(Bias_Cy46=mean(bias))
bias46$Bias_Cy46=bias46$Bias_Cy46*100
bias46


ggplot(data=bias46,aes(x = fctime,y=Bias_Cy46))+
  geom_line()+
  #scale_y_continuous(breaks=seq(-2,2,0.1))+
  scale_x_continuous(breaks=seq(0,2100,300))+
  geom_line(y=0,color="black")

############################################
#
#                 AROME_CY43
#
############################################

template="{DD}/FULLPOS_202201{DD}00_00{HH}"
template_obs="{DD}/FULLPOS_AROME_{HH}00"


grid=harpIO::read_grid("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy43/01/FULLPOS_2022010100_0000","CLSTEMPERATURE")

as.geofield("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy43/01/FULLPOS_2022010100_0000",domain = grid)

det_verify()
parameters=c("t2m","S10m")

verif43_hum=verify_spatial(
  start_date = 20220101,
  end_date = 20220131,
  parameter = "RH2m",  #c("t2m","Pmsl","S10m","T850","T500"),
  det_model=c("AROME_43"),
  lead_time = 0,
  lt_unit = "h",
  by = "6h",
  verif_domain = grid ,
  fc_file_path = list(
    AROME_46="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy43"),
  fc_file_template = list(
    AROME_46=template),
  fc_file_format = "fa",
  ob_file_path = "~/LIMA/Analyse",
  ob_file_template= template_obs,
  ob_file_format = "fa",
  sqlite_path="~/LIMA/Harp-scores/R-output/sqlite/",
  sqlite_file="Cy43")


##__Calculer__Les__scores_mensuels__############
a=verif43$basic

bias43=verif43_hum$basic %>%
  group_by(fcdate)%>%
  summarise(Bias_Cy43=mean(bias))
bias43

bias43$Bias_Cy43=bias43$Bias_Cy43*100
table_bias=inner_join(bias43,bias46)

names(table_bias)

ggplot(data=table_bias,aes(x=fctime,y=Bias_Cy43,color="Bias_Cy43"))+
  geom_line()+
  geom_line(aes(x=fctime,y=Bias_Cy46,color="Bias_Cy46"))+
  scale_color_manual(labels = c("Cy43", "Cy46"), values = c("blue", "red"))+
  #scale_y_continuous(breaks=seq(-1,0.5,0.05))+
  scale_x_continuous(breaks=seq(0,18,3))+
  geom_line(y=0,color="black")

############################################
#                                          #
#         AROME_CY46-Cy43 Same             #
#                                          #
############################################

template ="{DD}/PFAL03ALGE01+00{HH}"

template_obs="{DD}/FULLPOS_AROME_{HH}00"

grid=harpIO::read_grid("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy46/01/PFAL03ALGE01+0000","CLSTEMPERATURE")

as.geofield("~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy46/01/PFAL03ALGE01+0000",domain = grid)

det_verify()


verif46=verify_spatial(
  start_date = 20220101,
  end_date = 20220131,
  parameter = c("t2m") , #,"RH2m","Pmsl","S10m","T850","T500"),
  det_model=c("AROME_43","AROME_46"),
  lead_time = 0,
  lt_unit = "h",
  by = "6h",
  verif_domain = grid ,
  fc_file_path = list(
    AROME_46="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy46",
    AROME_43="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy43"),
  fc_file_template = list(
    AROME_46=template,
    AROME_43=template),
  fc_file_format = "fa",
  ob_file_path = "~/LIMA/Analyse",
  ob_file_template= template_obs,
  ob_file_format = "fa",
  sqlite_path="~/LIMA/Harp-scores/R-output/sqlite/",
  sqlite_file="Cy46")






##__Calculer__Les__scores_mensuels__############

bias46=verif$basic %>%
  group_by(fctime)%>%
  summarise(Bias_ALADIN=mean(bias))






####PLOT_SCORES___

plot_spatial_verif(verif,SAL,filter_by = vars(fctime==0) )


mean(reseau00$bias)

mean(verif$basic$bias)

plot_spatial_verif(verif_data = verif,score = "FSS")
harpSpatial::

  harpVis::plot_spatial_verif( )

spatial

shiny_plot_spatial_verif()

harpVis::plot_spatial_verif(ver = )
#########################___Verif_Process___#################"

path="~/LIMA/output/Cy46/01"
template ="PFAL03ALGE01+00{HH}"
template_obs="FULLPOS_AROME_{HH}00"

fcst=read_forecast(
  start_date = 20220101,
  end_date = 20220101,
  by = "0h",
  parameter = "t2m",
  fcst_model = "AROME",
  # lead_time = seq(0, 24, 6),
  file_path = "~/HPC/ICMSHAL03+0000",
  file_template = template,
  file_format = "fa",
  #  transformation = "interpolate",
  show_progress = TRUE
)



#######__POINT-FORECAST____ ####
template ="{DD}/PFAL03ALGE01+00{HH}"
template1 ="{DD}/FULLPOS_2022010100_{HH}00"

t2m = read_point_forecast(
  start_date    = 20220101,
  end_date      = 20220101,
  by            = "6h",
  fcst_model    = c("AROME_CY46", "AROME_CY43"),
  fcst_type     = "det",
  parameter     = "t2m",
  file_path = list(
    AROME_CY46="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy46",
    AROME_CY43="~/LIMA/Harp-scores/FULLPOS/Harp/AROME/Cy43"),
  file_template = list(
    AROME_CY46=template,
    AROME_CY43=template1))



#################____TEST______###############

domain=meteogrid::as.geodomain(x ="output/Cy46/01/PFAL03ALGE01+0006")


a=read_grid("~/HPC/ICMSHAL03+0002-1.3",file_format = "fa",parameter = "t2m")

a=read_grid("/home/wchikhi/HPC/ICMSHAL03+0000",parameter = "t2m")

plot_field(a-273.15)

a=harpSpatial::verify_basic(obfield = An,fcfield = CY46)
harpSpatial::verify_basic(obfield = An,fcfield = CY43)














