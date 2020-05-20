codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
setwd(datadir)

crops_cal = read.csv("GEOGLAM_crop_calendars.csv")
# the second set of cols we can just recalculate in R and do it correctly - spill over to next yr
crops_cal = crops_cal[,c(1:8)]
#origin = "2019-12-31"
# origin = "2020-01-01"
# to include the current seasons, try starting 2019
# origin = as.Date("2018-12-31")
# crops_cal$plant_date = as.Date(crops_cal$planting, origin=origin)
# but this doesn't get us next year
# there must be a better way to do this, but let's try this for now
# basically to get to next year, need to add the diff in remaining yr to the start date (planting) and the days
#crops_cal$veg_date = crops_cal$planting[1] + as.Date(crops_cal$vegetative[1]) + as.Date(paste0(year(crops_cal$plant_date[1]), "-12-31")) - crops_cal$plant_date[1]
# diff = as.Date(paste0(year(crops_cal$plant_date[1]), "-12-31")) - crops_cal$plant_date[1]
# leap year is making this off by one..
# crops_cal$plant_date[1] + (as.Date(paste0(year(crops_cal$plant_date[1]), "-12-31")) - crops_cal$plant_date[1]) + days(crops_cal$vegetative[1])
# test it
# origin = "2020-12-31"
# crops_cal$plant_date[1] + (as.Date(paste0(year(crops_cal$plant_date[1]), "-12-31")) - crops_cal$plant_date[1]) + days(crops_cal$vegetative[1])
# deal with this later if we are off by a day we need to fix it
# there must be simpler way..
# setup function to calc correct date
# calc_date = function(x){
#   if(crops_cal$planting > crops_cal$outofseaso){
#     year_diff = crops_cal$plant_date + (as.Date(paste0(year(crops_cal$plant_date), "-12-31")) - crops_cal$plant_date)
#     crops_cal$plant_date = as.Date(crops_cal$planting, origin=origin)
#     crops_cal$veg_date = year_diff + days(crops_cal$vegetative)
#     crops_cal$harv_date = year_diff + days(crops_cal$harvest)
#     crops_cal$end_date = year_diff + days(crops_cal$endofseaso)
#     crops_cal$out_date = year_diff + days(crops_cal$outofseaso)
#   }
# }

# res <- do.call(rbind, lapply(df2$Value, function(x) cbind(Value = x, 
#                                                           as.data.frame.list(colSums(df1[df1$A >= x, 2:3])))))
# names(res)[-1] <- paste0("SUM_", names(res)[-1])

################################
origin = as.Date("2018-12-31")
originPlusOne = origin  + years(1)

# if plant date before july of 2019, push to 2020 otherwise, keep in 2019
crops_cal$plant_date = ifelse(crops_cal$planting < 180, 
                              as.Date(crops_cal$planting, origin=originPlusOne),
                              as.Date(crops_cal$planting, origin=origin))
class(crops_cal$plant_date) = "Date"

# get diffs
# how is there not a simple package for this?!!!
# get number of days in origin year
interval = interval(origin, originPlusOne)
days_in_yr = time_length(as.duration(interval), "day")

# specific for plant_date year
crops_cal$plant_date_yr = as.Date(paste0(year(crops_cal$plant_date), "-12-31"))
crops_cal$plant_date_yrPlus1 = crops_cal$plant_date_yr  + years(1)
crops_cal$plant_date_yr_interval = interval(crops_cal$plant_date_yr, crops_cal$plant_date_yrPlus1)
crops_cal$days_in_plant_yr = time_length(as.duration(crops_cal$plant_date_yr_interval), "day")

# get plant veg diff
crops_cal$veg_plant_diff = ifelse(crops_cal$vegetative < crops_cal$planting,
                                    (crops_cal$days_in_plant_yr - crops_cal$planting) + crops_cal$vegetative,
                                    crops_cal$vegetative - crops_cal$planting)
# get veg date
crops_cal$veg_date = crops_cal$plant_date + days(crops_cal$veg_plant_diff)

# repeat for others... 
# TODO - melt into one col and then sort smallest number to figure out what to add to what
#######################################
crops_cal$veg_date_yr = as.Date(paste0(year(crops_cal$veg_date), "-12-31"))
crops_cal$veg_date_yrPlus1 = crops_cal$veg_date_yr  + years(1)
crops_cal$veg_date_yr_interval = interval(crops_cal$veg_date_yr, crops_cal$veg_date_yrPlus1)
crops_cal$days_in_veg_yr = time_length(as.duration(crops_cal$veg_date_yr_interval), "day")

# get harv veg yr diff
crops_cal$harv_veg_diff = ifelse(crops_cal$harvest < crops_cal$vegetative,
                                  (crops_cal$days_in_veg_yr - crops_cal$vegetative) + crops_cal$harvest,
                                  crops_cal$harvest - crops_cal$vegetative)


