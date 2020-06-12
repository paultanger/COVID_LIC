# this uses the UK group model version 3 data (June 2020)
codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"
plotdir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
require(plyr)
setwd(datadir)

# set directory
setwd(codedir)
TheDir = "2020_06_11_archive/AFG"
# get list of files
peaks <- sort(list.files(dirname(TheDir), "peak.qs", full.names = TRUE, recursive = TRUE))
alls <- sort(list.files(dirname(TheDir), "alls.qs", full.names = TRUE, recursive = TRUE))

# get country names from directories
countries = as.vector(list.files(dirname(TheDir)))

# name the file list vector
names(peaks) <- countries
names(alls) <- countries

# disable scinot
options(scipen=999)

# combine into one df
AllPeakData = ldply(peaks, qread)
# this is too big to do at once
#AllAllsData = ldply(alls, qread)
alls1 = alls[1:49]
alls2 = alls[50:98]
AllAllsData1 = ldply(alls1, qread)
AllAllsData1 = setDT(AllAllsData1)
setwd(datadir)
filename = addStampToFilename('AllAllSData1', 'qs')
qsave(AllAllsData1, filename)
# subset it
AllAllsData1.11scens.AgeAll = AllAllsData1[age == "all" & scen_id %in% c(1,2,14,27,42,39,44,45,49,50,51) & compartment %in% c("cases", "death_o")]

# do with part 2
AllAllsData2 = ldply(alls2, qread)
AllAllsData2 = setDT(AllAllsData2)
setwd(datadir)
filename = addStampToFilename('AllAllSData2', 'qs')
qsave(AllAllsData2, filename)
# subset it
AllAllsData2.11scens.AgeAll = AllAllsData1[age == "all" & scen_id %in% c(1,2,14,27,42,39,44,45,49,50,51) & compartment %in% c("cases", "death_o")]
# try combine them
AllAllsData = c(AllAllsData1, AllAllsData2)

########### OLD ###############
# convert to data tables
AllPeakData = setDT(AllPeakData)
AllAllsData = setDT(AllAllsData)

# save as qs files for later
setwd(datadir)
filename = addStampToFilename('AllPeakData', 'qs')
qsave(AllPeakData, filename)
filename = addStampToFilename('AllAllSData', 'qs')
qsave(AllAllsData, filename)

# subset alls to just 11 and just all ages group and just cases and deaths
AllAllsData.7scens.AgeAll = AllAllsData[age == "all" & scen_id %in% c(1,2,14,27,42,39,44,45,49,50,51) & compartment %in% c("cases", "death_o")]

AllAllsData.7scens.AgeAll = droplevels(AllAllsData.7scens.AgeAll)
setnames(AllAllsData.7scens.AgeAll, ".id", "Country")

# save this, for plotting and possibly other things
filename = addStampToFilename('AllAlls11ScensAgeAll', 'qs')
qsave(AllAllsData.7scens.AgeAll, filename)

