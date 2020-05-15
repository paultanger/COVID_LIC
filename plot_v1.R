codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('plot_function.R')
#setwd("2020_05_05_archived_04_30_generated/afghanistan/")

require(qs)
#alls = qread('alls.qs')
setwd(datadir)
alls = qread('AllAlls7ScensAgeAll_20200514_1709.qs')
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
subset.alls.plot <- subset.alls.plot[, Scenarios:=as.factor(Scenarios)]
subset.alls.plot <- subset.alls.plot[, Country:=as.factor(Country)]


# convert to date
# set origin - will be easy to define origin for each country and pull that
origin = "2019-12-31"
subset.alls.plot$Date = as.Date(subset.alls.plot$t, origin=origin)
  
#subset.alls.plot$Scenarios = with(subset.alls.plot, factor(Scenarios, ordered=T))
# levels(subset.alls.plot$scen_id)
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
other_sorting_cols = fread("country_folder_list_with_regions.csv", stringsAsFactors=T, drop=1, header=T)

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
countries = levels(subset.alls.plot$Country)

AllAllsData.7scens.AgeAll.SelectCountries = subset.alls.plot[Country %in% countries & compartment %in% compartments]
AllAllsData.7scens.AgeAll.SelectCountries = droplevels(AllAllsData.7scens.AgeAll.SelectCountries)

# make a list of the subsets for each country
countrieslist = split(AllAllsData.7scens.AgeAll.SelectCountries, by="Country")

# TODO: maybe change this to a data table or apply function
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
i= 1
j = 1
# initialize list to store results
plots = vector(mode = "list", length = length(countrieslist))
names(plots) = countries
# create plot objects and put in list
for(i in i:length(countrieslist)){
  for(j in levels(countrieslist[[i]]$compartment)){
    #print(countrieslist[[i]]$compartment[j])
    print(paste0(names(countrieslist[i]), "_", j, "_AgeAll"))
    # name the file
    filename = addStampToFilename(paste0(names(countrieslist[i]), "_", j, "_AgeAll"), "pdf")
    # subset for compartment
    tempdata = countrieslist[[i]][compartment == j]
    # setup names of things
    mytitle = paste0(names(countrieslist[i]), " ", j, " over time")
    myxlab = "Date (days since 50 confirmed cases)"
    myylab = paste0("Number of ", j)
    # make the plot
    PlotObj = mydotplotv1(tempdata, mytitle, myxlab, myylab, fontsize=12, pointsize=4)
    # save into a list of plot objects
    plots[[i]][[j]] = c(plots[[i]][[j]],list(PlotObj))
    # access like: plots$afghanistan$death_o
    #ggsave(filename, PlotObj)
  }}

# print them
filename = addStampToFilename("AllCountriesAgeAllCasesDeaths", "pdf")

pdf("all.pdf", width=11, height=8.5)
# unpack list
do.call(c, unlist(plots, recursive=FALSE))
dev.off()

# or use this method:

sugarplots = arrangeGrob(mylegend, nrow=2, heights=c(1,10), # makes a small row for the legend at top, and big row for plots..
                         arrangeGrob( 
                           gluplot + theme(legend.position="none"),
                           penplot + theme(legend.position="none"),
                           gluWplot + theme(legend.position="none"),
                           penWplot + theme(legend.position="none"),
                           ncol=2) # defines columns for plots only
