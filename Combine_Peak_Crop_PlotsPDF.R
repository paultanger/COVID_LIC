codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"
plotdir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
source('plot_crop_cal_function.R')
setwd(datadir)

# load files
crop_plots = readRDS("SelectCountriesAllRegionsCropPlots_20200617_1829.Robj")
other_crop_plots = readRDS("OtherCountriesAllRegionsCropPlots_20200617_1829.Robj")

# from plot_v1.R we should have a list object of ggplots = plots
plots = readRDS("peak_plots_listUKSmooth_20200617_1821.RObj")

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

# make sub-lists
plots_separate = plots_to_combine[names(plots_to_combine) %in% just_peak]
plots_by_region = plots_to_combine[names(plots_to_combine) %in% combine_region_countries]
plots_to_combine = plots_to_combine[names(plots_to_combine) %in% combine_countries]

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

# order the country lists
combine_countries = sort(combine_countries)
map.plots = vector(mode = "list", length = length(combine_countries))
names(map.plots) = combine_countries

for(i in seq(map.plots)){
  # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
  #get file from directory
  filename = map_filenames.countries$map_filename[names(map.plots)[i] == map_filenames.countries$USAID_Country]
  paste(names(map.plots)[i], " ", filename)
  mapimg = readPNG(filename)
  mapimg = rasterGrob(mapimg)
  map.plots[[i]]$map_plot <- mapimg
  #map.plots[[i]]$map_plot <- list(mapimg)
}
map.plots = map.plots[order(names(map.plots))]

# for regions
combine_region_countries = sort(combine_region_countries)
map.plots.regions = vector(mode = "list", length = length(combine_region_countries))
names(map.plots.regions) = combine_region_countries
map.plots.regions = map.plots.regions[order(names(map.plots.regions))]

# now create text objects
mytheme <- ttheme_default(base_size = 7)
setwd(codedir)
for(i in seq(map.plots)){
  # subset data for each country
  #paste(names(map.plots)[i], " ", filename)
  #countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"),
  #                                     size = 7, x = 0.1, y = .95, hjust=0)
  # instead just insert png with text
  textimg = readPNG("source_text.png")
  textimg = rasterGrob(textimg)
  map.plots[[i]]$map_text <- textimg
}

# # for regions
for(i in seq(map.plots.regions)){
  # subset data for each country
  #paste(names(map.plots.regions)[i], " ", filename)
  # countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"),
  #                                     size = 7, x = 0.1, y = .95, hjust=0)
  # map.plots.regions[[i]]$map_text <- countrytext
  textimg = readPNG("source_text.png")
  textimg = rasterGrob(textimg)
  map.plots.regions[[i]]$map_text <- textimg
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

for(i in seq(plots_to_combine)){
  if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
    print(paste0("crop_plots$", names(plots_to_combine)[i]))
    temp_country_name = names(plots_to_combine)[[i]]
    plots_to_combine[[i]]$crop_plot <- crop_plots_to_combine[[temp_country_name]]
  }
}

########## ########## ########## ########## ########## ########## 
########## ONLY RUN THIS FOR THE NEW COMBINED PDF APPROACH #######
##### THIS WILL PUT ALL THE PLOTS IN ONE LIST: cases, crop_plot, map_plot

for(i in seq(plots_to_combine)){
  if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
    print(paste0("crop_plots$", names(plots_to_combine)[i]))
    temp_country_name = names(plots_to_combine)[[i]]
    plots_to_combine[[i]]$crop_plot <- list(crop_plots_to_combine[[temp_country_name]])
  }
}
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")

for(i in seq(map.plots)){
  # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
  #get file from directory
  filename = map_filenames.countries$map_filename[names(map.plots)[i] == map_filenames.countries$USAID_Country]
  paste(names(map.plots)[i], " ", filename)
  mapimg = readPNG(filename)
  mapimg = rasterGrob(mapimg)
  plots_to_combine[[i]]$map_plot <- list(mapimg)
}

# save this
setwd(datadir)
filename = addStampToFilename("map_plots", "RDS")
# saveRDS(plots_to_combine, filename)

########## END OF RUN THIS FOR THE NEW COMBINED PDF APPROACH #######
########## ########## ########## ########## ########## ########## 

# for(i in seq(map.plots)){
#   if (names(map.plots)[[i]] == names(plots_to_combine[i])){
#     map.plots[[i]]$title <- ggdraw() + draw_label(names(map.plots[i]), fontface='bold')
#     bottom <- plot_grid(plots_to_combine[[i]]$cases, plots_to_combine[[i]]$crop_plot, ncol=1, align="v", axis="l", rel_heights = c(2, 1))
#     map.plots[[i]]$bottom <- bottom
#   }
# }
# save this version with "bottom" plots
setwd(datadir)
filename = addStampToFilename("map.plots_pdf", "RDS")
# saveRDS(map.plots, filename)


