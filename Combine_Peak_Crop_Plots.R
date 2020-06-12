codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"
plotdir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
source('plot_crop_cal_function.R')
setwd(datadir)

# from plot_crop_cal_v1.R we should have two list object of ggplots:
# select countries (regions don't need to be separate) = crop_plots
# other countries (regions need to be separate) = other_crop_plots

# load files
crop_plots = readRDS("SelectCountriesAllRegionsCropPlots_20200603_1429.Robj")
other_crop_plots = readRDS("OtherCountriesAllRegionsCropPlots_20200603_1429.Robj")

# from plot_v1.R we should have a list object of ggplots = plots
#plots = readRDS("peak_plots_list_20200527_1619.RObj")
#plots = readRDS("peak_plots_list_20200602_1706.RObj")
# version with pretty breaks
plots = readRDS("peak_plots_list_20200602_1712.RObj")


# the easier ones first, we'll take the list object from each and plot together
# do this for the select countries - don't need to do by regions

# use the code below, but write it into a loop in functions.R

# alternative: try to put the crop plots in the same list as peak plots (nested for each country)
plots_to_combine = plots

# TODO: fix with lapply?
#lapply(seq_along(plots_to_combine), function(y) if (names(plots_to_combine)[[y]] %in% names(crop_plots)) {y$crop_plot <- crop_plots$names(plots_to_combine)[[y]] }) #, simplify = FALSE,USE.NAMES = TRUE)

# subset plots to combine for only countries with crop plots..
peak_countries = names(plots_to_combine)
crop_countries = names(crop_plots)
crop_region_countries = names(other_crop_plots)

combine_countries = intersect(peak_countries, crop_countries)
combine_region_countries = intersect(peak_countries, crop_region_countries)
just_peak = setdiff(peak_countries, c(crop_countries, crop_region_countries))
just_GEOGLAM = setdiff(c(crop_countries, crop_region_countries), peak_countries)

# combine into df for Katie
# venn_groups = list(combine_countries, combine_region_countries, just_peak, just_GEOGLAM)
# n.countries <- sapply(venn_groups, length)
# seq.max <- seq_len(max(n.countries))
# venn_groups_countries <- as.data.frame(sapply(venn_groups, "[", i = seq.max))
# colnames(venn_groups_countries) = c("combine_countries", "combine_region_countries", "just_peak", "just_GEOGLAM")
# filename = addStampToFilename("Country_Groups", "csv")
# write.csv(venn_groups_countries, filename, row.names = F, na="")

# make sub-lists
plots_separate = plots_to_combine[names(plots_to_combine) %in% just_peak]
plots_by_region = plots_to_combine[names(plots_to_combine) %in% combine_region_countries]
plots_to_combine = plots_to_combine[names(plots_to_combine) %in% combine_countries]

# plot countries without crops on their own
# setwd(plotdir)
# filename = addStampToFilename("Countries_No_GEOGLAM", "pdf")
# pdf(filename, width=8.5, height=11)
# # # unpack list
# for (i in plots_separate) {
#   print(i)
#   #crop_plots$i
# }
# dev.off()

# TODO: move this into the loop or a separate script?
# integrate country and region maps into plots
# they are stored here as EPS:
# setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")

################## FINAL VERSION OF THIS FOR LOOP #######################

# testimg6 = readPNG("KEN_WestTEST.png")
# testimg6 = rasterGrob(testimg6) # just=c("left","bottom"))
# title <- ggdraw() + draw_label(names(plots_by_region[8]), fontface='bold')
# title
# # add text with the days between peak cases and deaths for each country
# # load file with peak dates
# setwd(datadir)
# PeakCasesDeathsDates = read.csv("PeakCaseDeathDatesAllCountries_20200602_1354.csv")
# PeaksbyCountry.wide.plots = read.csv("PeakCaseDeathDatesAllCountriesForPlots_20200604_1525.csv")
# colnames(PeaksbyCountry.wide.plots) = c("USAID_Country", "Region", "Scenario", "Peak Cases Date", "Peak Deaths Date")
# 
# # within loop subset data for country
# mydata1 = PeaksbyCountry.wide.plots[PeaksbyCountry.wide.plots$USAID_Country == "Ethiopia", ]
# 
# # countrytext = ggplot(mydata1)
# #countrytext = ggdraw() + draw_label(paste0("Data: Model projections of COVID-19 cases and deaths over time, https://cmmid.github.io/topics/covid19/LMIC-projection-reports.html. Crop calendars: https://cropmonitor.org/index.php/eodatatools/baseline-data. Date of the 50th confirmed COVID-19 case: https://coronavirus.jhu.edu. In ", mydata1$USAID_Country, ", based on the model estimates for the scenarios presented here,\n the peak cases and peak deaths are expected:"), 
#                                     # size = 7, x = 0.1, y = 1, hjust=0)
# countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"), 
#                                     size = 7, x = 0.1, y = .9, hjust=0)
# countrytext
# mytheme <- ttheme_default(base_size = 8)
# countrytext = countrytext + annotation_custom(tableGrob(mydata1[,c(3:5)], rows = NULL, theme = mytheme), xmin = 0, ymin = -0.5)
# countrytext
# bottom <- plot_grid(plots_by_region$Ethiopia$cases, other_crop_plots$Ethiopia$Afar[[1]], ncol=1, align="v", axis="l", rel_heights = c(2, 1))
# bottom
# combinedtestbottom = grid.arrange(title, bottom, countrytext, testimg6, layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1))
# combinedtestbottom
# 
# setwd(plotdir)
# filename = addStampToFilename("MapTestpngbottomtable", "pdf")
# ggsave(filename, combinedtestbottom, width=8.5, height=11, units="in")


