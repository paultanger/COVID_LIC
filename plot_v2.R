codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('plot_function.R')
source('load_libs.R')
#setwd("2020_05_05_archived_04_30_generated/afghanistan/")

#alls = qread('alls.qs')
setwd(datadir)
alls = qread('AllAlls7ScensAgeAll_20200515_1422.qs')
subset.alls.plot = alls

# define factors
subset.alls.plot$Scenarios = ""
subset.alls.plot[scen_id == 1,11] <- "Unmitigated"
subset.alls.plot[scen_id == 3,11] <- "20% distancing"
subset.alls.plot[scen_id == 2,11] <- "50% distancing"
subset.alls.plot[scen_id == 5,11] <- "40/80 shielding"
subset.alls.plot[scen_id == 7,11] <- "80/80 shielding"
subset.alls.plot[scen_id == 39,11] <- "80/80 shielding, 20% distancing"
subset.alls.plot[scen_id == 23,11] <- "80/80 shielding, 50% distancing"
subset.alls.plot[, Scenarios:=as.factor(Scenarios)]
subset.alls.plot[, Country:=as.factor(Country)]


# convert to date
# set origin - will be easy to define origin for each country and pull that
origin = "2019-12-31"
subset.alls.plot$Date = as.Date(subset.alls.plot$t, origin=origin)

# ok, let's use the JHU origin when each country reported 50+ cases
# from organize JHU script:
JHUcases = fread("JHU_first_date_50_May09.csv", header=T)
JHUcasescountries = JHUcases[,c(3,5)]

#subset.alls.plot$JHU_date = as.Date(subset.alls.plot$t, origin=)
# TODO: there is probably an apply method to do this easier..
# because we are adding to a data.table we lose the date class
subset.alls.plot = merge(subset.alls.plot, JHUcasescountries, by.x = "Country", by.y = "country_folder", all.x=T)
# if date_50 is "day zero" then we just add t...
# but maybe we want t=1 to be equal to date_50 (diff of one day..)
# need to reassign date_50 as date
subset.alls.plot <- subset.alls.plot[, date_50:=as.Date(date_50, format='%m/%d/%y')]
# set t from JHU origin
subset.alls.plot$Date_JHU = subset.alls.plot$date_50 + days(subset.alls.plot$t)

  
#subset.alls.plot$Scenarios = with(subset.alls.plot, factor(Scenarios, ordered=T))
# levels(subset.alls.plot$scen_id)
# reorder scenarios
subset.alls.plot$Scenarios  <- factor(subset.alls.plot$Scenarios , levels = c(
                                  "Unmitigated",
                                  "20% distancing",
                                  "50% distancing",
                                  "40/80 shielding",
                                  "80/80 shielding",
                                  "80/80 shielding, 20% distancing",
                                  "80/80 shielding, 50% distancing"))

# here might be a good place to combine with other sorting variables like region?
# use this file:
setwd(datadir)
# other_sorting_cols = fread("country_folder_list_with_regions.csv", stringsAsFactors=T, drop=1, header=T)
# 
# head(subset.alls.plot,2)
# head(other_sorting_cols,2)

# use the newer version of sorting cols
other_sorting_cols = fread("JHU_UK_Katie_USAIDv4_GEO_FINAL_20200529_1529.csv", stringsAsFactors=T, header=T)

# merge with data in case we want to facet plot by these groups
subset.alls.plot = merge(other_sorting_cols, subset.alls.plot, by.x = "LSHTM_Country", by.y = "Country", all=T)

# set Country cols as factors
subset.alls.plot[, LSHTM_Country:=as.factor(LSHTM_Country)]
subset.alls.plot[, USAID_Country:=as.factor(USAID_Country)]

# save object
filename = addStampToFilename('subset.alls.plot', 'RObj')
#saveRDS(subset.alls.plot, filename)

####### TEST WITH ONE ############
# set titles
# mytitle = "Afghanistan symptomatic cases over time"
# myxlab = "Date (days since day zero)"
# myylab = "Number of cases"
# PlotObj = mydotplotv1(subset.alls.plot, mytitle, myxlab, myylab, fontsize=12, pointsize=4)
# PlotObj
# # save it
# filename = addStampToFilename('Afghanistan_Cases_Time_v3', 'pdf')
# # set data dir
# setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
# #ggsave(filename, PlotObj, width=7, height=6, units="in", scale=1.5)
# ggsave(filename, PlotObj)

