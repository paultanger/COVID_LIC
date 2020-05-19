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

# make a copy from the last run
full_alls <- together

################################# JHU data - cases reaching 50

# First sheet from the Data Services Hopkins COVID extract
JHU <- openxlsx::read.xlsx("./Data/JHU data.xlsx")

JHU <- plyr::rename(JHU, c("Table.Names" = "Table_Names", "Epi.Metric.Name"="Epi_Metric_Name",
                           "Epi.Metric.Value"="Epi_Metric_Value", "Country/Region"="Country_Region"))

confirmed <- subset(JHU, Epi_Metric_Name == "Confirmed")

# Process the country data
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


##########################################################################################
############################# Plotting / subsetting / tables / etc #######################
##########################################################################################

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

