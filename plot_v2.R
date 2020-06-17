codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('plot_function.R')
source('load_libs.R')

setwd(datadir)
alls = qread('AllAlls11ScensAgeAll_20200612_1532.qs')
subset.alls.plot = alls

# define factors
subset.alls.plot$Scenarios = ""
subset.alls.plot[scen_id == 1,11] <- "Unmitigated"
subset.alls.plot[scen_id == 2,11] <- "20% distancing"
subset.alls.plot[scen_id == 14,11] <- "60% distancing"
subset.alls.plot[scen_id == 27,11] <- "40% in-home elder shielding"
subset.alls.plot[scen_id == 42,11] <- "40% shielding, 80% reduction"
subset.alls.plot[scen_id == 39,11] <- "60% shielding, 60% reduction"
subset.alls.plot[scen_id == 44,11] <- "80% shielding, 80% reduction"
subset.alls.plot[scen_id == 45,11] <- "PHSM, school closure, lockdowns"
subset.alls.plot[scen_id == 49,11] <- "30 day 50% lockdown, PHSM"
subset.alls.plot[scen_id == 50,11] <- "60 day 50% lockdown, PHSM"
subset.alls.plot[scen_id == 51,11] <- "90 day 50% lockdown, PHSM"

subset.alls.plot[, Scenarios:=as.factor(Scenarios)]
subset.alls.plot[, Country:=as.factor(Country)]


# convert to date
# set origin - will be easy to define origin for each country and pull that
origin = "2019-12-31"
subset.alls.plot$Date = as.Date(subset.alls.plot$t, origin=origin)

# ok, let's use the JHU origin when each country reported 50+ cases
# from organize JHU script:
JHUcases = fread("JHU_first_date_50_May09.csv", header=T)
JHUcasescountries = JHUcases[,c(4,5)]

#subset.alls.plot$JHU_date = as.Date(subset.alls.plot$t, origin=)
# TODO: there is probably an apply method to do this easier..
# because we are adding to a data.table we lose the date class
subset.alls.plot = merge(subset.alls.plot, JHUcasescountries, by.x = "Country", by.y = "ISO3", all.x=T)
# if date_50 is "day zero" then we just add t...
# but maybe we want t=1 to be equal to date_50 (diff of one day..)
# need to reassign date_50 as date
subset.alls.plot <- subset.alls.plot[, date_50:=as.Date(date_50, format='%m/%d/%y')]
# set t from JHU origin
subset.alls.plot$Date_JHU = subset.alls.plot$date_50 + days(subset.alls.plot$t)

# also add day zero estimates
dayzero = read.csv("day0_From_Carl_2020_06_12.csv")
subset.alls.plot = merge(subset.alls.plot, dayzero[,c(1,2)], by.x = "Country", by.y = "iso", all.x=T)
subset.alls.plot$date = as.Date(subset.alls.plot$date)
subset.alls.plot$Date_UK = subset.alls.plot$date + days(subset.alls.plot$t)

#subset.alls.plot$Scenarios = with(subset.alls.plot, factor(Scenarios, ordered=T))
# levels(subset.alls.plot$scen_id)
# reorder scenarios
subset.alls.plot$Scenarios  <- factor(subset.alls.plot$Scenarios , levels = c(
                                  "Unmitigated",
                                  "20% distancing",
                                  "60% distancing",
                                  "40% in-home elder shielding",
                                  "40% shielding, 80% reduction",
                                  "60% shielding, 60% reduction",
                                  "80% shielding, 80% reduction",
                                  "PHSM, school closure, lockdowns",
                                  "30 day 50% lockdown, PHSM",
                                  "60 day 50% lockdown, PHSM",
                                  "90 day 50% lockdown, PHSM"))

# here might be a good place to combine with other sorting variables like region?
# use this file:
setwd(datadir)
# use the newer version of sorting cols
other_sorting_cols = fread("JHU_UK_Katie_USAIDv4_GEO_FINAL_20200529_1529.csv", stringsAsFactors=T, header=T)

# merge with data in case we want to facet plot by these groups
subset.alls.plot = merge(other_sorting_cols, subset.alls.plot, by.x = "Country_Code", by.y = "Country", all=T)

# set Country cols as factors
subset.alls.plot[, LSHTM_Country:=as.factor(LSHTM_Country)]
subset.alls.plot[, USAID_Country:=as.factor(USAID_Country)]

# save object
filename = addStampToFilename('subset.alls.plot', 'RDS')
#saveRDS(subset.alls.plot, filename)

############### DO ALL ##################

# load file
subset.alls.plot = readRDS("subset.alls.plot_20200616_1524.RDS")

# define countries to include
# TODO: adapt later to filter based on subset of other_sorting_cols
#countries = c("afghanistan", "ethiopia")
# compartments = c("cases", "death_o")
compartments = c("cases")
# countries = c("afghanistan")

# all countries
subset.alls.plot[, Country_Code:=as.factor(Country_Code)]
countries = levels(subset.alls.plot$Country_Code)

# drop countries without a JHU 50 date yet
subset.alls.plot = na.omit(subset.alls.plot, cols="Date_JHU")

AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[Country_Code %in% countries & compartment %in% compartments]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)

# save object
filename = addStampToFilename('AllAllsData.11scens.AgeAll.SelectCountries.WithUKdate', 'RObj')
#saveRDS(AllAllsData.7scens.AgeAll.SelectCountries, filename)
AllAllsData.7scens.AgeAll.SelectCountries = readRDS("AllAllsData.11scens.AgeAll.SelectCountries.WithUKdate_20200616_1525.RObj")

# make a list of the subsets for each country
countrieslist = split(AllAllsData.7scens.AgeAll.SelectCountries, by="USAID_Country")
AllAllsData.7scens.AgeAll.SelectCountries$USAID_Country = as.factor(AllAllsData.7scens.AgeAll.SelectCountries$USAID_Country)
# countries = levels(AllAllsData.7scens.AgeAll.SelectCountries$LSHTM_Country)
# use USAID names (which will become the list names)
countries = names(countrieslist)

# run again with to get plot objects
plots = plot_loop(countrieslist, countries, compartments, fontsize=9, CI=F, regions_plotting=F, smoothing=T)
plots$Afghanistan$cases

# save object
filename = addStampToFilename('peak_plots_listJHU', 'RObj')
#saveRDS(plots, filename)

# with UK dates
plotsUK = plot_loop(countrieslist, countries, compartments, fontsize=9, CI=F, regions_plotting=F, smoothing=T)
plotsUK$Afghanistan$cases

# save object
setwd(datadir)
filename = addStampToFilename('peak_plots_listUKSmooth', 'RObj')
#saveRDS(plotsUK, filename)
plotsUK = readRDS("peak_plots_listUKSmooth.RObj")

# print them
setwd(plotdir)
filename = addStampToFilename("PeakPlotsJHU", "pdf")
pdf(filename, width=11, height=8.5)
for (i in plots) {
  print(i)
}
dev.off()

filename = addStampToFilename("PeakPlotsUKsmooth", "pdf")
pdf(filename, width=11, height=8.5)
for (i in plotsUK) {
  print(i)
}
dev.off()