######################## MAKE PLOTS ##################################

# convert region names to match filenames for maps
# get the file to make a new col to translate these
setwd(datadir)
sorting_cols = read.csv("JHU_UK_Katie_USAIDv4_GEO_FINAL_20200529_1529.csv")
geoglam = read.csv("GEOGLAM_crop_calendars_v3.csv")
geoglam = geoglam[,c(1,2)]
# put regions, countries and codes together
sorting_cols = sorting_cols[,c(1,3,9)]
map_filenames = merge(geoglam, sorting_cols, by.x = "country", by.y = "GEOGLAM_Country", all.x=T)
map_filenames$region = gsub(" ", "_", map_filenames$region)
map_filenames$region = gsub("_-_", "_", map_filenames$region)
# default is just country code and png
map_filenames$map_filename = paste0(map_filenames$Country_Code, ".png")
# determine if we are plotting regions
map_filenames$plot_regions = F
map_filenames$plot_regions[map_filenames$USAID_Country %in% combine_region_countries] = T
# redo the filenames for these
#map_filenames$map_filename2[map_filenames$plot_regions == T] = paste0(map_filenames$Country_Code, "_", map_filenames$region, ".png")
map_filenames$map_filename = ifelse(map_filenames$plot_regions == T, paste0(map_filenames$Country_Code, "_", map_filenames$region, ".png"), map_filenames$map_filename)

filename = addStampToFilename("map_filenames", "csv")
# write.csv(map_filenames, filename, row.names = F, na="")

# subset into two
map_filenames.countries = unique(map_filenames[map_filenames$plot_regions == F, c(3,5)])
map_filenames.regions = unique(map_filenames[map_filenames$plot_regions == T, c(3,5)])

map_filenames.countries = map_filenames.countries[map_filenames.countries$USAID_Country %in% combine_countries,]

# make plots
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")

i=1
map.plots = vector(mode = "list", length = length(combine_countries))
names(map.plots) = combine_countries

for(i in i:length(map.plots)){
  # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
  #get file from directory
  filename = map_filenames.countries$map_filename[names(map.plots)[i] == map_filenames.countries$USAID_Country]
  paste(names(map.plots)[i], " ", filename)
  mapimg = readPNG(filename)
  mapimg = rasterGrob(mapimg)
  map.plots[[i]]$map_plot <- mapimg
}

# for regions
i=1
map.plots.regions = vector(mode = "list", length = length(combine_region_countries))
names(map.plots.regions) = combine_region_countries

# for(i in i:length(map.plots.regions)){
#   # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
#   #get file from directory
#   filename = map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country]
#   paste(names(map.plots.regions)[i], " ", filename)
#   mapimg = readPNG(filename)
#   mapimg = rasterGrob(mapimg)
#   map.plots.regions[[i]]$map_plot <- mapimg
# }


# now create text objects
setwd(datadir)
PeakCasesDeathsDates = read.csv("PeakCaseDeathDatesAllCountries_20200602_1354.csv")
PeaksbyCountry.wide.plots = read.csv("PeakCaseDeathDatesAllCountriesForPlots_20200604_1525.csv")
colnames(PeaksbyCountry.wide.plots) = c("USAID_Country", "Region", "Scenario", "Peak Cases Date", "Peak Deaths Date")
# save this for markdown access
setwd(datadir)
filename = addStampToFilename("PeaksbyCountry.wide.plots", "csv")
#write.csv(PeaksbyCountry.wide.plots[,c(2:6)], filename, row.names = F)

mytheme <- ttheme_default(base_size = 7)

