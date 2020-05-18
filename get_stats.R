
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

