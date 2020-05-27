codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
source('plot_crop_cal_function.R')
setwd(datadir)

# crops_cal = read.csv("CropCal_20200519_1000.csv", colClasses=c(rep("factor",3), rep("numeric",5), rep("Date", 5)))
# crops_cal = read.csv("CropCalv2_20200519_2041.csv", colClasses=c(rep("factor",3), rep("numeric",5), rep("Date", 5)))
# crops_cal = read.csv("CropCalv3_just_dates_20200520_1125.csv", colClasses=c(rep("factor",3), rep("Date", 5)))
# crops_cal = read.csv("CropCalv3_just_dates_20200520_1141.csv", colClasses=c(rep("factor",3), rep("Date", 10)))
#crops_cal = read.csv("CropCalv4_just_dates_20200520_1558.csv", colClasses=c(rep("factor",3), rep("Date", 12)))
# revised GEOGLAM data
#crops_cal = read.csv("CropCalv4_just_dates_20200522_1418.csv", colClasses=c(rep("factor",3), rep("Date", 12)))
# new version with adjusted out dates
# crops_cal = read.csv("CropCalv5_just_dates_20200526_1026.csv", colClasses=c(rep("factor",3), rep("Date", 12)))
# just one country for now

#crops_cal = crops_cal[(crops_cal$country == "Afghanistan") & (crops_cal$region == "Badghis and Faryab"), ]

# multiple regions
#crops_cal = crops_cal[(crops_cal$country == "Afghanistan"), ]
#crops_cal = crops_cal[(crops_cal$country == "Ethiopia"), ]
#crops_cal = crops_cal[(crops_cal$country == "Turkmenistan"), ]

# just keep dates
#crops_cal = crops_cal[,-c(4:8)]

# make it long format
#crops_cal_long = melt(crops_cal, id=c("country", "region", "crop"), variable.name = "dates", value.name = "value")

####### TEST WITH ONE ############
# set titles
# mytitle = "Country Region"
# myxlab = "Date"
# myylab = "Crops"
# PlotObj = plot_crop_cal(crops_cal, mytitle, myxlab, myylab, fontsize=9, linesize=2)
# PlotObj

# save it
# filename = addStampToFilename('Afghanistan_Crop_Cal_Region_v1', 'pdf')
# set data dir
# setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
#ggsave(filename, PlotObj, width=7, height=6, units="in", scale=1.5)
#ggsave(filename, PlotObj)

###########################
# loop through all

# setup list to plot of countries
# crops_cal = read.csv("CropCalv4_just_dates_20200520_1558.csv", colClasses=c(rep("factor",3), rep("Date", 12)))
# crops_cal = read.csv("CropCalv4_just_dates_20200522_1418.csv", colClasses=c(rep("factor",3), rep("Date", 12)))
crops_cal = read.csv("CropCalv5_just_dates_20200526_1026.csv", colClasses=c(rep("factor",3), rep("Date", 12)))
# countries = c("Afghanistan")

# add USAID country names
# use the newer version of sorting cols
other_sorting_cols = fread("JHU_UK_Katie_USAIDv4_GEO_FINAL_20200527_1127.csv", stringsAsFactors=T, header=T)

# merge with data in case we want to facet plot by these groups
crops_cal = merge(other_sorting_cols, crops_cal, by.x = "GEOGLAM_Country", by.y = "country", all.y=T)
#countries = levels(crops_cal$USAID_Country)

# define countries we don't need to plot regions separately
countries = c('Afghanistan', 'Algeria', 'Bangladesh', 'Bolivia', 'Cambodia', 
'Cape Verde', 'Colombia', 'Cuba', "Dem People's Rep of Korea", 'Djibouti', 
'Egypt', 'El Salvador', 'Equador', 'Eritrea', 'eSwatini', 'Gambia', 
'Guatemala', 'Guinea-Bissau', 'Haiti', 'Indonesia', 'Iran  (Islamic Republic of)', 
'Iraq', 'Kyrgyzstan', "Lao People's Democratic Republic", 'Lebanon', 'Lesotho', 
'Libya', 'Malawi', 'Mauritania', 'Mongolia', 'Myanmar', 'Namibia', 'Nepal', 'Nicaragua', 
'Niger', 'Pakistan', 'Peru', 'Philippines', 'Rwanda', 'Sierra Leone', 'Somalia', 
'South Africa', 'Sri Lanka', 'Sudan', 'Syrian Arab Republic', 'Tajikistan', 'Thailand', 
'Tunisia', 'Uzbekistan', 'Vietnam', 'Yemen')

crops_cal.SelectCountries = crops_cal[crops_cal$GEOGLAM_Country %in% countries, ]
crops_cal.SelectCountries = droplevels(crops_cal.SelectCountries)

crops_cal.SelectCountries = as.data.table(crops_cal.SelectCountries)
countrieslist = split(crops_cal.SelectCountries, by="USAID_Country")
#crops_cal.SelectCountries$Country_OU = as.factor(crops_cal.SelectCountries$Country_OU)

# redefine countries here to become list names (to match up with other plots)
countriesforplots = names(countrieslist)

# run loop
crop_plots = crop_plot_loop(countrieslist, countriesforplots, fontsize=9, regions=F)
#crop_plots$Afghanistan
# access like:
# crop_plots$Afghanistan
# crop_plots$Algeria

# print them
# setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
# filename = addStampToFilename("SelectCountriesAllRegionsCropPlotsRevised", "pdf")
# pdf(filename, width=11, height=8.5)
# # unpack list
# for (i in crop_plots) {
#   print(i)
#   #crop_plots$i
# }
# dev.off()

# ok, now plot the countries where we need the regions
allcountries = levels(crops_cal$GEOGLAM_Country)
other_countries = allcountries[!(allcountries %in% countries)]
crops_cal.OtherCountries = crops_cal[crops_cal$GEOGLAM_Country %in% other_countries, ]
crops_cal.OtherCountries = droplevels(crops_cal.OtherCountries)

crops_cal.OtherCountries = as.data.table(crops_cal.OtherCountries)
other_countries_list = split(crops_cal.OtherCountries, by="USAID_Country")

other_countries_list <- lapply(other_countries_list, function(x) droplevels(x))

# redefine other country list to match other plots (using USAID names)
other_countries = names(other_countries_list)

other_crop_plots = crop_plot_loop2(other_countries_list, other_countries, fontsize=9, linesize=4)

# save these objects
setwd(datadir)
filename = addStampToFilename("SelectCountriesAllRegionsCropPlots", "Robj")
saveRDS(crop_plots, filename)
filename = addStampToFilename("OtherCountriesAllRegionsCropPlots", "Robj")
saveRDS(other_crop_plots, filename)

# print them
# filename = addStampToFilename("OtherCountriesAllRegionsCropPlots", "pdf")
# 
# pdf(filename, width=11, height=8.5)
# # unpack list
# do.call(c, unlist(other_crop_plots, recursive=FALSE))
# dev.off()
