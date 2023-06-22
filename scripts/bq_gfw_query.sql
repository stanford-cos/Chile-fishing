#standardSQL
-- Chile VMS
-- Test pulling fishing effort hours
-- Althea Marks, COS
-- 2023-05-31

SELECT  lat, lon, timestamp, hours, nnet_score

FROM `world-fishing-827.pipe_chile_production_v20211126.research_positions` 
WHERE 
--DATE(timestamp) = "2023-05-01"
  _PARTITIONTIME >= "2023-03-01 00:00:00"
  AND _PARTITIONTIME < "2023-03-31 00:00:00"

---
SELECT
  SUM(fishing_hours) AS total_fishing_hours,
  geartype
FROM
  [global-fishing-watch:global_footprint_of_fisheries.fishing_effort]
WHERE
  _PARTITIONTIME >= "2016-01-01 00:00:00"
  AND _PARTITIONTIME < "2017-01-01 00:00:00"
  AND flag = 'NOR'
GROUP BY
  geartype
ORDER BY
  total_fishing_hours DESC