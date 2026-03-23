CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.stg_employees_clean` AS

WITH deduped AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY employee_id ORDER BY hire_date DESC
    ) AS rn
  FROM `staff-sizing-portfolio.staff_sizing.stg_employees`
  WHERE employee_id IS NOT NULL AND employee_id != ''
),

cleaned AS (
  SELECT
    employee_id,
    name,

    -- Normalización de rol
    CASE
      WHEN role IN (
        'Piloto Comandante','Piloto Copiloto','Tripulante Cabina Senior',
        'Tripulante Cabina','Ground Staff','Agente Check-in',
        'Supervisor Operaciones','Tecnico Mantencion','Administrativo','Seguridad'
      ) THEN role
      WHEN LOWER(role) IN ('piloto','pilot')        THEN 'Piloto Copiloto'
      WHEN LOWER(role) IN ('tcabin','cabin','cabina') THEN 'Tripulante Cabina'
      WHEN LOWER(role) IN ('ground','tierra')        THEN 'Ground Staff'
      WHEN role = '' OR role IS NULL                 THEN 'UNK_ROLE'
      ELSE 'UNK_ROLE'
    END AS role_normalized,
    role AS role_original,

    -- Normalización de categoría
    CASE
      WHEN role IN ('Piloto Comandante','Piloto Copiloto')            THEN 'Cockpit'
      WHEN role IN ('Tripulante Cabina Senior','Tripulante Cabina')   THEN 'Cabina'
      WHEN role IN ('Ground Staff','Agente Check-in',
                    'Supervisor Operaciones','Tecnico Mantencion',
                    'Seguridad')                                       THEN 'Tierra'
      WHEN role = 'Administrativo'                                    THEN 'Admin'
      ELSE 'UNK'
    END AS category_normalized,

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
    base_code AS base_original,

    contract_type,

    -- Parseo de fechas
    CASE
      WHEN REGEXP_CONTAINS(hire_date, r'^\d{4}-\d{2}-\d{2}$')
        THEN PARSE_DATE('%Y-%m-%d', hire_date)
      ELSE NULL
    END AS hire_date_parsed,

    CASE
      WHEN REGEXP_CONTAINS(birth_date, r'^\d{4}-\d{2}-\d{2}$')
        THEN PARSE_DATE('%Y-%m-%d', birth_date)
      ELSE NULL
    END AS birth_date_parsed,

    CASE WHEN is_active = '1' THEN TRUE ELSE FALSE END AS is_active,

    -- Horas mensuales: validar contra límite regulatorio
    SAFE_CAST(monthly_hours AS INT64) AS monthly_hours_int,
    CASE
      WHEN role IN ('Piloto Comandante','Piloto Copiloto')
        AND SAFE_CAST(monthly_hours AS INT64) > 100 THEN TRUE
      WHEN role IN ('Tripulante Cabina Senior','Tripulante Cabina')
        AND SAFE_CAST(monthly_hours AS INT64) > 120 THEN TRUE
      ELSE FALSE
    END AS exceeds_regulatory_limit,

    SAFE_CAST(seniority_years AS INT64) AS seniority_years_int,

    -- Flags de calidad
    CASE WHEN role NOT IN (
      'Piloto Comandante','Piloto Copiloto','Tripulante Cabina Senior',
      'Tripulante Cabina','Ground Staff','Agente Check-in',
      'Supervisor Operaciones','Tecnico Mantencion','Administrativo','Seguridad'
    ) THEN TRUE ELSE FALSE END AS is_role_dirty

  FROM deduped WHERE rn = 1
)

SELECT * FROM cleaned
WHERE hire_date_parsed IS NOT NULL;