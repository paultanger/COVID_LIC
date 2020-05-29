codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"
plotdir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/"

setwd(codedir)
source('functions.R')
source('plot_function.R')
source('load_libs.R')
#setwd("2020_05_05_archived_04_30_generated/afghanistan/")

#alls = qread('alls.qs')
setwd(datadir)
alls = qread('AllAlls7ScensAgeAll_20200515_1422.qs')
subset.alls.plot = alls

# define factors
subset.alls.plot$Scenarios = ""
subset.alls.plot[scen_id == 1,11] <- "Unmitigated"
subset.alls.plot[scen_id == 3,11] <- "20% distancing"
subset.alls.plot[scen_id == 2,11] <- "50% distancing"
subset.alls.plot[scen_id == 5,11] <- "40/80 shielding"
subset.alls.plot[scen_id == 7,11] <- "80/80 shielding"
subset.alls.plot[scen_id == 39,11] <- "80/80 shielding, 20% distancing"
subset.alls.plot[scen_id == 23,11] <- "80/80 shielding, 50% distancing"
subset.alls.plot[, Scenarios:=as.factor(Scenarios)]
subset.alls.plot[, Country:=as.factor(Country)]

# convert to date
# set origin - will be easy to define origin for each country and pull that
origin = "2019-12-31"
subset.alls.plot$Date = as.Date(subset.alls.plot$t, origin=origin)

# ok, let's use the JHU origin when each country reported 50+ cases
# from organize JHU script:
JHUcases = fread("JHU_first_date_50_May09.csv", header=T)
JHUcasescountries = JHUcases[,c(3,5)]

#subset.alls.plot$JHU_date = as.Date(subset.alls.plot$t, origin=)
# TODO: there is probably an apply method to do this easier..
# because we are adding to a data.table we lose the date class
subset.alls.plot = merge(subset.alls.plot, JHUcasescountries, by.x = "Country", by.y = "country_folder", all.x=T)
# if date_50 is "day zero" then we just add t...
# but maybe we want t=1 to be equal to date_50 (diff of one day..)
# need to reassign date_50 as date
subset.alls.plot <- subset.alls.plot[, date_50:=as.Date(date_50, format='%m/%d/%y')]
# set t from JHU origin
subset.alls.plot$Date_JHU = subset.alls.plot$date_50 + days(subset.alls.plot$t)

#subset.alls.plot$Scenarios = with(subset.alls.plot, factor(Scenarios, ordered=T))
# levels(subset.alls.plot$scen_id)
# reorder scenarios
subset.alls.plot$Scenarios  <- factor(subset.alls.plot$Scenarios , levels = c(
                                  "Unmitigated",
                                  "20% distancing",
                                  "50% distancing",
                                  "40/80 shielding",
                                  "80/80 shielding",
                                  "80/80 shielding, 20% distancing",
                                  "80/80 shielding, 50% distancing"))

# here might be a good place to combine with other sorting variables like region?
# use this file:
setwd(datadir)
# use the newer version of sorting cols
other_sorting_cols = fread("JHU_UK_Katie_USAIDv4_GEO_FINAL_20200527_1127.csv", stringsAsFactors=T, header=T)

# use verion with IDs to add later
other_sorting_cols = fread("JHU_UK_Katie_USAIDv4_GEO_FINAL_20200528_1700.csv", stringsAsFactors=T, header=T)

# merge with data in case we want to facet plot by these groups
subset.alls.plot = merge(other_sorting_cols, subset.alls.plot, by.x = "LSHTM_Country", by.y = "Country", all=T)

# set Country cols as factors
subset.alls.plot[, LSHTM_Country:=as.factor(LSHTM_Country)]
subset.alls.plot[, USAID_Country:=as.factor(USAID_Country)]

# save object
filename = addStampToFilename('subset.alls.plot', 'RObj')
#saveRDS(subset.alls.plot, filename)

############### DO ALL ##################

# load file
#subset.alls.plot = readRDS("subset.alls.plot_20200527_1159.RObj")

# define countries to include
# TODO: adapt later to filter based on subset of other_sorting_cols
compartments = c("cases", "death_o")

# all countries
countries = levels(subset.alls.plot$USAID_Country)

# drop countries without a JHU 50 date yet
subset.alls.plot = na.omit(subset.alls.plot, cols="Date_JHU")

AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[USAID_Country %in% countries & compartment %in% compartments]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)

# just keep key cols
#as.data.frame(colnames(AllAllsData.7scens.AgeAll.SelectCountries))
RegionPeak = AllAllsData.7scens.AgeAll.SelectCountries[,c(8,34,43,46,39)]
#head(RegionPeak,3)
# we need to do something like for each day, sum the med for all countries by region
RegionPeakSumsPerDay = setDT(RegionPeak)[, .(.N, med=sum(med)), by=c('region_abbrev', 'compartment', 'Scenarios', 'Date_JHU')]

# summarize which countries
RegionCountries = as.data.frame(AllAllsData.7scens.AgeAll.SelectCountries[,c(8,3)])
RegionCountries = unique(RegionCountries)
RegionCountries = as.data.table(RegionCountries)
RegionsSummary = setDT(RegionCountries)[, .(Countries=USAID_Country), by=c('region_abbrev')]

# make a list of the subsets for each country
regionslist = split(RegionPeakSumsPerDay, by="region_abbrev")

# save object
filename = addStampToFilename('regionslist', 'RObj')
#saveRDS(regionslist, filename)
#regionslist = readRDS("regionslist_20200528_1716.RObj")

regions = names(regionslist)

# TODO: maybe change this to a data table or apply function
plots = plot_loop(regionslist, regions, compartments, fontsize=9, CI=F)

# print them
setwd(plotdir)
filename = addStampToFilename("Regions_Peak_Cases_Deaths", "pdf")

pdf(filename, width=11, height=8.5)
# unpack list
do.call(c, unlist(plots, recursive=F))
# for (i in plots) {
#   print(i)
#   #crop_plots$i
# }
dev.off()

# save object
#filename = addStampToFilename('peak_plots_list', 'RObj')
#saveRDS(plots, filename)
