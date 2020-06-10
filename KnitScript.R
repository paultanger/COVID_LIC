# create new env... and make it pretty like rstudio does
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"
codedir = "~/Desktop/github/COVID_LIC/"
filename = "Combined_Plots_Md.Rmd"
setwd(codedir)
source('load_libs.R')
source('functions.R')
#library(knitr);knit(filename, output=paste0(datadir, outputfilename), encoding='UTF-8', envir = new.env())
outputfilename = addStampToFilename("Combined_Plots_Output", "md")
outputfilenamehtml = addStampToFilename("Combined_Plots_Output", "html")

# this doesn't seem to use the YAML settings
setwd(datadir)
knit(paste0(codedir, filename), output=paste0(datadir, outputfilename), envir = new.env())
markdownToHTML(outputfilename, output=outputfilenamehtml)
