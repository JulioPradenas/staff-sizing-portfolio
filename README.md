# ✈️ Staff Sizing & Headcount Planning 2027
### Portfolio Data Analyst — BigQuery · GCP · Looker Studio

![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-FF6F00?style=flat&logo=googlecloud&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker_Studio-4285F4?style=flat&logo=looker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)

---

## 📌 Objetivo

Modelar la dotación de personal de una aerolínea LATAM por base, rol y temporada,
identificando brechas críticas y generando recomendaciones de contratación para 2027.

> **Pregunta de negocio**: ¿Cuántos tripulantes y personal de tierra necesitamos
> contratar en 2027, por base y rol, para cubrir la operación sin brechas críticas
> ni violaciones regulatorias?

---

## 🏗 Arquitectura
Fuente (CSV)
↓
stg_*          → datos crudos sin tocar
↓
stg_clean    → limpieza documentada con supuestos
↓
dim + fct_*  → modelo dimensional (star schema)
↓
mart_*         → sizing, gaps, rotación, forecast, alertas
↓
Looker Studio / Google Sheets → consumo ejecutivo

---

## 📊 Dashboard Looker Studio

🔗 [Ver dashboard en vivo](https://lookerstudio.google.com/TU-LINK-AQUI)

### Executive Overview
![Executive Overview](looker/screenshots/01_executive_overview.png)

### Gap Analysis
![Gap Analysis](looker/screenshots/02_gap_analysis.png)

### Alertas Operacionales
![Alertas](looker/screenshots/03_alertas_operacionales.png)

---

## 🗂 Estructura del proyecto
staff-sizing-portfolio/
├── data_gen/              ← CSVs sintéticos (14.000+ filas)
│   ├── employees.csv          (2.000 filas)
│   ├── flight_schedule.csv    (8.000 filas)
│   ├── absences.csv           (3.000 filas)
│   ├── attrition.csv          (1.500 filas)
│   ├── role_requirements.csv  (  160 filas)
│   ├── bases.csv              (    8 filas)
│   └── roles.csv              (   10 filas)
├── sql/
│   ├── 01_staging/        ← limpieza + flags regulatorios
│   ├── 02_dimensions/     ← dim_base, dim_role, dim_contract, dim_employee, dim_date
│   ├── 03_facts/          ← fct_headcount_daily, fct_absences, fct_attrition
│   ├── 04_marts/          ← sizing, gaps, forecast, contratación
│   └── 05_alerts/         ← alertas regulatorias y operacionales
├── scripts/
│   ├── upload_to_bq.py       ← carga CSVs a BigQuery
│   └── export_to_sheets.py   ← exporta recomendación a Excel
├── docs/                  ← documentación completa
├── looker/                ← capturas del dashboard
└── sheets/                ← output ejecutivo Excel

---

## 📐 Modelo dimensional

| Tabla | Tipo | Descripción | Filas |
|---|---|---|---|
| `fct_headcount_daily` | Fact | Dotación real por día × base × rol | 276.192 |
| `fct_absences` | Fact | Ausencias con impacto FTE | 2.912 |
| `fct_attrition` | Fact | Salidas con costo de reemplazo | 1.500 |
| `dim_date` | Dimensión | Calendario 2022–2027 con temporadas | 2.191 |
| `dim_base` | Dimensión | 8 bases con hub_type y timezone | 8 |
| `dim_role` | Dimensión | 10 roles con límites regulatorios | 10 |
| `dim_contract` | Dimensión | Tipos de contrato con FTE equivalent | 4 |
| `dim_employee` | Dimensión | Empleados con segmentos de edad y antigüedad | 2.000 |

---

## 🔮 Forecast 2027 — 3 escenarios

| Escenario | Rotación | Cuándo usarlo |
|---|---|---|
| Base | Promedio histórico mensual | Planificación operacional normal |
| Conservador | Promedio − 1 stddev | Escenario optimista |
| Estrés | Promedio + 1.5 stddev en temporada alta | Alta rotación + expansión flota |

**Fórmula FTE proyectado:**
FTE_proyectado = FTE_actual − Salidas_mes − (Ausentismo_semanal × 4)

---

## 👥 Recomendación de contratación

Tabla `mart_hiring_reco_2027` — priorizada por urgencia:

| Prioridad | Condición | Acción |
|---|---|---|
| P1 URGENTE | Gap < -10 Y 10+ meses con gap | Iniciar proceso inmediatamente |
| P2 CRITICO | Gap < -5 O 6+ meses con gap | Próximo ciclo de selección |
| P3 PLANIFICAR | Gap < 0 | Planificar Q3/Q4 2027 |
| P4 OK | Sin gap proyectado | Sin acción inmediata |

---

## 🚨 Alertas operacionales

4 tipos de alerta en `mart_alerts_daily`:

| Tipo | Severidad | Owner |
|---|---|---|
| STAFFING_GAP | P1 | HR Operations |
| REGULATORY_VIOLATION | P1 | Compliance |
| CRITICAL_LOSS | P1 | HR Talent |
| DATA_QUALITY_ROLE | P2 | Data Engineering |

---

## ⚙️ Cómo reproducir el proyecto

```bash
# 1. Clonar el repo
git clone https://github.com/JulioPradenas/staff-sizing-portfolio.git
cd staff-sizing-portfolio

# 2. Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Autenticar GCP
gcloud auth application-default login

# 5. Cargar datos a BigQuery
python scripts/upload_to_bq.py

# 6. Ejecutar todos los SQLs
python scripts/run_all_sql.py
```

---

## 📚 Documentación

| Documento | Descripción |
|---|---|
| [Supuestos de staging](docs/assumptions_staging.md) | Reglas de limpieza y flags regulatorios |
| [Star Schema](docs/star_schema.md) | Modelo dimensional |
| [KPI Definitions](docs/kpi_definitions.md) | Definición de métricas |
| [Forecast Method](docs/forecast_method.md) | Metodología de proyección |
| [Hiring Policy](docs/hiring_policy.md) | Fórmula y política de contratación |
| [Runbook Alertas](docs/runbook_alerts.md) | Acciones ante cada alerta |
| [Executive Pack](docs/executive_pack.md) | Guía del output en Sheets |

---

## 🛠 Stack técnico

- **BigQuery** — SQL avanzado, CROSS JOIN, DATE_DIFF, window functions
- **GCP** — BigQuery Sandbox
- **Looker Studio** — dashboards conectados a BigQuery
- **Python** — carga de datos y exportación
- **Google Sheets / Excel** — output ejecutivo