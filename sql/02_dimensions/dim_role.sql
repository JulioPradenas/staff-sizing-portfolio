CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.dim_role` AS
SELECT
  role_name,
  category,
  SAFE_CAST(max_monthly_hours  AS INT64)   AS max_monthly_hours,
  SAFE_CAST(min_rest_hours     AS INT64)   AS min_rest_hours,
  CASE WHEN requires_license = '1' THEN TRUE ELSE FALSE END AS requires_license,
  license_type,
  SAFE_CAST(avg_training_days  AS INT64)   AS avg_training_days
FROM `staff-sizing-portfolio.staff_sizing.stg_roles`;