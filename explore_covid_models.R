#install.packages('qs')
library(qs)
library(Hmisc)

scen_over = readRDS(file = "../../scenarios_overview.rds")
# these are all the parameters for the diff scenarios
scen = readRDS('../../scenarios.rds')
# one s
scen[[1]] #unmitigated

# two s - 20 and 50%
scen[[2]] #50% self-isolation and 20/50% social-distancing
# in the paper, this is scen 2 and 3

# 16 s - combinations of hirisk_prop_isolated and hirisk_lorisk_contact
scen[[3]] #50% self-isolation and 80% shielding
# in the paper, this is scen 7

# 32 s - combinations of gen_socdist_other and gen_socdist_contact (basically combinations of 2 and 3 above)
scen[[4]] #50% self-isolation and 80% shielding and 20/50% social-distancing
# in the paper this must be scen 4,5,6... although it seems like it would only cover scen 6 (80 shield, 20 distance)

# look at digest.R - I think that is the script that generated it... start at line 166
# takes one arg.. I think dir of files
# quantiles are not what we thought?
# refprobs <- c(lo.lo=0.025, lo=0.25, med=0.5, hi=0.75, hi.hi=0.975)

setwd('../2020_05_05_archived_04_30_generated/afghanistan/')
# this is the value of each parameter for each day of all runs "all s" - so all scenarios with all quartiles
alls = qread('alls.qs')
describe(alls)
summary(alls)
str(alls)
levels(alls$compartment)

scene = alls[,9]
summary(scene)
# makes sense mostly except what is the s values?
# those are the specific scenarios from above

# subset
alls.subset = alls[(alls$compartment =='cases') & (alls$age == "all") & (alls$t == 111) & (alls$scen_id %in% c(1,2))]

alls.subset = alls[(alls$compartment =='cases') & (alls$age == "all") & (alls$scen_id %in% c(2))]

# get peak of scen 2
alls.subset[alls.subset$med == max(alls.subset$med)]

Eforday0 = subset(alls, (compartment == "E") & (t== 1))
# there is 6 age groups including all and 51 scenarios

# this is also run data t is the time.. so 30 60 days etc
# 500 runs.. but which scenario? I think unmitigated?
# it has more compartments: S Is Ia Ip R unused levels
# just has E, which I believe is exposed people
qs001 = qread('001.qs')
summary(qs001)
levels(qs001$compartment)
qs001 = droplevels(qs001)
levels(qs001$compartment)
# qs001[(qs001$compartment == "S"),]
# subset(qs001, as.character(compartment) == "S")

# this has values, reduction and effectiveness excluding scenario 1 only at key times of 30 60 etc
# but it seems diff than values in alls.qs???
# maybe it is median of runs? nope
accs = qread('accs.qs')
levels(accs$metric)
accs14t30 = accs[(accs$compartment =='E') & (accs$age == "<14") & (accs$t == 30) & (accs$scen_id == 2) & (accs$metric %in% c('value', 'reduction'))]
alls14t30 = alls[(alls$compartment =='E') & (alls$age == "<14") & (alls$t == 30) & (alls$scen_id == 2)]

peak[(peak$compartment =='cases') & (peak$age == "all") & (peak$scen_id == 2) & (peak$metric %in% c('value'))]

qs00114t30 = qs001[(qs001$compartment =='E') & (qs001$age == "<14") & (qs001$t == 30)]
median(qs00114t30$value)

# this is probably what we want
# it is the peak numbers for each scenario, but doesn't have t for them
# it doesn't have scen 1 (unmitigated)
# well it does have timing..
peak = qread('peak.qs')
peak = droplevels(peak)
levels(peak$metric)
# [1] "value"         "timing"        "delay"        
# [4] "reduction"     "effectiveness"
levels(peak$compartment)
# ok I think this is what we want for each country for the simple analysis
peakEvaluetime = peak[(peak$compartment =='E') & (peak$age == '<14') & (peak$scen_id == 2) & (peak$metric %in% c('value', 'timing'))]
