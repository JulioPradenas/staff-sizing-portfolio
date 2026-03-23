# Runbook de Alertas

## P1 — STAFFING_GAP
**Qué significa**: la dotación efectiva está por debajo del mínimo requerido.

**Acción**:
1. Verificar si hay ausencias masivas no planificadas en la base
2. Evaluar redistribución temporal desde bases con dotación OK
3. Activar proceso de contratación urgente si el gap persiste > 2 semanas
4. Escalar a Gerencia de Operaciones si afecta vuelos programados

**Owner**: HR Operations

---

## P1 — REGULATORY_VIOLATION
**Qué significa**: uno o más empleados superan el límite de horas mensuales permitido por regulación de aviación civil.

**Acción**:
1. Identificar empleados específicos con `exceeds_regulatory_limit = TRUE`
2. Reasignar vuelos a tripulantes con horas disponibles
3. Notificar a la Autoridad de Aviación Civil si la violación supera 48 horas
4. Documentar incidente en sistema de Compliance

**Owner**: Compliance

---

## P1 — CRITICAL_LOSS
**Qué significa**: un empleado con más de 5 años de antigüedad se fue sin reemplazo asignado en los últimos 30 días.

**Acción**:
1. Verificar si el proceso de reemplazo fue iniciado
2. Evaluar redistribución de responsabilidades en el equipo
3. Activar proceso de selección con prioridad alta
4. Considerar contratación temporal mientras se completa el proceso

**Owner**: HR Talent

---

## P2 — DATA_QUALITY_ROLE
**Qué significa**: más del 0.1% de los empleados de una base tienen rol no reconocido.

**Acción**:
1. Revisar sistema de origen (HRIS) para esa base
2. Solicitar corrección retroactiva de registros
3. Estos empleados no se incluyen en el sizing — puede subestimar dotación real

**Owner**: Data Engineering