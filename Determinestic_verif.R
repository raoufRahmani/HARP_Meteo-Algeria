library(here)
library(harp)
library(tidyverse)

rm(list=ls())
parameters <- c("T2m", "Rh2m", "S10m")
#parameters <- "T500"
models <- c( "arome43","arome46")
mname=c("arome43","arome46")
colour=c("red","blue")
col=data_frame(mname,colour)
col
source("~/LIMA/Harp-scores/R-src/obs_to_sqlite.R")

for ( par in parameters){

forecast <-read_point_forecast(start_date = 20220101,
                                    end_date =  20220131,
                                    lead_time = seq(0,48,6),
                                    fcst_type = "det", 
                                    by = "1d",
                                    parameter = par,
                                    fcst_model = c("arome43","arome46"),
                                    file_path = "~/LIMA/Harp-scores/R-output/sqlite")
  
  obs <- read_point_obs(start_date = first_validdate(forecast), 
           end_date   = last_validdate(forecast),
           parameter  = par,
           stations   = pull_stations(forecast),
           obs_path   =  here("~/LIMA/Harp-scores/obs/Database/") 
           )

  forecast <- join_to_fcst(forecast , obs)

  verif <- det_verify(forecast,par,show_progress = T)
  name <- paste0("~/LIMA/scores/scores_obs/",par,"Bias.png",sep="")
  
  title <- paste0("BIAS  ", par," : 00:00 01 Janv.2022 - 23:00 31 Janv.2022" )
  png(filename = name,res=200,width = 2000,height = 1500)
  plot_point_verif(verif,bias ,colour_theme = "theme_grey",plot_caption = "Météo-Algérie",
                   plot_title = title,colour_table = col
                   )
    dev.off()
  
    ### rmse
    name <- paste0("~/LIMA/scores/scores_obs/",par,"RMSE.png",sep="")
     title <- paste0("RMSE  ", par," : 00:00 01 Janv.2022 - 23:00 31 Janv.2022" )
    png(filename = name,res=200,width = 2000,height = 1500)
    plot_point_verif(verif,rmse ,colour_theme = "theme_grey",plot_caption = "Météo-Algérie",
                     plot_title = title,colour_table = col
    )
    
    dev.off()
    
  }
# 
# verif
# 
# forecast
# 
# 
# #######################""""

# forecast <-read_point_forecast(start_date = 20220101,
#                                end_date =  20220131,
#                                lead_time = seq(0,48,6),
#                                fcst_type = "det",
#                                by = "1d",
#                                parameter = "T2m",
#                                fcst_model = c("arome43","arome46"),
#                                file_path = "~/LIMA/Harp-scores/R-output/sqlite")
# 
# obs <- read_point_obs(start_date = first_validdate(forecast),
#                       end_date   = last_validdate(forecast),
#                       parameter  = "T2m",
#                       stations   = pull_stations(forecast),
#                       obs_path   =  here("~/LIMA/Harp-scores/obs/Database/")
# )
# 
# forecast <- join_to_fcst(forecast , obs)
# 
# verif <- det_verify(forecast,"T2m",show_progress = T)
# #name <- paste0("~/LIMA/scores/scores_obs/",par,"Bias",sep="")
# 
# #title <- paste0("BIAS  ", par," : 00:00 01 Janv.2022 - 23:00 31 Janv.2022" )
# 
# a=plot_point_verif(verif,
#                  bias ,
#                  colour_theme = "theme_harp_grey",plot_caption = "Météo-Algérie",
#                  verif_type = "det"
#                  )
# 
# 
# mname=c("arome43","arome46")
# colour=c("red","blue")
# col=data.frame(mname,colour)
# col
# plot_point_verif(verif,
#                     bias ,colour_theme = "theme_harp_grey",plot_caption = "Météo-Algérie",
#                    colour_table = col,
# )
# 
# 
# head(verif,n = 1)
# plot1=ggplot(verif$det_summary_scores, aes(x = leadtime, y = bias))+
#   geom_line(aes(color = mname, linetype = mname))+
#   scale_color_manual(values = c("red", "blue"))+
#   scale_linetype_manual(values = c("solid", "solid"))+
#   scale_x_continuous(breaks=unique(verif$det_summary_scores$leadtime))+
#   labs(title="Bias & RMSE T2m : 01.Janv-2022 - 31.Janv-2022" , y="Bias ", x="leadtime",
#   caption="Source: Météo-Algérie")+
#   theme_bw()+
#   theme(legend.position = "bottom")
# 
# 
# save_point_verif(verif,verif_path = "~/test/")
# 
# shiny_plot_point_verif("~/test/")
# plot_scatter(forecast,parameter = "T2m",arome43)+
# plot_scatter(forecast,parameter = "T2m",arome46)
# 
# fn_plot_point_verif(harp_verif_input = verif , png_archive = "~/",table_SIDS = T)
# '''
