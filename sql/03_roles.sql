-- Relacionar cada médico con su usuario de PostgreSQL
ALTER TABLE medico
ADD COLUMN IF NOT EXISTS usuario_bd VARCHAR(50) UNIQUE;


-- Crear roles generales
CREATE ROLE rol_administrador NOLOGIN;
CREATE ROLE rol_recepcionista NOLOGIN;
CREATE ROLE rol_medico NOLOGIN;


-- Crear usuarios de prueba
CREATE ROLE usr_admin
    LOGIN PASSWORD 'Temp_Admin_2026!'
    IN ROLE rol_administrador;

CREATE ROLE usr_recepcion
    LOGIN PASSWORD 'Temp_Recep_2026!'
    IN ROLE rol_recepcionista;

CREATE ROLE med_ramirez
    LOGIN PASSWORD 'Temp_Med1_2026!'
    IN ROLE rol_medico;

CREATE ROLE med_torres
    LOGIN PASSWORD 'Temp_Med2_2026!'
    IN ROLE rol_medico;


-- Asociar los usuarios con sus médicos
UPDATE medico
SET usuario_bd = 'med_ramirez'
WHERE id_medico = 1;

UPDATE medico
SET usuario_bd = 'med_torres'
WHERE id_medico = 2;


-- Retirar permisos generales
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;


-- Permitir acceso al esquema
GRANT USAGE ON SCHEMA public
TO rol_administrador, rol_recepcionista, rol_medico;


-- Permisos del administrador
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public
TO rol_administrador;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public
TO rol_administrador;


-- Permisos del recepcionista
GRANT SELECT, INSERT, UPDATE ON TABLE cita
TO rol_recepcionista;

GRANT USAGE, SELECT ON SEQUENCE cita_id_cita_seq
TO rol_recepcionista;

GRANT SELECT ON TABLE horario, medico, especialidad
TO rol_recepcionista;


-- Permisos del médico
GRANT SELECT ON TABLE cita
TO rol_medico;

GRANT SELECT ON TABLE horario, especialidad
TO rol_medico;

GRANT SELECT (
    id_medico,
    nombre,
    apellido,
    colegiatura,
    id_especialidad,
    usuario_bd
)
ON TABLE medico TO rol_medico;


-- Activar seguridad por filas
ALTER TABLE cita ENABLE ROW LEVEL SECURITY;
ALTER TABLE cita FORCE ROW LEVEL SECURITY;


-- Política para el administrador
CREATE POLICY pol_cita_admin ON cita
FOR ALL TO rol_administrador
USING (true)
WITH CHECK (true);


-- Políticas para el recepcionista
CREATE POLICY pol_cita_recepcion_sel ON cita
FOR SELECT TO rol_recepcionista
USING (true);

CREATE POLICY pol_cita_recepcion_ins ON cita
FOR INSERT TO rol_recepcionista
WITH CHECK (true);

CREATE POLICY pol_cita_recepcion_upd ON cita
FOR UPDATE TO rol_recepcionista
USING (true)
WITH CHECK (true);


-- Política para que cada médico vea solamente sus citas
CREATE POLICY pol_cita_medico_sel ON cita
FOR SELECT TO rol_medico
USING (
    id_horario IN (
        SELECT h.id_horario
        FROM horario h
        JOIN medico m
            ON h.id_medico = m.id_medico
        WHERE m.usuario_bd = current_user
    )
);
