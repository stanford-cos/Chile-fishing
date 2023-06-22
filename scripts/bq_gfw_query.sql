#standardSQL
-- Chile VMS
-- Test pulling fishing effort hours
-- Althea Marks, COS
-- 2023-05-31

with

mytable as (
SELECT 
-- change round number to adjust lat / lon degrees 
  ROUND(lat, 2) AS lat_bin,
  ROUND(lon, 2) AS lon_bin,
  timestamp, 
  hours, 
  nnet_score,
  ssvid

FROM `world-fishing-827.pipe_chile_production_v20211126.research_positions` 
WHERE 
  DATE(timestamp) >= "2023-05-01"
  AND DATE(timestamp) < "2023-05-10"
  AND nnet_score > 0.5
)

select
  lat_bin,
  lon_bin,
  sum(hours) as hours
from mytable
group by lat_bin, lon_bin