# ✈️ Staff Sizing & Headcount Planning 2027
### Portfolio Data Analyst — BigQuery · GCP · Looker Studio

![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-FF6F00?style=flat&logo=googlecloud&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker_Studio-4285F4?style=flat&logo=looker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)

---

## 📌 Objetivo

Modelar la dotación de personal de una aerolínea LATAM por base, rol y temporada.

> **Pregunta de negocio**: ¿Cuántos tripulantes y personal de tierra necesitamos
> contratar en 2027, por base y rol, para cubrir la operación sin brechas críticas?

---

## 🏗 Arquitectura
```
Fuente (CSV)
    ↓
stg_*          → datos crudos sin tocar
    ↓
stg_*_clean    → limpieza documentada con supuestos
    ↓
dim_* + fct_*  → modelo dimensional
    ↓
mart_*         → sizing, gaps, riesgo de rotación, recomendación
    ↓
Looker Studio / Google Sheets → consumo ejecutivo
```

---

## 📐 Mini-proyectos

| # | Nombre | Entregable |
|---|---|---|
| 0 | Setup | Entorno GCP + repo |
| 1 | Staging | stg_*_clean en BigQuery |
| 2 | Dimensional | dim_* + fct_* |
| 3 | KPIs | mart_sizing_weekly + mart_gap_analysis |
| 4 | Forecast | mart_headcount_forecast_2027 |
| 5 | Contratación | mart_hiring_reco_2027 |
| 6 | Alertas | mart_alerts_daily |
| 7 | Dashboard | Looker Studio (3 páginas) |
| 8 | Sheets | Executive pack |

---

## 🛠 Stack técnico
- **BigQuery** — SQL avanzado, modelado dimensional
- **GCP** — BigQuery Sandbox
- **Looker Studio** — dashboards ejecutivos
- **Python** — carga y exportación de datos
- **Google Sheets** — output ejecutivo