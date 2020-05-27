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
crop_plots = readRDS("SelectCountriesAllRegionsCropPlots_20200527_1404.Robj")
OtherCountriesAllRegionsCropPlots = readRDS("OtherCountriesAllRegionsCropPlots_20200527_1404.Robj")

# from plot_v1.R we should have a list object of ggplots = plots
plots = readRDS("peak_plots_list_20200527_1421.RObj")

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

combine_countries = intersect(peak_countries, crop_countries)
just_peak = setdiff(peak_countries, crop_countries)

# make sub-lists
plots_separate = plots_to_combine[names(plots_to_combine) %in% just_peak]
plots_to_combine = plots_to_combine[names(plots_to_combine) %in% combine_countries]

# plot countries without crops on their own
setwd(plotdir)
filename = addStampToFilename("Countries_No_GEOGLAM", "pdf")
pdf(filename, width=11, height=8.5)
# # unpack list
for (i in plots_separate) {
  print(i)
  #crop_plots$i
}
dev.off()

# test = sapply(plots_to_combine, "[", combine_countries)
# test2 <- lapply(plots_to_combine, function(x) {names(x) %in% combine_countries})
# or with reduce on the actual lists?

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

i=1
for(i in i:length(plots_to_combine)){
  if (names(plots_to_combine)[[i]] == names(crop_plots_to_combine[i])){
    print(paste0("crop_plots$", names(plots_to_combine)[i]))
    temp_country_name = names(plots_to_combine)[[i]]
    plots_to_combine[[i]]$crop_plot <- crop_plots_to_combine[[temp_country_name]]
  }
}

### this is the part that I need to fix.. maybe %in% not working
# i=1
# for(i in i:length(plots_to_combine)){
#   print(names(plots_to_combine)[[i]])
#   if (names(plots_to_combine)[[i]] %in% names(crop_plots)){
#     print(paste0("crop_plots$", names(plots_to_combine)[[i]]))
#     #plots_to_combine[[i]]$crop_plot <- list(paste0("crop_plots$", names(plots_to_combine)[[i]]))
#     temp_country_name = names(plots_to_combine)[[i]]
#     plots_to_combine[[i]]$crop_plot <- crop_plots[[temp_country_name]]
#     # or as nested list
#     #plots_to_combine[[i]]$crop_plot <- list(crop_plots[[temp_country_name]])
#   }
# }

# return a list of the combined plots
combined_plots = combine_plots_loop(plots_to_combine)

# print them
setwd(plotdir)
filename = addStampToFilename("SelectCountriesCombinedPlots", "pdf")
pdf(filename, width=11, height=8.5)
# unpack list
for (i in combined_plots) {
  print(i)
  #crop_plots$i
}
dev.off()


#####################################

# or try cowplot?
# plot_grid(p1, PlotObj, labels = c('A', 'B'), label_size = 12)
# together = plot_grid(plots$afghanistan$cases[[1]], PlotObj, labels = c('A', 'B'), label_size = 12)

# set title
# title <- ggdraw() + draw_label("Afghanistan", fontface='bold')
#bottom_row <- plot_grid(nutrient_boxplot, tss_flow_plot, ncol = 2, labels = "AUTO")

# plot together
#overlayed = ggdraw(p) + draw_image(logo_file, x = 1, y = 1, hjust = 1, vjust = 1, width = 0.13, height = 0.2)
# final = plot_grid(title, together, flow_timeseries, nrow = 3, labels = c("", "", "C"), rel_heights = c(0.2, 1, 1))
# final = plot_grid(title, plots$afghanistan$cases[[1]], PlotObj, align = "v", ncol = 1, rel_heights = c(0.25, 0.75))

# ideas
# https://felixfan.github.io/stacking-plots-same-x/
# https://gist.github.com/tomhopper/faa24797bb44addeba79

# final = plot_grid(title, plots$afghanistan$cases[[1]], PlotObj, align = "v", ncol = 1, rel_heights = c(0.2, 1, 1))
# final
# dev.off()
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