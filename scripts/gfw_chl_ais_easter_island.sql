-- pacific rim shape
pacific as (
  select st_geogfromtext(geometry, make_valid => TRUE) as geometry
  from `gfwanalysis.pacific.pacific_rim`
),
-- GFW anchorages
anchorage as (
  select s2id, st_geogpoint(lon, lat) as loc
  from `world-fishing-827.anchorages.named_anchorages_v20220511`
),
-- anchorages in the Pacific rim
anchorage_pacific as (
    select s2id from pacific
    cross join (select * from anchorage)
    where st_within(loc, geometry)
),


with
fishing_ais as (
  select
    timestamp,
    extract(year from timestamp) as year,
    ssvid,
    lat,
    lon,
    hours,
    nnet_score,
    night
  from `world-fishing-827.gfw_research.pipe_v20201001_fishing`
  where timestamp between '2021-01-01' and '2021-01-03'
    and (lat > 10 and lon > 10)
),
chile as (
  -- EEZ shape file
),
fishing_ais_chile as (
  -- filter fishing_ais within chile
),
fishing_ais_info as (
  select * from fishing_ais_chile
  left join (
    select
      ssvid,
      year,
      if(best_flag = 'UNK', null, best_flag) as flag,
      best_vessel_class as gear_type
      from `world-fishing-827.gfw_research.fishing_vessels_ssvid`
  )
  using(ssvid, year)
),
fishing_ais_fishing as (
  -- only select AIS when fishing
  select *
  from fishing_ais_info
  where nnet_score > 0.5
    or (gear_type = 'squid_jigger' and night_loitering = 1)
)
select
  flag,
  gear_type,
  sum(hours) as fishing_hours
from fishing_ais_fishing
group by flag, gear_type