JHUcases <- read.csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"))

# TODO: finish this
# probably make long, and then find when cases > 49
# make a simple table with each country and that date
# then update the origin date in the plot_v1 file

# also combine with Katie's region file

# ok Brian started this so let's use his
codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
setwd(datadir)

JHUcases = read.csv("JHU_first_date_50_May09.csv")

# combine with Katie's
other_sorting_cols = fread("country_folder_list_with_regions.csv", stringsAsFactors=T, drop=1, header=T)

# merge JHU country name and code into Katie's file
# well actually better to use the full JHU list (before we sorted by > 50 case countries) - that file is here:
JHUcases = read.csv("JHU_confirmed_cases_all_countries.csv")

JHUcountries = JHUcases[,c(2:4)]
# rename cols
colnames(JHUcountries) <- c("JHU_Country", "Country_OU", "Country_Code")
head(JHUcountries)
head(other_sorting_cols,2)
other_sorting_cols = merge(other_sorting_cols, JHUcountries, all=T)
# reorder cols
other_sorting_cols = other_sorting_cols[,c(2,3,4,8,1,9,5,6,7)]
# export so Katie can update later if Bangladesh is added etc
setwd(datadir)
filename = addStampToFilename('SortingColsLookupCountriesRegionsEtc', 'csv')
#write.csv(other_sorting_cols, filename, row.names = FALSE)

# try to match JHU country with USAID country based on country codes
fromUSAIDsheet = fread("COVID Data - master_country_list.csv", stringsAsFactors=T, header=T)
# and other_sorting_cols variable from above (which is JHU and UK and Katie's)

JHU_UK_Katie_USAID = merge(other_sorting_cols, fromUSAIDsheet, by.x = "Country_Code", by.y = "iso_alpha3", all=T)
# rearrange cols
as.data.frame(colnames(JHU_UK_Katie_USAID))
JHU_UK_Katie_USAIDv2 = JHU_UK_Katie_USAID[,c(2,3,4,14:16,1,5,6,10,12,8,7,13,9,17:34)]
# export to check
setwd(datadir)
filename = addStampToFilename('JHU_UK_Katie_USAIDv2', 'csv')
write.csv(JHU_UK_Katie_USAIDv2, filename, row.names = FALSE)

# ok I made some edits after discussion with Katie so this is the official version:
JHU_UK_Katie_USAIDv3 = fread("JHU_UK_Katie_USAIDv2_20200526_1150.csv", stringsAsFactors=T, header=T)

# now merge with GEOGLAM names

# add the country lookup for the GEOGLAM crop data
GEOGLAM = fread("GEOGLAM_crop_calendars_v3.csv", stringsAsFactors=T, header=T)
GEOGLAM_Countries = as.data.frame(levels(GEOGLAM$country))
colnames(GEOGLAM_Countries) = "GEOGLAM_Countries"

# export to check
setwd(datadir)
filename = addStampToFilename('GEOGLAM_Countries', 'csv')
write.csv(GEOGLAM_Countries, filename, row.names = FALSE)

# seems like merging with USAID_Country will match most, and we'll have to resolve the rest manually
JHU_UK_Katie_USAIDv3_GEO = merge(GEOGLAM_Countries, JHU_UK_Katie_USAIDv3, by.x="GEOGLAM_Countries", by.y="USAID_Country", all=T)
filename = addStampToFilename('JHU_UK_Katie_USAIDv3_GEO', 'csv')
#write.csv(JHU_UK_Katie_USAIDv3_GEO, filename, row.names = FALSE)

# ok, reimport the manually updated version
GEOGLAM = fread("GEOGLAM_Countries_20200526_1315.csv", stringsAsFactors=T, header=T)
JHU_UK_Katie_USAIDv4_GEO = merge(GEOGLAM[,c(1,2)], JHU_UK_Katie_USAIDv3, by.x="GEOGLAM_to_USAID", by.y="USAID_Country", all=T)
# check it
filename = addStampToFilename('JHU_UK_Katie_USAIDv4_GEO', 'csv')
#write.csv(JHU_UK_Katie_USAIDv4_GEO, filename, row.names = FALSE)

# looks good, rename col
names(JHU_UK_Katie_USAIDv4_GEO)[names(JHU_UK_Katie_USAIDv4_GEO) == "GEOGLAM_to_USAID"] <- "USAID_Country"

# save it!
filename = addStampToFilename('JHU_UK_Katie_USAIDv4_GEO_FINAL', 'csv')
write.csv(JHU_UK_Katie_USAIDv4_GEO, filename, row.names = FALSE)

# and continue integration of the case date in the plotv1 script as origin