###############
# first subset crop plot list
crop_plots_region_to_combine = other_crop_plots[names(other_crop_plots) %in% combine_region_countries]
names(plots_by_region)
names(crop_plots_region_to_combine)

# order lists
crop_plots_region_to_combine = crop_plots_region_to_combine[order(names(crop_plots_region_to_combine))]
plots_by_region = plots_by_region[order(names(plots_by_region))]

# regions
# backup test
map.plots.regions.backup = map.plots.regions
# map.plots.regions = map.plots.regions.backup

# order the list regions the same..
map.plots.regions = map.plots.regions[order(names(map.plots.regions))]
map_filenames.regions = map_filenames.regions[with(map_filenames.regions, order(USAID_Country, map_filename)),]

# fix things where two words not sorting correctly
rownames(map_filenames.regions) <- NULL
# this includes: 
map_filenames.regions = map_filenames.regions[c(1:61,63,62,64:124,126,125,127:147),] # 63,62,126,125

# # combine plots into one big list
for(i in seq(plots_by_region)){
  if (names(plots_by_region)[[i]] == names(crop_plots_region_to_combine[i])){
    print(paste0("crop_plots$", names(plots_by_region)[i]))
    temp_country_name = names(plots_by_region)[[i]]
    plots_by_region[[i]]$crop_plots <- crop_plots_region_to_combine[[temp_country_name]]
  }
}

########## ########## ########## ########## ########## ########## 
########## ONLY RUN THIS FOR THE NEW COMBINED PDF APPROACH #######
##### THIS WILL PUT ALL THE PLOTS IN ONE LIST: cases, crop_plot, map_plot

setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")
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

# save this
setwd(datadir)
filename = addStampToFilename("plots_by_region", "RDS")
# saveRDS(plots_by_region, filename)

########## END OF RUN THIS FOR THE NEW COMBINED PDF APPROACH #######
########## ########## ########## ########## ########## ########## 

for(i in seq(map.plots.regions)){
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
backupmap.plots.regions = map.plots.regions
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")
for(i in seq(map.plots.regions)){
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

region.plots = vector(mode = "list", length = length(map.plots.regions))

for(i in seq(map.plots.regions)){
  j = 1
  for(j in j:length(map.plots.regions[[i]]$bottom_plots)){
    region.plots[[i]][[ names(map.plots.regions[[i]]$bottom_plots[j]) ]]  = arrangeGrob(map.plots.regions[[i]]$title, map.plots.regions[[i]]$bottom_plots[[j]], map.plots.regions[[i]]$map_text, map.plots.regions[[i]]$map_plot[[j]], layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1))
    #arrangeGrob(map.plots.regions[[i]]$title, map.plots.regions[[i]]$bottom_plots[[j]], map.plots.regions[[i]]$map_text, map.plots.regions[[i]]$map_plot[[j]], layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1))
  }
}
names(region.plots) = names(map.plots.regions)

# put into big list
allplots = vector(mode = "list", length = length(map.plots))
# reload map plots
setwd(datadir)
#map.plots = readRDS("map.plots_pdf_20200623_1715.RDS")
i=1
for(i in i:length(map.plots)){
  if (names(map.plots)[[i]] == names(plots_to_combine[i])){
    allplots[[names(map.plots)[[i]]]]  = list(arrangeGrob(map.plots[[i]]$title, map.plots[[i]]$bottom, map.plots[[i]]$map_text, map.plots[[i]]$map_plot, layout_matrix = cbind(c(1,2,2,3), c(1,2,2,4)), heights=c(.4,3,1,1)))
  }
}
# not sure why this is twice as long..
allplots = allplots[c(36:70)]

# add the region ones..
allplots = c(allplots, region.plots)

# order it
allplots = allplots[order(names(allplots))]

# save it
setwd(datadir)
filename = addStampToFilename("allplots", "RDS")
#saveRDS(allplots, filename)

filename = addStampToFilename("region.plots_pdf", "RDS")
#saveRDS(region.plots, filename)

filename = addStampToFilename("map.plots_pdf", "RDS")
#saveRDS(map.plots, filename)

# try printing together
setwd(plotdir)
filename = addStampToFilename("AllPlotsTogether", "pdf")
pdf(filename, width=8.5, height=11)
for (i in seq(allplots)) {
  for (j in seq(allplots[[i]])) {
    grid.newpage()
    grid.draw(allplots[[i]][[j]])
  }
}
dev.off()
