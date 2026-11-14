
CREATE TABLE IF NOT EXISTS auditoria_cita (
    id_auditoria BIGSERIAL PRIMARY KEY,
    operacion VARCHAR(10) NOT NULL
        CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE')),
    fecha_hora TIMESTAMPTZ NOT NULL DEFAULT now(),
    usuario_bd TEXT NOT NULL,
    id_cita INTEGER NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB
);

REVOKE ALL ON auditoria_cita FROM PUBLIC;
GRANT SELECT ON auditoria_cita TO rol_administrador;


CREATE OR REPLACE FUNCTION fn_auditar_cita()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_usuario TEXT;
BEGIN
    IF current_setting('role') <> 'none' THEN
        v_usuario := current_setting('role');
    ELSE
        v_usuario := session_user;
    END IF;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_cita (
            operacion, usuario_bd, id_cita,
            datos_anteriores, datos_nuevos
        )
        VALUES (
            TG_OP, v_usuario, NEW.id_cita,
            NULL, to_jsonb(NEW)
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_cita (
            operacion, usuario_bd, id_cita,
            datos_anteriores, datos_nuevos
        )
        VALUES (
            TG_OP, v_usuario, NEW.id_cita,
            to_jsonb(OLD), to_jsonb(NEW)
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_cita (
            operacion, usuario_bd, id_cita,
            datos_anteriores, datos_nuevos
        )
        VALUES (
            TG_OP, v_usuario, OLD.id_cita,
            to_jsonb(OLD), NULL
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;


DROP TRIGGER IF EXISTS trg_auditar_cita ON cita;

CREATE TRIGGER trg_auditar_cita
AFTER INSERT OR UPDATE OR DELETE ON cita
FOR EACH ROW
EXECUTE FUNCTION fn_auditar_cita();


-- Prueba de modificacion
RESET ROLE;
SET ROLE usr_recepcion;

UPDATE cita
SET motivo = 'Prueba de auditoría'
WHERE id_cita = 1;


-- Prueba de insercion y eliminacion
RESET ROLE;
SET ROLE usr_admin;

INSERT INTO horario (id_medico, fecha, hora)
VALUES (1, '2026-11-21', '10:00');

INSERT INTO cita (id_paciente, id_horario, motivo, estado)
VALUES (
    1,
    (SELECT MAX(id_horario) FROM horario),
    'Prueba de auditoría',
    'programada'
);

DELETE FROM cita
WHERE id_horario = (SELECT MAX(id_horario) FROM horario);


-- Verificar los registros
RESET ROLE;

SELECT
    id_auditoria,
    operacion,
    fecha_hora,
    usuario_bd,
    id_cita,
    datos_anteriores,
    datos_nuevos
FROM auditoria_cita
ORDER BY id_auditoria;

