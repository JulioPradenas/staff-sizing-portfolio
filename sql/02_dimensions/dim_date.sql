CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.dim_date` AS
SELECT
  date_day,
  EXTRACT(YEAR FROM date_day)      AS year,
  EXTRACT(QUARTER FROM date_day)   AS quarter,
  EXTRACT(MONTH FROM date_day)     AS month,
  FORMAT_DATE('%B', date_day)      AS month_name,
  EXTRACT(WEEK FROM date_day)      AS week_of_year,
  DATE_TRUNC(date_day, MONTH)      AS first_day_of_month,
  DATE_TRUNC(date_day, WEEK)       AS first_day_of_week,
  -- Temporada operacional
  CASE
    WHEN EXTRACT(MONTH FROM date_day) IN (12,1,2) THEN 'Alta_Verano'
    WHEN EXTRACT(MONTH FROM date_day) IN (6,7,8)  THEN 'Alta_Invierno'
    ELSE 'Baja'
  END AS season
FROM UNNEST(
  GENERATE_DATE_ARRAY('2022-01-01','2027-12-31', INTERVAL 1 DAY)
) AS date_day;