# Metodología de Forecast de Dotación

## Método
Forecast estadístico basado en historial 2022–2024, implementado en SQL puro (BigQuery).
Modela tres fuerzas simultáneas: rotación histórica, ausentismo proyectado y requerimientos operacionales.

## Escenarios

| Escenario | Rotación | Ausentismo | Cuándo usarlo |
|---|---|---|---|
| Base | Promedio histórico mensual | Promedio histórico semanal × 4 | Planificación operacional normal |
| Conservador | Promedio − 1 stddev | Promedio histórico | Escenario optimista, menor rotación |
| Estrés | Promedio + 1.5 stddev en temporada alta | Promedio histórico | Incorporaciones masivas, alta rotación |

## Fórmula de FTE proyectado
```
FTE_proyectado = FTE_actual − Salidas_mes − (Ausentismo_semanal × 4)
```

## GAP proyectado
```
GAP = FTE_proyectado − min_headcount_requerido
```
- GAP negativo → hay que contratar
- GAP positivo → hay margen de dotación

## Supuestos
- FTE actual = último snapshot disponible (diciembre 2024)
- Rotación y ausentismo asumidos constantes en 2027
- Requerimientos mínimos no cambian en 2027
- Temporadas altas: enero/febrero/diciembre y junio/julio/agosto

## Limitaciones
- No modela crecimiento de flota ni nuevas rutas
- No captura cambios regulatorios de horas máximas
- Revisar y recalibrar cada trimestre con datos actualizados