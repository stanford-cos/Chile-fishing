# Map Chile VMS fishing effort

# Load Libraries
library(tidyverse)
library(raster)
library(rnaturalearth)
library(rnaturalearthdata)
library(viridis)

# directories
data_raw_dir <- file.path("./data/raw")
data_proc_dir <- file.path("./data/processed")
out_dir <- file.path("./output")
scripts_dir <- file.path("./scripts")


# Import data from  bq_gfw_query.sql
fish_data <- read_csv(file.path(data_raw_dir, "gfw_research_positions_2023_06_15.csv"))

# round data to .01 degree grids
fish_round <- fish_data %>% 
  mutate(lat_bin = round(lat, digits = 1),
         lon_bin = round(lon, digits = 1)) %>% 
  filter(nnet_score == 1)

# group fishing effort by position
fish_group<- fish_round %>% 
  group_by(lat_bin, lon_bin) %>% 
  summarise(fish_hours_sum = sum(hours)) %>% 
  ungroup()

# check out basic summary stats
#summary(fish_group)

# Create a grid with all possible combinations of latitude and longitude
#grid <- expand.grid(lat = unique(fish_grid$lat), lon = unique(fish_grid$lon))
fish_grid <- fish_group %>% 
  complete(lat, lon) #%>% 

# get countries polygon layer
samerica <- rnaturalearth::ne_countries(continent = 'south america', returnclass = "sf", scale = "large")

# How do I get rid of NA gray color displaying on map?

(fish_map2 <- fish_grid %>% 
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



