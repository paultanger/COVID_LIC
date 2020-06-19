system("cp index.html docs/index.html")
system("rm index.html")

system("cp nationalregions.html docs/nationalregions.html")
system("cp -r nationalregions_files docs/nationalregions_files")

system("rm nationalregions.html")
system("rm -r nationalregions_files")

system("cp subnationalregions.html docs/subnationalregions.html")
system("cp -r subnationalregions_files docs/subnationalregions_files")

system("rm subnationalregions.html")
system("rm -r subnationalregions_files")

system("git commit -m \"update webpages")