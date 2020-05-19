library(foreign)    # for read/write function for STATA
library(sdcMicro)	  # sdcMicro package
library(dplyr)      # for data manipulation 

library(readr)      # for reading in 'flat' files
library(ggplot2)    # for graphs
library(data.table) # for big tables
library(readxl)     # for reading excel sheets
library(doBy)       # for deleting extra members from a household/ summarize data

library(sqldf)

library(qs)

setwd("C:/Users/bgeistwhite/Documents/Docs/dev/Ad_hoc/London School")


########

zero <- qs::qread("./covidm_hpc_output/countries/ethiopia/001.qs")
accs <- qs::qread("./covidm_hpc_output/countries/ethiopia/accs.qs")
alls <- qs::qread("./covidm_hpc_output/countries/ethiopia/alls.qs")
peak <- qs::qread("./covidm_hpc_output/countries/ethiopia/peak.qs")

summary(peak)

table(peak$metric)
table(peak$compartment)
table(peak$scen_id)

table(peak$metric, peak$compartment)

table(peak$metric, peak$compartment, peak$scen_id)

table(accs$metric, accs$compartment)

###

scendata      <- readRDS("./Country_Modelling_Reports/scenarios.rds")
scenkey <- readRDS("./Country_Modelling_Reports/scenarios_overview.rds")

scen_order <- c(
  1,
  scenkey[ scen == 2 & s == 2, index],
  scenkey[ scen == 2 & s == 1, index],
  scenkey[ scen == 3 & s == 2, index],
  scenkey[ scen == 3 & s == 4, index],
  scenkey[ scen == 4 & s == 20, index],
  scenkey[ scen == 4 & s == 4, index]
)

scens <- cbind.data.frame(scen_order, c(  "Unmitigated",
                                 "20% distancing",
                                 "50% distancing",
                                 "40/80 shielding",
                                 "80/80 shielding",
                                 "80/80 shielding, 20% distancing",
                                 "80/80 shielding, 50% distancing") )
names(scens) <- c('index', 'description')
write.csv(scens, "./mod/named_scenario_ids.csv", row.names=FALSE)

# scens <- plyr::rename(scens, c('V1'='index', 'V2'='description'))

# scenkey <- add_column(scenkey, description = NA)

scenkey <- left_join(x=scenkey, y=scens, by="index")
scenkey <- dplyr::select(scenkey, -s, -scen)

scen_done <- plyr::rename(scenkey, c("index"="scen_id"))


################ COUNTRIES #########

#lmic.countries <- c(
# Folder list is from list in the London School list, with minor errors removed
countries <- c(
  "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso",
  "Burundi", "Cabo Verde", "Cameroon", "Central African Republic",
  "Chad", "Comoros", "Congo", "Cote d'Ivoire",
  "Dem. Republic of the Congo", "Djibouti", "Egypt",
  "Equatorial Guinea", "Eritrea", "Eswatini", "Ethiopia", "Gabon",
  "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Kenya", "Lesotho",
  "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania",
  "Mauritius", "Morocco", "Mozambique", "Namibia", "Niger",
  "Nigeria", "Rwanda", "Senegal", "Seychelles",
  "Sierra Leone", "Somalia", "South Africa", "South Sudan",
  "Sudan", "Tunisia", "Uganda", "United Republic of Tanzania",
  "Zambia", "Zimbabwe", "Cambodia", "Afghanistan",
  
  "Bahrain",  "Iran",  "Iraq",  "Israel",  "Jordan",  "Kuwait",  "Lebanon",
  "Oman",  "Palestine",  "Qatar",  "Saudi Arabia",  "Syrian Arab Republic",  "Turkey",
  "United Arab Emirates",  "Yemen"
)

c_folds <- tolower(countries)
c_folds <- gsub(" ", "", c_folds, fixed = TRUE)
c_folds <- gsub("'", "", c_folds, fixed = TRUE)
c_folds <- gsub(".", "", c_folds, fixed = TRUE)
c_folds <- gsub("-", "", c_folds, fixed = TRUE)
c_folds <- sort(c_folds)

