system("cp index.html docs/index.html")

system("cp nationalregions.html docs/nationalregions.html")
system("cp -r nationalregions_files docs/nationalregions_files")

system("cp subnationalregions.html docs/subnationalregions.html")
system("cp -r subnationalregions_files docs/subnationalregions_files")

system("git commit -m \"update webpages")