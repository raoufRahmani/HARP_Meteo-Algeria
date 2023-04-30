library(tidyverse)
library(harp)

rm(list=ls())
tab=read.table("~/PROJECTS/Fac/2010.txt")
head(tab)
str(tab)
names(tab)=c("date","lon","lat","mslp")
tab$date=as.Date(tab$date)
head(tab)
str(tab)

tt=tab %>%
  filter(date >= "2010-01-01" & date <= "2010-01-03")
tt
t=tab %>%
  group_by(date)%>%
  transpose(tab)





a=read_forecast(start_date = 20220201,
              end_date = 20220201,
              fcst_model = "arome",
              parameter=c("T2m","Rh2m","S10m","T850"),
              lead_time = seq(0,48,6),
              file_path = "~/HPC/MAJ-OPER/harp/harp",
              file_template="PFAL03ALGE01+00{LDT2}",
              file_format = "fa",
              by = "1d",return_data = T)
library(dplyr)

for (par in c("T2m","Rh2m","S10m","T850")){
for (i in seq(0,48,6)){
plot_field(a %>%
             filter(parameter==par),"arome",lead_time = i,plot_col =arome_det  )
}
}

a=read_forecast(start_date = 20220201,
                end_date = 20220201,
                fcst_model = "arome",
                parameter="Rh2m",
                lead_time = seq(0,48,6),
                file_path = "~/HPC/MAJ-OPER/harp/harp",
                file_template="PFAL03ALGE01+00{LDT2}",
                file_format = "fa",
                by = "1d",return_data = T)


for (i in seq(0,48,6)){
  plot_field(a,"arome",lead_time = i,plot_col =arome_det ,palette = rev(heat.colors(256)) )
}