write.csv(c_folds,  "./mod/country_folder_list.csv", row.names=TRUE)

################## Combine the countries / outputs #############

# "alls" takes like 15 minutes to run
filecodes <- c("peak", "accs", "alls")

### All the data in one place
for (f in filecodes) {
  rm(together)
  for (kountry in c_folds) {
    results <- qs::qread( paste0("./covidm_hpc_output/countries/", kountry, "/", f, ".qs")) 
    results <- as.data.frame( add_column(results, .before="scen_id", country=kountry) )

    if (!exists("together")) {
      together <- results   
    } else {
      together <- plyr::rbind.fill(together, results)
    }
  }
  
  together <- left_join(x=together, y=scen_done, by="scen_id")
  write.csv(together,  paste0("./mod/", f, "_all.csv"), row.names=FALSE)
}

filecodes <- c("alls")

### All the data in one place
for (f in filecodes) {
  rm(together)
  for (kountry in c_folds) {
    results <- qs::qread( paste0("./covidm_hpc_output/countries/", kountry, "/", f, ".qs")) 
    results <- as.data.frame( add_column(results, .before="scen_id", country=kountry) )
    
    if (!exists("together")) {
      together <- results   
    } else {
      together <- plyr::rbind.fill(together, results)
    }
  }
  
  together2 <- left_join(x=together, y=scen_done, by="scen_id")
  #write.csv(together,  paste0("./mod/", f, "_all.csv"), row.names=FALSE)
}


# TODO make this drop output into country folders
for (f in filecodes) {
  rm(together)
  for (kountry in c('afghanistan')) {
    results <- qs::qread( paste0("./covidm_hpc_output/countries/", kountry, "/", f, ".qs")) 
    results <- as.data.frame( add_column(results, .before="scen_id", country=kountry) )
    
    if (!exists("together")) {
      together <- results   
    } else {
      together <- plyr::rbind.fill(together, results)
    }
  }
  
  together <- left_join(x=together, y=scen_done, by="scen_id")
  write.csv(together,  paste0("./mod/outputs_augmented/", f, "_all.csv"), row.names=FALSE)
}


################################# JHU data - cases reaching 50

# First sheet from the Data Services Hopkins COVID extract
JHU <- openxlsx::read.xlsx("./Data/JHU data.xlsx")

JHU <- plyr::rename(JHU, c("Table.Names" = "Table_Names", "Epi.Metric.Name"="Epi_Metric_Name",
                           "Epi.Metric.Value"="Epi_Metric_Value", "Country/Region"="Country_Region"))

confirmed <- subset(JHU, Epi_Metric_Name == "Confirmed")

confirmed <- add_column(confirmed, country_folder=NA, .before="iso2" )
confirmed$country_folder <- tolower(confirmed$Country_Region)
confirmed$country_folder <- gsub(" ", "", confirmed$country_folder, fixed = TRUE)
confirmed$country_folder <- gsub("'", "", confirmed$country_folder, fixed = TRUE)
confirmed$country_folder <- gsub(".", "", confirmed$country_folder, fixed = TRUE)
confirmed$country_folder <- gsub("-", "", confirmed$country_folder, fixed = TRUE)
#confirmed$country_folder <- sort(confirmed$country_folder)

confirmed$country_folder <- gsub("congo(brazzaville)", "congo",                    confirmed$country_folder, fixed = TRUE)
confirmed$country_folder <- gsub("congo(kinshasa)",    "demrepublicofthecongo",    confirmed$country_folder, fixed = TRUE)
confirmed$country_folder <- gsub("syria",              "syrianarabrepublic",       confirmed$country_folder, fixed = TRUE)
confirmed$country_folder <- gsub("tanzania",           "unitedrepublicoftanzania", confirmed$country_folder, fixed = TRUE)

# cf <- sqldf("select distinct country_folder from confirmed
#                     order by country_folder")
# write.csv(cf, "./mod/manually_merging_countries_2.csv")



