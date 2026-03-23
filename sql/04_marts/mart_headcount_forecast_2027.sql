CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.mart_headcount_forecast_2027` AS

WITH attrition_stats AS (
  SELECT
    base_code, role, category,
    AVG(total_exits)          AS avg_monthly_exits,
    STDDEV(total_exits)       AS stddev_exits,
    AVG(replacement_rate_pct) AS avg_replacement_rate
  FROM `staff-sizing-portfolio.staff_sizing.mart_attrition_history`
  GROUP BY 1,2,3
),

absence_stats AS (
  SELECT
    base_code, role,
    AVG(fte_impact)    AS avg_fte_absent_weekly,
    STDDEV(fte_impact) AS stddev_fte_absent
  FROM `staff-sizing-portfolio.staff_sizing.fct_absences`
  GROUP BY 1,2
),

current_headcount AS (
  SELECT
    base_code, role, category,
    AVG(headcount) AS current_headcount,
    AVG(fte_total) AS current_fte
  FROM `staff-sizing-portfolio.staff_sizing.fct_headcount_daily`
  WHERE date_day = (
    SELECT MAX(date_day)
    FROM `staff-sizing-portfolio.staff_sizing.fct_headcount_daily`
  )
  GROUP BY 1,2,3
),

requirements AS (
  SELECT
    base_code, role, category,
    SAFE_CAST(min_headcount     AS INT64) AS min_headcount,
    SAFE_CAST(optimal_headcount AS INT64) AS optimal_headcount
  FROM `staff-sizing-portfolio.staff_sizing.stg_role_requirements`
  WHERE valid_to IS NULL OR valid_to >= '2027-01-01'
),

months_2027 AS (
  SELECT
    DATE_TRUNC(d, MONTH) AS month,
    CASE
      WHEN EXTRACT(MONTH FROM d) IN (12,1,2) THEN 'Alta_Verano'
      WHEN EXTRACT(MONTH FROM d) IN (6,7,8)  THEN 'Alta_Invierno'
      ELSE 'Baja'
    END AS season
  FROM UNNEST(
    GENERATE_DATE_ARRAY('2027-01-01','2027-12-31', INTERVAL 1 MONTH)
  ) AS d
),

cross_data AS (
  SELECT
    m.month, m.season,
    c.base_code, c.role, c.category,
    c.current_headcount, c.current_fte,
    a.avg_monthly_exits, a.stddev_exits, a.avg_replacement_rate,
    ab.avg_fte_absent_weekly,
    r.min_headcount, r.optimal_headcount
  FROM months_2027 m
  CROSS JOIN current_headcount c
  LEFT JOIN attrition_stats  a  ON c.base_code = a.base_code AND c.role = a.role
  LEFT JOIN absence_stats    ab ON c.base_code = ab.base_code AND c.role = ab.role
  LEFT JOIN requirements     r  ON c.base_code = r.base_code AND c.role = r.role
)

SELECT
  month, season, base_code, role, category,
  ROUND(current_fte, 1)          AS current_fte,
  ROUND(min_headcount, 0)        AS min_headcount,
  ROUND(optimal_headcount, 0)    AS optimal_headcount,

  ROUND(COALESCE(avg_monthly_exits, 0), 1)           AS exits_base,
  ROUND(GREATEST(0,
    COALESCE(avg_monthly_exits,0) - COALESCE(stddev_exits,0)
  ), 1)                                              AS exits_conservative,
  ROUND(
    COALESCE(avg_monthly_exits,0) +
    CASE WHEN season IN ('Alta_Verano','Alta_Invierno')
      THEN COALESCE(stddev_exits,0) * 1.5
      ELSE COALESCE(stddev_exits,0)
    END
  , 1)                                              AS exits_stress,

  ROUND(current_fte - COALESCE(avg_monthly_exits,0)
    - COALESCE(avg_fte_absent_weekly,0) * 4, 1)     AS projected_fte_base,

  ROUND(current_fte
    - GREATEST(0, COALESCE(avg_monthly_exits,0) - COALESCE(stddev_exits,0))
    - COALESCE(avg_fte_absent_weekly,0) * 4, 1)     AS projected_fte_conservative,

  ROUND(current_fte
    - (COALESCE(avg_monthly_exits,0) + COALESCE(stddev_exits,0) * 1.5)
    - COALESCE(avg_fte_absent_weekly,0) * 4, 1)     AS projected_fte_stress,

  ROUND(current_fte - COALESCE(avg_monthly_exits,0)
    - COALESCE(avg_fte_absent_weekly,0) * 4
    - COALESCE(min_headcount,0), 1)                 AS projected_gap_base

FROM cross_data
WHERE current_fte > 0;