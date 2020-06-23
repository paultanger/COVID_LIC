diff --git a/Combine_Peak_Crop_Plots.R b/Combine_Peak_Crop_Plots.R
index 5357223..b84ba40 100644
--- a/Combine_Peak_Crop_Plots.R
+++ b/Combine_Peak_Crop_Plots.R
@@ -13,14 +13,17 @@ setwd(datadir)
 # other countries (regions need to be separate) = other_crop_plots
 
 # load files
-crop_plots = readRDS("SelectCountriesAllRegionsCropPlots_20200603_1429.Robj")
-other_crop_plots = readRDS("OtherCountriesAllRegionsCropPlots_20200603_1429.Robj")
+# crop_plots = readRDS("SelectCountriesAllRegionsCropPlots_20200603_1429.Robj")
+# other_crop_plots = readRDS("OtherCountriesAllRegionsCropPlots_20200603_1429.Robj")
+crop_plots = readRDS("SelectCountriesAllRegionsCropPlots_20200617_1829.Robj")
+other_crop_plots = readRDS("OtherCountriesAllRegionsCropPlots_20200617_1829.Robj")
 
 # from plot_v1.R we should have a list object of ggplots = plots
 #plots = readRDS("peak_plots_list_20200527_1619.RObj")
 #plots = readRDS("peak_plots_list_20200602_1706.RObj")
 # version with pretty breaks
-plots = readRDS("peak_plots_list_20200602_1712.RObj")
+# plots = readRDS("peak_plots_list_20200602_1712.RObj")
+plots = readRDS("peak_plots_listUKSmooth_20200617_1821.RObj")
 
 
 # the easier ones first, we'll take the list object from each and plot together
@@ -138,29 +141,43 @@ filename = addStampToFilename("map_filenames", "csv")
 map_filenames.countries = unique(map_filenames[map_filenames$plot_regions == F, c(3,5)])
 map_filenames.regions = unique(map_filenames[map_filenames$plot_regions == T, c(3,5)])
 
+# get list of region countries that are new (not in old list)
+# new.map_filenames.regions = map_filenames.regions
+# old.map_filenames.regions = map_filenames.regions
+
+
+# missing.map.regions = setdiff(new.map_filenames.regions$map_filename, old.map_filenames.regions$map_filename)
+setwd(datadir)
+filename = addStampToFilename("missing.map.regions", "csv")
+# write.csv(missing.map.regions, filename, row.names = F)
+
 map_filenames.countries = map_filenames.countries[map_filenames.countries$USAID_Country %in% combine_countries,]
 
 # make plots
 setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")
 
-i=1
+# order the country lists
+combine_countries = sort(combine_countries)
 map.plots = vector(mode = "list", length = length(combine_countries))
 names(map.plots) = combine_countries
 
