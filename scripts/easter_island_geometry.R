# Get Easter Island EEZ boundary from Marine Regions website
# convert and save to WTK format compatable with Big Query

# Packages
library(mregions)
library(sf)
library(dplyr)

# search for geo codes & names
#test <- mr_geo_code(place = "easter", like = TRUE, fuzzy = FALSE)

# Get shape file from Marine Regions
easter_island_eez <- mregions::mr_shp(key = "MarineRegions:eez",
                                      filter = "Chilean Exclusive Economic Zone (Easter Island)",
                                      maxFeatures = 200) # what is maxFeatures? number of features
# check shp is what we expect
# library(leaflet)
# leaflet() %>%
#   addTiles() %>%
#   addPolygons(data = easter_island_eez)

# Convert the geometry column to WKT format
easter_island_eez_geo <- easter_island_eez$geometry

# add text value to global environment 
easter_island_eez_wkt <- sf::st_as_text(easter_island_eez_geo)

# Create a data frame containing the WKT strings
wkt_df <- data.frame(wkt_geometry = easter_island_eez_wkt)

# create local file path
eez_file_local <- file.path(data_dir, "easter_island_eez_wkt.csv")

# write_csv(wkt_df, eez_file_local, col_names = F)

# Check if the file exists
if (!file.exists(eez_file_local)) {
  write_csv(wkt_df, eez_file_local, col_names = FALSE)
} else {
  message("File already exists in data folder. Skipping write.")
}