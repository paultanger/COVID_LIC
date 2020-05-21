codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
source('plot_crop_cal_function.R')
setwd(datadir)

# crops_cal = read.csv("CropCal_20200519_1000.csv", colClasses=c(rep("factor",3), rep("numeric",5), rep("Date", 5)))
# crops_cal = read.csv("CropCalv2_20200519_2041.csv", colClasses=c(rep("factor",3), rep("numeric",5), rep("Date", 5)))
# crops_cal = read.csv("CropCalv3_just_dates_20200520_1125.csv", colClasses=c(rep("factor",3), rep("Date", 5)))
# crops_cal = read.csv("CropCalv3_just_dates_20200520_1141.csv", colClasses=c(rep("factor",3), rep("Date", 10)))
crops_cal = read.csv("CropCalv4_just_dates_20200520_1558.csv", colClasses=c(rep("factor",3), rep("Date", 12)))

# just one country for now

crops_cal = crops_cal[(crops_cal$country == "Afghanistan") & (crops_cal$region == "Badghis and Faryab"), ]

# multiple regions
#crops_cal = crops_cal[(crops_cal$country == "Afghanistan"), ]
crops_cal = crops_cal[(crops_cal$country == "Ethiopia"), ]
crops_cal = crops_cal[(crops_cal$country == "Turkmenistan"), ]

# just keep dates
#crops_cal = crops_cal[,-c(4:8)]

# make it long format
#crops_cal_long = melt(crops_cal, id=c("country", "region", "crop"), variable.name = "dates", value.name = "value")

####### TEST WITH ONE ############
# set titles
mytitle = "Country Region"
myxlab = "Date"
myylab = "Crops"
PlotObj = plot_crop_cal(crops_cal, mytitle, myxlab, myylab, fontsize=9, linesize=2)
PlotObj

# save it
filename = addStampToFilename('Afghanistan_Crop_Cal_Region_v1', 'pdf')
# set data dir
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
#ggsave(filename, PlotObj, width=7, height=6, units="in", scale=1.5)
ggsave(filename, PlotObj)

# TODO: loop through all

# setup list to plot of countries
crops_cal = read.csv("CropCalv4_just_dates_20200520_1558.csv", colClasses=c(rep("factor",3), rep("Date", 12)))
countries = c("Afghanistan")
countries = levels(crops_cal$country)

crops_cal.SelectCountries = crops_cal[crops_cal$country %in% countries, ]
crops_cal.SelectCountries = droplevels(crops_cal.SelectCountries)

crops_cal.SelectCountries = as.data.table(crops_cal.SelectCountries)
countrieslist = split(crops_cal.SelectCountries, by="country")
#crops_cal.SelectCountries$Country_OU = as.factor(crops_cal.SelectCountries$Country_OU)
#countries = levels(crops_cal.SelectCountries$country)

# run loop
crop_plots = crop_plot_loop(countrieslist, countries, fontsize=9)
# access like:
# crop_plots$Afghanistan
# crop_plots$Algeria

# print them
setwd("~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/")
filename = addStampToFilename("AllCountriesAllRegionsCropPlots", "pdf")
pdf(filename, width=11, height=8.5)
# unpack list
for (i in crop_plots) {
  print(i)
  #crop_plots$i
}
dev.off()

# or try cowplot?
# plot_grid(p1, PlotObj, labels = c('A', 'B'), label_size = 12)
# together = plot_grid(plots$afghanistan$cases[[1]], PlotObj, labels = c('A', 'B'), label_size = 12)

# set title
title <- ggdraw() + draw_label("Afghanistan", fontface='bold')
#bottom_row <- plot_grid(nutrient_boxplot, tss_flow_plot, ncol = 2, labels = "AUTO")

# plot together
#overlayed = ggdraw(p) + draw_image(logo_file, x = 1, y = 1, hjust = 1, vjust = 1, width = 0.13, height = 0.2)
# final = plot_grid(title, together, flow_timeseries, nrow = 3, labels = c("", "", "C"), rel_heights = c(0.2, 1, 1))
# final = plot_grid(title, plots$afghanistan$cases[[1]], PlotObj, align = "v", ncol = 1, rel_heights = c(0.25, 0.75))

# ideas
# https://felixfan.github.io/stacking-plots-same-x/
# https://gist.github.com/tomhopper/faa24797bb44addeba79

final = plot_grid(title, plots$afghanistan$cases[[1]], PlotObj, align = "v", ncol = 1, rel_heights = c(0.2, 1, 1))
final
dev.off()
# but I guess we really need 2019 to include the current ongoing season

# # with grid arrange
# library(grid)
# grid.newpage()
# grid.draw(rbind(ggplotGrob(plots$afghanistan$cases[[1]]), ggplotGrob(PlotObj), size = "last"))
# 
# # or with egg?
# install.packages('egg')
# library(egg)
# ggarrange(plots$afghanistan$cases[[1]], PlotObj, ncol=1)
# 
# # to get them to have same x I think I need to put all data together and plot in one object
# 
# # but could try this..?
# draft <- ggdraw(plots$afghanistan$cases[[1]]) + ggdraw(PlotObj)
#   
# # and also overlay with the maps
# # https://wilkelab.org/cowplot/articles/drawing_with_on_plots.html
# inset <- ggplot(mpg, aes(drv)) + 
#   geom_bar(fill = "skyblue2", alpha = 0.7) + 
#   scale_y_continuous(expand = expand_scale(mult = c(0, 0.05))) +
#   theme_minimal_hgrid(11)
# 
# ggdraw(p + theme_half_open(12)) +
#   draw_plot(inset, .45, .45, .5, .5) +
#   draw_plot_label(
#     c("A", "B"),
#     c(0, 0.45),
#     c(1, 0.95),
#     size = 12
#   )
# 
# 
