from google.cloud import bigquery

client = bigquery.Client(project="staff-sizing-portfolio")
result = client.query("SELECT 1 AS test").result()
for row in result:
    print(f"✅ Conexión exitosa al proyecto staff-sizing-portfolio")