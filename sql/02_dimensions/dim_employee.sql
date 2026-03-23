CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.dim_employee` AS
SELECT
  employee_id,
  name,
  role_normalized        AS role,
  category_normalized    AS category,
  base_normalized        AS base_code,
  contract_type,
  hire_date_parsed       AS hire_date,
  birth_date_parsed      AS birth_date,
  is_active,
  monthly_hours_int      AS monthly_hours,
  seniority_years_int    AS seniority_years,
  exceeds_regulatory_limit,
  is_role_dirty,

  -- Segmento de antigüedad
  CASE
    WHEN seniority_years_int < 1  THEN '0-1 años'
    WHEN seniority_years_int < 3  THEN '1-3 años'
    WHEN seniority_years_int < 5  THEN '3-5 años'
    WHEN seniority_years_int < 10 THEN '5-10 años'
    ELSE '10+ años'
  END AS seniority_segment,

  -- Segmento de edad
  CASE
    WHEN DATE_DIFF(CURRENT_DATE(), birth_date_parsed, YEAR) < 30 THEN 'Sub-30'
    WHEN DATE_DIFF(CURRENT_DATE(), birth_date_parsed, YEAR) < 40 THEN '30-40'
    WHEN DATE_DIFF(CURRENT_DATE(), birth_date_parsed, YEAR) < 50 THEN '40-50'
    ELSE '50+'
  END AS age_segment

FROM `staff-sizing-portfolio.staff_sizing.stg_employees_clean`;