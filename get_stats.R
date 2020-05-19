codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('plot_function.R')
source('load_libs.R')
#setwd("2020_05_05_archived_04_30_generated/afghanistan/")

# get quick stats on dates..
# so we want to get the JHU peak date..
# keep what we need
PeakMedAllCntryAllScensCases = subset.alls.plot[,c("age","t","scen_id","Date","date_50"):=NULL]

# get peaks
PeakMedAllCntryAllScensCases2 = PeakMedAllCntryAllScensCases[
  PeakMedAllCntryAllScensCases[, .I[which.max(med)], by=list(Country_OU, compartment,Scenarios)]$V1]

# drop NA
summary(PeakMedAllCntryAllScensCases2)
PeakMedAllCntryAllScensCases2 = na.omit(PeakMedAllCntryAllScensCases2, cols="Date_JHU")
# save this in case want to use pivot tables
filename = addStampToFilename("PeakMedAllCntryAllScensCases2", "csv")
write.csv(PeakMedAllCntryAllScensCases2, filename, row.names = F)

# load the file above
setwd(datadir)
PeakMedAllCntryAllScensCases2 = read.csv("official_output/PeakMedAllCntryAllScensCases2_20200517_1714.csv")
# set asdates
PeakMedAllCntryAllScensCases2$Date_JHU = as.Date(PeakMedAllCntryAllScensCases2$Date_JHU)

# instead of just cases below, just get the ranges of everything
PeakMedAllCntryAllScens.Ranges.n.etc = PeakMedAllCntryAllScensCases2[, .( Min=min(Date_JHU, na.rm=T), Median=median(Date_JHU), Max=max(Date_JHU, na.rm=T)), by=c('Continent', 'USAID_region', 'compartment', 'Scenarios')]

# but this won't work because need to get min of lo and hi dates separately
PeakMedAllCntryAllScens.Ranges.n.etc = setDT(PeakMedAllCntryAllScensCases2)[, .(.N, Min=min(Date_JHU, na.rm=T), Median=median(Date_JHU), Max=max(Date_JHU, na.rm=T)), by=c('Continent', 'USAID_region', 'compartment', 'Scenarios')]

# just med
PeakMedAllCntryAllScens.Ranges.n.etc = setDT(PeakMedAllCntryAllScensCases2)[, .(.N, Median=median(Date_JHU)), by=c('Continent', 'USAID_region', 'compartment', 'Scenarios')]

# export this
setwd(datadir)
filename = addStampToFilename("DateStats_AllCountriesBins", "csv")
write.csv(PeakMedAllCntryAllScens.Ranges.n.etc, filename, row.names = F)

# include the subregions and remove non USAID presence countries
PeakMedAllCntryAllScensCases3 = PeakMedAllCntryAllScensCases2[USAID_presence != 'N']

PeakMedAllCntryAllScens.Ranges.n.etc = setDT(PeakMedAllCntryAllScensCases3)[, .(.N, Median=median(Date_JHU)), by=c('Continent', 'USAID_region', 'USAID_subregion', 'compartment', 'Scenarios')]

# save this
setwd(datadir)
filename = addStampToFilename("DateStats_AllCountriesBinsWithSubRegionsAndPresence", "csv")
write.csv(PeakMedAllCntryAllScens.Ranges.n.etc, filename, row.names = F)

# TODO: include list of countries in the output (instead of just N)
# TODO: get min and max

# just cases
PeakMedAllCntryAllScensCases2 = PeakMedAllCntryAllScensCases2[compartment == "cases"]

# so we want the range of dates for each scenario (for all countries)
# maybe later do for USAID countries
summary(PeakMedAllCntryAllScensCases2$Date_JHU)
with(PeakMedAllCntryAllScensCases2, tapply(Date_JHU, Scenarios, range))

filename = addStampToFilename("DateStats_AllCountries", "txt")
setwd(datadir)
sink(filename)
with(PeakMedAllCntryAllScensCases2, tapply(Date_JHU, Scenarios, range))
sink()

