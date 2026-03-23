CREATE OR REPLACE TABLE `staff-sizing-portfolio.staff_sizing.stg_flight_schedule_clean` AS

WITH cleaned AS (
  SELECT
    flight_id,
    origin,
    destination,

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

    aircraft_type,

    -- Parseo de fecha de vuelo
    CASE
      WHEN REGEXP_CONTAINS(flight_date, r'^\d{4}-\d{2}-\d{2}$')
        THEN PARSE_DATE('%Y-%m-%d', flight_date)
      ELSE NULL
    END AS flight_date_parsed,

    season,

    -- Requerimientos de tripulación
    SAFE_CAST(crew_required_cockpit AS INT64) AS crew_required_cockpit,
    SAFE_CAST(crew_required_cabin   AS INT64) AS crew_required_cabin,
    SAFE_CAST(ground_staff_required AS INT64) AS ground_staff_required,
    SAFE_CAST(flight_hours          AS FLOAT64) AS flight_hours,

    -- Total tripulación requerida por vuelo
    COALESCE(SAFE_CAST(crew_required_cockpit AS INT64), 0) +
    COALESCE(SAFE_CAST(crew_required_cabin   AS INT64), 0) +
    COALESCE(SAFE_CAST(ground_staff_required AS INT64), 0) AS total_crew_required,

    -- Flag: vuelo de larga distancia (> 8 horas)
    CASE
      WHEN SAFE_CAST(flight_hours AS FLOAT64) > 8 THEN TRUE
      ELSE FALSE
    END AS is_long_haul

  FROM `staff-sizing-portfolio.staff_sizing.stg_flight_schedule`
  WHERE flight_id IS NOT NULL AND flight_id != ''
)

SELECT * FROM cleaned
WHERE flight_date_parsed IS NOT NULL
  AND total_crew_required > 0;