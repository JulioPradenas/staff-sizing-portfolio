# Executive Pack — Recomendacion de Contratacion 2027

## Archivo
`sheets/hiring_reco_2027.xlsx`

## Pestanas

| Pestana | Contenido |
|---|---|
| RESUMEN | Totales, # roles por prioridad, top 10 mas criticos |
| DETALLE | Recomendacion completa por base x rol con prioridad coloreada |
| SUPUESTOS | Metodologia resumida para equipos no tecnicos |

## Como interpretar la prioridad

- P1 URGENTE   — iniciar proceso de seleccion inmediatamente
- P2 CRITICO   — incluir en proximo ciclo de contratacion
- P3 PLANIFICAR — planificar para Q3/Q4 2027
- P4 OK        — sin accion inmediata

## Como interpretar Meses_Para_Cubrir

Tiempo estimado desde el inicio del proceso hasta que el nuevo empleado esta operativo.
Incluye seleccion + capacitacion.
Ejemplo: Piloto Comandante tiene promedio 1.4 meses solo de capacitacion.

## Cuando actualizar

- Cambio en dotacion activa (ingresos/salidas masivas)
- Actualizacion de requerimientos minimos por base
- Cambio en proyeccion de rutas o flota 2027

## Como regenerar el archivo

```bash
source venv/bin/activate
python scripts/export_to_sheets.py
```