-for(i in i:length(map.plots)){
+for(i in seq(map.plots)){
   # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
   #get file from directory
   filename = map_filenames.countries$map_filename[names(map.plots)[i] == map_filenames.countries$USAID_Country]
   paste(names(map.plots)[i], " ", filename)
   mapimg = readPNG(filename)
   mapimg = rasterGrob(mapimg)
-  map.plots[[i]]$map_plot <- mapimg
+  #map.plots[[i]]$map_plot <- mapimg
+  map.plots[[i]]$map_plot <- list(mapimg)
 }
+map.plots = map.plots[order(names(map.plots))]
 
 # for regions
-i=1
+combine_region_countries = sort(combine_region_countries)
 map.plots.regions = vector(mode = "list", length = length(combine_region_countries))
 names(map.plots.regions) = combine_region_countries
+map.plots.regions = map.plots.regions[order(names(map.plots.regions))]
 
 # for(i in i:length(map.plots.regions)){
 #   # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
@@ -174,35 +191,39 @@ names(map.plots.regions) = combine_region_countries
 
 
 # now create text objects
-setwd(datadir)
-PeakCasesDeathsDates = read.csv("PeakCaseDeathDatesAllCountries_20200602_1354.csv")
-PeaksbyCountry.wide.plots = read.csv("PeakCaseDeathDatesAllCountriesForPlots_20200604_1525.csv")
-colnames(PeaksbyCountry.wide.plots) = c("USAID_Country", "Region", "Scenario", "Peak Cases Date", "Peak Deaths Date")
-
-mytheme <- ttheme_default(base_size = 7)
-
-i = 1
-for(i in i:length(map.plots)){
-  # subset data for each country
-  mydata1 = PeaksbyCountry.wide.plots[PeaksbyCountry.wide.plots$USAID_Country == names(map.plots)[i], ]
-  paste(names(map.plots)[i], " ", filename)
-  countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"), 
-                                      size = 7, x = 0.1, y = .95, hjust=0)
-  countrytext = countrytext + annotation_custom(tableGrob(mydata1[,c(3:5)], rows = NULL, theme = mytheme), xmin = 0, ymin = -0.15)
-  map.plots[[i]]$map_text <- countrytext
-}
-
-# for regions
-i = 1
-for(i in i:length(map.plots.regions)){
-  # subset data for each country
-  mydata1 = PeaksbyCountry.wide.plots[PeaksbyCountry.wide.plots$USAID_Country == names(map.plots.regions)[i], ]
-  paste(names(map.plots.regions)[i], " ", filename)
-  countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"), 
-                                      size = 7, x = 0.1, y = .95, hjust=0)
-  countrytext = countrytext + annotation_custom(tableGrob(mydata1[,c(3:5)], rows = NULL, theme = mytheme), xmin = 0, ymin = -0.15)
-  map.plots.regions[[i]]$map_text <- countrytext
-}
+# setwd(datadir)
+# PeakCasesDeathsDates = read.csv("PeakCaseDeathDatesAllCountries_20200602_1354.csv")
+# PeaksbyCountry.wide.plots = read.csv("PeakCaseDeathDatesAllCountriesForPlots_20200604_1525.csv")
+# colnames(PeaksbyCountry.wide.plots) = c("USAID_Country", "Region", "Scenario", "Peak Cases Date", "Peak Deaths Date")
+# # save this for markdown access
+# setwd(datadir)
+# filename = addStampToFilename("PeaksbyCountry.wide.plots", "csv")
+# #write.csv(PeaksbyCountry.wide.plots[,c(2:6)], filename, row.names = F)
+# 
+# mytheme <- ttheme_default(base_size = 7)
+# 
+# i = 1
+# for(i in i:length(map.plots)){
+#   # subset data for each country
+#   mydata1 = PeaksbyCountry.wide.plots[PeaksbyCountry.wide.plots$USAID_Country == names(map.plots)[i], ]
+#   paste(names(map.plots)[i], " ", filename)
+#   countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"), 
+#                                       size = 7, x = 0.1, y = .95, hjust=0)
+#   countrytext = countrytext + annotation_custom(tableGrob(mydata1[,c(3:5)], rows = NULL, theme = mytheme), xmin = 0, ymin = -0.15)
+#   map.plots[[i]]$map_text <- countrytext
+# }
+# 
+# # for regions
+# i = 1
+# for(i in i:length(map.plots.regions)){
+#   # subset data for each country
+#   mydata1 = PeaksbyCountry.wide.plots[PeaksbyCountry.wide.plots$USAID_Country == names(map.plots.regions)[i], ]
+#   paste(names(map.plots.regions)[i], " ", filename)
+#   countrytext = ggdraw() + draw_label(paste0("Data sources: London School of Hygiene & Tropical Medicine (LSHTM) for COVID-19 modeling\n Group on Earth Observations Global Agricultural Monitoring Initiative (GEOGLAM) for crop calendars\n Johns Hopkins University for date of 50th confirmed cases.  Contact: CHillbruner@usaid.gov"), 
+#                                       size = 7, x = 0.1, y = .95, hjust=0)
+#   countrytext = countrytext + annotation_custom(tableGrob(mydata1[,c(3:5)], rows = NULL, theme = mytheme), xmin = 0, ymin = -0.15)
+#   map.plots.regions[[i]]$map_text <- countrytext
+# }
 
 # big loop to make the whole figures
 # or use code below.. or the resultant lists:
@@ -222,23 +243,46 @@ plots_to_combine_backup = plots_to_combine
 crop_plots_to_combine = crop_plots_to_combine[order(names(crop_plots_to_combine))]
 plots_to_combine = plots_to_combine[order(names(plots_to_combine))]
 
-i=1
-for(i in i:length(plots_to_combine)){
+# for the markdown approach, add the map plots to plots to combine
+for(i in seq(map.plots)){
+  # if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
+  #get file from directory
+  filename = map_filenames.countries$map_filename[names(map.plots)[i] == map_filenames.countries$USAID_Country]
+  paste(names(map.plots)[i], " ", filename)
+  mapimg = readPNG(filename)
+  mapimg = rasterGrob(mapimg)
+  plots_to_combine[[i]]$map_plot <- list(mapimg)
+}
+# save this
+setwd(datadir)
+filename = addStampToFilename("country_plots_for_markdown", "RDS")
+# saveRDS(plots_to_combine, filename)
+# saveRDS(map.plots, filename)
+
+for(i in seq(plots_to_combine)){
   if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
     print(paste0("crop_plots$", names(plots_to_combine)[i]))
     temp_country_name = names(plots_to_combine)[[i]]
-    plots_to_combine[[i]]$crop_plot <- crop_plots_to_combine[[temp_country_name]]
+    plots_to_combine[[i]]$crop_plot <- list(crop_plots_to_combine[[temp_country_name]])
   }
 }
