from google.cloud import bigquery
from pathlib import Path

PROJECT  = "staff-sizing-portfolio"
SQL_DIR  = Path(__file__).parent.parent / "sql"

# En 04_marts el orden importa: sizing_weekly primero (alerts y gap_analysis dependen de él)
MART_ORDER = [
    "mart_sizing_weekly.sql",
    "mart_attrition_history.sql",
    "mart_headcount_forecast_2027.sql",
    "mart_hiring_reco_2027.sql",
    "mart_gap_analysis.sql",
    "mart_alerts_daily.sql",
]

LAYERS = [
    "01_staging",
    "02_dimensions",
    "03_facts",
    "04_marts",
]

client = bigquery.Client(project=PROJECT)

for layer in LAYERS:
    layer_dir = SQL_DIR / layer
    if layer == "04_marts":
        sql_files = [layer_dir / f for f in MART_ORDER]
    else:
        sql_files = sorted(layer_dir.glob("*.sql"))
    print(f"\n--- {layer} ({len(sql_files)} archivos) ---")
    layer_ok = True
    for sql_file in sql_files:
        sql = sql_file.read_text()
        try:
            client.query(sql).result()
            print(f"  ✅ {sql_file.name}")
        except Exception as e:
            print(f"  ❌ {sql_file.name}: {e}")
            layer_ok = False
    if not layer_ok:
        print(f"\n⛔ Abortando: {layer} tuvo errores. Corrige antes de continuar.")
        raise SystemExit(1)

print("\n🎉 Pipeline completado")
