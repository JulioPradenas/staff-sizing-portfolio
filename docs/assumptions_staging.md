# Supuestos de limpieza — Staging

## employees

| Campo | Problema | Regla aplicada | Impacto en negocio |
|---|---|---|---|
| role | "piloto", "TCABIN", vacío | Mapeo a nombre estándar; resto → UNK_ROLE | Roles UNK excluidos del sizing |
| base_code | "Santiago", "lima", etc. | Mapeo a código interno | Sin pérdida de datos |
| hire_date | Nulo | Excluir fila | Sin impacto — < 1% de registros |
| monthly_hours | > límite regulatorio | Flag exceeds_regulatory_limit = TRUE | Alerta para revisión manual |
| employee_id | Duplicados | Conservar registro más reciente | Evita sobrecontar dotación |

## absences

| Campo | Problema | Regla aplicada | Impacto en negocio |
|---|---|---|---|
| start_date | ~4% nulo | Excluir fila | Pérdida menor en tasa de ausentismo |
| days_absent | Nulo o cero | Excluir fila | Evita distorsionar promedio de días |
| days_absent | > 60 días | Flag is_long_absence = TRUE | Revisión manual requerida |
| approved | Vacío | Tratar como FALSE | Conservador — ausencia no confirmada |

## attrition

| Campo | Problema | Regla aplicada | Impacto en negocio |
|---|---|---|---|
| exit_date | Nulo | Excluir fila | Sin impacto — < 1% |
| seniority_years | Nulo | SAFE_CAST → NULL | No afecta conteo de salidas |
| was_replaced | Vacío | Tratar como FALSE | Conservador — asume no reemplazado |
| seniority > 5 + sin reemplazo | Combinación crítica | Flag is_critical_loss = TRUE | Alerta P1 en sistema de alertas |

## flight_schedule

| Campo | Problema | Regla aplicada | Impacto en negocio |
|---|---|---|---|
| flight_date | Nulo | Excluir fila | Sin impacto |
| flight_hours | Nulo | SAFE_CAST → NULL | No afecta conteo de vuelos |
| flight_hours > 8 | Vuelo largo | Flag is_long_haul = TRUE | Requerimiento adicional de tripulación |
| total_crew = 0 | Error de datos | Excluir fila | Evita vuelos sin tripulación en sizing |

## Reglas generales
- Bases válidas: SCL · LIM · BOG · GRU · EZE · MIA · MAD · JFK
- Roles válidos: 10 roles estándar definidos en stg_roles
- Todo valor no reconocido → UNK_ROLE o UNK_BASE
- Filas sin fecha válida → excluidas

## Alertas de calidad
- Si % roles UNK > 5% en cualquier base → alerta P2
- Si empleado con exceeds_regulatory_limit = TRUE → alerta P1
- Si is_critical_loss = TRUE → alerta P1