+# save for markdown approach
+setwd(datadir)
+filename = addStampToFilename("map.plots", "RDS")
+# saveRDS(plots_to_combine, filename)
 
-i = 1
-for(i in i:length(map.plots)){
-  if (names(map.plots)[[i]] == names(plots_to_combine[i])){
-    map.plots[[i]]$title <- ggdraw() + draw_label(names(map.plots[i]), fontface='bold')
-    bottom <- plot_grid(plots_to_combine[[i]]$cases, plots_to_combine[[i]]$crop_plot, ncol=1, align="v", axis="l", rel_heights = c(2, 1))
-    map.plots[[i]]$bottom <- bottom
-  }
-}
+# i = 1
+# for(i in i:length(map.plots)){
+#   if (names(map.plots)[[i]] == names(plots_to_combine[i])){
+#     map.plots[[i]]$title <- ggdraw() + draw_label(names(map.plots[i]), fontface='bold')
+#     bottom <- plot_grid(plots_to_combine[[i]]$cases, plots_to_combine[[i]]$crop_plot, ncol=1, align="v", axis="l", rel_heights = c(2, 1))
+#     map.plots[[i]]$bottom <- bottom
+#   }
+# }
+# save this version with "bottom" plots
+setwd(datadir)
+filename = addStampToFilename("map.plots", "RDS")
+# saveRDS(map.plots, filename)
 
 ###############
 # first subset crop plot list
