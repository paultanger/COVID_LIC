require(data.table)
require(qs)
require(plyr)

setwd("~/Desktop/github/COVID_LIC")
source('functions.R')

# set directory
setwd("~/Desktop/github/COVID_LIC/")
TheDir = "2020_05_05_archived_04_30_generated/"
# get list of files
peaks <- sort(list.files(dirname(TheDir), "peak.qs", full.names = TRUE, recursive = TRUE))
alls <- sort(list.files(dirname(TheDir), "alls.qs", full.names = TRUE, recursive = TRUE))

# get country names from directories
countries = as.vector(list.files(TheDir))

# name the file list vector
names(peaks) <- countries
names(alls) <- countries

# combine into one df
AllPeakData = ldply(peaks, qread)
AllAllsData = ldply(alls, qread)

# convert to data tables
AllPeakData = setDT(AllPeakData)
AllAllsData = setDT(AllAllsData)

# disable scinot
options(scipen=999)

# save as qs files for later
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/")
filename = addStampToFilename('AllPeakData', 'qs')
qsave(AllPeakData, filename)
filename = addStampToFilename('AllAllSData', 'qs')
qsave(AllAllsData, filename)

# subset alls to just 7 and just all ages group and just cases and deaths
AllAllsData.7scens.AgeAll = AllAllsData[age == "all" & scen_id %in% c(1,3,2,5,7,39,23) & compartment %in% c("cases", "death_o")]

AllAllsData.7scens.AgeAll = droplevels(AllAllsData.7scens.AgeAll)
setnames(AllAllsData.7scens.AgeAll, ".id", "Country")

# save this, for plotting and possibly other things
filename = addStampToFilename('AllAlls7ScensAgeAll', 'qs')
qsave(AllAllsData.7scens.AgeAll, filename)

