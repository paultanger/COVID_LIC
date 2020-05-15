codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
setwd(datadir)

require(lubridate)

crops_cal = read.csv("GEOGLAM_crop_calendars.csv")
# the second set of cols we can just recalculate in R and do it correctly - spill over to next yr
crops_cal = crops_cal[,c(1:8)]
origin = "2019-12-31"
crops_cal$plant_date = as.Date(crops_cal$planting, origin=origin)
crops_cal$veg_date = as.Date(crops_cal$planting + crops_cal$vegetative, origin=origin)
crops_cal$veg_date = as.Date(crops_cal$vegetative, origin=as.Date(origin) + crops_cal$planting))
crops_cal$veg_date = crops_cal$plant_date + days(crops_cal$vegetative)
ymd(crops_cal$plant_date[1]) + days(crops_cal$vegetative[1])
