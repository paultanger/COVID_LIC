codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
setwd(datadir)

subset.alls.plot = readRDS("subset.alls.plot_20200527_1159.RObj")
subset.alls.plot = readRDS("subset.alls.plot_20200616_1524.RDS")

compartments = c("cases", "death_o")
countries = levels(subset.alls.plot$USAID_Country)
AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[USAID_Country %in% countries & compartment %in% compartments & Scenarios=="Unmitigated"]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)
PeakMedAllCntryAllScensCases = as.data.table(AllAllsData.7scens.AgeAll.SelectCountries)
as.data.frame(colnames(PeakMedAllCntryAllScensCases))
PeakMedAllCntryAllScensCases = PeakMedAllCntryAllScensCases[,c(2,7,36,41,45,48,50)]
head(PeakMedAllCntryAllScensCases, 2)

# get quick stats on dates..
# so we want to get the JHU peak date..
# keep what we need
#PeakMedAllCntryAllScensCases = subset.alls.plot[,c("age","t","scen_id","Date","date_50"):=NULL]

# get peaks 
PeakMedAllCntryAllScensCases2 = PeakMedAllCntryAllScensCases[
  PeakMedAllCntryAllScensCases[, .I[which.max(med)], by=list(region_name, USAID_Country, compartment, Scenarios)]$V1]

# get peaks for UK
PeakMedAllCntryAllScensCases1 = PeakMedAllCntryAllScensCases[,-6]
PeakMedAllCntryAllScensCases2 = PeakMedAllCntryAllScensCases1[
  PeakMedAllCntryAllScensCases1[, .I[which.max(med)], by=list(region_name, USAID_Country, compartment, Scenarios)]$V1]

# get peaks for JHU
PeakMedAllCntryAllScensCases2 = PeakMedAllCntryAllScensCases[,-7]
PeakMedAllCntryAllScensCases3 = PeakMedAllCntryAllScensCases2[
  PeakMedAllCntryAllScensCases2[, .I[which.max(med)], by=list(region_name, USAID_Country, compartment, Scenarios)]$V1]


# drop med, we just want dates
PeakMedAllCntryAllScensCases2 = PeakMedAllCntryAllScensCases2[,-4]

# drop countries with no data
PeakMedAllCntryAllScensCases2 = PeakMedAllCntryAllScensCases2[!is.na(PeakMedAllCntryAllScensCases2$Date_JHU),]

# save this
setwd(datadir)
filename = addStampToFilename("peak_cases_deaths_all_countries", "csv")
write.csv(PeakMedAllCntryAllScensCases2, filename, row.names = F)

# can do it with dt functions?
# PeakMedAllCntryAllScensCases3 = PeakMedAllCntryAllScensCases2[, peak_diff := compartment.Date_JHU - compartment.Date_JHU, keyby=.(USAID_Country, region_abbrev, Scenarios)]
# PeakMedAllCntryAllScensCases3 = PeakMedAllCntryAllScensCases2[PeakMedAllCntryAllScensCases2, on=.(Date_JHU, compartment), peak_diff := Date_JHU - i.Date_JHU, by=.(USAID_Country, region_abbrev, Scenarios)]
# PeakMedAllCntryAllScensCases3 = PeakMedAllCntryAllScensCases2[, peak_diff := Date_JHU - Date_JHU, by=.(USAID_Country, region_abbrev, Scenarios)]
# 
# data[data[condition=="dark"], on=.(measure,subject), v := score - i.score ]

# get range of peak death days
peak_death_dates = PeakMedAllCntryAllScensCases2[compartment == "death_o"]
deaths.summary = setDT(peak_death_dates)[, .(.N, Min=min(Date_UK),
                                               Median=median(Date_UK),
                                               Max=max(Date_UK)), 
                                           keyby=.(Scenarios)]

deaths.summary.region = setDT(peak_death_dates)[, .(.N, Min=min(Date_UK),
                                             Median=median(Date_UK),
                                             Max=max(Date_UK)), 
                                         keyby=.(Scenarios, region_name)]

