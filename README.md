# Proyecto de Seguridad de Bases de Datos

## Descripción

Este repositorio contiene el desarrollo del proyecto de seguridad de bases de datos.

Se implementará una base de datos para la gestión de citas médicas y se desarrollarán las diferentes actividades indicadas en el proyecto.

## Base de datos

El proyecto utiliza **PostgreSQL 18.6**.

## Actividad 1: Esquema de la base de datos

En esta actividad se implementó el esquema de una base de datos para gestionar:

- Pacientes
- Médicos
- Especialidades
- Horarios
- Citas

El archivo correspondiente es:

```text
01_esquema.sql
```

Este archivo contiene la creación de las tablas, sus relaciones, datos de prueba y consultas utilizando `JOIN`.

## Datos de prueba

Actualmente se han registrado:

- 3 especialidades
- 5 médicos
- 10 pacientes
- 20 horarios
- 20 citas

## Consultas realizadas

Se incluyeron consultas utilizando `JOIN` para:

1. Mostrar las citas junto con los datos del paciente, médico, horario, motivo y estado.
2. Mostrar los médicos junto con la especialidad a la que pertenecen.

## Estructura actual

```text
seguridad-bd/
├── 01_esquema.sql
└── README.md
```

Aca se agregaran las demas actividades y contenidos conforme se vaya avanzando
