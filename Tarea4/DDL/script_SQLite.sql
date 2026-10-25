PRAGMA foreign_keys = ON;

-- PASCUALINA: MODELO FISICO SQLITE (15 TABLAS)
-- Ejecutar en una base de datos nueva.

CREATE TABLE estudiante (
 id_estudiante INTEGER PRIMARY KEY,
 nombre TEXT NOT NULL,
 apellido TEXT NOT NULL,
 correo TEXT NOT NULL UNIQUE,
 password_hash TEXT NOT NULL,
 fecha_registro TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 ultima_actividad TEXT,
 estado TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo','inactivo','suspendido'))
);

CREATE TABLE perfil (
 id_perfil INTEGER PRIMARY KEY,
 id_estudiante INTEGER NOT NULL UNIQUE,
 area_estudio TEXT,
 biografia TEXT,
 programa TEXT,
 semestre INTEGER CHECK (semestre IS NULL OR semestre >= 1),
 ciudad TEXT,
 desorg_perfil TEXT,
 fecha_actualizacion TEXT DEFAULT CURRENT_TIMESTAMP,
 preferencias_json TEXT CHECK (preferencias_json IS NULL OR (json_valid(preferencias_json) AND CASE WHEN json_valid(preferencias_json) THEN json_type(preferencias_json) = 'object' ELSE 0 END)),
 FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE habilidad (id_habilidad INTEGER PRIMARY KEY, nombre TEXT NOT NULL, descripcion TEXT);
CREATE TABLE interes (id_interes INTEGER PRIMARY KEY, nombre TEXT NOT NULL, descripcion TEXT);

CREATE TABLE seguir (
 id_seguidor INTEGER NOT NULL,
 id_seguido INTEGER NOT NULL,
 fecha_seguimiento TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id_seguidor, id_seguido),
 CHECK (id_seguidor <> id_seguido),
 FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE mentoria (
 id_mentor INTEGER NOT NULL,
 id_aprendiz INTEGER NOT NULL,
 fecha_seguimiento TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id_mentor, id_aprendiz),
 CHECK (id_mentor <> id_aprendiz),
 FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY (id_aprendiz) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE publicacion (
 id_publicacion INTEGER PRIMARY KEY,
 id_estudiante INTEGER NOT NULL,
 contenido TEXT NOT NULL,
 tipo TEXT,
 fecha_publicacion TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE miembro_grupo (
 id_estudiante INTEGER NOT NULL,
 id_grupo INTEGER NOT NULL,
 fecha_ingreso TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 rol TEXT,
 PRIMARY KEY (id_estudiante,id_grupo),
 FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE evento (
 id_evento INTEGER PRIMARY KEY,
 id_grupo INTEGER NOT NULL,
 nombre TEXT NOT NULL,
 descripcion TEXT,
 fecha_inicio TEXT NOT NULL,
 fecha_fin TEXT,
 lugar TEXT,
 modalidad TEXT,
 organizador TEXT,
 fecha_creacion TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
 FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE comentario (
 id_comentario INTEGER PRIMARY KEY,
 id_publicacion INTEGER NOT NULL,
 id_estudiante INTEGER NOT NULL,
 comentario TEXT NOT NULL,
 fecha_comentario TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE reaccion (
 id_estudiante INTEGER NOT NULL,
 id_publicacion INTEGER NOT NULL,
 tipo_reaccion TEXT NOT NULL,
 fecha TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id_estudiante,id_publicacion),
 FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE asistente_evento (
 id_estudiante INTEGER NOT NULL,
 id_evento INTEGER NOT NULL,
 estado TEXT,
 fecha_registro TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id_estudiante,id_evento),
 FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE estudiante_habilidad (
 id_estudiante INTEGER NOT NULL,
 id_habilidad INTEGER NOT NULL,
 nivel TEXT,
 fecha_agregado TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id_estudiante,id_habilidad),
 FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE estudiante_interes (
 id_estudiante INTEGER NOT NULL,
 id_interes INTEGER NOT NULL,
 fecha_agregado TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id_estudiante,id_interes),
 FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE,
 FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON DELETE CASCADE ON UPDATE CASCADE
);

-- RESULTADO 1: VERIFICACION
SELECT COUNT(*) AS total_tablas FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%';

-- RESULTADO 2: DICCIONARIO DE COLUMNAS (formato compacto)
SELECT m.name AS tabla, p.cid + 1 AS num, p.name AS columna,
       p.type AS tipo, CASE WHEN p."notnull" = 1 OR p.pk > 0 THEN 'NO' ELSE 'SI' END AS nulo,
       CASE WHEN p.pk > 0 THEN 'PK' ELSE '' END AS pk,
       CASE WHEN EXISTS (SELECT 1 FROM pragma_foreign_key_list(m.name) f WHERE f."from" = p.name) THEN 'FK' ELSE '' END AS fk,
       COALESCE(p.dflt_value,'') AS defecto
FROM sqlite_master AS m
JOIN pragma_table_info(m.name) AS p
WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%'
ORDER BY m.name,p.cid;

-- RESULTADO 3: RELACIONES
SELECT m.name AS tabla, f."from" AS columna, f."table" AS referencia,
       f."to" AS col_ref, f.on_update AS actualiza, f.on_delete AS elimina
FROM sqlite_master AS m
JOIN pragma_foreign_key_list(m.name) AS f
WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%'
ORDER BY m.name,f.id;

-- RESULTADO 4: RESTRICCIONES (SQL de definicion, fuente de CHECK, UNIQUE, PK y FK)
SELECT name AS tabla, sql AS definicion_sql
FROM sqlite_master
WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
ORDER BY name;

-- RESULTADO 5: INDICES Y UNICIDAD
SELECT m.name AS tabla, i.name AS indice, i."unique" AS unico, i.origin AS origen
FROM sqlite_master AS m
JOIN pragma_index_list(m.name) AS i
WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%'
ORDER BY m.name,i.name;

-- PRUEBA JSON (sin insertar registros)
SELECT json_valid('{"notificaciones":true,"tema":"lila"}') AS json_valido,
       json_extract('{"notificaciones":true,"tema":"lila"}', '$.tema') AS tema;