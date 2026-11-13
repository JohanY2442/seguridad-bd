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
