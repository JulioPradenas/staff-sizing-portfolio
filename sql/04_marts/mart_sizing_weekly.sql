CREATE OR REPLACE VIEW `staff-sizing-portfolio.staff_sizing.mart_sizing_weekly` AS

WITH weekly_headcount AS (
  -- Dotación real promedio por semana
  SELECT
    DATE_TRUNC(date_day, WEEK)  AS week,
    base_code,
    role,
    category,
    AVG(headcount)              AS avg_headcount,
    AVG(fte_total)              AS avg_fte,
    AVG(avg_seniority)          AS avg_seniority,
    SUM(regulatory_violations)  AS regulatory_violations
  FROM `staff-sizing-portfolio.staff_sizing.fct_headcount_daily`
  GROUP BY 1,2,3,4
),

weekly_absences AS (
  -- Impacto de ausentismo por semana
  SELECT
    absence_week                AS week,
    base_code,
    role,
    COUNT(*)                    AS absence_count,
    SUM(days_absent)            AS total_days_absent,
    SUM(fte_impact)             AS total_fte_absent
  FROM `staff-sizing-portfolio.staff_sizing.fct_absences`
  GROUP BY 1,2,3
),

requirements AS (
  -- Dotación mínima y óptima requerida
  SELECT
    base_code,
    role,
    category,
    SAFE_CAST(min_headcount     AS INT64) AS min_headcount,
    SAFE_CAST(optimal_headcount AS INT64) AS optimal_headcount
  FROM `staff-sizing-portfolio.staff_sizing.stg_role_requirements`
  WHERE valid_to IS NULL OR valid_to >= '2024-01-01'
)

SELECT
  h.week,
  h.base_code,
  h.role,
  h.category,
  ROUND(h.avg_headcount, 1)                         AS avg_headcount,
  ROUND(h.avg_fte, 1)                               AS avg_fte,
  COALESCE(a.total_fte_absent, 0)                   AS fte_absent,
  ROUND(h.avg_fte - COALESCE(a.total_fte_absent,0), 1) AS effective_fte,
  r.min_headcount,
  r.optimal_headcount,
  h.regulatory_violations,

  -- GAP vs mínimo requerido
  ROUND(
    h.avg_fte - COALESCE(a.total_fte_absent,0) - COALESCE(r.min_headcount,0)
  , 1)                                              AS gap_vs_minimum,

  -- GAP vs óptimo
  ROUND(
    h.avg_fte - COALESCE(a.total_fte_absent,0) - COALESCE(r.optimal_headcount,0)
  , 1)                                              AS gap_vs_optimal,

  -- Semáforo de riesgo
  CASE
    WHEN h.avg_fte - COALESCE(a.total_fte_absent,0) < COALESCE(r.min_headcount,0)
      THEN 'CRITICO'
    WHEN h.avg_fte - COALESCE(a.total_fte_absent,0) < COALESCE(r.optimal_headcount,0)
      THEN 'BAJO'
    ELSE 'OK'
  END                                               AS staffing_status

FROM weekly_headcount h
LEFT JOIN weekly_absences  a USING (week, base_code, role)
LEFT JOIN requirements     r USING (base_code, role);