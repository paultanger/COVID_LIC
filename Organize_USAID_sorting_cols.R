codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"
plotdir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
source('plot_crop_cal_function.R')
setwd(datadir)

# RFS COVID priority countries
RFSpriority = read.csv("RFS_COVID_Priority_Countries.csv")

# some country names don't match, let's see which ones
other_sorting_cols = fread("JHU_UK_Katie_USAIDv4_GEO_FINAL_20200528_1700.csv", stringsAsFactors=T, header=T)

USAIDcountries = levels(other_sorting_cols$USAID_Country)
RFSprioritycountries = levels(RFSpriority$Countries)

# which are not in USAID country list?
ToFix = setdiff(RFSprioritycountries, USAIDcountries)

# merge with data in case we want to facet plot by these groups
other_sorting_cols2 = merge(other_sorting_cols, RFSpriority, by.x = "USAID_Country", by.y = "Countries", all=T)

# check it
merged = merged[, c(1,34)]
# export
filename = addStampToFilename("RFS_priority_to_check", "csv")
write.csv(merged, filename, row.names = F)

# looks good, now merge the other list from Katie
FocusAligned = read.csv("Priority & Aligned Countries - FTF, Resilience, FFP, Water, Nutrition.csv")

# which countries match?
FocusAlignedcountries = levels(FocusAligned$Country)
ToFix = setdiff(FocusAlignedcountries, USAIDcountries)

other_sorting_cols3 = merge(other_sorting_cols2, FocusAligned, by.x = "USAID_Country", by.y = "Country", all=T)

# export
filename = addStampToFilename("JHU_UK_Katie_USAIDv4_GEO_FINAL", "csv")
write.csv(other_sorting_cols3, filename, row.names = F)
