SET NAMES utf8mb4;

-- Catalogo principal de estudiantes; correo unico y estado controlado.
CREATE TABLE estudiante (
 id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 apellido VARCHAR(100) NOT NULL,
 correo VARCHAR(254) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 ultima_actividad DATETIME,
 estado VARCHAR(20) NOT NULL DEFAULT 'activo',
 CONSTRAINT ck_estudiante_estado CHECK (estado IN ('activo','inactivo','suspendido'))
);
-- Perfil: uno por estudiante (UNIQUE en la FK implementa 1:1).
-- preferencias_json almacena preferencias variables; no sustituye las tablas relacionales de intereses y habilidades.
CREATE TABLE perfil (
 id_perfil INT AUTO_INCREMENT PRIMARY KEY,
 id_estudiante INTEGER NOT NULL UNIQUE,
 area_estudio VARCHAR(120), biografia TEXT, programa VARCHAR(120),
 semestre INTEGER, ciudad VARCHAR(100), desorg_perfil TEXT,
 fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP,
 preferencias_json JSON,
 CONSTRAINT ck_perfil_semestre CHECK (semestre IS NULL OR semestre >= 1),
 CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
 ON UPDATE CASCADE ON DELETE CASCADE
);
-- Catalogo de habilidades.
CREATE TABLE habilidad (
 id_habilidad INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL, descripcion TEXT
);
-- Catalogo de intereses.
CREATE TABLE interes (
 id_interes INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL, descripcion TEXT
);
-- Seguimiento entre estudiantes: PK compuesta impide duplicar la pareja.
CREATE TABLE seguir (
 id_seguidor INTEGER NOT NULL, id_seguido INTEGER NOT NULL,
 fecha_seguimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_seguir PRIMARY KEY (id_seguidor,id_seguido),
 CONSTRAINT fk_seguir_seguidor FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_seguir_seguido FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Mentorias: PK compuesta de mentor y aprendiz.
CREATE TABLE mentoria (
 id_mentor INTEGER NOT NULL, id_aprendiz INTEGER NOT NULL,
 fecha_seguimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_mentoria PRIMARY KEY (id_mentor,id_aprendiz),
 CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_mentoria_aprendiz FOREIGN KEY (id_aprendiz) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Grupo: el creador debe ser un estudiante existente.
CREATE TABLE grupo (
 id_grupo INT AUTO_INCREMENT PRIMARY KEY,
 creador_id INTEGER NOT NULL, nombre VARCHAR(120) NOT NULL,
 descripcion TEXT, tipo VARCHAR(50),
 fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 estado VARCHAR(20) NOT NULL DEFAULT 'activo',
 CONSTRAINT ck_grupo_estado CHECK (estado IN ('activo','inactivo','cerrado')),
 CONSTRAINT fk_grupo_creador FOREIGN KEY (creador_id) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE RESTRICT
);
-- Publicacion: autor existente.
CREATE TABLE publicacion (
 id_publicacion INT AUTO_INCREMENT PRIMARY KEY,
 id_estudiante INTEGER NOT NULL, contenido TEXT NOT NULL,
 tipo VARCHAR(50), fecha_publicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Interseccion estudiante-grupo, con PK compuesta.
CREATE TABLE miembro_grupo (
 id_estudiante INTEGER NOT NULL, id_grupo INTEGER NOT NULL,
 fecha_ingreso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, rol VARCHAR(50),
 CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_estudiante,id_grupo),
 CONSTRAINT fk_miembro_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_miembro_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Evento: cada evento pertenece a un grupo.
CREATE TABLE evento (
 id_evento INT AUTO_INCREMENT PRIMARY KEY,
 id_grupo INTEGER NOT NULL, nombre VARCHAR(120) NOT NULL,
 descripcion TEXT, fecha_inicio DATETIME NOT NULL, fecha_fin DATETIME,
 lugar VARCHAR(150), modalidad VARCHAR(50), organizador VARCHAR(120),
 fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT ck_evento_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
 CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Comentario: depende de publicacion y estudiante.
CREATE TABLE comentario (
 id_comentario INT AUTO_INCREMENT PRIMARY KEY,
 id_publicacion INTEGER NOT NULL, id_estudiante INTEGER NOT NULL,
 comentario TEXT NOT NULL, fecha_comentario DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Reaccion: una por estudiante y publicacion, segun PK compuesta del diagrama.
CREATE TABLE reaccion (
 id_estudiante INTEGER NOT NULL, id_publicacion INTEGER NOT NULL,
 tipo_reaccion VARCHAR(50) NOT NULL, fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_reaccion PRIMARY KEY (id_estudiante,id_publicacion),
 CONSTRAINT fk_reaccion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Asistencia a eventos: PK compuesta evita inscripciones repetidas.
CREATE TABLE asistente_evento (
 id_estudiante INTEGER NOT NULL, id_evento INTEGER NOT NULL,
 estado VARCHAR(50), fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_asistente_evento PRIMARY KEY (id_estudiante,id_evento),
 CONSTRAINT fk_asistente_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_asistente_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Habilidades por estudiante: tabla puente N:M.
CREATE TABLE estudiante_habilidad (
 id_estudiante INTEGER NOT NULL, id_habilidad INTEGER NOT NULL,
 nivel VARCHAR(50), fecha_agregado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_estudiante_habilidad PRIMARY KEY (id_estudiante,id_habilidad),
 CONSTRAINT fk_eh_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_eh_habilidad FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Intereses por estudiante: tabla puente N:M.
CREATE TABLE estudiante_interes (
 id_estudiante INTEGER NOT NULL, id_interes INTEGER NOT NULL,
 fecha_agregado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_estudiante_interes PRIMARY KEY (id_estudiante,id_interes),
 CONSTRAINT fk_ei_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_ei_interes FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Validacion de objeto JSON en el perfil (se permite NULL).
ALTER TABLE perfil ADD CONSTRAINT ck_perfil_json_objeto CHECK (preferencias_json IS NULL OR JSON_TYPE(preferencias_json) = 'OBJECT');



-- VERIFICACION: debe devolver 15 tablas si el esquema esta vacio.
SELECT COUNT(*) AS total_tablas
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE';

-- INVENTARIO DE TABLAS
SHOW TABLES;
-- DICCIONARIO FISICO DE COLUMNAS (incluye tipo JSON)
SELECT c.TABLE_NAME AS tabla,
       c.ORDINAL_POSITION AS posicion,
       c.COLUMN_NAME AS columna,
       c.COLUMN_TYPE AS tipo_dato,
       c.CHARACTER_MAXIMUM_LENGTH AS longitud,
       c.IS_NULLABLE AS permite_nulos,
       c.COLUMN_DEFAULT AS valor_predeterminado,
       CASE WHEN c.COLUMN_KEY = 'PRI' THEN 'SI' ELSE 'NO' END AS clave_primaria,
       CASE WHEN EXISTS (
           SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k
           WHERE k.TABLE_SCHEMA = c.TABLE_SCHEMA
             AND k.TABLE_NAME = c.TABLE_NAME
             AND k.COLUMN_NAME = c.COLUMN_NAME
             AND k.REFERENCED_TABLE_NAME IS NOT NULL
       ) THEN 'SI' ELSE 'NO' END AS clave_foranea
FROM information_schema.COLUMNS c
JOIN information_schema.TABLES t
  ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
WHERE c.TABLE_SCHEMA = DATABASE() AND t.TABLE_TYPE = 'BASE TABLE'
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;

-- RELACIONES Y REGLAS REFERENCIALES
SELECT k.TABLE_NAME AS tabla_origen,
       k.COLUMN_NAME AS columna_origen,
       k.REFERENCED_TABLE_NAME AS tabla_destino,
       k.REFERENCED_COLUMN_NAME AS columna_destino,
       r.UPDATE_RULE AS regla_actualizacion,
       r.DELETE_RULE AS regla_eliminacion
FROM information_schema.KEY_COLUMN_USAGE k
JOIN information_schema.REFERENTIAL_CONSTRAINTS r
  ON r.CONSTRAINT_SCHEMA = k.CONSTRAINT_SCHEMA
 AND r.CONSTRAINT_NAME = k.CONSTRAINT_NAME
 AND r.TABLE_NAME = k.TABLE_NAME
WHERE k.TABLE_SCHEMA = DATABASE()
  AND k.REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY k.TABLE_NAME, k.ORDINAL_POSITION;

-- RESTRICCIONES PK, FK, UNIQUE Y CHECK
SELECT TABLE_NAME AS tabla,
       CONSTRAINT_NAME AS restriccion,
       CONSTRAINT_TYPE AS tipo
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME;

-- COMPROBACION DEL CAMPO JSON
SELECT TABLE_NAME AS tabla, COLUMN_NAME AS columna, COLUMN_TYPE AS tipo
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'perfil' AND COLUMN_NAME = 'preferencias_json';

-- PRUEBA DE INSERCION Y LECTURA DE JSON
INSERT INTO estudiante(nombre, apellido, correo, password_hash)
VALUES ('Prueba', 'Pascualina', 'prueba_json_pascualina@example.org', 'hash_de_prueba');
SET @id_estudiante_prueba = LAST_INSERT_ID();
INSERT INTO perfil(id_estudiante, preferencias_json)
VALUES (@id_estudiante_prueba, '{"notificaciones":{"eventos":true},"dispositivo":{"tipo":"movil"}}');
SELECT id_estudiante, preferencias_json,
       JSON_UNQUOTE(JSON_EXTRACT(preferencias_json, '$.dispositivo.tipo')) AS tipo_dispositivo
FROM perfil
WHERE id_estudiante = @id_estudiante_prueba;