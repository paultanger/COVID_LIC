# COVID_LIC (impacts of COVID-19 in Low & Middle Income Countries)

This repository is a collection of my work analyzing and integrating data mostly from these two sources of COVID-19 impacts in Low and Middle Income Countries.
* https://github.com/cmmid/covidm_reports.  Described in more detail here: https://cmmid.github.io/topics/covid19/LMIC-projection-reports.html.  This is a collection of country-specific projected COVID-19 epidemics with and without interventions.
* https://github.com/CSSEGISandData/COVID-19.  Lots of data here, we were mostly using the dates for each country in which they reported > 50 COVID cases.

This is a work in progress and some files need to be cleaned up but the key places to start are these files:

* These capture and consolidate data:
  * ConsolidateQSfiles.R
  * organize_crop_calendar.R
  * Organize_JHU_50confirmedcase.R

* These produce various outputs (summary and graphics):
  * get_stats.R
  * plot_crop_cal_v1.R
  * plot_v1.R

Supporting files (best to just source them):
* load_libs.R
* functions.R
* plot_crop_cal_function.R
* plot_function.R

If you have any questions or would like to contribute, please do!
