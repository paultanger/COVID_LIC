# Define function for filenames with date stamp
addStampToFilename = function(filename, extension){
  filenameWithStamp = paste(filename, "_", format(Sys.time(),"%Y%m%d_%H%M"), ".", extension, sep="")
  return (filenameWithStamp)
}

#http://stackoverflow.com/questions/13649473/add-a-common-legend-for-combined-ggplots
ggplotlegend = function(plotobj){
  tmp <- ggplot_gtable(ggplot_build(plotobj))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}

# TODO: maybe change this to a data table or apply function
plot_loop = function(countriesOrRegionslist, countries_or_bin, compartments, fontsize=12, pointsize=4, CI=F, deaths_on_cases=F, regions_plotting=F){
  # returns a list of plot objects
  # access like: plots$afghanistan$death_o[[1]]
  i= 1
  j = 1
  # initialize list to store results
  plots = vector(mode = "list", length = length(countriesOrRegionslist))
  names(plots) = countries_or_bin
  # create plot objects and put in list
  for(i in i:length(countriesOrRegionslist)){
    for(j in levels(countriesOrRegionslist[[i]]$compartment)){
      #print(countrieslist[[i]]$compartment[j])
      print(paste0(names(countriesOrRegionslist[i]), "_", j, "_AgeAll"))
      # name the file
      filename = addStampToFilename(paste0(names(countriesOrRegionslist[i]), "_", j, "_AgeAll"), "pdf")
      # subset for compartment
      tempdata = countriesOrRegionslist[[i]][compartment == j]
      # setup names of things
      mytitle = paste0(names(countriesOrRegionslist[i]), " ", j, " over time")
      myxlab = "Date (days since 50 confirmed cases)"
      myylab = paste0("Number of ", j)
      # make the plot
      PlotObj = mydotplotv1(tempdata, mytitle, myxlab, myylab, fontsize=fontsize, pointsize=4, CI=CI, deaths_on_cases)
      # save into a list of plot objects
      if(regions_plotting==T){
      plots[[i]][[j]] = c(plots[[i]][[j]], list(PlotObj))
      }
      if(regions_plotting==F){
        plots[[i]][j] = c(plots[[i]][j], list(PlotObj))
      }
      # access like: plots$afghanistan$death_o[[1]]
      #ggsave(filename, PlotObj)
    }}
  return (plots)
}

plot_loop_together = function(countriesOrRegionslist, countries_or_bin, compartments, fontsize=12, pointsize=4, CI=F, deaths_on_cases=F, linesize=1.2){
  # returns a list of plot objects
  i= 1
  # initialize list to store results
  plots = vector(mode = "list", length = length(countriesOrRegionslist))
  names(plots) = countries_or_bin
  # create plot objects and put in list
  for(i in i:length(countriesOrRegionslist)){
      print(paste0(names(countriesOrRegionslist[i]), "_", "cases, deaths", "_AgeAll"))
      # subset for compartment
      tempdata = countriesOrRegionslist[[i]]
      # setup names of things
      mytitle = paste0(names(countriesOrRegionslist[i]), " ", "cases", " over time")
      myxlab = "Date (days since 50 confirmed cases)"
      myylab = paste0("Number of ", "cases")
      # make the plot
      PlotObj = mydotplotv1(tempdata, mytitle, myxlab, myylab, fontsize=fontsize, pointsize=4, CI=CI, deaths_on_cases, linesize=linesize)
      # save into a list of plot objects
      plots[[i]] = c(plots[[i]], list(PlotObj))
      names(plots[[i]]) = "case_death"
      # access like: plots$afghanistan$death_o[[1]]
      #ggsave(filename, PlotObj)
    }
  return (plots)
}

# TODO: maybe change this to a data table or apply function
crop_plot_loop = function(countrieslist, countries_, fontsize=10, linesize=4, regions=T){
  # returns a list of plot objects
  # access like: plots$afghanistan[[1]]
  i= 1
  # initialize list to store results
  plots = vector(mode = "list", length = length(countrieslist))
  names(plots) = countries_
  # create plot objects and put in list
  for(i in i:length(countrieslist)){
      print(paste0(names(countrieslist[i]), "_"))
      # name the file
      #filename = addStampToFilename(paste0(names(countrieslist[i]), "_Crops"), "pdf")
      # subset for compartment
      #tempdata = countrieslist[[i]]
      # setup names of things
      # if plotting regions
      #mytitle = paste0(names(countrieslist[i]), countrieslist[[i]]$region)
      mytitle = paste0(names(countrieslist[i]))
      myxlab = "Date"
      myylab = paste0("Crops")
      # make the plot
      PlotObjCrop = plot_crop_cal(countrieslist[[i]], mytitle, myxlab, myylab, fontsize=fontsize, linesize=linesize, regions=regions)
      # save into a list of plot objects
      plots[i] = list(PlotObjCrop)
      # access like: plots$afghanistan[[1]]
      #ggsave(filename, PlotObj)
    }
  return (plots)
}

