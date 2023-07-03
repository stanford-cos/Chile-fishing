# Map Chile VMS fishing effort

# Load Libraries
library(renv)
library(tidyverse)
library(raster)
library(rnaturalearth)
library(rnaturalearthdata)
library(viridis)
library(leaflet)
library(leaflet.extras)
library(mapview)
library(lubridate)
library(htmltools)



# analysis functions ----------------------------------

# Calc how many positions available for each ssvid
# input dataframe must have ssvid column
get_vessels <- function(adataframe){
  vessels <- adataframe |> 
    group_by(ssvid) |> 
    summarise(count = n()) |> 
    arrange(desc(count))
  
  return(vessels)
}


# Get a single vessel record
get_one_vessel <- function(adataframe, vessel_index){
  
  vessels <- adataframe |> 
    group_by(ssvid) |> 
    summarise(count = n()) |> 
    arrange(desc(count))
  
   a_vessel <- adataframe |> 
    filter(ssvid == vessels[[vessel_index,"ssvid"]]) |> 
     mutate(#nnet_score = ifelse(nnet_score > 0.5, 1, 0),
            #nnet_score = replace_na(nnet_score, 0),
            timestamp = ymd_hms(timestamp)) |> 
     arrange(timestamp)
     
  return(a_vessel)
}

# Get single ssvid name
get_one_ssvid <- function(adataframe, vessel_index){
  vessels <- adataframe |> 
    group_by(ssvid) |> 
    summarise(count = n()) |> 
    arrange(desc(count))
  return(vessels[[1,1]])
}

## Map with leaflet that shows all lat & lon positions
map_one_vessel <- function(a_vessel){
  
  pal <- colorNumeric(
    palette = "viridis",
    domain = a_vessel$nnet_score,
    reverse = TRUE)
  
  map <- leaflet(a_vessel) |> 
    addProviderTiles(providers$Esri.OceanBasemap) |> 
    addTiles() |> 
    setView(lng = mean(a_vessel$lon), 
            lat = mean(a_vessel$lat), 
            zoom = 7) |> 
    addCircleMarkers(lng = ~lon, 
                     lat = ~lat,
                     color = ~pal(nnet_score),
                     radius = 4,
                     label = ~htmlEscape(timestamp)) |>  
    addPolylines(data = a_vessel,
                 lng = ~lon, 
                 lat = ~lat, 
                 weight=3, 
                 opacity=6, 
                 color="grey") |> 
    addLegend("bottomright", 
              pal = pal, 
              values = c(0,1,NA),
              title = "nnet score",
              opacity = 1) |>
    addMiniMap(
      tiles = providers$Esri.OceanBasemap,
      position = 'topright',
      width = 100, height = 100,
      toggleDisplay = FALSE)
  
  return(map)
}

# Create a grid with all possible combinations of latitude and longitude
#grid <- expand.grid(lat = unique(fish_grid$lat), lon = unique(fish_grid$lon))
# fish_grid <- fish_group %>% 
#   complete(lat, lon) 


#### Map with Leaflet - lat & long binned data
map_one_bin_vessel <- function(a_vessel){
  
  pal <- colorNumeric(
    palette = "magma",
    domain = a_vessel$nnet_score,
    reverse = TRUE)
  
  map <- leaflet(a_vessel) |> 
    addProviderTiles(providers$Esri.OceanBasemap) |> 
    addTiles() |> 
    setView(lng = mean(a_vessel$lon_bin), 
            lat = mean(a_vessel$lat_bin), 
            zoom = 7) |> 
    addCircleMarkers(lng = ~lon_bin, 
                     lat = ~lat_bin,
                     color = ~pal(nnet_score),
                     radius = 4) |>  
    addPolylines(data = a_vessel,
                 lng = ~lon_bin, 
                 lat = ~lat_bin, 
                 weight=3, 
                 opacity=6, 
                 color="grey") |> 
    addLegend("bottomright", pal = pal, values = ~nnet_score,
              title = "nnet_score",
              opacity = 1) |>
    addMiniMap(
      tiles = providers$Esri.OceanBasemap,
      position = 'topright',
      width = 100, height = 100,
      toggleDisplay = FALSE)
    
  return(map)
}




# show all base maps
# names(providers)

# If we want to link lat/lng values - will need timestamp data


# # get countries polygon layer
# samerica <- rnaturalearth::ne_countries(continent = 'south america', returnclass = "sf", scale = "large")
# 
# # How do I get rid of NA gray color displaying on map?
# 
# (fish_map2 <- fish_data %>% 
#     ggplot() +
#     geom_sf(data = samerica) +
#     # geom_tile(aes(x = lon, y = lat, fill = fish_hours_sum), 
#     #           width = tile_width, 
#     #           height = tile_height) +
#     geom_raster(aes(x = lon, y = lat, fill = fish_hours_sum)) +
#     scale_fill_viridis(begin = 0.1, 
#                        end = 0.95, 
#                        direction = -1, 
#                        option = "B") +
#     coord_sf(xlim = c(min(fish_grid$lon)-25, 
#                       max(fish_grid$lon)+15),
#              ylim = c(min(fish_grid$lat), 
#                       max(fish_grid$lat))) +
#     theme_light() +
#     labs(x="",
#          y="",
#          fill ="Total Fishing Hours") +
#     theme(legend.position = c(0.2, 0.17))
# )



