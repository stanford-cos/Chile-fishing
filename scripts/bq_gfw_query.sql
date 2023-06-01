#standardSQL
-- Chile VMS
-- Test pulling fishing effort hours
-- Althea Marks, COS
-- 2023-05-31

SELECT  lat, lon, timestamp, hours, nnet_score

FROM `world-fishing-827.pipe_chile_production_v20211126.research_positions` 
WHERE 
DATE(timestamp) = "2023-05-01"