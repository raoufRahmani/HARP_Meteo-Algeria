library(tidyverse)
library(harp)

formatc <- function(char,n=2){formatC(char,width = n, flag = "0",digits = 2)}

path <- function(chemin,day,hh){paste0(chemin,"/",formatc(day),"/",formatc(hh),
                                    "/alg/synop_alg_202201",formatc(day),formatc(hh),"00.text",sep="")}


obs_dir <- "/home/wchikhi/LIMA/obs/0101"

header=c('iden','stat','aa','mm','dd','hh','lat','lon','vv','dv','t2m','h2m','mslp','neb')


names=path(obs_dir,01,09)
table <- read_table(names,col_names = header,na = "NA")

#names(table) <- header

for( day in seq(1,31,1)){
  
  for ( hh in seq(0,18,3)){
 
   ficIN <- path(obs_dir,day,hh)
   print(ficIN)
   tab <- read_table(ficIN,col_names = header,na = "NA")
  # names(tab) <- header
   table=rbind(table,tab)
 
   
    }
  ##_end for heure
} ##_end for date 

tab=read_table("/home/wchikhi/LIMA/obs/0101/all_Synops/syn.txt",col_names = header,na = "NA",progress = T)
str(tab)
tab$vv=as.numeric()
summary(tab)

table(tab$h2m)
