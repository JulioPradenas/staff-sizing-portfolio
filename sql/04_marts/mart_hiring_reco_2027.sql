CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.mart_hiring_reco_2027` AS

WITH annual_gaps AS (
  -- Agregamos el gap proyectado anual por base y rol
  SELECT
    base_code,
    role,
    category,
    AVG(current_fte)             AS current_fte,
    AVG(min_headcount)           AS min_headcount,
    AVG(optimal_headcount)       AS optimal_headcount,
    SUM(exits_base)              AS annual_exits_base,
    SUM(exits_stress)            AS annual_exits_stress,
    AVG(projected_fte_base)      AS avg_projected_fte_base,
    AVG(projected_fte_stress)    AS avg_projected_fte_stress,
    MIN(projected_gap_base)      AS worst_gap_base,
    COUNTIF(projected_gap_base < 0) AS months_with_gap
  FROM `staff-sizing-portfolio.staff_sizing.mart_headcount_forecast_2027`
  GROUP BY 1,2,3
),

attrition_context AS (
  -- Contexto de rotación para estimar reemplazos necesarios
  SELECT
    base_code,
    role,
    AVG(replacement_rate_pct)    AS avg_replacement_rate,
    AVG(total_training_days_needed) AS avg_training_days
  FROM `staff-sizing-portfolio.staff_sizing.mart_attrition_history`
  GROUP BY 1,2
)

SELECT
  g.base_code,
  g.role,
  g.category,
  ROUND(g.current_fte, 1)                AS current_fte,
  ROUND(g.min_headcount, 0)              AS min_headcount,
  ROUND(g.optimal_headcount, 0)          AS optimal_headcount,
  ROUND(g.annual_exits_base, 1)          AS annual_exits_base,
  ROUND(g.annual_exits_stress, 1)        AS annual_exits_stress,
  g.months_with_gap,
  ROUND(g.worst_gap_base, 1)             AS worst_gap_base,

  -- Contrataciones necesarias escenario base
  GREATEST(0, CEIL(
    COALESCE(g.min_headcount, 0) - g.avg_projected_fte_base +
    g.annual_exits_base
  ))                                     AS hires_needed_base,

  -- Contrataciones necesarias escenario estrés
  GREATEST(0, CEIL(
    COALESCE(g.optimal_headcount, 0) - g.avg_projected_fte_stress +
    g.annual_exits_stress
  ))                                     AS hires_needed_stress,

  ROUND(a.avg_replacement_rate, 1)       AS avg_replacement_rate_pct,
  ROUND(a.avg_training_days, 0)          AS avg_training_days,

  -- Tiempo estimado para cubrir la brecha (meses)
  CASE
    WHEN a.avg_training_days IS NULL THEN NULL
    ELSE ROUND(a.avg_training_days / 22.0, 1)
  END                                    AS months_to_fill,

  -- Prioridad de contratación
  CASE
    WHEN g.worst_gap_base < -10
      AND g.months_with_gap >= 10        THEN 'P1 - URGENTE'
    WHEN g.worst_gap_base < -5
      OR g.months_with_gap >= 6         THEN 'P2 - CRITICO'
    WHEN g.worst_gap_base < 0           THEN 'P3 - PLANIFICAR'
    ELSE 'P4 - OK'
  END                                    AS hiring_priority,

  RANK() OVER (
    ORDER BY g.worst_gap_base ASC, g.months_with_gap DESC
  )                                      AS priority_rank

FROM annual_gaps g
LEFT JOIN attrition_context a
  ON g.base_code = a.base_code AND g.role = a.role
WHERE g.current_fte > 0;