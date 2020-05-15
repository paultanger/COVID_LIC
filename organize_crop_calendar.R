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
origin = "2020-01-01"
crops_cal$plant_date = as.Date(crops_cal$planting, origin=origin)
# but this doesn't get us next year
# there must be a better way to do this, but let's try this for now
# basically to get to next year, need to add the diff in remaining yr to the start date (planting) and the days
#crops_cal$veg_date = crops_cal$planting[1] + as.Date(crops_cal$vegetative[1]) + as.Date(paste0(year(crops_cal$plant_date[1]), "-12-31")) - crops_cal$plant_date[1]
# diff = as.Date(paste0(year(crops_cal$plant_date[1]), "-12-31")) - crops_cal$plant_date[1]
# leap year is making this off by one..
crops_cal$plant_date[1] + (as.Date(paste0(year(crops_cal$plant_date[1]), "-12-31")) - crops_cal$plant_date[1]) + days(crops_cal$vegetative[1])
# test it
origin = "2020-12-31"
crops_cal$plant_date[1] + (as.Date(paste0(year(crops_cal$plant_date[1]), "-12-31")) - crops_cal$plant_date[1]) + days(crops_cal$vegetative[1])
# deal with this later if we are off by a day we need to fix it
# maybe an alternative way to do this is only add 365 to a date if planting is less than end of season
# TODO: fix origin date
crops_cal$veg_date = as.Date(crops_cal$vegetative, origin=origin)

crops_cal$veg_date = as.Date(crops_cal$vegetative, origin=as.Date(origin) + crops_cal$planting))
crops_cal$veg_date = crops_cal$plant_date + days(crops_cal$vegetative)
ymd(crops_cal$plant_date[1]) + days(crops_cal$vegetative[1])
