CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.stg_absences_clean` AS

WITH cleaned AS (
  SELECT
    absence_id,
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

    absence_type,

    -- Parseo de fechas
    CASE
      WHEN REGEXP_CONTAINS(start_date, r'^\d{4}-\d{2}-\d{2}$')
        THEN PARSE_DATE('%Y-%m-%d', start_date)
      ELSE NULL
    END AS start_date_parsed,

    CASE
      WHEN REGEXP_CONTAINS(end_date, r'^\d{4}-\d{2}-\d{2}$')
        THEN PARSE_DATE('%Y-%m-%d', end_date)
      ELSE NULL
    END AS end_date_parsed,

    SAFE_CAST(days_absent AS INT64)  AS days_absent_int,
    CASE WHEN approved = '1' THEN TRUE ELSE FALSE END AS is_approved,

    -- Flag: ausencia sospechosamente larga (> 60 días)
    CASE
      WHEN SAFE_CAST(days_absent AS INT64) > 60 THEN TRUE
      ELSE FALSE
    END AS is_long_absence

  FROM `staff-sizing-portfolio.staff_sizing.stg_absences`
  WHERE absence_id IS NOT NULL AND absence_id != ''
)

SELECT * FROM cleaned
WHERE start_date_parsed IS NOT NULL
  AND days_absent_int IS NOT NULL
  AND days_absent_int > 0;