i = 1
for(i in i:length(map.plots)){
  # subset data for each country
  mydata1 = PeaksbyCountry.wide.plots[PeaksbyCountry.wide.plots$USAID_Country == names(map.plots)[i], ]
  paste(names(map.plots)[i], " ", filename)
  countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"), 
                                      size = 7, x = 0.1, y = .95, hjust=0)
  countrytext = countrytext + annotation_custom(tableGrob(mydata1[,c(3:5)], rows = NULL, theme = mytheme), xmin = 0, ymin = -0.15)
  map.plots[[i]]$map_text <- countrytext
}

# for regions
i = 1
for(i in i:length(map.plots.regions)){
  # subset data for each country
  mydata1 = PeaksbyCountry.wide.plots[PeaksbyCountry.wide.plots$USAID_Country == names(map.plots.regions)[i], ]
  paste(names(map.plots.regions)[i], " ", filename)
  countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"), 
                                      size = 7, x = 0.1, y = .95, hjust=0)
  countrytext = countrytext + annotation_custom(tableGrob(mydata1[,c(3:5)], rows = NULL, theme = mytheme), xmin = 0, ymin = -0.15)
  map.plots.regions[[i]]$map_text <- countrytext
}

# big loop to make the whole figures
# or use code below.. or the resultant lists:
# for countries: plots_to_combine
# for regions: plots_by_region

# combine plots for countries with both peak and crop plots

# first subset crop plot list
crop_plots_to_combine = crop_plots[names(crop_plots) %in% combine_countries]
plots_to_combine_backup = plots_to_combine
#plots_to_combine = plots_to_combine_backup
# maybe we could rewrite the loop to just match names in two separate lists
# instead of combining into one..

# order lists
crop_plots_to_combine = crop_plots_to_combine[order(names(crop_plots_to_combine))]
plots_to_combine = plots_to_combine[order(names(plots_to_combine))]

# for the markdown approach, add the map plots to plots to combine
for(i in seq(map.plots)){
  # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
  #get file from directory
  filename = map_filenames.countries$map_filename[names(map.plots)[i] == map_filenames.countries$USAID_Country]
  paste(names(map.plots)[i], " ", filename)
  mapimg = readPNG(filename)
  mapimg = rasterGrob(mapimg)
  plots_to_combine[[i]]$map_plot <- mapimg
}
# save this
setwd(datadir)
filename = addStampToFilename("country_plots_for_markdown", "RDS")
# saveRDS(plots_to_combine, filename)

i=1
for(i in i:length(plots_to_combine)){
  if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
    print(paste0("crop_plots$", names(plots_to_combine)[i]))
    temp_country_name = names(plots_to_combine)[[i]]
    plots_to_combine[[i]]$crop_plot <- crop_plots_to_combine[[temp_country_name]]
  }
}

i = 1
for(i in i:length(map.plots)){
  if (names(map.plots)[[i]] == names(plots_to_combine[i])){
    map.plots[[i]]$title <- ggdraw() + draw_label(names(map.plots[i]), fontface='bold')
    bottom <- plot_grid(plots_to_combine[[i]]$cases, plots_to_combine[[i]]$crop_plot, ncol=1, align="v", axis="l", rel_heights = c(2, 1))
    map.plots[[i]]$bottom <- bottom
  }
}
# save this version with "bottom" plots
setwd(datadir)
filename = addStampToFilename("map.plots", "RDS")
# saveRDS(map.plots, filename)

###############
# first subset crop plot list
crop_plots_region_to_combine = other_crop_plots[names(other_crop_plots) %in% combine_region_countries]
names(plots_by_region)
names(crop_plots_region_to_combine)

# order lists
crop_plots_region_to_combine = crop_plots_region_to_combine[order(names(crop_plots_region_to_combine))]
plots_by_region = plots_by_region[order(names(plots_by_region))]

# combine plots into one big list
i=1
for(i in i:length(plots_by_region)){
  if (names(plots_by_region)[[i]] == names(crop_plots_region_to_combine[i])){
    print(paste0("crop_plots$", names(plots_by_region)[i]))
    temp_country_name = names(plots_by_region)[[i]]
    plots_by_region[[i]]$crop_plots <- crop_plots_region_to_combine[[temp_country_name]]
  }
}


# regions
# backup test
# map.plots.regions.backup = map.plots.regions
# map.plots.regions = map.plots.regions.backup
# i = 1
# j = 1
# for(i in i:length(map.plots.regions)){
#   if (names(map.plots.regions)[[i]] == names(plots_by_region[i])){
#     map.plots.regions[[i]]$title <- ggdraw() + draw_label(names(map.plots.regions[i]), fontface='bold')
#     # bottom and map_plot will need to be sublists..
#     for(j in length(plots_by_region[[i]]$crop_plots)){
#       temp_region_name = names(plots_by_region[[i]][[2]][j])
#       bottom <- plot_grid(plots_by_region[[i]]$cases, plots_by_region[[i]][[2]][j][[1]][[1]], ncol=1, align="v", axis="l", rel_heights = c(2, 1))
#       map.plots.regions[[i]]$bottom_plots[temp_region_name] =  list(bottom)
#       #map.plots.regions[[i]][[temp_region_name]] = c(map.plots.regions[[i]][[temp_region_name]] , list(bottom))
#     }
#   }
# }