############### DO ALL ##################

# load file
subset.alls.plot = readRDS("subset.alls.plot_20200527_1159.RObj")

# define countries to include
# TODO: adapt later to filter based on subset of other_sorting_cols
#countries = c("afghanistan", "ethiopia")
# compartments = c("cases", "death_o")
compartments = c("cases")
# countries = c("afghanistan")

# all countries
countries = levels(subset.alls.plot$LSHTM_Country)

# drop countries without a JHU 50 date yet
subset.alls.plot = na.omit(subset.alls.plot, cols="Date_JHU")

AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[LSHTM_Country %in% countries & compartment %in% compartments]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)

# save object
filename = addStampToFilename('AllAllsData.7scens.AgeAll.SelectCountries', 'RObj')
#saveRDS(AllAllsData.7scens.AgeAll.SelectCountries, filename)
AllAllsData.7scens.AgeAll.SelectCountries = readRDS("AllAllsData.7scens.AgeAll.SelectCountries_20200602_1552.RObj")

# make a list of the subsets for each country
countrieslist = split(AllAllsData.7scens.AgeAll.SelectCountries, by="USAID_Country")
AllAllsData.7scens.AgeAll.SelectCountries$USAID_Country = as.factor(AllAllsData.7scens.AgeAll.SelectCountries$USAID_Country)
# countries = levels(AllAllsData.7scens.AgeAll.SelectCountries$LSHTM_Country)
# use USAID names (which will become the list names)
countries = names(countrieslist)

# TODO: maybe change this to a data table or apply function
#setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
#plots = plot_loop(countrieslist, countries, compartments, fontsize=10)

# print them
# filename = addStampToFilename("AllCountriesAgeAllCasesDeaths_JHU50", "pdf")
# 
# pdf(filename, width=11, height=8.5)
# # unpack list
# do.call(c, unlist(plots, recursive=FALSE))
# dev.off()

# or use this method:
# run again with to get plot objects
plots = plot_loop(countrieslist, countries, compartments, fontsize=9, CI=F, regions_plotting=F)
plots$Afghanistan$cases

# save object
filename = addStampToFilename('peak_plots_list', 'RObj')
#saveRDS(plots, filename)

setwd(datadir)
mylegend = ggplotlegend(plots$afghanistan$death_o[[1]])
#mylegend = mylegend + theme(legend.position = "right")
case_death_plots = arrangeGrob(mylegend, nrow=2, heights=c(1,10), # makes a small row for the legend at top, and big row for plots..
                         arrangeGrob( 
                           plots$afghanistan$cases[[1]] + theme(legend.position="none"),
                           plots$afghanistan$death_o[[1]] + theme(legend.position="none"),
                           ncol=2)) # defines columns for plots only
ggsave("test.pdf", case_death_plots)
plots$afghanistan$cases[[1]]

# plot with points for peak deaths date
# will need data for both cases and deaths, so need to re-run
# load file
subset.alls.plot = readRDS("subset.alls.plot_20200527_1159.RObj")
compartments = c("cases", "death_o")
countries = levels(subset.alls.plot$LSHTM_Country)
AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[LSHTM_Country %in% countries & compartment %in% compartments]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)
countrieslist = split(AllAllsData.7scens.AgeAll.SelectCountries, by="USAID_Country")
AllAllsData.7scens.AgeAll.SelectCountries$USAID_Country = as.factor(AllAllsData.7scens.AgeAll.SelectCountries$USAID_Country)
countries = names(countrieslist)

plots = plot_loop_together(countrieslist, countries, compartments, fontsize=9, CI=F, deaths_on_cases=F, linesize=.5)