# get harv date
crops_cal$harv_date = crops_cal$veg_date + days(crops_cal$harv_veg_diff)

#######################################

crops_cal$harv_date_yr = as.Date(paste0(year(crops_cal$harv_date), "-12-31"))
crops_cal$harv_date_yrPlus1 = crops_cal$harv_date_yr  + years(1)
crops_cal$harv_date_yr_interval = interval(crops_cal$harv_date_yr, crops_cal$harv_date_yrPlus1)
crops_cal$days_in_harv_yr = time_length(as.duration(crops_cal$harv_date_yr_interval), "day")

# get end harv yr diff
crops_cal$end_harv_diff = ifelse(crops_cal$endofseaso < crops_cal$harvest,
                                 (crops_cal$days_in_harv_yr - crops_cal$harvest) + crops_cal$endofseaso,
                                 crops_cal$endofseaso - crops_cal$harvest)


# get harv date
crops_cal$end_date = crops_cal$harv_date + days(crops_cal$end_harv_diff)


#######################################

crops_cal$end_date_yr = as.Date(paste0(year(crops_cal$end_date), "-12-31"))
crops_cal$end_date_yrPlus1 = crops_cal$end_date_yr  + years(1)
crops_cal$end_date_yr_interval = interval(crops_cal$end_date_yr, crops_cal$end_date_yrPlus1)
crops_cal$days_in_end_yr = time_length(as.duration(crops_cal$end_date_yr_interval), "day")

# get out end yr diff
crops_cal$out_end_diff = ifelse(crops_cal$outofseaso < crops_cal$endofseaso,
                                 (crops_cal$days_in_end_yr - crops_cal$endofseaso) + crops_cal$outofseaso,
                                 crops_cal$outofseaso - crops_cal$endofseaso)


# get out date
crops_cal$out_date = crops_cal$end_date + days(crops_cal$out_end_diff)

# export to check
setwd(datadir)
filename = addStampToFilename("CropCalv3", "csv")
write.csv(crops_cal, filename, row.names = F)

# just keep dates
cropcalv3 = crops_cal[,c(1:3, 9, 15, 21, 27, 33)]
filename = addStampToFilename("CropCalv3_just_dates", "csv")
write.csv(cropcalv3, filename, row.names = F)

# add another year.. will use as new segments
cropcalv3$plant_date2 = cropcalv3$plant_date + dyears(1)
cropcalv3$veg_date2 = cropcalv3$veg_date + dyears(1)
cropcalv3$harv_date2 = cropcalv3$harv_date + dyears(1)
cropcalv3$end_date2 = cropcalv3$end_date + dyears(1)
cropcalv3$out_date2 = cropcalv3$out_date + dyears(1)

filename = addStampToFilename("CropCalv3_just_dates", "csv")
write.csv(cropcalv3, filename, row.names = F)

#######################################

# if next date smaller than plant date, then find diff between plant date & yr end
# and add to next date days, otherwise, just add to plant date
# can't we just skip to the end of the year and add the days to that and make this simpler? TODO: try it
# this won't work.. need to add the diffs not the day of year!
                                  
# then calc actual dates
# crops_cal$veg_date = ifelse(crops_cal$vegetative < crops_cal$planting, 
#                               (crops_cal$plant_date + days(as.Date(paste0(year(crops_cal$plant_date), "-12-31")) - crops_cal$plant_date) + days(crops_cal$vegetative)),
#                               crops_cal$plant_date + days(crops_cal$vegetative))
# class(crops_cal$veg_date) = "Date"
# 
# # do for rest
# crops_cal$harv_date = ifelse(crops_cal$harvest < crops_cal$vegetative, 
#                             (crops_cal$veg_date + days(as.Date(paste0(year(crops_cal$veg_date), "-12-31")) - crops_cal$veg_date) + days(crops_cal$harvest)),
#                             crops_cal$veg_date + days(crops_cal$harvest))
# class(crops_cal$harv_date) = "Date"
# 
# crops_cal$end_date = ifelse(crops_cal$endofseaso < crops_cal$harvest, 
#                              (crops_cal$harv_date + days(as.Date(paste0(year(crops_cal$harv_date), "-12-31")) - crops_cal$harv_date) + days(crops_cal$endofseaso)),
#                              crops_cal$harv_date + days(crops_cal$endofseaso))
# class(crops_cal$end_date) = "Date"
# 
# crops_cal$out_date = ifelse(crops_cal$outofseaso < crops_cal$endofseaso, 
#                             (crops_cal$end_date + days(as.Date(paste0(year(crops_cal$end_date), "-12-31")) - crops_cal$end_date) + days(crops_cal$outofseaso)),
#                             crops_cal$end_date + days(crops_cal$outofseaso))
# class(crops_cal$out_date) = "Date"



# for now, let's try to plot this
# first save it
setwd(datadir)
filename = addStampToFilename("CropCalv2", "csv")
write.csv(crops_cal, filename, row.names = F)

