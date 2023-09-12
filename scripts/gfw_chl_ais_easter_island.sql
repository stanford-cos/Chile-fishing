-- AIS fishing effort within Chile Easter Island EEZ

-- Import WTK (EEZ geometry) for Easter Island. Stored in Google Cloud Storage Bucket
WITH
easter_island as (
  SELECT 
    ST_GEOGFROMTEXT(string_field_0) as eez_geometry
  FROM 
    `sdss-scrt-marks.chile_geospatial.easter-island-eez-wtk`
  LIMIT 1  -- Assuming there's only one multipolygon representing the entire Easter Island EEZ
),

-- Pull fishing effort data from exact date range
fishing_ais as (
  SELECT
    timestamp,
    extract(year from timestamp) as year,
    ssvid,
    lat,
    lon,
    ST_GEOGPOINT(lon, lat) as point_geometry,
    hours,
    nnet_score,
    night_loitering
  FROM 
    `world-fishing-827.gfw_research.pipe_v20201001_fishing`
  WHERE _PARTITIONTIME -- table is partitioned by day - use this to limit query size
    BETWEEN '2023-01-01' 
    AND '2023-07-31'
    -- AND lat > 10 AND lon > 10 -- use this to create a 'bounding box' around of area of interest need to insert > & < to create rectangular. 
),

-- Select points that are contained within Easter Island EEZ polygon
easter_fishing as(
SELECT 
  fishing_ais.* 
FROM 
  fishing_ais, easter_island
WHERE 
  ST_CONTAINS(eez_geometry, point_geometry) -- Returns TRUE if the polygon contains the point inside it.
),

-- attach relevant vessel information to fishing inside Easter Island EEZ
ais_chile_info as (
  select * 
  from easter_fishing
  left join (select * from `world-fishing-827.gfw_research.fishing_vessels_ssvid_v20230801`)
  using (ssvid, year)
),

-- Not all rows represent fishing, only want nural net score above 0.5 and squid jiggers loitering
ais_chile_fishing as (
select *,
  CASE 
    WHEN best_vessel_class = 'squid_jigger' 
      AND night_loitering = 1 
      THEN hours
    WHEN nnet_score > 0.5 
      THEN hours
    ELSE 0
  END as fishing_hours
from ais_chile_info
)

-- remove rows where no fishing occuring
SELECT * 
FROM ais_chile_fishing
WHERE fishing_hours > 0 