# save these
setwd(datadir)
filename = addStampToFilename("peak_death_dates", "csv")
write.csv(deaths.summary, filename, row.names = F)

setwd(datadir)
filename = addStampToFilename("deaths.summary.region", "csv")
write.csv(deaths.summary.region, filename, row.names = F)

# make wide to calc day diff
PeaksbyCountry.wide = dcast.data.table(PeakMedAllCntryAllScensCases2, USAID_Country + region_name ~ Scenarios + compartment, value.var = "Date_UK")

# make it wide, but keep two cols so we can put into plots
PeaksbyCountry.wide.plots = dcast.data.table(PeakMedAllCntryAllScensCases2, USAID_Country + region_name + Scenarios ~ compartment, value.var = "Date_UK")

# renam cols to make it pretty
colnames(PeaksbyCountry.wide.plots) = c("USAID_Country", "Region", "Scenario", "Peak Cases", "Peak Deaths")

setwd(datadir)
filename = addStampToFilename("PeakCaseDeathDatesAllCountriesForPlots", "csv")
write.csv(PeaksbyCountry.wide.plots, filename, row.names = F)

# save this
setwd(datadir)
filename = addStampToFilename("PeakCaseDeathDatesAllCountries", "csv")
write.csv(PeaksbyCountry.wide, filename, row.names = F)

# get diffs the long way..
PeaksbyCountry.wide$unmit_diff = PeaksbyCountry.wide$Unmitigated_death_o - PeaksbyCountry.wide$Unmitigated_cases
PeaksbyCountry.wide$dist20_diff = PeaksbyCountry.wide$`20% distancing_death_o` - PeaksbyCountry.wide$`20% distancing_cases`
PeaksbyCountry.wide$dist50_diff = PeaksbyCountry.wide$`50% distancing_death_o` - PeaksbyCountry.wide$`50% distancing_cases`
PeaksbyCountry.wide$shield4080_diff = PeaksbyCountry.wide$`40/80 shielding_death_o` - PeaksbyCountry.wide$`40/80 shielding_cases`
PeaksbyCountry.wide$shield8080_diff = PeaksbyCountry.wide$`80/80 shielding_death_o` - PeaksbyCountry.wide$`80/80 shielding_cases`
PeaksbyCountry.wide$shield80dist20_diff = PeaksbyCountry.wide$`80/80 shielding, 20% distancing_death_o` - PeaksbyCountry.wide$`80/80 shielding, 20% distancing_cases`
PeaksbyCountry.wide$shield80dist50_diff = PeaksbyCountry.wide$`80/80 shielding, 50% distancing_death_o` - PeaksbyCountry.wide$`80/80 shielding, 50% distancing_cases`

# just keep diffs
as.data.frame(colnames(PeaksbyCountry.wide))
PeaksbyCountry.wide = PeaksbyCountry.wide[,c(1,2,17:23)]
head(PeaksbyCountry.wide)
# make long
PeaksbyCountry.long = melt(PeaksbyCountry.wide, id = c("USAID_Country", "region_abbrev"), variable.name = "Scenarios", value.name = "days_between_peaks")

PeaksbyCountryRegion.summary = setDT(PeaksbyCountry.long)[, .(Min=min(days_between_peaks),
                                                       Median=median(days_between_peaks),
                                                       Max=max(days_between_peaks)), 
                                                   keyby=.(Scenarios, region_abbrev, USAID_Country)]

PeaksbyRegion.summary = setDT(PeaksbyCountry.long)[, .(Min=min(days_between_peaks),
                               Median=median(days_between_peaks),
                               Max=max(days_between_peaks)), 
                               keyby=.(Scenarios, region_abbrev)]

Peaks.summary = setDT(PeaksbyCountry.long)[, .(Min=min(days_between_peaks),
                                                        Median=median(days_between_peaks),
                                                        Max=max(days_between_peaks)), 
                                                    keyby=.(Scenarios)]

Peaks.summary$diff = Peaks.summary$Max - Peaks.summary$Min

