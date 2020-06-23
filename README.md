# COVID_LIC (impacts of COVID-19 in Low & Middle Income Countries)

## Description and Background
This repository is a collection of my work analyzing and integrating data mostly from these two sources of COVID-19 impacts in Low and Middle Income Countries.
* https://github.com/cmmid/covidm_reports.  Described in more detail here: https://cmmid.github.io/topics/covid19/LMIC-projection-reports.html.  This is a collection of country-specific projected COVID-19 epidemics with and without interventions.
* https://github.com/CSSEGISandData/COVID-19.  Lots of data here, we were mostly using the dates for each country in which they reported > 50 COVID cases.

## Draft output website
The draft output is being published here: https://paultanger.github.io/COVID_LIC/

## Prerequisites
Outlined in load_libs.R and described in more detail below.

## Installation
For now, the best way is clone or fork the repo.  The data files have not been uplodated yet, so please contact the author for assistance.

## How to use
This is a work in progress and some files need to be cleaned up but the key places to start are these files:

* These capture and consolidate data:
  * ConsolidateQSfiles.R
  * organize_crop_calendar.R
  * Organize_JHU_50confirmedcase.R
  * Organize_USAID_sorting_cols.R

* These produce various outputs (summary and graphics):
  * get_stats.R
  * plot_crop_cal_v1.R
  * plot_v1.R
  * Combine_Peak_Crop_Plots.R
  * plot_regions.R

Development is in progress for a markdown output (rather than pdf outputs):
  * Combined_Plots_Md.Rmd

Supporting files (best to just source them):
* load_libs.R
* functions.R
* plot_crop_cal_function.R
* plot_function.R

For the webpages, there is three 3 Rmd files:
* index.Rmd builds the main page
* nationalregions.Rmd builds the nationalregions.html using CountryTemplate.Rmd
* subnationalregions.Rmd builds the subnationalregions.html using CountryTemplateSubRegions.Rmd

For testing of the website, there is a test repo, to pull from that:
git pull test master

## Future plans
Improve documentation and add additional analysis

## How to contribute
If you have any questions or would like to contribute, please let me know, <paultangercoder@gmail.com>.

## License
To be updated later
