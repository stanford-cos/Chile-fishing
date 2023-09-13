-- AIS fishing events within Chile Easter Island EEZ
-- Uses table nested regions eez to filter (instead of eez geometry)

WITH
easter_fishing as (
  SELECT 
    timestamp,
    extract(year from timestamp) as year,
    ssvid,
    hours,
    nnet_score,
    night_loitering
  FROM `world-fishing-827.gfw_research.pipe_v20201001_fishing`, 
    unnest(regions.eez) as eez -- expand array in regions column 
  WHERE _PARTITIONTIME -- table is partitioned by day - use this to limit query size
    BETWEEN '2019-01-01' 
    AND '2023-09-12'
    -- only interested in fishing effort within Chile / Easter Island EEZ - labeled as CHL EEZ
  and eez in ( 
    select cast(eez_id as string)
    from `world-fishing-827.gfw_research.eez_info`
    where sovereign1_iso3 = 'CHL'
      and territory1 = 'Easter Island' -- comment out this line to query for entire Chile EEZ
  )
),

ais_vessel_info as (
  select * 
  from easter_fishing
  left join (select * from `world-fishing-827.gfw_research.fishing_vessels_ssvid_v20230801`)
  using (ssvid, year)
),

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
from ais_vessel_info
)

SELECT * 
FROM ais_chile_fishing
WHERE fishing_hours > 0 