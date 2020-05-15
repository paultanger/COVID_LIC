codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('plot_function.R')
#setwd("2020_05_05_archived_04_30_generated/afghanistan/")

require(qs)
#alls = qread('alls.qs')
setwd(datadir)
alls = qread('AllAlls7ScensAgeAll_20200514_1709.qs')
subset.alls.plot = alls

# first test with afghanistan all ages 
# use the alls file

# subset for testing
#subset.alls.plot = alls[(alls$compartment =='cases') & (alls$age == "all") & (alls$scen_id %in% c(1,3,2,5,7,23,39)), ]

# define factors

subset.alls.plot$Scenarios = ""
subset.alls.plot[scen_id == 1,11] <- "Unmitigated"
subset.alls.plot[scen_id == 3,11] <- "20% distancing"
subset.alls.plot[scen_id == 2,11] <- "50% distancing"
subset.alls.plot[scen_id == 5,11] <- "40/80 shielding"
subset.alls.plot[scen_id == 7,11] <- "80/80 shielding"
subset.alls.plot[scen_id == 39,11] <- "80/80 shielding, 20% distancing"
subset.alls.plot[scen_id == 23,11] <- "80/80 shielding, 50% distancing"

subset.alls.plot <- subset.alls.plot[, Scenarios:=as.factor(Scenarios)]

# convert to date

# set origin - will be easy to define origin for each country and pull that
origin = "2019-12-31"
subset.alls.plot$Date = as.Date(subset.alls.plot$t, origin=origin)
  
#subset.alls.plot$Scenarios = with(subset.alls.plot, factor(Scenarios, ordered=T))
# levels(subset.alls.plot$scen_id)
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
other_sorting_cols = fread("country_folder_list_with_regions.csv", stringsAsFactors=T, drop=1, header=T)

# set titles
mytitle = "Afghanistan symptomatic cases over time"
myxlab = "Date (days since day zero)"
myylab = "Number of cases"

PlotObj = mydotplotv1(subset.alls.plot, mytitle, myxlab, myylab, fontsize=12, pointsize=4)
PlotObj

# save it
filename = addStampToFilename('Afghanistan_Cases_Time_v3', 'pdf')
# set data dir
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/")

#ggsave(filename, PlotObj, width=7, height=6, units="in", scale=1.5)
ggsave(filename, PlotObj)

# define countries to include
countries = c("afghanistan", "ethiopia")
compartments = c("cases")
AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[Country %in% countries & compartment %in% compartments]

# named list
countrieslist = list("afghanistan", "ethiopia")
names(countrieslist) = countries

# drop levels
library(reshape2)

i= 1
for(i in i:length(countrieslist)){
  # name the file
  filename = addStampToFilename(paste0(names(countrieslist[i]), "_cases_", "_AgeAll"), "pdf")
  #jpeg(filename, width=15, height=15, units="in", res=150, quality=90)
  # subset data
  tempdata = AllAllsData.7scens.AgeAll.SelectCountries[compartment %in% compartments]
  # make the plot
  PlotObj = mydotplotv1(subset.alls.plot, mytitle, myxlab, myylab, fontsize=12, pointsize=4)
  ggsave(filename, PlotObj)
}