@@ -251,8 +295,7 @@ crop_plots_region_to_combine = crop_plots_region_to_combine[order(names(crop_plo
 plots_by_region = plots_by_region[order(names(plots_by_region))]
 
 # combine plots into one big list
-i=1
-for(i in i:length(plots_by_region)){
+for(i in seq(plots_by_region)){
   if (names(plots_by_region)[[i]] == names(crop_plots_region_to_combine[i])){
     print(paste0("crop_plots$", names(plots_by_region)[i]))
     temp_country_name = names(plots_by_region)[[i]]
@@ -285,32 +328,38 @@ for(i in i:length(plots_by_region)){
 # names(map.plots.regions.list) = names(map.plots.regions)
 # for(j in levels(other_countries_list[[i]]$region)){
 
-i = 1
-j = 1
-
 # order the list regions the same..
 map.plots.regions = map.plots.regions[order(names(map.plots.regions))]
 map_filenames.regions = map_filenames.regions[with(map_filenames.regions, order(USAID_Country, map_filename)),]
 
 # fix things where two words not sorting correctly
 rownames(map_filenames.regions) <- NULL
-map_filenames.regions = map_filenames.regions[c(1:44,46,45,47:90,92,91,93:110),]
-
-for(i in i:length(map.plots.regions)){
-  if (names(map.plots.regions)[[i]] == names(plots_by_region[i])){
-    map.plots.regions[[i]]$title <- ggdraw() + draw_label(names(map.plots.regions[i]), fontface='bold')
-    # bottom and map_plot will need to be sublists..
-    print(names(map.plots.regions[i]))
-    j=1
-    for(j in j:length(plots_by_region[[i]]$crop_plots)){
-      temp_region_name = names(plots_by_region[[i]]$crop_plots[j])
-      print(temp_region_name)
-      bottom <- plot_grid(plots_by_region[[i]]$cases, plots_by_region[[i]]$crop_plots[j][[1]][[1]], ncol=1, align="v", axis="l", rel_heights = c(2, 1))
-      map.plots.regions[[i]]$bottom_plots[temp_region_name] =  list(bottom)
-      #map.plots.regions[[i]][[temp_region_name]] = c(map.plots.regions[[i]][[temp_region_name]] , list(bottom))
-    }
-  }
-}
+# this includes: 
+# Central African Republic (West has Central region map; Vakaga has West; South West has Vakaga; Central has South West)
+# Guinea (Zone North has Zone South; Zone South has Zone South East; Zone East has Zone West; Zone West has Zone North)
+# Tanzania (Central has Northern; Northeast has Northern Coast; Northern has Southeast; Northern Coast has Southwest; Southeast has Central; Southwest has Northeast)
+map_filenames.regions = map_filenames.regions[c(1:61,63,62,64:124,126,125,127:147),] # 63,62,126,125
+#map_filenames.regions = map_filenames.regions[c(1:44,46,45,47:90,92,91,93:110),]
+
+# until we have the maps remove new countries
+# map_filenames.regions2 = map_filenames.regions[map_filenames.regions$USAID_Country %in% c("Benin", "Burkina Faso"),]
+# map_filenames.regions = map_filenames.regions2
+
+# for(i in seq(map.plots.regions)){
+#   if (names(map.plots.regions)[[i]] == names(plots_by_region[i])){
+#     map.plots.regions[[i]]$title <- ggdraw() + draw_label(names(map.plots.regions[i]), fontface='bold')
+#     # bottom and map_plot will need to be sublists..
+#     print(names(map.plots.regions[i]))
+#     j=1
+#     for(j in seq(plots_by_region[[i]]$crop_plots)){
+#       temp_region_name = names(plots_by_region[[i]]$crop_plots[j])
+#       print(temp_region_name)
+#       bottom <- plot_grid(plots_by_region[[i]]$cases, plots_by_region[[i]]$crop_plots[j][[1]][[1]], ncol=1, align="v", axis="l", rel_heights = c(2, 1))
+#       map.plots.regions[[i]]$bottom_plots[temp_region_name] =  list(bottom)
+#       #map.plots.regions[[i]][[temp_region_name]] = c(map.plots.regions[[i]][[temp_region_name]] , list(bottom))
+#     }
+#   }
+# }
 
 # redo the map plots - one for each region
 # for(i in i:length(map.plots.regions)){
@@ -322,28 +371,45 @@ for(i in i:length(map.plots.regions)){
 #   mapimg = rasterGrob(mapimg)
 #   map.plots.regions[[i]]$map_plot <- mapimg
 # }
+# setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")
+# i=1
+# for(i in i:length(map.plots.regions)){
+#     j=1
+#     for(j in j:length(map.plots.regions[[i]]$bottom_plots)){
+#       filename = map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country][j]
+#       print(filename)
+#       #paste(names(map.plots.regions)[i], " ", filename)
+#       # test = map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country]
+#       # print(test[j])
+#       # #print(map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country][j])
+#       mapimg = readPNG(filename)
+#       mapimg = rasterGrob(mapimg)
+#       temp_region_name = names(map.plots.regions[[i]]$bottom_plots[j])
+#       map.plots.regions[[i]]$map_plot[temp_region_name] = list(mapimg)
+#     }
+# }
+
+# markdown approach, add maps to plots_by_region
 setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/GEOGLAM_map_files/")
-i=1
-for(i in i:length(map.plots.regions)){
-    j=1
-    for(j in j:length(map.plots.regions[[i]]$bottom_plots)){
-      filename = map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country][j]
-      print(filename)
-      #paste(names(map.plots.regions)[i], " ", filename)
-      # test = map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country]
-      # print(test[j])
-      # #print(map_filenames.regions$map_filename[names(map.plots.regions)[i] == map_filenames.regions$USAID_Country][j])
-      mapimg = readPNG(filename)
-      mapimg = rasterGrob(mapimg)
-      temp_region_name = names(map.plots.regions[[i]]$bottom_plots[j])
-      map.plots.regions[[i]]$map_plot[temp_region_name] = list(mapimg)
-    }
+plots_by_regionbackup = plots_by_region
+for(i in seq(plots_by_region)){
+  for(j in seq(plots_by_region[[i]]$crop_plots)){
+    filename = map_filenames.regions$map_filename[names(plots_by_region)[i] == map_filenames.regions$USAID_Country][j]
+    print(filename)
+    mapimg = readPNG(filename)
+    mapimg = rasterGrob(mapimg)
+    temp_region_name = names(plots_by_region[[i]]$crop_plots[j])
+    plots_by_region[[i]]$map_plot[temp_region_name] = list(mapimg)
   }
+}
 
 # save it
 setwd(datadir)
+filename = addStampToFilename("plots_by_region", "RDS")
+# saveRDS(plots_by_region, filename)
+setwd(datadir)
 filename = addStampToFilename("map.plots", "RDS")
-# saveRDS(map.plots, filename)
+# saveRDS(plots_to_combine, filename)
 filename = addStampToFilename("map.plots.regions", "RDS")
 # saveRDS(map.plots.regions, filename)
 
@@ -398,6 +464,13 @@ dev.off()
 # }
 # dev.off()
 
+# do with the temp files for markdown approach
+map.plots = readRDS("map.plots_20200617_1128.RDS")
+region.plots = readRDS("plots_by_region_20200616_1936.RDS") 
+combined.plots = c(map.plots, region.plots)
+combined.plots = combined.plots[order(names(combined.plots))]
+filename = addStampToFilename("combined.plots.for.markdown", "RDS")
+# saveRDS(combined.plots, filename)
 
 # put into big list
 allplots = vector(mode = "list", length = length(map.plots))