PeaksbyCountry.range = Peaks.summary[,c(1,2,4)]

# save these
#PeaksbyCountryRegion.summary
filename = addStampToFilename("PeaksbyCountryRegion.summary", "csv")
write.csv(PeaksbyCountryRegion.summary, filename, row.names = F)

#PeaksbyRegion.summary
filename = addStampToFilename("PeaksbyRegion.summary", "csv")
write.csv(PeaksbyRegion.summary, filename, row.names = F)

#Peaks.summary
filename = addStampToFilename("Peaks.summary", "csv")
write.csv(Peaks.summary, filename, row.names = F)

#PeaksbyCountry.range
filename = addStampToFilename("PeaksbyCountry.range", "csv")
write.csv(PeaksbyCountry.range, filename, row.names = F)

####### ####### ####### ####### ####### ####### ####### ####### ####### ####### 
####### get cumulative cases for 12 months
# can do this from accs files, or the final tables from their sync folders
# but I'll do it from alls file since I already have that
# numbers may be slightly diff - flag for Katie
AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[USAID_Country %in% countries & compartment %in% compartments]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)
AllCntryAllScensCasesDeaths = as.data.table(AllAllsData.7scens.AgeAll.SelectCountries)
as.data.frame(colnames(AllCntryAllScensCasesDeaths))
CumulAllCntryAllScensCasesDeaths = AllCntryAllScensCasesDeaths[,c(2,7,36,41,45)]
head(CumulAllCntryAllScensCasesDeaths, 2)

SumsCumulAllCntryAllScensCasesDeaths = setDT(CumulAllCntryAllScensCasesDeaths)[, .(Cumul_Value=sum(med)), keyby=.(region_name, USAID_Country, Scenarios, compartment)]
# SumsCumulAllCntryAllScensCasesDeaths = CumulAllCntryAllScensCasesDeaths[CumulAllCntryAllScensCasesDeaths[, sum(med), by=list(USAID_Country, Scenarios, compartment)]$V1]
# nicer col names
colnames(SumsCumulAllCntryAllScensCasesDeaths) = c("Region", "Country", "Scenario", "Parameter", "Cumululative 1 yr total")
SumsCumulAllCntryAllScensCasesDeaths$`Cumululative 1 yr total` = round(SumsCumulAllCntryAllScensCasesDeaths$`Cumululative 1 yr total`)

SumsCumulAllCntryAllScensCasesDeaths
setwd(datadir)
filename = addStampToFilename("CumulAllCntryAllScensCasesDeaths", "csv")
write.csv(SumsCumulAllCntryAllScensCasesDeaths, filename, row.names = F)

####### ####### ####### ####### ####### ####### ####### ####### ####### ####### ####### 
####### ####### ####### ####### ####### ####### ####### ####### ####### ####### ####### 
####### ####### ####### ####### ####### ####### ####### ####### ####### ####### ####### 

# load the file above
setwd(datadir)

# get min and max too
MedPeakMedAllCntryAllScensCases = PeakMedAllCntryAllScensCases[
  PeakMedAllCntryAllScensCases[, .I[which.max(med)], by=list(Country_OU, compartment,Scenarios)]$V1]
LoPeakMedAllCntryAllScensCases = PeakMedAllCntryAllScensCases[
  PeakMedAllCntryAllScensCases[, .I[which.max(lo)], by=list(Country_OU, compartment,Scenarios)]$V1]
HiPeakMedAllCntryAllScensCases = PeakMedAllCntryAllScensCases[
  PeakMedAllCntryAllScensCases[, .I[which.max(hi)], by=list(Country_OU, compartment,Scenarios)]$V1]
# put them together
Combo = cbind(LoPeakMedAllCntryAllScensCases, MedPeakMedAllCntryAllScensCases[,15], HiPeakMedAllCntryAllScensCases[,15])
# rename cols
names(Combo)[15] = 'JHU_Lo_Peak'
names(Combo)[16] = 'JHU_Med_Peak'
names(Combo)[17] = 'JHU_Hi_Peak'

