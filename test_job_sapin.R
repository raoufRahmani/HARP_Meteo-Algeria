rm(list=ls())
header=c('SID','stat','aa','mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb')
names(spain)=c('SID','stat','aa','mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb')

world_stat=station_list
spain=read.csv2("~/LIMA/obs/spain/spain.csv",header = F,sep=",",col.names = header)
spain

world_stat
summary(spain)
str(spain)
world_stat=world_stat %>%
  filter(lat >= 28 & lat <= 40 & lon >= -3 & lon <= 9)
class(spain)
s= spain[,c("iden","stat")]
names(s)=c("SID","station")
str(world_stat)
str(s)
s=distinct(s)
world_stat
tab=inner_join(s,world_stat)
tab
tab
lon=tab$lon
lat=tab$lat

mapWorld=borders(xlim=c(-15,20),ylim = c(30,45), colour="gray80", fill="gray50")
mp=ggplot()+mapWorld +
geom_point(aes(lon,lat), col="red")
mp




