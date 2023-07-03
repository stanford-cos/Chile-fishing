#standardSQL
-- Chile VMS
-- Test pulling fishing effort hours
-- Althea Marks, COS
-- 2023-07-03

# Get data (without summarizing) from research_positions table within date range
SELECT  lat, lon, ssvid, timestamp, hours, nnet_score, speed

FROM `world-fishing-827.pipe_chile_production_v20211126.research_positions` 
  WHERE 
    DATE(timestamp) >= "2023-05-01"
    AND DATE(timestamp) < "2023-05-10"