# reassign to continue with below steps
PeakMedAllCntryAllScensCases2 = Combo

# TODO: could we do it together? not working yet
# MedPeaks <- PeakMedAllCntryAllScensCases[PeakMedAllCntryAllScensCases[, lapply(.SD, which.max()), .SDcols = 'med', by=list(Country_OU, compartment,Scenarios)]$V1]
# LoPeaks <- DT[, lapply(.SD, max), .SDcols = VarToMax, by = c(GrpVar1, GrpVar2)]
# HiPeaks <- DT[, lapply(.SD, max), .SDcols = VarToMax, by = c(GrpVar1, GrpVar2)]
# merge(DTmaxs, DTaves)

# drop NA
summary(PeakMedAllCntryAllScensCases2)
PeakMedAllCntryAllScensCases2 = na.omit(PeakMedAllCntryAllScensCases2, cols="Date_JHU")
PeakMedAllCntryAllScensCases2 = na.omit(PeakMedAllCntryAllScensCases2, cols="JHU_Med_Peak")
# save this in case want to use pivot tables
filename = addStampToFilename("PeakMedAllCntryAllScensCases2", "csv")
write.csv(PeakMedAllCntryAllScensCases2, filename, row.names = F)

filename = addStampToFilename("PeakMedAllCntryAllScensCases2LoHi", "csv")
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

# with combo var above
LoHiMedPeakMedAllCntryAllScens.Ranges.n.Combo = setDT(PeakMedAllCntryAllScensCases2)[, .(.N, Min=min(JHU_Lo_Peak, na.rm=T), Median=median(JHU_Med_Peak), Max=max(JHU_Hi_Peak, na.rm=T)), by=c('Continent', 'USAID_region', 'compartment', 'Scenarios')]

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

PeakMedAllCntryAllScens.min = setDT(PeakMedAllCntryAllScensCases3)[, .(.N, Min=min(Date_JHU)), by=c('Continent', 'USAID_region', 'USAID_subregion', 'compartment', 'Scenarios')]

PeakMedAllCntryAllScens.max = setDT(PeakMedAllCntryAllScensCases3)[, .(.N, Max=max(Date_JHU)), by=c('Continent', 'USAID_region', 'USAID_subregion', 'compartment', 'Scenarios')]

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

# what is death rate?
# load file
subset.alls.plot = readRDS("subset.alls.plot_20200527_1159.RObj")
compartments = c("cases", "death_o")
countries = levels(subset.alls.plot$LSHTM_Country)
AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[LSHTM_Country %in% countries & compartment %in% compartments]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)
countrieslist = split(AllAllsData.7scens.AgeAll.SelectCountries, by="USAID_Country")
AllAllsData.7scens.AgeAll.SelectCountries$USAID_Country = as.factor(AllAllsData.7scens.AgeAll.SelectCountries$USAID_Country)
countries = names(countrieslist)

death.dt = as.data.table(AllAllsData.7scens.AgeAll.SelectCountries)
death.dt = death.dt[,c(2,33,38,42)]
# dcast
death.dt.wide = dcast(death.dt, USAID_Country + Scenarios ~ compartment, value.var = "med", fun.aggregate = sum)
death.dt.wide$death_rate = (death.dt.wide$death_o / death.dt.wide$cases) * 100
# death.dt.wide = as.data.table(death.dt.wide)
# calculate
# death_rate = death.dt.wide[, as.list(summary(death.dt.wide$death_rate)), by=c('USAID_Country', 'Scenarios')]
# death_rate <- aggregate(.~Scenarios, death.dt.wide, FUN=c(min, median, max))

death.dt.wide = death.dt.wide[,c(1,2,5)]
death_rate2 <- aggregate(death_rate ~ Scenarios, data=death.dt.wide, FUN=function(x) c(min(x), median(x), max(x)))
death_rate2 <- cbind(death_rate2[,1], as.data.frame(death_rate2[,2]))
names(death_rate2) <- c("Scenario", "min", "median", "max")

# get diff between peak case and peak death day for each country and then get range
