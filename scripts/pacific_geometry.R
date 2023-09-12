# script to pull in and work with Pacific and South China Sea Boundary


read_in_ocean("pacific")
read_in_ocean("south_china_sea")

# can combine simple features of the same class - 
# would pacific (multipolygon) & south china sea (polygon) work
total_pacific <- st_sfc(pacific, south_china_sea)
