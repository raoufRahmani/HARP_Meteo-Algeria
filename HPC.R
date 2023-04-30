##### NAMEL_AMB VS OPER   ( 180s )
template ="{YYYY}/{MM}/{DD}/r00/FULLPOS_{YYYY}{MM}{DD}00_00{LDT2}"
template_obs="PFAL03ALGE01+00{HH}"

path="/fennecData/data/chprod/AROME/FULLPOS"

grid=harpIO::read_grid("/onm/dem/home/wchikhi/FULLPOS/ANALYSE/01/FULLPOS_AROME_0000","CLSTEMPERATURE")
a=sqlite_opts(path = "~")
Bias=read_forecast(
   start_date = 20220101,
   end_date = 20220101,
   fcst_model = "AROME",
   by = "1d",
   lead_time = seq(0,18,6),
   parameter = "T2m" , #,"RH2m","Pmsl","S10m","T850","T500"),
   file_path = path,
   file_template = template,
   file_format = "fa",
   return_data = T,
   transformation = "none",
    output_file_opts = a
   )
?read_forecast
### ISLAM43 VS OPER    ( 180s )


template_obs="{YYYY}/{MM}/{DD}/r00/FULLPOS_{YYYY}{MM}{DD}00_00{HH}"
template ="{DD}{MM}{YYYY}-pnt/PFAL03ALGE01+00{LDT2}"
path="/onm/dem/share"

grid=harpIO::read_grid("/onm/dem/share/01012022-dit/PFAL03ALGE01+0000","CLSTEMPERATURE")

AROMEPNT=verify_spatial(
  start_date = 20220101,
  end_date = 20220101,
  det_model="AROME",
  by = "1d",
  lead_time = seq(0,24,6),
  lt_unit = "h",
  parameter = "T2m" , #,"RH2m","Pmsl","S10m","T850","T500"),
  verif_domain = grid ,
  fc_file_path = path,
  fc_file_template = template,
  fc_file_format = "fa",
  ob_file_path = "/fennecData/data/chprod/AROME/FULLPOS",
  ob_file_template= template_obs,
  ob_file_format = "fa"
)


#__ ISLAM43 VS AMB_NAMEL ( 180s )



template_dit="{DD}{MM}{YYYY}-dit/PFAL03ALGE01+00{HH}"
template_pnt="{DD}{MM}{YYYY}-pnt/PFAL03ALGE01+00{LDT2}"
path="/onm/dem/share"

grid=harpIO::read_grid("/onm/dem/share/01012022-dit/PFAL03ALGE01+0000","CLSTEMPERATURE")

ISLAMAMB=verify_spatial(
  start_date = 20220101,
  end_date = 20220101,
  det_model="AROME",
  by = "1d",
  lead_time = seq(0,18,6),
  lt_unit = "h",
  parameter = "T2m",       #,"RH2m","Pmsl","S10m","T850","T500"),
  verif_domain = grid ,
  fc_file_path = path,
  fc_file_template = template_pnt,
  fc_file_format = "fa",
  ob_file_path = path,
  ob_file_template= template_dit,
  ob_file_format = "fa",trans
  )


transf







DIT=AROMEDIT$basic
PNT=AROMEPNT$basic
ISL=ISLAMAMB$basic



Bias_46=AROME46$basic %>%
  mutate(rmse=sqrt(mse))%>%
  group_by(leadtime)%>%
  summarise(Bias_46=mean(bias),RMSE_46=mean(rmse),MSE_46=mean(mse))
