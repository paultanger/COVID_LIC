#install.packages("ggplot2")
require(ggplot2)
require(scales)

cbPalette2 <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

plot_crop_cal = function(mydata, mytitle, myxlab, myylab, fontsize=12, linesize=4, CI=F){
  # lines for each scenario
  dotplot <- ggplot(mydata, aes(x=value, y=crop, group=crop, color=crop)) +
    #geom_line(size = 10),
    # plant to out
    # to get same color as crop put this inside aes color = crop
    geom_segment(aes(x=plant_date, xend=veg_date, yend=crop), color = "#E69F00", size = linesize+5, data=mydata) +
  #+ geom_label(data=mydata, aes(x=plant_date, y=crop,  label = "P"), vjust = "center", hjust = "center") +
  # veg to end
  geom_segment(aes(x=veg_date, xend=harv_date, yend=crop), color = "#F0E442", size = linesize+5, data=mydata) +
  geom_segment(aes(x=harv_date, xend=end_date, yend=crop), color = "#009E73", size = linesize+5, data=mydata) +
  geom_segment(aes(x=end_date, xend=out_date, yend=crop), color = "#D55E00", size = linesize+5, data=mydata) +
  #geom_segment(aes(x=veg_date, xend=end_date, yend=crop), size = linesize+5, data=mydata)
  # add a second year
  geom_segment(aes(x=plant_date2, xend=veg_date2, yend=crop), color = "#E69F00", size = linesize+5, data=mydata) +
    #+ geom_label(data=mydata, aes(x=plant_date, y=crop,  label = "P"), vjust = "center", hjust = "center") +
    # veg to end
    geom_segment(aes(x=veg_date2, xend=harv_date2, yend=crop), color = "#F0E442", size = linesize+5, data=mydata) +
    geom_segment(aes(x=harv_date2, xend=end_date2, yend=crop), color = "#009E73", size = linesize+5, data=mydata) +
    geom_segment(aes(x=end_date2, xend=out_date2, yend=crop), color = "#D55E00", size = linesize+5, data=mydata)
  # add CI
  if(CI==T){
    dotplot <- dotplot + geom_ribbon(aes(ymin=mydata$lo, ymax=mydata$hi, fill=Scenarios), linetype=2, alpha=0.1, show.legend = F, color=mydata$Scenarios)}
  
  # add points for values
  # geom_point(aes(shape=scen_id, color=scen_id, fill=scen_id),   size=pointsize)
  
  # use custom colors
  dotplot <- dotplot + scale_fill_manual(values=cbPalette2)
  dotplot <- dotplot + scale_color_manual(values=cbPalette2)
  
  # could split by metric or something later (like cases and deaths) 
  #dotplot <- dotplot + facet_grid(region ~ .)
  
  # or do as facet wrap?
  dotplot <- dotplot + facet_wrap(~ region) # labeller = label_wrap_gen())
  
  # add title
  dotplot <- dotplot + ggtitle(mytitle)
  
  # add labels
  dotplot <- dotplot +  xlab(myxlab) + ylab(myylab)
  
  # adjust scale
  #dotplot <- dotplot + scale_x_date(date_breaks = "1 month", date_labels="%b")
  # this drops the data unless we include all the ends of geom segment
  dotplot <- dotplot + scale_x_date(date_breaks = "1 month", date_labels="%b", limits=c(as.Date("2020-04-01"), as.Date("2021-04-01")))
  # try to limit to same x axis as other data
  #dotplot <- dotplot + coord_cartesian(xlim = c(as.Date("2020-04-01"), as.Date("2021-04-01"), clip="on"))
  # this would change legend title
  #scale_colour_discrete("Continents"),
  #dotplot <- dotplot + scale_y_continuous(breaks = waiver(), n.breaks=10, labels = comma)
  
  dotplot <- dotplot + theme( # add elements to theme
    plot.margin = unit(c(1,1,1,1), "lines"), # make margins a little bigger so y axis label fits
    plot.title = element_text(face="bold", size=fontsize+2, hjust = 0.5),
    axis.text = element_text(color="black", size=fontsize),
    axis.title.x = element_text(face="bold", size=fontsize, vjust=0),
    axis.title.y = element_text(face="bold", size=fontsize, angle=90, vjust=0),
    axis.text.x = element_text(angle=45),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_blank(),
    #axis.ticks.x = element_line(size=1, color="black"),
    #axis.ticks.length = unit(.25, "cm"),
    panel.grid.major.x = element_blank(), # switch off major gridlines
    panel.grid.major.y = element_blank(),
    #panel.grid.major.y = element_line(color="grey", size=1), # grid line size is 1... a bit smaller than error bars
    #panel.grid.minor = element_blank(), # switch off minor gridlines
    #legend.key = element_rect(color=NULL),
    legend.position = "top",
    #legend.position = c(0.9,.8), # manually position the legend (numbers being from 0,0 at bottom left of whole plot to 1,1 at top right)
    #legend.title = element_blank(), # switch off the legend title
    legend.text = element_text(size=fontsize-2),
    #legend.key.size = unit(1.5, "cm"),
    legend.key = element_blank(), # switch off the rectangle around symbols in the legend
    panel.background = element_blank(), # panel background
    #plot.background = , # plot background
    # this is the facet text
    strip.text = element_text(size=fontsize-2, face="bold"),
    strip.background = element_blank(), # background of facet label
    panel.border = element_rect(fill=NA)
  )
  return(dotplot)
}