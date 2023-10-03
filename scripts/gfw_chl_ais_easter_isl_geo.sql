-- AIS fishing events within Chile Easter Island EEZ
-- Uses table nested regions eez to filter (instead of eez geometry)
-- Pull vessel info from 2 tables
-- Created 2023-09-22
-- Modified 2023-09-26

WITH
easter_fishing as (
  SELECT 
    timestamp,
    extract(year from timestamp) as year,
    lat,
    lon,
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
-- merge best flag and best vessel class from research table (processed)
ais_vessel_info as (
  select * 
  from easter_fishing
  left join (
    select * 
    from `world-fishing-827.gfw_research.fishing_vessels_ssvid_v20230801`)
    using (ssvid, year)
),
-- merge vessel information complied from AIS and registries
vessel_db AS (
  SELECT *
  FROM ais_vessel_info AS a
  LEFT JOIN (
    SELECT 
      DISTINCT -- no duplicate values
      identity.ssvid AS ssvid,
      identity.imo AS imo,
      unnested_registry.shipname AS ship_name,
      unnested_registry.owner AS owner,
      unnested_activity.first_timestamp AS first_timestamp,
      unnested_activity.last_timestamp AS last_timestamp,
      unnested_activity.messages AS messages,
      unnested_registry.callsign AS callsign,
      unnested_registry.mmsi_registry AS mmsi_registry,
      unnested_registry.confidence AS gfw_confidence,
      unnested_registry.owner_address AS owner_address,
      unnested_registry.owner_flag AS owner_flag,
      unnested_registry.authorized_from AS authorized_from,
      unnested_registry.authorized_to AS authorized_to,
      matched,
      loose_match
    FROM `world-fishing-827.vessel_database.all_vessels_v20230801`,
    UNNEST(activity) AS unnested_activity, -- struct / nested data structure
    UNNEST(registry) AS unnested_registry
  ) AS j
  ON a.ssvid = j.ssvid
  AND a.timestamp > j.first_timestamp
  AND (a.timestamp < j.last_timestamp OR j.last_timestamp IS NULL) -- keep NULL values
),
-- account for data difference in squid jigger fishing activity
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
from vessel_db
)
-- output resulting table
SELECT * 
FROM ais_chile_fishing
WHERE fishing_hours > 0 