test = plots$Afghanistan$case_death
testdf = test$data
pointsize = 3
#test <- test + stat_summary(data = testdf[testdf$compartment=="death_o",], aes(Date_JHU, med, color=Scenarios, fill=Scenarios, group=Scenarios), fun.max = max, geom="point", size=pointsize, show.legend = F) # color=Scenarios, fill=Scenarios)
testdfdeaths = testdf[testdf$compartment=="death_o",]
#testformax = testdfdeaths[which.max(testdfdeaths$med),]
testformax = testdfdeaths[with(testdfdeaths, ave(med, Scenarios, FUN=max)==med)]
names(testformax)[names(testformax) == "med"] = "med2"
#test <- test + stat_summary(data = testformax, fun.max = max, geom="point", size=pointsize, show.legend = F) # color=Scenarios, fill=Scenarios)
#test <- test + scale_y_continuous(breaks = waiver(), n.breaks=10, labels = comma, sec.axis = ~ . / 100)
# test <- test + scale_y_continuous(breaks = waiver(), n.breaks=10, labels = comma, sec.axis = sec_axis(~ (. /100), name = "Deaths"))
# test <- test + geom_point(data = testformax, aes(Date_JHU, med2), size=pointsize, show.legend = F)
# #test <- test + geom_point(data = testformax, size=pointsize, show.legend = F)
# test
# test <- test + stat_summary(aes(label=round(..y..,2)), fun=max, geom="text", size=6, hjust = -0.3)


### closest here...
test = plots$Afghanistan$case_death
test
test <- test + geom_point(data = testformax, mapping = aes(y=med2*100, group=Scenarios), size=pointsize, show.legend = F)
test
test <- test + scale_y_continuous(breaks = waiver(), n.breaks=10, labels = comma, sec.axis = sec_axis(~ (. /100), name = "Deaths"))
test
test <- test + geom_text(data = testformax, aes(x=testformax$Date_JHU, y=testformax$med2*100, label=round(testformax$med2)), hjust = -0.25, show.legend = F)
test
test <- test + geom_line(data = testformax, mapping = aes(Date_JHU, med), size=pointsize, show.legend = F)
test

# try with lines..
linesize=0.5
test = plots$Afghanistan$case_death
test
test <- test + geom_vline(data = testformax, aes(xintercept=Date_JHU, group=Scenarios, color=Scenarios), size=linesize+.5, linetype=5, show.legend = F)
test

# what is death rate?
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


# # try with CI
# # just with one scenario to get this working
# AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[Country_OU %in% countries & compartment %in% compartments & Scenarios == "Unmitigated"]
# # or with 4 scenarios
# AllAllsData.7scens.AgeAll.SelectCountries = AllAllsData.7scens.AgeAll.SelectCountries[Country_OU %in% countries & compartment %in% compartments & Scenarios %in% c("Unmitigated", "20% distancing", "50% distancing", "40/80 shielding")]
# countrieslist = split(AllAllsData.7scens.AgeAll.SelectCountries, by="Country_OU")
# countries = levels(AllAllsData.7scens.AgeAll.SelectCountries$Country_OU)
# plots = plot_loop(countrieslist, countries, compartments, fontsize=10, CI=T)
# plots$afghanistan$cases[[1]]
# # ok this is weird... 
# # I think we need to get the diff between med and lo and med and hi to get CI
# plottest = AllAllsData.7scens.AgeAll.SelectCountries[compartment == "cases" & Country_OU == "afghanistan"]
# plottest$Country_OU = as.factor(plottest$Country_OU)
# countries = levels(plottest$Country_OU)
# plot(plottest$med ~ plottest$Date_JHU)
# lines(plottest$Date_JHU, plottest$lo, pch = 18, col = "blue", type = "b", lty = 2)
# lines(plottest$Date_JHU, plottest$hi, pch = 20, col = "red", type = "b", lty = 3)
# legend("topright", legend=c("med", "lo", "hi"),
#        col=c("black", "blue", "red"), lty = 1:3, cex=0.8)
# 
# # try ggplot CI method..
# countrieslist = split(plottest, by="Country_OU")
# plots = plot_loop(countrieslist, countries, compartments, fontsize=10, CI=T)
# plots$afghanistan$cases[[1]]
# 
# 
# # or try cowplot?
# plot_grid(p1, p2, labels = c('A', 'B'), label_size = 12)
# ggdraw(p) + 
#   draw_image(logo_file, x = 1, y = 1, hjust = 1, vjust = 1, width = 0.13, height = 0.2)
# 

