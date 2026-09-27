## bd1-redsocial-grupo3
## Modelo conceptual de la red social pascualina
### Integrantes del equipo 3
* Jose Daniel Vargas Henao
* Jesus David Vargas Henao

Diseño y formalización del *modelo lógico relacional* de base de datos para la Red Social Pascualina, estructurado en *Tercera Forma Normal (3FN)* a partir del modelo conceptual previo. La solución consolida la arquitectura lógica mediante un diagrama relacional formal, esquema de claves, diccionario de datos y matriz de integridad.

### La solución soporta 15 tablas organizadas en cinco módulos funcionales[cite: 4]:
* *Perfiles Estudiantiles y Preferencias:* Entidades ESTUDIANTE y PERFIL (relación 1:1), junto a las tablas asociativas ESTUDIANTE_HABILIDAD y ESTUDIANTE_INTERES que normalizan atributos multivaluados en 3FN[cite: 4].
* *Red de Contactos y Mentorías:* Relaciones reflexivas resueltas en las tablas intermedias SEGUIR (seguidor/seguido) y MENTORIA (mentor/aprendiz) con claves primarias compuestas[cite: 4].
* *Muro e Interacción Social:* Publicación de contenidos con la tabla PUBLICACION e interacciones mediante COMENTARIO y REACCION (asociación de estudiante con publicación)[cite: 4].
* *Grupos de Estudio y Comunidades:* Registro de comunidades en GRUPO (con clave foránea al creador) y control de miembros mediante MIEMBRO_GRUPO[cite: 4].
* *Gestión de Eventos:* Planificación de actividades académicas y sociales mediante EVENTO y seguimiento de participación en ASISTENTE_EVENTO[cite: 4].
