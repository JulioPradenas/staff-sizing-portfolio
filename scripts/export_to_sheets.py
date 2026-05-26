from google.cloud import bigquery
import pandas as pd

client = bigquery.Client(project="staff-sizing-portfolio")

df = client.query("""
  SELECT
    base_code            AS Base,
    role                 AS Rol,
    category             AS Categoria,
    current_fte          AS FTE_Actual,
    min_headcount        AS Dotacion_Minima,
    optimal_headcount    AS Dotacion_Optima,
    worst_gap_base       AS Peor_Gap,
    months_with_gap      AS Meses_Con_Gap,
    hires_needed_base    AS Contrataciones_Base,
    hires_needed_stress  AS Contrataciones_Estres,
    avg_training_days    AS Dias_Capacitacion,
    months_to_fill       AS Meses_Para_Cubrir,
    hiring_priority      AS Prioridad,
    priority_rank        AS Ranking
  FROM `staff-sizing-portfolio.staff_sizing.mart_hiring_reco_2027`
  ORDER BY priority_rank ASC
""").to_dataframe()

df.to_excel("sheets/hiring_reco_2027.xlsx", index=False)
print(f"Exportado: {len(df)} filas -> sheets/hiring_reco_2027.xlsx")