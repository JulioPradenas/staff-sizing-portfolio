CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.fct_absences`
AS
SELECT
  a.absence_id,
  a.employee_id,
  a.base_normalized        AS base_code,
  a.role_normalized        AS role,
  a.absence_type,
  a.start_date_parsed      AS absence_date,
  a.end_date_parsed,
  a.days_absent_int        AS days_absent,
  a.is_approved,
  a.is_long_absence,

  -- Mes y año para agregaciones
  DATE_TRUNC(a.start_date_parsed, MONTH) AS absence_month,
  DATE_TRUNC(a.start_date_parsed, WEEK)  AS absence_week,

  -- Costo en FTE: días ausente / días laborables del mes (22)
  ROUND(a.days_absent_int / 22.0, 3)     AS fte_impact,

  -- Categoría del rol ausente
  r.category

FROM `staff-sizing-portfolio.staff_sizing.stg_absences_clean` a
LEFT JOIN `staff-sizing-portfolio.staff_sizing.dim_role` r
  ON a.role_normalized = r.role_name;