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
write.csv(other_sorting_cols, filename, row.names = FALSE)

# here is a new version
other_sorting_cols2 = fread("SortingCols_From_USAID_v1.csv", stringsAsFactors=F, header=T)
other_sorting_cols3 = fread("SortingColsLookupCountriesRegionsEtc_20200519_0839.csv", stringsAsFactors=F, header=T)

# merge these two versions to check
other_sorting_cols4 = merge(other_sorting_cols2, other_sorting_cols3, by.x="JHU_name", by.y="JHU_Country", all=T)
setwd(datadir)
filename = addStampToFilename('SortingColsLookupCountriesRegionsEtcv2', 'csv')
write.csv(other_sorting_cols4, filename, row.names = FALSE)

# check with Katie which to keep

# and continue integration of the case date in the plotv1 script as origin