# map.plots.regions.list = vector(mode = "list", length = length(map.plots.regions))
# names(map.plots.regions.list) = names(map.plots.regions)
# for(j in levels(other_countries_list[[i]]$region)){

i = 1
j = 1

# order the list regions the same..
map.plots.regions = map.plots.regions[order(names(map.plots.regions))]
map_filenames.regions = map_filenames.regions[with(map_filenames.regions, order(USAID_Country, map_filename)),]

# fix things where two words not sorting correctly
rownames(map_filenames.regions) <- NULL
map_filenames.regions = map_filenames.regions[c(1:44,46,45,47:90,92,91,93:110),]

for(i in i:length(map.plots.regions)){
  if (names(map.plots.regions)[[i]] == names(plots_by_region[i])){
    map.plots.regions[[i]]$title <- ggdraw() + draw_label(names(map.plots.regions[i]), fontface='bold')
    # bottom and map_plot will need to be sublists..
    print(names(map.plots.regions[i]))
    j=1
    for(j in j:length(plots_by_region[[i]]$crop_plots)){
      temp_region_name = names(plots_by_region[[i]]$crop_plots[j])
      print(temp_region_name)
      bottom <- plot_grid(plots_by_region[[i]]$cases, plots_by_region[[i]]$crop_plots[j][[1]][[1]], ncol=1, align="v", axis="l", rel_heights = c(2, 1))
      map.plots.regions[[i]]$bottom_plots[temp_region_name] =  list(bottom)
      #map.plots.regions[[i]][[temp_region_name]] = c(map.plots.regions[[i]][[temp_region_name]] , list(bottom))
    }
  }
}

# redo the map plots - one for each region
# for(i in i:length(map.plots.regions)){
#   # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
#   #get file from directory
#   filename = map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country]
#   paste(names(map.plots.regions)[i], " ", filename)
#   mapimg = readPNG(filename)
#   mapimg = rasterGrob(mapimg)
#   map.plots.regions[[i]]$map_plot <- mapimg
# }
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")
i=1
for(i in i:length(map.plots.regions)){
    j=1
    for(j in j:length(map.plots.regions[[i]]$bottom_plots)){
      filename = map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country][j]
      print(filename)
      #paste(names(map.plots.regions)[i], " ", filename)
      # test = map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country]
      # print(test[j])
      # #print(map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country][j])
      mapimg = readPNG(filename)
      mapimg = rasterGrob(mapimg)
      temp_region_name = names(map.plots.regions[[i]]$bottom_plots[j])
      map.plots.regions[[i]]$map_plot[temp_region_name] = list(mapimg)
    }
}

# markdown approach, add maps to plots_by_region
for(i in seq(plots_by_region)){
  for(j in seq(plots_by_region[[i]]$crop_plots)){
    filename = map_filenames.regions$map_filename[names(plots_by_region)[i] == map_filenames.regions$USAID_Country][j]
    print(filename)
    mapimg = readPNG(filename)
    mapimg = rasterGrob(mapimg)
    temp_region_name = names(plots_by_region[[i]]$crop_plots[j])
    plots_by_region[[i]]$map_plot[temp_region_name] = list(mapimg)
  }
}

# save it
setwd(datadir)
filename = addStampToFilename("plots_by_region", "RDS")
# saveRDS(plots_by_region, filename)
setwd(datadir)
filename = addStampToFilename("map.plots", "RDS")
# saveRDS(map.plots, filename)
filename = addStampToFilename("map.plots.regions", "RDS")
# saveRDS(map.plots.regions, filename)

# map.plots = readRDS("map.plots_20200606_1452.RDS")
# map.plots.regions = readRDS("map.plots.regions_20200606_0904.RDS")
# for now, just print the region ones on their own
region.plots = vector(mode = "list", length = length(map.plots.regions))
i = 1
for(i in i:length(map.plots.regions)){
  j = 1
  for(j in j:length(map.plots.regions[[i]]$bottom_plots)){
    region.plots[[i]][[ names(map.plots.regions[[i]]$bottom_plots[j]) ]]  = arrangeGrob(map.plots.regions[[i]]$title, map.plots.regions[[i]]$bottom_plots[[j]], map.plots.regions[[i]]$map_text, map.plots.regions[[i]]$map_plot[[j]], layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1))
    #arrangeGrob(map.plots.regions[[i]]$title, map.plots.regions[[i]]$bottom_plots[[j]], map.plots.regions[[i]]$map_text, map.plots.regions[[i]]$map_plot[[j]], layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1))
  }
}
names(region.plots) = names(map.plots.regions)
# unpacked = unlist(region.plots, recursive = F)
# unpacked2 = unlist(unpacked, recursive = F)

