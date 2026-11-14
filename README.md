# Seguridad de una base de datos de citas médicas

## Descripción

Este proyecto desarrolla una base de datos para gestionar citas médicas utilizando PostgreSQL. Se trabajó con las tablas de pacientes, médicos, especialidades, horarios y citas. También se implementaron permisos para distintos tipos de usuarios, una vista para recepción, protección de datos personales y auditoría de operaciones.

## Herramientas utilizadas

- PostgreSQL 18.6.
- pgAdmin 4.
- PowerShell para realizar el respaldo y la restauración.

## Base de datos

El nombre de la base de datos utilizada es `citas_medicas`.

Se registraron datos ficticios para las pruebas:

- 3 especialidades.
- 5 médicos.
- 10 pacientes.
- 20 horarios iniciales.
- 20 citas iniciales.

Durante las pruebas de auditoría se agregó un horario temporal y se insertó y eliminó una cita. Por eso, en la base restaurada se verificaron 21 horarios, 20 citas y 3 registros de auditoría.

## Estructura del proyecto

```text
seguridad-bd/
├── backup/
│   └── citas_medicas.backup
├── docs/
│   ├── capturas/
│   │   ├── 02_actividad1_join_1.png
│   │   ├── 02_actividad1_join_2.png
│   │   ├── 04_actividad2_show_ssl.png
│   │   ├── 05_actividad2_stat_ssl.png
│   │   ├── 06_actividad3_medico_citas.png
│   │   ├── 07_actividad3_denegado_paciente.png
│   │   ├── 08_actividad3_denegado_update.png
│   │   ├── 09_actividad3_recepcion_update.png
│   │   ├── 10_actividad4_vista_recepcion.png
│   │   ├── 11_actividad4_proteccion_dni.png
│   │   ├── 12_actividad5_auditoria_detalle.png
│   │   ├── 13_actividad5_auditoria_registros.png
│   │   ├── 14_actividad5_respaldo_restauracion.png
│   │   ├── 15_actividad5_conteos_restaurada.png
│   │   └── 16_actividad5_join_restaurada.png
│   └── informe_seguridad_bd.pdf  (agregar el informe final)
├── sql/
│   ├── 01_esquema.sql
│   ├── 02_datos.sql
│   ├── 03_roles.sql
│   ├── 04_vistas.sql
│   └── 05_auditoria.sql
└── README.md
```

## Archivos SQL

Los archivos se ejecutan en el siguiente orden, sobre una base de datos nueva y vacía:

1. **`01_esquema.sql`**: crea las tablas, claves primarias, claves foráneas y restricciones para evitar horarios duplicados y citas en un mismo horario.
2. **`02_datos.sql`**: inserta los datos ficticios y ejecuta dos consultas `JOIN`: una muestra las citas con los datos del paciente y del médico; la otra muestra los médicos y sus especialidades.
3. **`03_roles.sql`**: crea los roles y usuarios de prueba, asigna permisos y configura la seguridad por filas para que cada médico consulte únicamente sus propias citas.
4. **`04_vistas.sql`**: crea `vista_recepcion`, permite su consulta al rol de recepción y muestra un ejemplo de enmascaramiento y seudonimización del DNI.
5. **`05_auditoria.sql`**: crea la tabla de auditoría, la función y el trigger para registrar operaciones `INSERT`, `UPDATE` y `DELETE` sobre las citas. Al final del archivo se encuentran las pruebas de auditoría.

Los scripts se deben ejecutar una sola vez en una base recién creada. No se deben volver a ejecutar los `INSERT` ni las pruebas de `05_auditoria.sql` sobre la base ya utilizada, porque pueden duplicar datos o generar nuevos registros de auditoría. Los archivos `03_roles.sql` y `05_auditoria.sql` requieren que los pasos anteriores se hayan ejecutado correctamente.

## Usuarios de prueba

En `03_roles.sql` se crean los siguientes usuarios:

- `usr_admin`: administrador.
- `usr_recepcion`: recepcionista.
- `med_ramirez`: usuario asociado al médico con ID 1.
- `med_torres`: usuario asociado al médico con ID 2.

Las contraseñas incluidas en el script son temporales y solo para pruebas locales. No deben utilizarse como credenciales reales.

## Pruebas realizadas

### Actividad 1: esquema y consultas

Se crearon las tablas de pacientes, médicos, especialidades, horarios y citas. Se verificaron las relaciones y se ejecutaron dos consultas `JOIN`.

### Actividad 2: conexión y autenticación

Se explicó el flujo de autenticación de la aplicación mediante JWT y la conexión a PostgreSQL con credenciales propias. En la configuración probada, `SHOW ssl;` devolvió `off` y la consulta a `pg_stat_ssl` devolvió `false`; por lo tanto, la conexión utilizada no estaba cifrada mediante SSL.

### Actividad 3: roles y permisos

Se probaron operaciones permitidas y denegadas para recepción y médicos. La política de seguridad por filas restringe las citas visibles para cada médico según el usuario asociado en la tabla `medico`.

### Actividad 4: vista y protección de datos

Se creó la vista `vista_recepcion`, que muestra la información necesaria para gestionar las citas sin exponer el DNI. También se ejecutó una consulta de ejemplo para mostrar el DNI enmascarado y un código seudonimizado.

### Actividad 5: auditoría y respaldo

El trigger registra la operación realizada, la fecha y hora, el usuario de PostgreSQL, el ID de la cita y los datos anteriores y nuevos cuando corresponda. Se probaron las operaciones `UPDATE`, `INSERT` y `DELETE`.

Se generó el respaldo `citas_medicas.backup` y se restauró en una base de datos llamada `citas_restaurada`. Después se compararon los conteos de filas y se ejecutó nuevamente una consulta `JOIN`.

## Respaldo y restauración

El archivo de respaldo se encuentra en `backup/citas_medicas.backup`. Los siguientes comandos se ejecutan desde la carpeta principal del proyecto en PowerShell. Se considera que las herramientas de PostgreSQL 18 están instaladas en la ruta indicada; si la instalación utiliza otra ruta, se debe modificar.

Crear el respaldo:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -U postgres -Fc -d citas_medicas -f "backup\citas_medicas.backup"
```

Crear una base vacía para la restauración (solo si todavía no existe):

```powershell
& "C:\Program Files\PostgreSQL\18\bin\createdb.exe" -U postgres citas_restaurada
```

Restaurar el respaldo:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" -U postgres -d citas_restaurada "backup\citas_medicas.backup"
```

La restauración se realizó en la misma instalación de PostgreSQL donde se habían creado los roles de prueba. `pg_dump` respalda una base de datos, pero no incluye las definiciones globales de los roles del servidor.

## Evidencias

Las capturas de las consultas y pruebas se encuentran en `docs/capturas/`. Incluyen los resultados de los `JOIN`, las pruebas SSL, los permisos, la vista de recepción, la protección del DNI, la auditoría y la restauración.

Antes de entregar, agregar también la captura del diagrama entidad-relación de la Actividad 1 en `docs/capturas/`, por ejemplo con el nombre `01_actividad1_diagrama_er.png`, y guardar el informe final de máximo 6 páginas en `docs/informe_seguridad_bd.pdf`.
