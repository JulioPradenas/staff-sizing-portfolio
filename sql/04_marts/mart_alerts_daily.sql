CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.mart_alerts_daily` AS

WITH staffing_alerts AS (
  SELECT
    base_code, role,
    'STAFFING_GAP'  AS alert_type,
    'P1'            AS severity,
    'HR Operations' AS owner,
    CONCAT('GAP=', ROUND(gap_vs_minimum,1),
           ' FTE en semana ', CAST(week AS STRING)) AS detail
  FROM `staff-sizing-portfolio.staff_sizing.mart_sizing_weekly`
  WHERE staffing_status = 'CRITICO'
    AND week = (SELECT MAX(week) FROM `staff-sizing-portfolio.staff_sizing.mart_sizing_weekly`)
),

regulatory_alerts AS (
  SELECT
    base_code, role,
    'REGULATORY_VIOLATION' AS alert_type,
    'P1'                   AS severity,
    'Compliance'           AS owner,
    CONCAT(CAST(regulatory_violations AS STRING),
           ' empleados superan horas maximas') AS detail
  FROM `staff-sizing-portfolio.staff_sizing.fct_headcount_daily`
  WHERE regulatory_violations > 0
    AND date_day = (SELECT MAX(date_day) FROM `staff-sizing-portfolio.staff_sizing.fct_headcount_daily`)
),

critical_loss_alerts AS (
  SELECT
    base_code, role,
    'CRITICAL_LOSS' AS alert_type,
    'P1'            AS severity,
    'HR Talent'     AS owner,
    CONCAT(CAST(COUNT(*) AS STRING), ' salidas criticas sin reemplazo') AS detail
  FROM `staff-sizing-portfolio.staff_sizing.fct_attrition`
  WHERE is_critical_loss = TRUE
    AND exit_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  GROUP BY base_code, role
),

role_quality AS (
  SELECT
    base_normalized AS base_code,
    COUNTIF(role_normalized = 'UNK_ROLE') / COUNT(*) AS pct_unk
  FROM `staff-sizing-portfolio.staff_sizing.stg_employees_clean`
  GROUP BY base_normalized
),

data_quality_alerts AS (
  SELECT
    base_code,
    'UNK_ROLE'          AS role,
    'DATA_QUALITY_ROLE' AS alert_type,
    'P2'                AS severity,
    'Data Engineering'  AS owner,
    CONCAT(CAST(ROUND(pct_unk * 100, 1) AS STRING), '% roles UNK') AS detail
  FROM role_quality
  WHERE pct_unk > 0.001
)

SELECT CURRENT_DATE() AS alert_date, * FROM staffing_alerts
UNION ALL
SELECT CURRENT_DATE() AS alert_date, * FROM regulatory_alerts
UNION ALL
SELECT CURRENT_DATE() AS alert_date, * FROM critical_loss_alerts
UNION ALL
SELECT CURRENT_DATE() AS alert_date, * FROM data_quality_alerts;