# this version will plot each region in a separate plot (to combine with the peaks)
crop_plot_loop2 = function(other_countries_list, other_countries, fontsize=10, linesize=4){
  # returns a list of plot objects
  # access like: plots$afghanistan$regionname[[1]]
  i= 1
  j = 1
  # initialize list to store results
  other_plots = vector(mode = "list", length = length(other_countries_list))
  names(other_plots) = other_countries
  # create plot objects and put in list
  for(i in i:length(other_countries_list)){
    for(j in levels(other_countries_list[[i]]$region)){
      print(paste0(names(other_countries_list[i]), "_", j))
      # name the file
      #filename = addStampToFilename(paste0(names(other_countries_list[i]), "_", j, "_Crops"), "pdf")
      # subset for region
      tempdata = other_countries_list[[i]][region == j]
      # setup names of things
      # if plotting regions
      mytitle = paste0(names(other_countries_list[i]), " ", j)
      myxlab = "Date"
      myylab = paste0("Crops")
      # make the plot
      PlotObjCrop = plot_crop_cal(tempdata, mytitle, myxlab, myylab, fontsize=fontsize, linesize=linesize, regions=F)
      # save into a list of plot objects
      other_plots[[i]][[j]] = c(other_plots[[i]][[j]],list(PlotObjCrop))
      # access like: plots$afghanistan[[1]]
      #ggsave(filename, PlotObj)
    }
  }
  return (other_plots)
}

combine_plots_loop = function(plots_to_combine){
  # returns a list of plot objects
  i= 1
  # initialize list to store results
  combine_plots = vector(mode = "list", length = length(plots_to_combine))
  names(combine_plots) = names(plots_to_combine)
  # create plot objects and put in list
  # go through countries
  for(i in i:length(plots_to_combine)){
    # define overall plot title - country
    title <- ggdraw() + draw_label(names(plots_to_combine[i]), fontface='bold')
    # if it has a crop plot... plot together
    if (length(plots_to_combine[[i]]) > 1) {
      # peak plots have names of [[1]].. I prob need to fix later
      #combine_plots[i] = list(plot_grid(title, plots_to_combine[[i]][[1]], plots_to_combine[[i]][[2]], align = "v", ncol = 1, rel_heights = c(0.2, 1.3, .7)) )
      # try force left alignment of plots
      combine_plots[i] = list(plot_grid(title, plots_to_combine[[i]][[1]], plots_to_combine[[i]][[2]], align = "v", axis = "r", greedy = T, ncol = 1, rel_heights = c(0.2, 1.3, .7)) )
      
    }
  }
  # maybe later plot something for countries without crops
      #plots_to_combine[[i]]$cases
  return (combine_plots)
}

combine_plots_loop_regions = function(plots_by_region){
  # returns a list of plot objects
  i= 1
  j = 1
  # initialize list to store results
  combine_plots = vector(mode = "list", length = length(plots_by_region))
  names(combine_plots) = names(plots_by_region)
  # create plot objects and put in list
  # go through countries
  for(i in i:length(plots_by_region)){
    # define overall plot title - country
    title <- ggdraw() + draw_label(names(plots_by_region[i]), fontface='bold')
    case_plot <- plots_by_region[[i]][1]
    print(names(plots_by_region[i]))
    print(names(plots_by_region[[i]][1]))
    # for each region, create a plot
    j = 1
    for(j in j:length(plots_by_region[[i]][[2]])){ #test = plots_by_region[[i]][[2]][[j]][[1]]
      print(names(plots_by_region[[i]][[2]][j]))
      combine_plots[[i]][[j]] = list(plot_grid(title, case_plot[[1]], plots_by_region[[i]][[2]][[j]][[1]], align = "v", ncol = 1, rel_heights = c(0.2, 1, .7)) )
    }
  }
  return (combine_plots)
}