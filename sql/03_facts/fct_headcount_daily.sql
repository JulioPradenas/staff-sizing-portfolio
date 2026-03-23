CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.fct_headcount_daily`
AS
WITH dates AS (
  SELECT date_day
  FROM `staff-sizing-portfolio.staff_sizing.dim_date`
  WHERE date_day BETWEEN '2022-01-01' AND '2024-12-31'
),

active_employees AS (
  SELECT
    employee_id,
    role,
    category,
    base_code,
    contract_type,
    hire_date,
    monthly_hours,
    seniority_years,
    exceeds_regulatory_limit
  FROM `staff-sizing-portfolio.staff_sizing.dim_employee`
  WHERE is_active = TRUE
    AND base_code NOT IN ('UNK_BASE')
    AND role NOT IN ('UNK_ROLE')
),

-- Cruzamos cada empleado activo con cada día
-- para generar un registro de dotación diaria
headcount AS (
  SELECT
    d.date_day,
    e.base_code,
    e.role,
    e.category,
    e.contract_type,
    COUNT(e.employee_id)                    AS headcount,
    SUM(CASE WHEN c.fte_equivalent IS NOT NULL
      THEN c.fte_equivalent ELSE 1.0 END)   AS fte_total,
    AVG(e.monthly_hours)                    AS avg_monthly_hours,
    AVG(e.seniority_years)                  AS avg_seniority,
    COUNTIF(e.exceeds_regulatory_limit)     AS regulatory_violations
  FROM dates d
  CROSS JOIN active_employees e
  LEFT JOIN `staff-sizing-portfolio.staff_sizing.dim_contract` c
    ON e.contract_type = c.contract_type
  GROUP BY 1,2,3,4,5
)

SELECT * FROM headcount;