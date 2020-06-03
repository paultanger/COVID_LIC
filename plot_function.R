#install.packages("ggplot2")
require(ggplot2)
require(scales)

cbPalette2 <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

mydotplotv1 = function(mydata, mytitle, myxlab, myylab, fontsize=12, pointsize=4, CI=F, deaths_on_cases=F, linesize=1.2){
  # lines for each scenario
  dotplot <- ggplot(mydata, aes(x=Date_JHU, y= med, group=Scenarios, color=Scenarios)) +
    geom_line(data=mydata[mydata[["compartment"]] == "cases",], size = linesize)
  # add CI
    if(CI==T){
      dotplot <- dotplot + geom_ribbon(aes(ymin=mydata$lo, ymax=mydata$hi, fill=Scenarios), linetype=2, alpha=0.1, show.legend = F, color=mydata$Scenarios)}
  
    # add points for values
    # geom_point(aes(shape=scen_id, color=scen_id, fill=scen_id),   size=pointsize)
  
  # 
  if(deaths_on_cases == T) {
    # or this?
    dotplot <- dotplot + stat_summary(fun.data = mydata[mydata$compartment=="death_o",], fun = max, geom="point", shape=Scenarios, color=Scenarios, fill=Scenarios, size=pointsize)
    #stat_summary(aes(label=round(..y..,2)), fun.y=min,geom="text", size=6, hjust = -0.3)
    #dotplot <- dotplot + geom_point(aes(data=mydata[mydata$compartment=="death_o",], x = Date_JHU, y = which.max(med), shape=Scenarios, color=Scenarios, fill=Scenarios),   size=pointsize)
    
  }
  
  # use custom colors
  dotplot <- dotplot + scale_fill_manual(values=cbPalette2)
  dotplot <- dotplot + scale_color_manual(values=cbPalette2)
  
  # could split by metric or something later (like cases and deaths) 
  #dotplot <- dotplot + facet_grid(tissue ~ .)
  
  # add title
  dotplot <- dotplot + ggtitle(mytitle)
  
  # add labels
  dotplot <- dotplot +  xlab(myxlab) + ylab(myylab)
  
  # adjust scale
  #dotplot <- dotplot + scale_x_continuous(limits= c(0, max(mydata$t)+5), breaks = round((seq(0, max(mydata$t)+5, by = 5)/5)) * 5)
  # demo_datetime(date_range("20170115", 30), labels = label_date())
  # dotplot <- dotplot + scale_x_datetime(labels = label_date()) 
  # dotplot <- dotplot + scale_x_date(date_breaks = "1 month", date_labels="%b")
  # force to same scale as other plot
  dotplot <- dotplot + scale_x_date(date_breaks = "1 month", date_labels="%b", limits=c(as.Date("2020-04-15"), as.Date("2021-04-01")))
  # this would change legend title
  #scale_colour_discrete("Continents"),
  dotplot <- dotplot + scale_y_continuous(breaks = waiver(), n.breaks=10, labels = comma)
  # try to force same number of breaks for everything (even if this might look bad, requested by client)
  # breaky=9
  # breaks = seq(min(mydata$med),round(max(mydata$med),-5), length.out = breaky)
  # dotplot <- dotplot + scale_y_continuous(breaks = breaks, labels = comma)
  #breaky=100
  #dotplot <- dotplot + scale_y_continuous( breaks = round(  (seq(0, max(mydata$med)+breaky, by = breaky)/breaky)) * breaky) # limits= c(0, max(mydata$med)+breaky),
  #dotplot <- dotplot + scale_y_continuous(breaks= pretty_breaks(), labels = comma)
  
  
  dotplot <- dotplot + theme( # add elements to theme
    plot.margin = unit(c(1,1,1,1), "lines"), # make margins a little bigger so y axis label fits
    plot.title = element_text(face="bold", size=fontsize+2, hjust = 0.5),
    axis.text = element_text(color="black", size=fontsize),
    axis.text.x = element_text(angle=90, size=fontsize-2),
    axis.title.x = element_text(face="bold", size=fontsize, vjust=0),
    axis.title.y = element_text(face="bold", size=fontsize, angle=90, vjust=0),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_blank(),
    #axis.ticks.x = element_line(size=1, color="black"),
    #axis.ticks.length = unit(.25, "cm"),
    panel.grid.major.x = element_blank(), # switch off major gridlines
    panel.grid.major.y = element_line(color="grey", size=.3), # grid line size is 1... a bit smaller than error bars
    #panel.grid.major.y = element_blank(), # grid line size is 1... a bit smaller than error bars
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
    strip.text = element_text(size=fontsize, face="bold"),
    strip.background = element_blank(), # background of facet label
    panel.border = element_rect(fill=NA)
  )
  return(dotplot)
}