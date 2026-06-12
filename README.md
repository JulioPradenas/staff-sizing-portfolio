# ✈️ Staff Sizing & Headcount Planning 2027
### Portfolio Data Analyst — BigQuery · GCP · Looker Studio

![BigQuery](https://img.shields.io/badge/BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-FF6F00?style=flat&logo=googlecloud&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker_Studio-4285F4?style=flat&logo=looker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)

---

## Objetivo

Modelar la dotación de personal de una aerolínea LATAM por base, rol y temporada,
identificando brechas críticas y generando recomendaciones de contratación para 2027.

> **Pregunta de negocio**: ¿Cuántos tripulantes y personal de tierra necesitamos
> contratar en 2027, por base y rol, para cubrir la operación sin brechas críticas
> ni violaciones regulatorias?

---

## Dashboard Looker Studio

🔗 [Ver dashboard en vivo](https://datastudio.google.com/s/v0nebmXHLEM)

| Página | Contenido |
|---|---|
| Executive Overview | KPIs globales de dotación, forecast 2027, alertas activas por base |
| Gap Analysis | Brechas por base y rol, evolución semanal del gap, filtros por base y categoría |

---

## Pipeline ELT

```
Fuente (7 CSVs · 14.000+ filas)
        │
        ▼
01_staging      stg_*_clean     Limpieza, normalización, flags regulatorios
        │
        ▼
02_dimensions   dim_*           Star schema: base, rol, contrato, empleado, fecha
        │
        ▼
03_facts        fct_*           Dotación diaria (276K filas), ausencias, attrition
        │
        ▼
04_marts        mart_*          KPIs semanales, gaps, forecast, contratación, alertas
        │
        ▼
Looker Studio · Excel ejecutivo
```

---

## Modelo dimensional

| Tabla | Tipo | Descripción | Filas |
|---|---|---|---|
| `fct_headcount_daily` | Fact | Dotación real por día × base × rol | 276.192 |
| `fct_absences` | Fact | Ausencias con impacto FTE | 2.912 |
| `fct_attrition` | Fact | Salidas con costo de reemplazo | 1.500 |
| `dim_date` | Dimensión | Calendario 2022–2027 con temporadas | 2.191 |
| `dim_base` | Dimensión | 8 bases con hub_type y timezone | 8 |
| `dim_role` | Dimensión | 10 roles con límites regulatorios | 10 |
| `dim_contract` | Dimensión | Tipos de contrato con FTE equivalente | 4 |
| `dim_employee` | Dimensión | Empleados con segmentos edad y antigüedad | 2.000 |

---

## Forecast 2027 — 3 escenarios

| Escenario | Rotación aplicada | Cuándo usarlo |
|---|---|---|
| Base | Promedio histórico mensual | Planificación operacional normal |
| Conservador | Promedio − 1 stddev | Escenario optimista |
| Estrés | Promedio + 1.5 stddev en temporada alta | Alta rotación + expansión de flota |

```
FTE_proyectado = FTE_actual − Salidas_mes − (Ausentismo_semanal × 4)
```

---

## Recomendación de contratación

`mart_hiring_reco_2027` — 80 combinaciones base × rol, priorizadas por urgencia:

| Prioridad | Condición | Acción |
|---|---|---|
| P1 URGENTE | Gap < −10 Y 10+ meses con gap | Iniciar proceso inmediatamente |
| P2 CRITICO | Gap < −5 O 6+ meses con gap | Próximo ciclo de selección |
| P3 PLANIFICAR | Gap < 0 | Planificar Q3/Q4 2027 |
| P4 OK | Sin gap proyectado | Sin acción inmediata |

Output en `sheets/hiring_reco_2027.xlsx` con 3 pestañas: **DETALLE · RESUMEN · SUPUESTOS**

---

## Alertas operacionales

`mart_alerts_daily` — 4 tipos de alerta con owner y runbook definido:

| Tipo | Severidad | Owner |
|---|---|---|
| STAFFING_GAP | P1 | HR Operations |
| REGULATORY_VIOLATION | P1 | Compliance |
| CRITICAL_LOSS | P1 | HR Talent |
| DATA_QUALITY_ROLE | P2 | Data Engineering |

---

## Estructura del proyecto

```
staff-sizing-portfolio/
├── data_gen/              ← CSVs sintéticos (14.000+ filas)
│   ├── employees.csv          (2.000 filas)
│   ├── flight_schedule.csv    (8.000 filas)
│   ├── absences.csv           (3.000 filas)
│   ├── attrition.csv          (1.500 filas)
│   ├── role_requirements.csv  (   80 filas)
│   ├── bases.csv              (    8 filas)
│   └── roles.csv              (   10 filas)
├── sql/
│   ├── 01_staging/        ← limpieza + flags regulatorios
│   ├── 02_dimensions/     ← dim_base, dim_role, dim_contract, dim_employee, dim_date
│   ├── 03_facts/          ← fct_headcount_daily, fct_absences, fct_attrition
│   └── 04_marts/          ← sizing, gaps, forecast, contratación, alertas
├── scripts/
│   ├── upload_to_bq.py        ← carga CSVs a BigQuery
│   ├── run_all_sql.py         ← ejecuta pipeline SQL completo (01→02→03→04)
│   └── export_to_sheets.py    ← genera Excel ejecutivo con 3 pestañas y formato
├── docs/                  ← documentación técnica y de negocio
├── sheets/                ← output ejecutivo Excel
└── looker/                ← capturas del dashboard
```

---

## Cómo reproducir el proyecto

```bash
# 1. Clonar el repositorio
git clone https://github.com/JulioPradenas/staff-sizing-portfolio.git
cd staff-sizing-portfolio

# 2. Crear entorno virtual e instalar dependencias
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 3. Autenticar con GCP
gcloud auth application-default login

# 4. Cargar datos crudos a BigQuery
python scripts/upload_to_bq.py

# 5. Ejecutar el pipeline SQL completo (staging → dims → facts → marts)
python scripts/run_all_sql.py

# 6. Generar el Excel ejecutivo
python scripts/export_to_sheets.py
open sheets/hiring_reco_2027.xlsx
```

---

## Documentación

| Documento | Descripción |
|---|---|
| [Star Schema](docs/star_schema.md) | Modelo dimensional y decisiones de diseño |
| [Supuestos de staging](docs/assumptions_staging.md) | Reglas de limpieza y flags regulatorios |
| [KPI Definitions](docs/kpi_definitions.md) | Definición de las 14 métricas operacionales |
| [Forecast Method](docs/forecast_method.md) | Metodología de proyección 3 escenarios |
| [Hiring Policy](docs/hiring_policy.md) | Fórmula y criterios de prioridad de contratación |
| [Runbook Alertas](docs/runbook_alerts.md) | Acciones y owners por tipo de alerta |
| [Executive Pack](docs/executive_pack.md) | Guía del output Excel para equipos no técnicos |

---

## Stack técnico

| Herramienta | Uso |
|---|---|
| **BigQuery** | Data warehouse principal — SQL avanzado, window functions, CROSS JOIN, DATE_DIFF |
| **GCP** | Autenticación y ejecución en BigQuery Sandbox |
| **Looker Studio** | Dashboards interactivos conectados directamente a BigQuery |
| **Python** | Carga de datos, automatización del pipeline SQL, exportación a Excel |
| **openpyxl / pandas** | Generación de Excel con formato condicional y múltiples pestañas |
