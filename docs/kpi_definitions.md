# Definiciones de KPIs

| KPI | Definición | Unidad | Cómo leerlo |
|---|---|---|---|
| avg_headcount | Promedio de empleados activos en el período | personas | Dotación bruta |
| avg_fte | Dotación en FTE equivalente | FTE | Normaliza part-time y honorarios |
| fte_absent | FTE perdidos por ausentismo | FTE | días_ausente / 22 días laborables |
| effective_fte | avg_fte − fte_absent | FTE | Dotación realmente disponible |
| min_headcount | Dotación mínima requerida por regulación/operación | personas | Piso operacional |
| optimal_headcount | Dotación óptima para operar sin presión | personas | Meta de contratación |
| gap_vs_minimum | effective_fte − min_headcount | FTE | Negativo = brecha crítica |
| gap_vs_optimal | effective_fte − optimal_headcount | FTE | Negativo = por debajo del óptimo |
| staffing_status | Semáforo CRITICO / BAJO / OK | categoría | Estado operacional de la semana |
| gap_severity | SEVERO / MODERADO / LEVE / OK | categoría | Urgencia de contratación |
| pct_weeks_critical | % semanas en estado CRITICO | % | 100% = siempre crítico |
| replacement_training_days | Días de capacitación para reemplazar un rol | días | Costo operacional de la rotación |
| fte_impact | días_ausente / 22 | FTE | Impacto de una ausencia en dotación |
| is_critical_loss | Salida de empleado con > 5 años sin reemplazo | boolean | TRUE = alerta P1 |