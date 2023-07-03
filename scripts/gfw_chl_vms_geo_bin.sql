#standardSQL
-- Chile VMS
-- Test pulling fishing effort hours
-- Althea Marks, COS
-- 2023-05-31


####### Bin by .01 lat & lon grid
WITH mytable AS (
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
SELECT
  lat_bin,
  lon_bin,
  ssvid,
  timestamp,
  nnet_score,
  SUM(hours) AS hours
FROM mytable
GROUP BY lat_bin, lon_bin, ssvid, timestamp, nnet_score;