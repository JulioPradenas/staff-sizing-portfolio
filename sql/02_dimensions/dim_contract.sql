CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.dim_contract` AS
SELECT DISTINCT
  contract_type,
  CASE
    WHEN contract_type = 'Indefinido'   THEN TRUE
    ELSE FALSE
  END AS is_permanent,
  CASE
    WHEN contract_type = 'Part-time'    THEN 0.5
    WHEN contract_type = 'Honorarios'   THEN 0.75
    ELSE 1.0
  END AS fte_equivalent
FROM `staff-sizing-portfolio.staff_sizing.stg_employees_clean`
WHERE contract_type IS NOT NULL AND contract_type != '';