# try printing from list
setwd(plotdir)
filename = addStampToFilename("CountryRegionPlots", "pdf")
i = 1

pdf(filename, width=8.5, height=11)
#grid.draw(region.plots[[1]]$Central)
# unpack list
#do.call(c, unlist(region.plots, recursive=F))
#do.call("grid.draw", region.plots)
for (i in i:length(region.plots)) {
  j = 1
  for (j in j:length(region.plots[[i]])) {
    grid.newpage()
    grid.draw(region.plots[[i]][[j]])
  }
}
dev.off()

# print it
# setwd(plotdir)
# filename = addStampToFilename("CountryRegionPlots", "pdf")
# i = 1
# j = 1
# pdf(filename, width=8.5, height=11)
# 
# i = 1
# for(i in i:length(map.plots.regions)){
#   j = 1
#   for(j in j:length(map.plots.regions[[i]]$bottom_plots)){
#     grid.arrange(map.plots.regions[[i]]$title, map.plots.regions[[i]]$bottom_plots[[j]], map.plots.regions[[i]]$map_text, map.plots.regions[[i]]$map_plot[[j]], layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1))
#   }
# }
# dev.off()


# put into big list
allplots = vector(mode = "list", length = length(map.plots))
i = 1
for(i in i:length(map.plots)){
  if (names(map.plots)[[i]] == names(plots_to_combine[i])){
    allplots[[names(map.plots)[[i]]]]  = list(arrangeGrob(map.plots[[i]]$title, map.plots[[i]]$bottom, map.plots[[i]]$map_text, map.plots[[i]]$map_plot, layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1)))
  }
}
# not sure why this is twice as long..
allplots = allplots[c(22:42)]

# add the region ones..
allplots = c(allplots, region.plots)

# order it
allplots = allplots[order(names(allplots))]

# save it
setwd(datadir)
filename = addStampToFilename("allplots", "RDS")
saveRDS(allplots, filename)

# try printing together
setwd(plotdir)
filename = addStampToFilename("AllPlotsTogether", "pdf")
i = 1
pdf(filename, width=8.5, height=11)
for (i in i:length(allplots)) {
  j = 1
  for (j in j:length(allplots[[i]])) {
    grid.newpage()
    grid.draw(allplots[[i]][[j]])
  }
}
dev.off()

# test it - then go back and add regions
# setwd(plotdir)
# filename = addStampToFilename("CountryPlots", "pdf")
# pdf(filename, width=8.5, height=11)
# # unpack list
# #do.call(c, unlist(allplots, recursive=F))
# for (i in allplots) {
#   grid.arrange(i)
# }
# dev.off()


######################################################################

