CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.dim_base` AS
SELECT
  base_code,
  base_name,
  city,
  country,
  cluster,
  hub_type,
  timezone
FROM `staff-sizing-portfolio.staff_sizing.stg_bases`
WHERE base_code IN ('SCL','LIM','BOG','GRU','EZE','MIA','MAD','JFK');