first_day <- sqldf("select Country_Region, country_folder, min(iso3) as ISO3, min(Date) as date_50 
                    from confirmed
                    where Epi_Metric_Value >= 50
                    group by Country_Region")


JHU_countries <- sqldf("select distinct Country_Region from confirmed")

other_countries <- left_join(x = JHU_countries, y = first_day, by = "Country_Region")
other_countries <- sqldf("select Country_Region from other_countries
                         where date_50 is null")

last_count <- sqldf("select c.Country_Region, country_folder, min(iso3) as ISO3, max(Epi_Metric_Value) as latest_confirmed_cases
                    from other_countries o
                    inner join confirmed c on o.Country_Region = c.Country_Region
                    group by c.Country_Region")

full_JHU <- sqldf("select Country_Region, country_folder, min(iso3) as ISO3, max(Epi_Metric_Value) as latest_confirmed_cases
                    from confirmed
                    group by Country_Region")

write.csv(first_day,  "./mod/JHU_first_date_50_May09.csv")
write.csv(last_count, "./mod/JHU_confirmed_cases_below_50_May09.csv")
write.csv(full_JHU,   "./mod/JHU_confirmed_cases_all_countries.csv")


####################
# compartment: always 6: cases  death_o        E nonicu_p    icu_p   hosp_p

fullpeak = subset(peak, peak$age=="all") # 5metric*6comp*50scen
fullpeak = subset(fullpeak, fullpeak$compartment=="cases")

head(fullpeak,20)
#scen_id 2-51

table(fullpeak$metric) # value, reduction, effectiveness, timing, delay

fullaccs = subset(accs, accs$age=="all") # per 3metric*6compartment*6t*50scen
head(fullaccs,20)

table(fullaccs$metric) # value, reduction, effectiveness
table(fullaccs$compartment)
table(fullaccs$scen_id) #2-51
table(fullaccs$t) #3-30s, 3-180s, c108


fullalls = subset(alls, alls$age=="all")
head(fullalls,20)

table(fullalls$compartment) 
table(fullalls$scen_id) # 1-51
table(fullalls$t) # 1-365, c306

# fullzero = subset(zero, zero$age=="all")
# head(fullzero,20)

table(zero$compartment) # doesn't have hosp, does have empties: Si, Ip, Is, Ia, R, subclinical
table(zero$run) # 1-500, weird counts
table(zero$t) # 0-365



##########################################################################################
############################# Plotting / subsetting / tables / etc #######################
##########################################################################################

#select country, peak estimate, day0, added days, result date?
  
############

# cumulative cases/deaths

# [histograms looking at compartments]
hist(table(fullalls[fullalls$compartment == 'E']$med), breaks=4000, xlim=c(0, 20),ylim=c(0, 300))

hist(table(fullalls[fullalls$compartment == 'cases']$med), breaks=4000, xlim=c(0, 20),ylim=c(0, 600))


try <- sqldf("
select med, country
from full_alls
where compartment=='death_o' and age='all' and country='afghanistan'")

cum_death <- sqldf("
select t, med, country, description
from full_alls
where compartment=='death_o' and age='all' and scen_id=23
order by country, scen_id, t")

cum_death2 <- sqldf("
select sum(med) as CumulativeDeaths, country, description
from cum_death
group by country")


cum_case <- sqldf("
select t, med, country, description
from full_alls
where compartment=='cases' and age='all' and scen_id=23
order by country, scen_id, t")

cum_case2 <- sqldf("
select sum(med) as CumulativeCases, country, description
from cum_case
group by country")

write.csv(cum_death2, "./mod/end_user/cumulative_deaths_by_country_scen23.csv")
write.csv(cum_case2, "./mod/end_user/cumulative_cases_by_country_scen23.csv")

####################
partial <- sqldf("
select *
from full_alls
where compartment=='cases' and age='all' and country='afghanistan'")

weird <- subset(partial,partial$hi.hi < partial$med)

sqldf("
select *
from partial
where hi.hi < med")


# full_alls[full_alls$med == max(full_alls$med)]
# hello = full_alls$med == max(full_alls$med)
# 
# hello <- subset(full_alls,  full_alls$med == max(full_alls$med))
