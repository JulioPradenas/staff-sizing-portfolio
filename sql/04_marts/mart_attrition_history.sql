CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.mart_attrition_history` AS

SELECT
  DATE_TRUNC(exit_date, MONTH)    AS month,
  base_code,
  role,
  category,
  COUNT(*)                        AS total_exits,
  COUNTIF(is_critical_loss)       AS critical_exits,
  COUNTIF(was_replaced)           AS replaced_exits,
  COUNTIF(NOT was_replaced)       AS unreplaced_exits,
  AVG(seniority_years)            AS avg_seniority_at_exit,
  SUM(replacement_training_days)  AS total_training_days_needed,

  -- Tasa de reemplazo: % de salidas que fueron reemplazadas
  ROUND(
    COUNTIF(was_replaced) / NULLIF(COUNT(*), 0) * 100
  , 1)                            AS replacement_rate_pct,

  -- Motivo más frecuente de salida
  (SELECT reason FROM (
    SELECT reason, COUNT(*) AS cnt
    FROM `staff-sizing-portfolio.staff_sizing.fct_attrition` inner_a
    WHERE DATE_TRUNC(inner_a.exit_date, MONTH) = DATE_TRUNC(exit_date, MONTH)
      AND inner_a.base_code = base_code
      AND inner_a.role      = role
    GROUP BY reason
    ORDER BY cnt DESC
    LIMIT 1
  ))                              AS top_exit_reason

FROM `staff-sizing-portfolio.staff_sizing.fct_attrition`
WHERE base_code != 'UNK_BASE'
  AND role      != 'UNK_ROLE'
GROUP BY 1,2,3,4;