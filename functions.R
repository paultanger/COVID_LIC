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
plot_loop = function(countrieslist, countries, compartments, fontsize=12, pointsize=4, CI=F){
  # retunrs a list of plot objects
  # access like: plots$afghanistan$death_o[[1]]
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
      PlotObj = mydotplotv1(tempdata, mytitle, myxlab, myylab, fontsize=fontsize, pointsize=4, CI=CI)
      # save into a list of plot objects
      plots[[i]][[j]] = c(plots[[i]][[j]],list(PlotObj))
      # access like: plots$afghanistan$death_o[[1]]
      #ggsave(filename, PlotObj)
    }}
  return (plots)
}