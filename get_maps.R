codedir = "~/Desktop/github/COVID_LIC"
datadir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/"
plotdir = "~/paultangerusda drive/2020_Sync/COVID analysis (Paul Tanger)/data/plots/test/"

setwd(codedir)
source('functions.R')
source('load_libs.R')
source('plot_crop_cal_function.R')
setwd(datadir)

theme_opts <- list(theme(panel.grid.minor = element_blank(),
                         panel.grid.major = element_blank(),
                         panel.background = element_blank(),
                         plot.background = element_blank(),
                         axis.line = element_blank(),
                         axis.text.x = element_blank(),
                         axis.text.y = element_blank(),
                         axis.ticks = element_blank(),
                         axis.title.x = element_blank(),
                         axis.title.y = element_blank(),
                         plot.title = element_blank()))

other_sorting_cols = fread("JHU_UK_Katie_USAIDv4_GEO_FINAL_20200529_1529.csv", stringsAsFactors=T, header=T)
other_sorting_cols = other_sorting_cols[,c(1,9)]
setwd(paste0(datadir, "GEOGLAM_map_files/"))

ISO = "BGD"
ISO = "BOL"
ISO = "COL"
ISO = "CUB"
ISO = "ECU"
ISO = "GTM"
ISO = "HTI"
ISO = "LKA"
ISO = "NPL"
ISO = "PAK"
ISO = "PER"
ISO = "SLV"
ISO = "TJK"
ISO = "ARG"
region = "Buenos_Aires"

themap <- getData("GADM", country=ISO, level=0)
#themap <- getData("GADM", country=ISO, level=1)
themap_UTM = themap
#plot(BGD)
#themap_UTM <- spTransform(themap, CRS("+init=EPSG:32737"))
#themap_UTM@data$region
#themap_UTM_region <- themap_UTM[themap_UTM@data$NAME_1 == region,]
themap_UTM_df<-fortify(themap_UTM)
# get place for name
centroids.df <- as.data.frame(coordinates(themap_UTM))
names(centroids.df) <- c("Longitude", "Latitude")

countryname = as.vector(other_sorting_cols[other_sorting_cols$Country_Code == ISO,1]$USAID_Country)
ids.df <- data.frame(id = countryname, centroids.df)

countrymap = ggplot() + 
  geom_polygon(data=themap_UTM, aes(long,lat,group=group), fill="darkgrey") +
  geom_path(data=themap_UTM, aes(long,lat, group=group), color="grey", size=0.1) + theme_opts +
  geom_text(data=ids.df, aes(label = id, x = Longitude, y = Latitude), size=12) #add labels at centroids
#countrymap
ggsave(paste0(ISO, "_", region, ".png"), countrymap, width=158, height=158, units= "mm", dpi=96)
