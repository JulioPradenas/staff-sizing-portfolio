CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.fct_attrition`
AS
SELECT
  a.attrition_id,
  a.employee_id,
  a.base_normalized        AS base_code,
  a.role_normalized        AS role,
  a.category,
  a.exit_date_parsed       AS exit_date,
  a.reason,
  a.seniority_years_int    AS seniority_years,
  a.contract_type,
  a.was_replaced,
  a.is_critical_loss,

  -- Agregaciones temporales
  DATE_TRUNC(a.exit_date_parsed, MONTH) AS exit_month,
  DATE_TRUNC(a.exit_date_parsed, WEEK)  AS exit_week,
  EXTRACT(YEAR FROM a.exit_date_parsed) AS exit_year,

  -- Costo de reemplazo estimado en días de capacitación
  COALESCE(r.avg_training_days, 0)      AS replacement_training_days,

  -- Segmento de antigüedad al momento de salida
  CASE
    WHEN a.seniority_years_int < 1  THEN '0-1 años'
    WHEN a.seniority_years_int < 3  THEN '1-3 años'
    WHEN a.seniority_years_int < 5  THEN '3-5 años'
    WHEN a.seniority_years_int < 10 THEN '5-10 años'
    ELSE '10+ años'
  END AS seniority_segment

FROM `staff-sizing-portfolio.staff_sizing.stg_attrition_clean` a
LEFT JOIN `staff-sizing-portfolio.staff_sizing.dim_role` r
  ON a.role_normalized = r.role_name;