# Functions for Chile VMS exploratory analysis 
# sourced by main_analysis.qmd

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
  return(vessels[[vessel_index,1]])
}

## Map with leaflet that shows all lat & lon positions
map_one_vessel <- function(a_vessel){
  
  pal_circ <- colorNumeric(
    palette = "viridis",
    domain = a_vessel$nnet_score,
    reverse = TRUE)
  
  # pal_line <- colorNumeric(
  #   palette = "magma",
  #   domain = a_vessel$speed,
  #   reverse = TRUE)
  # 
  map <- leaflet(a_vessel) |> 
    addProviderTiles(providers$Esri.OceanBasemap) |> 
    addTiles() |> 
    setView(lng = mean(a_vessel$lon), 
            lat = mean(a_vessel$lat), 
            zoom = 7) |> 
    addCircleMarkers(lng = ~lon, 
                     lat = ~lat,
                     color = ~pal_circ(nnet_score),
                     radius = 4,
                     label = ~htmlEscape(timestamp)) |>  
    addPolylines(data = a_vessel,
                 lng = ~lon, 
                 lat = ~lat, 
                 weight=3, 
                 opacity=6, 
                 color="grey") |> 
    addLegend("bottomright", 
              pal = pal_circ, 
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

#########################################
# Heat map  - Not working and stopped developing, doesn't make sense in this platform, too much data

# complete grid with all combinations of lat & lon
# specific function or use join 

# map_data <- fish_data |> 
#   mutate(lat = round(lat,1),
#          lon = round(lon, 1)) |> 
#   group_by(lat, lon) |> 
#   summarize(total_hrs = sum(hours, na.rm = T)) |> 
#   ungroup() 
# 
# test <- map_data[sample(nrow(map_data), 25),] |> 
#   expand.grid(x = map_data$lon, y = map_data$lat)
# #  complete(lat, lon)
# 
# 
# map <- map_data |> 
#   ggplot() +
#   geom_raster(aes(x = lon,
#                   y = lat,
#                   fill = total_hrs)) +
#   scale_fill_viridis()


# Create a grid with all possible combinations of latitude and longitude
#grid <- expand.grid(lat = unique(fish_grid$lat), lon = unique(fish_grid$lon))
#fish_grid <- fish_group |> 
#  complete(lat, lon)


###############
# top 10 PSMA Ports in the Pacific

### read in ocean boundary shapefiles
library(sf)

# arguement needs to be text
read_in_ocean <- function(ocean_folder){
  ocean <- sf::read_sf(file.path(data_dir, ocean_folder, "iho.shp"))
  assigned_name <- paste0("shp-", ocean_folder)
  assign(assigned_name, value = ocean, envir = .GlobalEnv)
 # return(get(assigned_name))
}



