DROP VIEW IF EXISTS vista_recepcion;

CREATE VIEW vista_recepcion AS
SELECT
    c.id_cita,
    h.fecha,
    h.hora,
    c.estado,
    c.motivo,
    (p.nombre || ' ' || p.apellido) AS paciente,
    (m.nombre || ' ' || m.apellido) AS medico,
    e.nombre AS especialidad
FROM cita c
JOIN paciente p     ON c.id_paciente = p.id_paciente
JOIN horario h      ON c.id_horario = h.id_horario
JOIN medico m       ON h.id_medico = m.id_medico
JOIN especialidad e ON m.id_especialidad = e.id_especialidad;

GRANT SELECT ON vista_recepcion TO rol_recepcionista, rol_administrador;

SELECT
    id_paciente,
    nombre || ' ' || apellido AS paciente,
    dni AS dni_original,
    REPEAT('*', GREATEST(LENGTH(dni) - 4, 0)) || RIGHT(dni, 4) AS dni_enmascarado,
    'PSEUDO-' || SUBSTRING(MD5(dni || 'clave_centro_medico_2026'), 1, 10) AS codigo_seudonimizado
FROM paciente

