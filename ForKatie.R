require(qs)
# get this from my google folder and put in your R working directory (wherever it currently is)
alls = qread('AllAllSData_20200514_1636.qs')

# subset - basically like filter in excel:
yourresult = AllAllsData[age == "all" & compartment == "death_o" & .id == "afghanistan" & scen_id == 1]
# view part of it - 10 rows
head(yourresult, 3)

# save it to csv
filename = "Yourresults.csv"
write.csv(yourresult, filename, row.names = FALSE)
