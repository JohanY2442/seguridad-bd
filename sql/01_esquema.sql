CREATE TABLE paciente (
  id_paciente SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  dni VARCHAR(8) NOT NULL UNIQUE,
  telefono VARCHAR(20),
  fecha_nacimiento DATE
);

CREATE TABLE especialidad (
  id_especialidad SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE medico (
  id_medico SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  colegiatura VARCHAR(20) NOT NULL UNIQUE,
  id_especialidad INTEGER NOT NULL,
  FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
);

CREATE TABLE horario (
  id_horario SERIAL PRIMARY KEY,
  id_medico INTEGER NOT NULL,
  fecha DATE NOT NULL,
  hora TIME NOT NULL,
  FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
  UNIQUE (id_medico, fecha, hora)
);

CREATE TABLE cita (
  id_cita SERIAL PRIMARY KEY,
  id_paciente INTEGER NOT NULL,
  id_horario INTEGER NOT NULL,
  motivo VARCHAR(200),
  estado VARCHAR(20) NOT NULL,
  FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
  FOREIGN KEY (id_horario) REFERENCES horario(id_horario),

  CONSTRAINT unique_horario_cita UNIQUE (id_horario),

  CONSTRAINT check_estado_cita
  CHECK (estado IN ('programada', 'atendida', 'cancelada'))
);


INSERT INTO especialidad (nombre) VALUES
('Cardiología'),
('Pediatría'),
('Dermatología');


INSERT INTO medico (nombre, apellido, colegiatura, id_especialidad) VALUES
('Carlos', 'Ramírez', 'CMP10001', 1),
('Ana', 'Torres', 'CMP10002', 2),
('Luis', 'Gómez', 'CMP10003', 3),
('María', 'Flores', 'CMP10004', 1),
('Jorge', 'Castillo', 'CMP10005', 2);


INSERT INTO paciente (nombre, apellido, dni, telefono, fecha_nacimiento) VALUES
('Juan', 'Pérez', '10203040', '987654321', '1995-03-15'),
('Lucía', 'García', '70700545', '987654322', '1998-07-20'),
('Ayla', 'Martínez', '70000003', '987123456', '1990-01-10'),
('Sofía', 'Rodríguez', '70241019', '984122000', '2001-11-05'),
('Diego', 'Sánchez', '70000005', '984789123', '1987-06-25'),
('Valeria', 'López', '70403020', '903172720', '1999-09-12'),
('Andrés', 'Mendoza', '70554570', '911555444', '1993-02-28'),
('Camila', 'Vargas', '70809001', '932720585', '2000-12-18'),
('Miguel', 'Rojas', '10506080', '936196789', '1985-05-30'),
('Celeste', 'Castro', '75548271', '987654330', '1997-08-08');


INSERT INTO horario (id_medico, fecha, hora) VALUES
(1, '2026-11-15', '09:00'),
(1, '2026-11-15', '11:00'),
(1, '2026-11-17', '10:00'),
(1, '2026-11-18', '15:00'),

(2, '2026-11-15', '08:00'),
(2, '2026-11-16', '10:00'),
(2, '2026-11-18', '09:00'),
(2, '2026-11-19', '11:00'),

(3, '2026-11-16', '14:00'),
(3, '2026-11-17', '09:00'),
(3, '2026-11-19', '10:00'),
(3, '2026-11-20', '16:00'),

(4, '2026-11-15', '14:00'),
(4, '2026-11-17', '08:00'),
(4, '2026-11-18', '11:00'),
(4, '2026-11-20', '09:00'),

(5, '2026-11-16', '08:00'),
(5, '2026-11-18', '10:00'),
(5, '2026-11-19', '15:00'),
(5, '2026-11-20', '11:00');


INSERT INTO cita (id_paciente, id_horario, motivo, estado) VALUES
(1, 1, 'Dolor en el pecho', 'programada'),
(2, 2, 'Control médico', 'atendida'),
(3, 3, 'Dolor de cabeza', 'programada'),
(4, 4, 'Consulta general', 'cancelada'),
(5, 5, 'Control pediátrico', 'programada'),
(6, 6, 'Fiebre', 'atendida'),
(7, 7, 'Dolor de garganta', 'programada'),
(8, 8, 'Control médico', 'programada'),
(9, 9, 'Problemas en la piel', 'atendida'),
(10, 10, 'Acné', 'programada'),
(1, 11, 'Revisión de la piel', 'programada'),
(2, 12, 'Control médico', 'atendida'),
(3, 13, 'Dolor en el pecho', 'programada'),
(4, 14, 'Control cardiológico', 'programada'),
(5, 15, 'Consulta médica', 'cancelada'),
(6, 16, 'Control médico', 'programada'),
(7, 17, 'Fiebre', 'atendida'),
(8, 18, 'Consulta pediátrica', 'programada'),
(9, 19, 'Problemas en la piel', 'programada'),
(10, 20, 'Control dermatológico', 'atendida');


-- Este join sirve para mostrar las citas con el paciente y el médico
SELECT
  paciente.nombre AS nombre_paciente,
  paciente.apellido AS apellido_paciente,
  medico.nombre AS nombre_medico,
  medico.apellido AS apellido_medico,
  horario.fecha,
  horario.hora,
  cita.motivo,
  cita.estado
FROM cita
JOIN paciente ON cita.id_paciente = paciente.id_paciente
JOIN horario ON cita.id_horario = horario.id_horario
JOIN medico ON horario.id_medico = medico.id_medico;


-- Este join sirve para mostrar a los médicos y sus especialidades
SELECT
  medico.nombre,
  medico.apellido,
  medico.colegiatura,
  especialidad.nombre AS especialidad
FROM medico
JOIN especialidad ON medico.id_especialidad = especialidad.id_especialidad;