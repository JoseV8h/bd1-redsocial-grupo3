-- Catalogo principal de estudiantes; correo unico y estado controlado.
CREATE TABLE estudiante (
 id_estudiante INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 apellido VARCHAR(100) NOT NULL,
 correo VARCHAR(254) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 ultima_actividad TIMESTAMP,
 estado VARCHAR(20) NOT NULL DEFAULT 'activo',
 CONSTRAINT ck_estudiante_estado CHECK (estado IN ('activo','inactivo','suspendido'))
);
-- Perfil: uno por estudiante (UNIQUE en la FK implementa 1:1).
CREATE TABLE perfil (
 id_perfil INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 id_estudiante INTEGER NOT NULL UNIQUE,
 area_estudio VARCHAR(120), biografia TEXT, programa VARCHAR(120),
 semestre INTEGER, ciudad VARCHAR(100), desorg_perfil TEXT,
 fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT ck_perfil_semestre CHECK (semestre IS NULL OR semestre >= 1),
 CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
 ON UPDATE CASCADE ON DELETE CASCADE
);
-- Catalogo de habilidades.
CREATE TABLE habilidad (
 id_habilidad INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL, descripcion TEXT
);
-- Catalogo de intereses.
CREATE TABLE interes (
 id_interes INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL, descripcion TEXT
);
-- Seguimiento entre estudiantes: PK compuesta impide duplicar la pareja.
CREATE TABLE seguir (
 id_seguidor INTEGER NOT NULL, id_seguido INTEGER NOT NULL,
 fecha_seguimiento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_seguir PRIMARY KEY (id_seguidor,id_seguido),
 CONSTRAINT ck_seguir_distintos CHECK (id_seguidor <> id_seguido),
 CONSTRAINT fk_seguir_seguidor FOREIGN KEY (id_seguidor) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_seguir_seguido FOREIGN KEY (id_seguido) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Mentorias: PK compuesta de mentor y aprendiz.
CREATE TABLE mentoria (
 id_mentor INTEGER NOT NULL, id_aprendiz INTEGER NOT NULL,
 fecha_seguimiento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_mentoria PRIMARY KEY (id_mentor,id_aprendiz),
 CONSTRAINT ck_mentoria_distintos CHECK (id_mentor <> id_aprendiz),
 CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_mentoria_aprendiz FOREIGN KEY (id_aprendiz) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Grupo: el creador debe ser un estudiante existente.
CREATE TABLE grupo (
 id_grupo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 creador_id INTEGER NOT NULL, nombre VARCHAR(120) NOT NULL,
 descripcion TEXT, tipo VARCHAR(50),
 fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 estado VARCHAR(20) NOT NULL DEFAULT 'activo',
 CONSTRAINT ck_grupo_estado CHECK (estado IN ('activo','inactivo','cerrado')),
 CONSTRAINT fk_grupo_creador FOREIGN KEY (creador_id) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE RESTRICT
);
-- Publicacion: autor existente.
CREATE TABLE publicacion (
 id_publicacion INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 id_estudiante INTEGER NOT NULL, contenido TEXT NOT NULL,
 tipo VARCHAR(50), fecha_publicacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Interseccion estudiante-grupo, con PK compuesta.
CREATE TABLE miembro_grupo (
 id_estudiante INTEGER NOT NULL, id_grupo INTEGER NOT NULL,
 fecha_ingreso TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, rol VARCHAR(50),
 CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_estudiante,id_grupo),
 CONSTRAINT fk_miembro_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_miembro_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Evento: cada evento pertenece a un grupo.
CREATE TABLE evento (
 id_evento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 id_grupo INTEGER NOT NULL, nombre VARCHAR(120) NOT NULL,
 descripcion TEXT, fecha_inicio TIMESTAMP NOT NULL, fecha_fin TIMESTAMP,
 lugar VARCHAR(150), modalidad VARCHAR(50), organizador VARCHAR(120),
 fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT ck_evento_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
 CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Comentario: depende de publicacion y estudiante.
CREATE TABLE comentario (
 id_comentario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 id_publicacion INTEGER NOT NULL, id_estudiante INTEGER NOT NULL,
 comentario TEXT NOT NULL, fecha_comentario TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Reaccion: una por estudiante y publicacion, segun PK compuesta del diagrama.
CREATE TABLE reaccion (
 id_estudiante INTEGER NOT NULL, id_publicacion INTEGER NOT NULL,
 tipo_reaccion VARCHAR(50) NOT NULL, fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_reaccion PRIMARY KEY (id_estudiante,id_publicacion),
 CONSTRAINT fk_reaccion_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_reaccion_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion(id_publicacion) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Asistencia a eventos: PK compuesta evita inscripciones repetidas.
CREATE TABLE asistente_evento (
 id_estudiante INTEGER NOT NULL, id_evento INTEGER NOT NULL,
 estado VARCHAR(50), fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_asistente_evento PRIMARY KEY (id_estudiante,id_evento),
 CONSTRAINT fk_asistente_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_asistente_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Habilidades por estudiante: tabla puente N:M.
CREATE TABLE estudiante_habilidad (
 id_estudiante INTEGER NOT NULL, id_habilidad INTEGER NOT NULL,
 nivel VARCHAR(50), fecha_agregado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_estudiante_habilidad PRIMARY KEY (id_estudiante,id_habilidad),
 CONSTRAINT fk_eh_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_eh_habilidad FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Intereses por estudiante: tabla puente N:M.
CREATE TABLE estudiante_interes (
 id_estudiante INTEGER NOT NULL, id_interes INTEGER NOT NULL,
 fecha_agregado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT pk_estudiante_interes PRIMARY KEY (id_estudiante,id_interes),
 CONSTRAINT fk_ei_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_ei_interes FOREIGN KEY (id_interes) REFERENCES interes(id_interes) ON UPDATE CASCADE ON DELETE CASCADE
);
COMMIT;

