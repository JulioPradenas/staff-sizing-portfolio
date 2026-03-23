CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.stg_attrition_clean` AS

WITH cleaned AS (
  SELECT
    attrition_id,
    employee_id,

    -- Normalización de base
    CASE
      WHEN UPPER(TRIM(base_code)) IN ('SCL','LIM','BOG','GRU','EZE','MIA','MAD','JFK')
                                                          THEN UPPER(TRIM(base_code))
      WHEN LOWER(TRIM(base_code)) IN ('santiago','stgo') THEN 'SCL'
      WHEN LOWER(TRIM(base_code)) = 'lima'               THEN 'LIM'
      WHEN LOWER(TRIM(base_code)) IN ('bogota','bogotá') THEN 'BOG'
      WHEN LOWER(TRIM(base_code)) IN ('sao paulo','gru') THEN 'GRU'
      WHEN LOWER(TRIM(base_code)) = 'buenos aires'       THEN 'EZE'
      WHEN LOWER(TRIM(base_code)) = 'miami'              THEN 'MIA'
      ELSE 'UNK_BASE'
    END AS base_normalized,

    -- Normalización de rol
    CASE
      WHEN role IN (
        'Piloto Comandante','Piloto Copiloto','Tripulante Cabina Senior',
        'Tripulante Cabina','Ground Staff','Agente Check-in',
        'Supervisor Operaciones','Tecnico Mantencion','Administrativo','Seguridad'
      ) THEN role
      WHEN LOWER(role) IN ('piloto','pilot')          THEN 'Piloto Copiloto'
      WHEN LOWER(role) IN ('tcabin','cabin','cabina') THEN 'Tripulante Cabina'
      WHEN LOWER(role) IN ('ground','tierra')         THEN 'Ground Staff'
      ELSE 'UNK_ROLE'
    END AS role_normalized,

    category,

    -- Parseo de fecha de salida
    CASE
      WHEN REGEXP_CONTAINS(exit_date, r'^\d{4}-\d{2}-\d{2}$')
        THEN PARSE_DATE('%Y-%m-%d', exit_date)
      ELSE NULL
    END AS exit_date_parsed,

    reason,
    SAFE_CAST(seniority_years AS INT64) AS seniority_years_int,
    contract_type,
    CASE WHEN was_replaced = '1' THEN TRUE ELSE FALSE END AS was_replaced,

    -- Flag: salida de empleado con alta antigüedad (> 5 años) sin reemplazo
    CASE
      WHEN SAFE_CAST(seniority_years AS INT64) > 5
        AND was_replaced = '0' THEN TRUE
      ELSE FALSE
    END AS is_critical_loss

  FROM `staff-sizing-portfolio.staff_sizing.stg_attrition`
  WHERE attrition_id IS NOT NULL AND attrition_id != ''
)

SELECT * FROM cleaned
WHERE exit_date_parsed IS NOT NULL;