# combine plots for countries with both peak and crop plots
# 
# # first subset crop plot list
# crop_plots_to_combine = crop_plots[names(crop_plots) %in% combine_countries]
# plots_to_combine_backup = plots_to_combine
# #plots_to_combine = plots_to_combine_backup
# # maybe we could rewrite the loop to just match names in two separate lists
# # instead of combining into one..
# 
# # order lists
# crop_plots_to_combine = crop_plots_to_combine[order(names(crop_plots_to_combine))]
# plots_to_combine = plots_to_combine[order(names(plots_to_combine))]
# 
# i=1
# for(i in i:length(plots_to_combine)){
#   if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
#     print(paste0("crop_plots$", names(plots_to_combine)[i]))
#     temp_country_name = names(plots_to_combine)[[i]]
#     plots_to_combine[[i]]$crop_plot <- crop_plots_to_combine[[temp_country_name]]
#   }
# }
# 
# # return a list of the combined plots
# combined_plots = combine_plots_loop(plots_to_combine)
# 
# # print them
# setwd(plotdir)
# filename = addStampToFilename("SelectCountriesCombinedPlots", "pdf")
# pdf(filename, width=8.5, height=11)
# # unpack list
# for (i in combined_plots) {
#   print(i)
#   #crop_plots$i
# }
# dev.off()
# 
# # now, combine plots_by_region with the "other countries" with one combined plot per region for each country
# 
# # first subset crop plot list
# crop_plots_region_to_combine = other_crop_plots[names(other_crop_plots) %in% combine_region_countries]
# names(plots_by_region)
# names(crop_plots_region_to_combine)
# 
# # order lists
# crop_plots_region_to_combine = crop_plots_region_to_combine[order(names(crop_plots_region_to_combine))]
# plots_by_region = plots_by_region[order(names(plots_by_region))]
# 
# # combine plots into one big list
# i=1
# for(i in i:length(plots_by_region)){
#   if (names(plots_by_region)[[i]] == names(crop_plots_region_to_combine[i])){
#     print(paste0("crop_plots$", names(plots_by_region)[i]))
#     temp_country_name = names(plots_by_region)[[i]]
#     plots_by_region[[i]]$crop_plots <- crop_plots_region_to_combine[[temp_country_name]]
#   }
# }
# 
# # save it
# setwd(datadir)
# filename = addStampToFilename("plots_by_region", "RObj")
# #saveRDS(plots_by_region, filename)
# 
# # return a list of the combined plots
# combined_plots_regions = combine_plots_loop_regions(plots_by_region)
# 
# # plot them
# setwd(plotdir)
# filename = addStampToFilename("CountriesRegionsPeakAndCropPlots", "pdf")
# pdf(filename, width=8.5, height=11)
# # unpack list
# do.call(c, unlist(combined_plots_regions, recursive=F))
# dev.off()
# 
# #########################################################################
# # # this reads it
# # test = readLines("GIN_North.eps", n=10)
# # # this creates an xml version
# # PostScriptTrace("ETH_Afar.eps")
# # # this reads into variable
# # ETH_Afar <- readPicture("ETH_Afar.eps.xml")
# # # this prints it (slow)
# # grid.picture(ETH_Afar)
# # # or use a tiff version
# # testimg = image_read("KEN_West_96dpi.tif")
# # # with base R
# # testimg1 = as.raster("KEN_West_96dpi.tif")
# # print(testimg1)
# # # with raster
# # require(raster)
# # require(rgdal)
# # testimg2 = raster("KEN_West_96dpi.tif")
# # testimg2 = readTIFF("KEN_West_96dpi.tif")
# # 
# # testimg5 = rasterGrob(testimg2, interpolate=TRUE)
# # testimg2 = as.ggplot(testimg2)
# # testimg5 = grid.raster(testimg2)
# # 
# # # with tiff
# # require(tiff)
# # testimg3 = readTIFF("KEN_West_96dpi.tif")
# # testimg4 = rasterGrob(testimg3) # just=c("left","bottom"))
# # testimg5 = as.ggplot(testimg4)
# # 
# # # with png
# # testimg6 = readPNG("KEN_WestTEST.png")
# # testimg6 = rasterGrob(testimg6) # just=c("left","bottom"))
# # 
# # # It delimits the figure region, which includes those margins.  The idea is
# # # that you do choose width and height appropriately, and use paper="special"
# # # turn into a grob
# # ETH_Afar_grob <- pictureGrob(ETH_Afar)
# # ETH_Afar_ggobj = as.ggplot(ETH_Afar_grob)
# # 
# # # test = ggimage(mat)
# # # test combine with other plots
# # title <- ggdraw() + draw_label(names(plots_by_region[8]), fontface='bold')
# # # just combine with title?
# # combined_title = plot_grid(title, ETH_Afar_ggobj, align = "h", ncol = 2, nrows = 1, rel_widths = c(.3, 1) )
# # combined_title = plot_grid(title, testimg5, align = "h", ncol = 2, nrows = 1, rel_widths = c(.3, 1) )
# # combined_title
# # # then see what it looks like all together
# # combinedtest = plot_grid(combined_title, plots_by_region$Ethiopia$cases, other_crop_plots$Ethiopia$Afar[[1]], align = "v", ncol = 1, rel_heights = c(0.5, 1.3, .7))
# # combinedtest
# # # or maybe something like this?
# # # combinedpeaktest = plot_grid(title, ETH_Afar_ggobj, plots_by_region$Ethiopia$cases, NULL, other_crop_plots$Ethiopia$Afar[[1]], NULL, ncol = 2, nrows = 3, rel_heights = c(0.2, 1.3, .7), rel_widths = c(1, 2, 2))
# # # combinedpeaktest
# # bottom <- plot_grid(plots_by_region$Ethiopia$cases, other_crop_plots$Ethiopia$Afar[[1]], ncol=1, align="v", axis="l", rel_heights = c(2, 1))
# # bottom
# # together = plot_grid(combined_title, bottom, ncol=1, align="v", axis = "l", rel_heights = c(1, 2))
# # together
# # 
# # # try with arrange grob
# # ############# this is the best so far I think
# # combinedtest2 = grid.arrange(title,ETH_Afar_ggobj,plots_by_region$Ethiopia$cases,other_crop_plots$Ethiopia$Afar[[1]], layout_matrix = cbind(c(1,3,4), c(2,3,4)))
# # combinedtest2 = grid.arrange(title,ETH_Afar_ggobj,plots_by_region$Ethiopia$cases,other_crop_plots$Ethiopia$Afar[[1]], layout_matrix = cbind(c(1,3,4), c(2,3,4)))
# # combinedtest2 = grid.arrange(title,ETH_Afar_ggobj,plots_by_region$Ethiopia$cases,other_crop_plots$Ethiopia$Afar[[1]], layout_matrix = cbind(c(1,3,4), c(2,3,4)))
# # 
# # # maybe force the two plots to align first (using bottom from above)
# # top <- plot_grid(title, testimg5, align = "b", ncol = 2, nrows = 1) #, rel_widths = c(.3, 1))
# # top
# # bottom <- plot_grid(plots_by_region$Ethiopia$cases, other_crop_plots$Ethiopia$Afar[[1]], ncol=1, align="v", axis="l", rel_heights = c(2, 1))
# # 
# # # add text with the days between peak cases and deaths for each country
# # # load file with peak dates
# # setwd(datadir)
# # PeakCasesDeathsDates = read.csv("PeakCaseDeathDatesAllCountries_20200602_1354.csv")
# # PeaksbyCountry.wide.plots = read.csv("PeakCaseDeathDatesAllCountriesForPlots_20200604_1525.csv")
# # colnames(PeaksbyCountry.wide.plots) = c("USAID_Country", "Region", "Scenario", "Peak Cases", "Peak Deaths")
# # 
# # # within loop subset data for country
# # mydata1 = PeaksbyCountry.wide.plots[PeaksbyCountry.wide.plots$USAID_Country == "Ethiopia", ]
# # 
# # # countrytext = ggplot(mydata1)
# # countrytext = ggdraw() + draw_label(paste0("In ", mydata1$USAID_Country, ", based on the model estimates for the scenarios \n presented here,\n the peak cases and peak deaths are expected:"), size = 9)
# # # theme for table
# # mytheme <- ttheme_default(base_size = 8)
# # countrytext = countrytext + annotation_custom(tableGrob(mydata1[,c(3:5)], rows = NULL, theme = mytheme), xmin = 0, ymin = -0.5)
# # # countrytext = countrytext + annotate(geom = "table", x = 37, y = -0.8, label = list(mydata1[,c(3:5)]), vjust = 1, hjust = 0)
# # countrytext
# # 
# # combinedtest4 = grid.arrange(top, bottom, layout_matrix = cbind(c(1,3,3), c(2,3,3)), heights=c(1,2,2))
# # combinedtest4tiff = grid.arrange(title, testimg5, bottom, layout_matrix = cbind(c(1,3,3), c(2,3,3)), heights=c(1,2,2))
# # combinedtest4png = grid.arrange(title, testimg6, bottom, layout_matrix = cbind(c(1,3,3), c(2,3,3)), heights=c(1,2,2))
# # #combinedtest4 = grid.arrange(title, testimg5, bottom, layout_matrix = cbind(c(1,3,3), c(2,3,3)), heights=c(1,2,2))
# # combinedtest4
# # combinedtestbottom = grid.arrange(title, bottom, countrytext, testimg6, layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1))
# # combinedtestbottom
# # setwd(plotdir)
# # filename = addStampToFilename("MapTestpngbottomtable", "pdf")
# # ggsave(filename, combinedtestbottom, width=8.5, height=11, units="in")
# # ############# 
# # 
# # combinedtest3 = grid.arrange(arrangeGrob(title, ETH_Afar_ggobj, ncols=2, widths = c(1, 1.5)), plots_by_region$Ethiopia$cases, other_crop_plots$Ethiopia$Afar[[1]], 
# #                              nrows = 3, heights = c(.2, .5, .3))
# # combinedtest3
# # 
# # 
# # 
# # # try with raster image
# # setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/TIFF")
# # 
# # img <- image_read("GHA_North.tif")
# # 
# # combinedtest5 = ggdraw() + draw_plot(bottom) + draw_image(img, x=1, y=0, hjust=.7, vjust=-.2, scale=.3)
# # setwd(plotdir)
# # filename = addStampToFilename("MapTest5", "pdf")
# # ggsave(filename, combinedtest5, width=8.5, height=11, units="in")
# # 
# # # save it
# # setwd(plotdir)
# # filename = addStampToFilename("MapTest", "pdf")
# # ggsave(filename, combinedtest2, width=8.5, height=11, units="in")
# # 
# # filename = addStampToFilename("MapTest", "pdf")
# # ggsave(filename, combinedtest3, width=8.5, height=11, units="in")
# 
# # grid.arrange(p, arrangeGrob(p,p,p, heights=c(3/4, 1/4, 1/4), ncol=1), ncol=2)
# 
# # test = sapply(plots_to_combine, "[", combine_countries)
# # test2 <- lapply(plots_to_combine, function(x) {names(x) %in% combine_countries})
# # or with reduce on the actual lists?
# 
# 
# 
# ### this is the part that I need to fix.. maybe %in% not working
# # i=1
# # for(i in i:length(plots_to_combine)){
# #   print(names(plots_to_combine)[[i]])
# #   if (names(plots_to_combine)[[i]] %in% names(crop_plots)){
# #     print(paste0("crop_plots$", names(plots_to_combine)[[i]]))
# #     #plots_to_combine[[i]]$crop_plot <- list(paste0("crop_plots$", names(plots_to_combine)[[i]]))
# #     temp_country_name = names(plots_to_combine)[[i]]
# #     plots_to_combine[[i]]$crop_plot <- crop_plots[[temp_country_name]]
# #     # or as nested list
# #     #plots_to_combine[[i]]$crop_plot <- list(crop_plots[[temp_country_name]])
# #   }
# # }
# 
# 
# 
# #####################################
# 
# # or try cowplot?
# # plot_grid(p1, PlotObj, labels = c('A', 'B'), label_size = 12)
# # together = plot_grid(plots$afghanistan$cases[[1]], PlotObj, labels = c('A', 'B'), label_size = 12)
# 
# # set title
# # title <- ggdraw() + draw_label("Afghanistan", fontface='bold')
# #bottom_row <- plot_grid(nutrient_boxplot, tss_flow_plot, ncol = 2, labels = "AUTO")
# 
# # plot together
# #overlayed = ggdraw(p) + draw_image(logo_file, x = 1, y = 1, hjust = 1, vjust = 1, width = 0.13, height = 0.2)
# # final = plot_grid(title, together, flow_timeseries, nrow = 3, labels = c("", "", "C"), rel_heights = c(0.2, 1, 1))
# # final = plot_grid(title, plots$afghanistan$cases[[1]], PlotObj, align = "v", ncol = 1, rel_heights = c(0.25, 0.75))
# 
# # ideas
# # https://felixfan.github.io/stacking-plots-same-x/
# # https://gist.github.com/tomhopper/faa24797bb44addeba79
# 
# # final = plot_grid(title, plots$afghanistan$cases[[1]], PlotObj, align = "v", ncol = 1, rel_heights = c(0.2, 1, 1))
# # final
# # dev.off()
# # but I guess we really need 2019 to include the current ongoing season
# 
# # # with grid arrange
# # library(grid)
# # grid.newpage()
# # grid.draw(rbind(ggplotGrob(plots$afghanistan$cases[[1]]), ggplotGrob(PlotObj), size = "last"))
# # 
# # # or with egg?
# # install.packages('egg')
# # library(egg)
# # ggarrange(plots$afghanistan$cases[[1]], PlotObj, ncol=1)
# # 
# # # to get them to have same x I think I need to put all data together and plot in one object
# # 
# # # but could try this..?
# # draft <- ggdraw(plots$afghanistan$cases[[1]]) + ggdraw(PlotObj)
# #   
# # # and also overlay with the maps
# # # https://wilkelab.org/cowplot/articles/drawing_with_on_plots.html
# # inset <- ggplot(mpg, aes(drv)) + 
# #   geom_bar(fill = "skyblue2", alpha = 0.7) + 
# #   scale_y_continuous(expand = expand_scale(mult = c(0, 0.05))) +
# #   theme_minimal_hgrid(11)
# # 
# # ggdraw(p + theme_half_open(12)) +
# #   draw_plot(inset, .45, .45, .5, .5) +
# #   draw_plot_label(
# #     c("A", "B"),
# #     c(0, 0.45),
# #     c(1, 0.95),
# #     size = 12
# #   )
# # 
# # 
# 
# 
# # from covidm reports github intervention plots:
# # ggplotqs(meltquantiles(a.dt[age=="all"]), aes(
# #    color=factor(scen_id), group=variable, alpha=variable
# #  )) +
# #    facet_grid(compartment ~ scen_id, scale = "free_y", switch = "y", labeller = fct_labels(
# #    scen_id = { res <- levels(int.factorize(c(1, scens))); names(res) <- c(1, scens); res }
# #  )) + 
# #  scale_x_t() +
# #  scale_alpha_manual(guide = "none", values = c(lo.lo=0.25, lo=0.5, med=1, hi=0.5, hi.hi=0.25)) 
# 
# # and from plotting support:
# # meltquantiles <- function(dt, probs = refprobs) {
# #   ky <- setdiff(names(dt), names(probs))
# #   setkeyv(melt(
# #     dt, measure.vars = names(probs)
# #   ), c(ky, "variable"))
# # }