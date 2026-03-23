CREATE OR REPLACE VIEW `staff-sizing-portfolio.staff_sizing.mart_gap_analysis` AS

WITH monthly_gaps AS (
  SELECT
    DATE_TRUNC(week, MONTH)       AS month,
    base_code,
    role,
    category,
    AVG(avg_headcount)            AS avg_headcount,
    AVG(effective_fte)            AS avg_effective_fte,
    AVG(min_headcount)            AS min_headcount,
    AVG(optimal_headcount)        AS optimal_headcount,
    AVG(gap_vs_minimum)           AS avg_gap_vs_minimum,
    AVG(gap_vs_optimal)           AS avg_gap_vs_optimal,
    SUM(regulatory_violations)    AS total_regulatory_violations,
    COUNTIF(staffing_status = 'CRITICO') AS weeks_critical,
    COUNTIF(staffing_status = 'BAJO')    AS weeks_low,
    COUNT(*)                             AS total_weeks
  FROM `staff-sizing-portfolio.staff_sizing.mart_sizing_weekly`
  GROUP BY 1,2,3,4
)

SELECT
  *,
  -- % de semanas en estado crítico
  ROUND(weeks_critical / total_weeks * 100, 1) AS pct_weeks_critical,

  -- Severidad del gap
  CASE
    WHEN avg_gap_vs_minimum < -10 THEN 'SEVERO'
    WHEN avg_gap_vs_minimum < -5  THEN 'MODERADO'
    WHEN avg_gap_vs_minimum < 0   THEN 'LEVE'
    ELSE 'OK'
  END AS gap_severity,

  -- Ranking de criticidad global
  RANK() OVER (
    ORDER BY avg_gap_vs_minimum ASC
  ) AS criticality_rank

FROM monthly_gaps;