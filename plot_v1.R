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
other_sorting_cols = fread("country_folder_list_with_regions.csv", stringsAsFactors=T, drop=1, header=T)

head(subset.alls.plot,2)
head(other_sorting_cols,2)

# merge with data in case we want to facet plot by these groups
subset.alls.plot = merge(other_sorting_cols, subset.alls.plot, by.x = "Country_OU", by.y = "Country", all=T)

####### TEST WITH ONE ############
# set titles
mytitle = "Afghanistan symptomatic cases over time"
myxlab = "Date (days since day zero)"
myylab = "Number of cases"
PlotObj = mydotplotv1(subset.alls.plot, mytitle, myxlab, myylab, fontsize=12, pointsize=4)
PlotObj
# save it
filename = addStampToFilename('Afghanistan_Cases_Time_v3', 'pdf')
# set data dir
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
#ggsave(filename, PlotObj, width=7, height=6, units="in", scale=1.5)
ggsave(filename, PlotObj)

############### DO ALL ##################
# define countries to include
# TODO: adapt later to filter based on subset of other_sorting_cols
#countries = c("afghanistan", "ethiopia")
compartments = c("cases", "death_o")
# all countries
countries = levels(subset.alls.plot$Country_OU)

# drop countries without a JHU 50 date yet
subset.alls.plot = na.omit(subset.alls.plot, cols="Date_JHU")

AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[Country_OU %in% countries & compartment %in% compartments]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)

# make a list of the subsets for each country
countrieslist = split(AllAllsData.7scens.AgeAll.SelectCountries, by="Country_OU")
AllAllsData.7scens.AgeAll.SelectCountries$Country_OU = as.factor(AllAllsData.7scens.AgeAll.SelectCountries$Country_OU)
countries = levels(AllAllsData.7scens.AgeAll.SelectCountries$Country_OU)

# TODO: maybe change this to a data table or apply function
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
plots = plot_loop(countrieslist, countries, compartments, fontsize=10)
# print them
filename = addStampToFilename("AllCountriesAgeAllCasesDeaths_JHU50", "pdf")

pdf(filename, width=11, height=8.5)
# unpack list
do.call(c, unlist(plots, recursive=FALSE))
dev.off()

# or use this method:
# run again with to get plot objects
plots = plot_loop(countrieslist, countries, compartments, fontsize=10, CI=T)
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

# try with CI
# just with one scenario to get this working
AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[Country_OU %in% countries & compartment %in% compartments & Scenarios == "Unmitigated"]
# or with 4 scenarios
AllAllsData.7scens.AgeAll.SelectCountries = AllAllsData.7scens.AgeAll.SelectCountries[Country_OU %in% countries & compartment %in% compartments & Scenarios %in% c("Unmitigated", "20% distancing", "50% distancing", "40/80 shielding")]
countrieslist = split(AllAllsData.7scens.AgeAll.SelectCountries, by="Country_OU")
countries = levels(AllAllsData.7scens.AgeAll.SelectCountries$Country_OU)
plots = plot_loop(countrieslist, countries, compartments, fontsize=10, CI=T)
plots$afghanistan$cases[[1]]
# ok this is weird... 
# I think we need to get the diff between med and lo and med and hi to get CI
plottest = AllAllsData.7scens.AgeAll.SelectCountries[compartment == "cases" & Country_OU == "afghanistan"]
plottest$Country_OU = as.factor(plottest$Country_OU)
countries = levels(plottest$Country_OU)
plot(plottest$med ~ plottest$Date_JHU)
lines(plottest$Date_JHU, plottest$lo, pch = 18, col = "blue", type = "b", lty = 2)
lines(plottest$Date_JHU, plottest$hi, pch = 20, col = "red", type = "b", lty = 3)
legend("topright", legend=c("med", "lo", "hi"),
       col=c("black", "blue", "red"), lty = 1:3, cex=0.8)

# try ggplot CI method..
countrieslist = split(plottest, by="Country_OU")
plots = plot_loop(countrieslist, countries, compartments, fontsize=10, CI=T)
plots$afghanistan$cases[[1]]


# or try cowplot?
plot_grid(p1, p2, labels = c('A', 'B'), label_size = 12)
ggdraw(p) + 
  draw_image(logo_file, x = 1, y = 1, hjust = 1, vjust = 1, width = 0.13, height = 0.2)

# from covidm reports github intervention plots:
# ggplotqs(meltquantiles(a.dt[age=="all"]), aes(
#    color=factor(scen_id), group=variable, alpha=variable
#  )) +
#    facet_grid(compartment ~ scen_id, scale = "free_y", switch = "y", labeller = fct_labels(
#    scen_id = { res <- levels(int.factorize(c(1, scens))); names(res) <- c(1, scens); res }
#  )) + 
#  scale_x_t() +
#  scale_alpha_manual(guide = "none", values = c(lo.lo=0.25, lo=0.5, med=1, hi=0.5, hi.hi=0.25)) 

# and from plotting support:
# meltquantiles <- function(dt, probs = refprobs) {
#   ky <- setdiff(names(dt), names(probs))
#   setkeyv(melt(
#     dt, measure.vars = names(probs)
#   ), c(ky, "variable"))
# }
