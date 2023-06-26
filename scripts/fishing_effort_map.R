# Map Chile VMS fishing effort

# Load Libraries
library(tidyverse)
library(raster)
library(rnaturalearth)
library(rnaturalearthdata)
library(viridis)
library(leaflet)
library(leaflet.extras)

# directories
data_dir <- file.path("./data")
out_dir <- file.path("./output")
scripts_dir <- file.path("./scripts")


# Import data from  bq_gfw_query.sql
fish_data <- read_csv(file.path(data_dir, "gfw_vms_binned_2023_06_26.csv"))

# ----------------------------------
get_a_vessel <- function(
    )

# Calc how many positions available for each ssvid
vessels <- fish_data |> 
  group_by(ssvid) |> 
  summarise(count = n()) |> 
  arrange(desc(count))

# filter data by vessel with the most positions
a_vessel <- fish_data |> 
  filter(ssvid == vessels[[4,"ssvid"]])

# Create a grid with all possible combinations of latitude and longitude
#grid <- expand.grid(lat = unique(fish_grid$lat), lon = unique(fish_grid$lon))
# fish_grid <- fish_group %>% 
#   complete(lat, lon) 


#### Map with Leaflet
map_vessel <- function(
    )

map <- leaflet(a_vessel) |> 
  addProviderTiles(providers$CartoDB.Positron) |> 
  addTiles() |> 
  setView(lng = mean(fish_data$lon_bin), 
          lat = mean(fish_data$lat_bin), 
          zoom = 4) |> 
  addCircleMarkers(lng = ~lon_bin, lat = ~lat_bin) # need tilda
map

# If we want to link lat/lng values - will need timestamp data


# Create a leaflet map object
heat <- leaflet(fish_data) %>%
  addTiles() %>%
  setView(lng = mean(fish_data$lon_bin), 
          lat = mean(fish_data$lat_bin), 
          zoom = 4) %>%
  addHeatmapTiles(lng = fish_data$lon_bin, 
                  lat = fish_data$lat_bin, 
                  intensity = fish_data$hours)

heat













# get countries polygon layer
samerica <- rnaturalearth::ne_countries(continent = 'south america', returnclass = "sf", scale = "large")

# How do I get rid of NA gray color displaying on map?

(fish_map2 <- fish_data %>% 
    ggplot() +
    geom_sf(data = samerica) +
    # geom_tile(aes(x = lon, y = lat, fill = fish_hours_sum), 
    #           width = tile_width, 
    #           height = tile_height) +
    geom_raster(aes(x = lon, y = lat, fill = fish_hours_sum)) +
    scale_fill_viridis(begin = 0.1, 
                       end = 0.95, 
                       direction = -1, 
                       option = "B") +
    coord_sf(xlim = c(min(fish_grid$lon)-25, 
                      max(fish_grid$lon)+15),
             ylim = c(min(fish_grid$lat), 
                      max(fish_grid$lat))) +
    theme_light() +
    labs(x="",
         y="",
         fill ="Total Fishing Hours") +
    theme(legend.position = c(0.2, 0.17))
)



