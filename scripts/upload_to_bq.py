from google.cloud import bigquery
import pandas as pd
import os

PROJECT  = "staff-sizing-portfolio"
DATASET  = "staff_sizing"
DATA_DIR = "data_gen"

SCHEMAS = {
    "stg_employees": [
        bigquery.SchemaField("employee_id","STRING"),
        bigquery.SchemaField("name","STRING"),
        bigquery.SchemaField("role","STRING"),
        bigquery.SchemaField("category","STRING"),
        bigquery.SchemaField("base_code","STRING"),
        bigquery.SchemaField("contract_type","STRING"),
        bigquery.SchemaField("hire_date","STRING"),
        bigquery.SchemaField("birth_date","STRING"),
        bigquery.SchemaField("is_active","STRING"),
        bigquery.SchemaField("monthly_hours","STRING"),
        bigquery.SchemaField("seniority_years","STRING"),
    ],
    "stg_flight_schedule": [
        bigquery.SchemaField("flight_id","STRING"),
        bigquery.SchemaField("origin","STRING"),
        bigquery.SchemaField("destination","STRING"),
        bigquery.SchemaField("base_code","STRING"),
        bigquery.SchemaField("aircraft_type","STRING"),
        bigquery.SchemaField("flight_date","STRING"),
        bigquery.SchemaField("season","STRING"),
        bigquery.SchemaField("crew_required_cockpit","STRING"),
        bigquery.SchemaField("crew_required_cabin","STRING"),
        bigquery.SchemaField("ground_staff_required","STRING"),
        bigquery.SchemaField("flight_hours","STRING"),
    ],
    "stg_absences": [
        bigquery.SchemaField("absence_id","STRING"),
        bigquery.SchemaField("employee_id","STRING"),
        bigquery.SchemaField("base_code","STRING"),
        bigquery.SchemaField("role","STRING"),
        bigquery.SchemaField("absence_type","STRING"),
        bigquery.SchemaField("start_date","STRING"),
        bigquery.SchemaField("end_date","STRING"),
        bigquery.SchemaField("days_absent","STRING"),
        bigquery.SchemaField("approved","STRING"),
    ],
    "stg_attrition": [
        bigquery.SchemaField("attrition_id","STRING"),
        bigquery.SchemaField("employee_id","STRING"),
        bigquery.SchemaField("base_code","STRING"),
        bigquery.SchemaField("role","STRING"),
        bigquery.SchemaField("category","STRING"),
        bigquery.SchemaField("exit_date","STRING"),
        bigquery.SchemaField("reason","STRING"),
        bigquery.SchemaField("seniority_years","STRING"),
        bigquery.SchemaField("contract_type","STRING"),
        bigquery.SchemaField("was_replaced","STRING"),
    ],
    "stg_role_requirements": [
        bigquery.SchemaField("req_id","STRING"),
        bigquery.SchemaField("base_code","STRING"),
        bigquery.SchemaField("role","STRING"),
        bigquery.SchemaField("category","STRING"),
        bigquery.SchemaField("min_headcount","STRING"),
        bigquery.SchemaField("optimal_headcount","STRING"),
        bigquery.SchemaField("max_hours_monthly","STRING"),
        bigquery.SchemaField("valid_from","STRING"),
        bigquery.SchemaField("valid_to","STRING"),
    ],
    "stg_bases": [
        bigquery.SchemaField("base_code","STRING"),
        bigquery.SchemaField("base_name","STRING"),
        bigquery.SchemaField("city","STRING"),
        bigquery.SchemaField("country","STRING"),
        bigquery.SchemaField("cluster","STRING"),
        bigquery.SchemaField("hub_type","STRING"),
        bigquery.SchemaField("timezone","STRING"),
    ],
    "stg_roles": [
        bigquery.SchemaField("role_name","STRING"),
        bigquery.SchemaField("category","STRING"),
        bigquery.SchemaField("max_monthly_hours","STRING"),
        bigquery.SchemaField("min_rest_hours","STRING"),
        bigquery.SchemaField("requires_license","STRING"),
        bigquery.SchemaField("license_type","STRING"),
        bigquery.SchemaField("avg_training_days","STRING"),
    ],
}

CSV_MAP = {
    "stg_employees":         "employees.csv",
    "stg_flight_schedule":   "flight_schedule.csv",
    "stg_absences":          "absences.csv",
    "stg_attrition":         "attrition.csv",
    "stg_role_requirements": "role_requirements.csv",
    "stg_bases":             "bases.csv",
    "stg_roles":             "roles.csv",
}

client = bigquery.Client(project=PROJECT)

for table_id, csv_file in CSV_MAP.items():
    path = os.path.join(DATA_DIR, csv_file)
    df   = pd.read_csv(path, dtype=str).fillna("")
    full = f"{PROJECT}.{DATASET}.{table_id}"
    job  = client.load_table_from_dataframe(
        df, full,
        job_config=bigquery.LoadJobConfig(
            schema=SCHEMAS[table_id],
            write_disposition="WRITE_TRUNCATE"
        )
    )
    job.result()
    print(f"✅ {full} ({len(df)} filas)")

print("\n🎉 Carga completa")