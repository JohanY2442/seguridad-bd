ALTER TABLE medico
ADD COLUMN IF NOT EXISTS usuario_bd VARCHAR(50) UNIQUE;

CREATE ROLE rol_administrador NOLOGIN;
CREATE ROLE rol_recepcionista NOLOGIN;
CREATE ROLE rol_medico NOLOGIN;

CREATE ROLE usr_admin     LOGIN PASSWORD 'Temp_Admin_2026!' IN ROLE rol_administrador;
CREATE ROLE usr_recepcion LOGIN PASSWORD 'Temp_Recep_2026!' IN ROLE rol_recepcionista;
CREATE ROLE med_ramirez   LOGIN PASSWORD 'Temp_Med1_2026!'  IN ROLE rol_medico;
CREATE ROLE med_torres    LOGIN PASSWORD 'Temp_Med2_2026!'  IN ROLE rol_medico;

UPDATE medico SET usuario_bd = 'med_ramirez' WHERE id_medico = 1;
UPDATE medico SET usuario_bd = 'med_torres'  WHERE id_medico = 2;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;

GRANT USAGE ON SCHEMA public TO rol_administrador, rol_recepcionista, rol_medico;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rol_administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rol_administrador;

GRANT SELECT, INSERT, UPDATE ON TABLE cita TO rol_recepcionista;
GRANT USAGE, SELECT ON SEQUENCE cita_id_cita_seq TO rol_recepcionista;
GRANT SELECT ON TABLE horario, medico, especialidad TO rol_recepcionista;

GRANT SELECT ON TABLE cita TO rol_medico;
GRANT SELECT ON TABLE horario, especialidad TO rol_medico;
GRANT SELECT (id_medico, nombre, apellido, colegiatura, id_especialidad, usuario_bd)
    ON TABLE medico TO rol_medico;

ALTER TABLE cita ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_cita_admin ON cita
    FOR ALL TO rol_administrador USING (true) WITH CHECK (true);

CREATE POLICY pol_cita_recepcion_sel ON cita
    FOR SELECT TO rol_recepcionista USING (true);

CREATE POLICY pol_cita_recepcion_ins ON cita
    FOR INSERT TO rol_recepcionista WITH CHECK (true);

CREATE POLICY pol_cita_recepcion_upd ON cita
    FOR UPDATE TO rol_recepcionista USING (true) WITH CHECK (true);

CREATE POLICY pol_cita_medico_sel ON cita
    FOR SELECT TO rol_medico
    USING (
        id_horario IN (
            SELECT h.id_horario
            FROM horario h
            JOIN medico m ON h.id_medico = m.id_medico
            WHERE m.usuario_bd = current_user
        )
    );

SET ROLE usr_recepcion;

-- ENSAYO 1 (Permitido): Recepción consulta la vista de la Actividad 4
SELECT id_cita, fecha, hora, paciente, medico, especialidad, estado
FROM vista_recepcion
ORDER BY fecha, hora
LIMIT 3;

-- ENSAYO 2 (Permitido): Recepción modifica una cita y verifica el cambio
UPDATE cita
SET estado = 'atendida'
WHERE id_cita = 1;

SELECT id_cita, paciente, estado
FROM vista_recepcion
WHERE id_cita = 1;

-- ENSAYO 4 (Denegado): Recepción intenta leer un campo personal excluido de la vista
-- Resultado esperado: ERROR: permission denied for table paciente
SELECT nombre, apellido, dni
FROM paciente;

SET ROLE med_ramirez;

-- ENSAYO 3 (Permitido): Médico consulta su programación sin filtro WHERE
-- Resultado esperado: devuelve solo sus 4 citas de las 20 totales
SELECT id_cita, id_paciente, id_horario, motivo, estado
FROM cita;

-- ENSAYO 5 (Denegado): Médico intenta modificar una de sus propias citas
-- Resultado esperado: ERROR: permission denied for table cita
UPDATE cita
SET estado = 'cancelada'
WHERE id_cita = 1;

-- Volver al usuario administrador
RESET ROLE;
