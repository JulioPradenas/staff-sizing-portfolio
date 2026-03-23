# Star Schema — staff_sizing

## Diagrama
```
                        dim_date
                           |
          dim_employee — — | — — dim_base
                      \    |    /
                       fct_headcount_daily
                      /         \
                dim_role       dim_contract


          dim_role — fct_absences — dim_base
          dim_role — fct_attrition — dim_base
```

## Tablas

| Tabla | Tipo | Granularidad | Filas |
|---|---|---|---|
| fct_headcount_daily | Fact | 1 fila por día × base × rol × contrato | 276.192 |
| fct_absences | Fact | 1 fila por ausencia | 2.912 |
| fct_attrition | Fact | 1 fila por salida | 1.500 |
| dim_date | Dimensión | 1 fila por día 2022–2027 | 2.191 |
| dim_base | Dimensión | 1 fila por base | 8 |
| dim_role | Dimensión | 1 fila por rol | 10 |
| dim_contract | Dimensión | 1 fila por tipo contrato | 4 |
| dim_employee | Dimensión | 1 fila por empleado | 2.000 |

## Joins principales

| Fact | Dimensión | Llave |
|---|---|---|
| fct_headcount_daily | dim_base | base_code |
| fct_headcount_daily | dim_role | role |
| fct_headcount_daily | dim_date | date_day |
| fct_headcount_daily | dim_contract | contract_type |
| fct_absences | dim_role | role |
| fct_absences | dim_base | base_code |
| fct_attrition | dim_role | role |
| fct_attrition | dim_base | base_code |

## Decisiones de diseño
- fct_headcount_daily usa CROSS JOIN para generar serie de tiempo completa
- FTE equivalent calculado en dim_contract para normalizar tipos de contrato
- Segmentos de antigüedad y edad calculados en dim_employee
- Temporada operacional calculada en dim_date
- Límites regulatorios almacenados en dim_role