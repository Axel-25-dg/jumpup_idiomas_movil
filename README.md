Voy a leer los archivos de views y serializers para darte el informe más completo posible.

Tengo toda la información necesaria. Ahora te genero el informe completo.

---

# Informe Completo: 57 Tablas, APIs y Lógica para la App Móvil

## ÍNDICE
1. [Módulo de Autenticación y Usuarios](#1-autenticación-y-usuarios)
2. [Módulo de Contenido Educativo](#2-contenido-educativo)
3. [Módulo de Progreso y Gamificación](#3-progreso-y-gamificación)
4. [Módulo de Aulas Virtuales](#4-aulas-virtuales)
5. [Módulo de Certificados](#5-certificados)
6. [Módulo de E-Commerce / Ventas](#6-e-commerce)
7. [Módulo de Mensajería](#7-mensajería)
8. [Módulo de Foro](#8-foro)
9. [Módulo de Feed Social](#9-feed-social)
10. [Módulo de Sesiones en Vivo](#10-sesiones-en-vivo)
11. [Módulo de Notificaciones](#11-notificaciones)
12. [Módulo de Multimedia](#12-multimedia)
13. [Módulo de Seguridad](#13-seguridad-y-dispositivos)
14. [Módulo de Sistema](#14-sistema-admin)
15. [WebSockets](#15-websockets)
16. [Flujos clave para Flutter](#16-flujos-clave-para-flutter)

---

## 1. Autenticación y Usuarios

### Tablas involucradas
| Tabla | Modelo | App |
|---|---|---|
| `learning_role` | `Role` | learning |
| `learning_user` | `User` | learning |
| `learning_userprofile` | `UserProfile` | learning |
| `password_resets` | `PasswordReset` | seguridad_acceso |
| `login_attempts` | `LoginAttempt` | seguridad_acceso |
| `active_sessions` | `ActiveSession` | seguridad_acceso |
| `blocked_ips` | `BlockedIp` | seguridad_acceso |
| `api_tokens` | `ApiToken` | seguridad_acceso |
| `biometric_devices` | `BiometricDevice` | seguridad_acceso |

### Campos exactos

**`Role`** → `id`, `name` (`admin`/`teacher`/`student`)

**`User`** → `id`, `username`, `email` *(único)*, `first_name`, `last_name`, `role` (FK), `is_staff`, `is_superuser`, `is_active`, `created_at`, `updated_at`, `deleted_at`

**`UserProfile`** → `id`, `user` (OneToOne), `first_name`, `last_name`, `avatar` *(file)*, `avatar_url` *(URL externa)*, `native_language`, `timezone`, `languages_learning` (M2M → Language), `languages_teaching` (M2M → Language)

### APIs

#### `POST /api/auth/register/` — Sin auth
```json
// REQUEST
{
  "username": "juan123",
  "email": "juan@test.com",
  "password": "Clave1234!",
  "password2": "Clave1234!",
  "first_name": "Juan",
  "last_name": "Pérez",
  "role": "student"   // o "teacher"
}

// RESPONSE 201
{
  "message": "Usuario registrado exitosamente.",
  "access": "eyJhbGci...",
  "refresh": "eyJhbGci...",
  "user": {
    "id": 5,
    "username": "juan123",
    "email": "juan@test.com",
    "role": "student",
    "is_staff": false,
    "is_superuser": false
  }
}
```
**Lógica:** crea User + UserProfile + UserStats automáticamente (via signal). Envía email de bienvenida. Devuelve JWT listo para usar.

#### `POST /api/auth/login/` — Sin auth
```json
// REQUEST
{
  "email": "juan@test.com",
  "password": "Clave1234!",
  "remember_me": false   // true = refresh dura 30 días en vez de 7
}

// RESPONSE 200
{
  "access": "eyJhbGci...",
  "refresh": "eyJhbGci...",
  "user": {
    "id": 5,
    "username": "juan123",
    "email": "juan@test.com",
    "role": "student",
    "is_staff": false,
    "is_superuser": false
  }
}
```
**Importante:** el `role` viene en el body Y en el payload del JWT. En Flutter usa el body directamente, no necesitas decodificar el JWT.

#### `POST /api/auth/token/refresh/` — Sin auth
```json
// REQUEST
{ "refresh": "eyJhbGci..." }

// RESPONSE 200
{ "access": "eyJhbGci...", "refresh": "eyJhbGci..." }
```

#### `GET /api/auth/me/` — Con auth
```json
// RESPONSE 200
{
  "id": 5,
  "username": "juan123",
  "email": "juan@test.com",
  "first_name": "Juan",
  "last_name": "Pérez",
  "role": { "id": 3, "name": "student" },
  "profile": {
    "id": 5,
    "first_name": "Juan",
    "last_name": "Pérez",
    "avatar": null,
    "avatar_url": "https://...",
    "native_language": "es",
    "timezone": "America/Guayaquil",
    "languages_learning": [1, 2],
    "languages_learning_details": [
      { "id": 1, "name": "English", "code": "EN", "flag_icon_url": "..." }
    ],
    "languages_teaching": [],
    "languages_teaching_details": []
  },
  "is_staff": false,
  "is_superuser": false,
  "is_active": true,
  "created_at": "2024-01-15T10:30:00Z"
}
```

#### `PATCH /api/auth/me/` — Con auth
Actualiza `first_name`, `last_name` y los campos del perfil anidado. Para subir avatar usa `multipart/form-data` con el campo `profile.avatar`.

#### `PATCH /api/auth/profile/update-languages/` — Con auth
```json
// Estudiante
{ "languages_learning": [1, 3] }

// Profesor
{ "languages_teaching": [2] }
```

#### Reset de contraseña (2 pasos)
```json
// Paso 1: POST /api/auth/password-reset/
{ "email": "juan@test.com" }
// → envía PIN de 6 dígitos al correo, válido 15 minutos
// RESPONSE: { "message": "Si el correo existe, recibirás un PIN..." }

// Paso 2: POST /api/auth/password-reset-confirm/
{
  "email": "juan@test.com",
  "code": "123456",
  "password": "NuevaClave1!",
  "password2": "NuevaClave1!"
}
// RESPONSE: { "message": "Contraseña restablecida exitosamente." }
```

#### Login biométrico
```json
// Paso 1: registrar dispositivo (usuario ya autenticado)
POST /api/auth/biometric/register/
{ "device_id": "UUID-del-dispositivo" }
// RESPONSE: { "biometric_token": "abc123hex...", "message": "..." }
// Guardar biometric_token de forma segura en el dispositivo

// Paso 2: login sin contraseña
POST /api/auth/biometric/login/
{ "device_id": "UUID-del-dispositivo", "biometric_token": "abc123hex..." }
// RESPONSE: igual que login normal (access + refresh + user)
```

---

## 2. Contenido Educativo

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_language` | `Language` |
| `learning_course` | `Course` |
| `learning_module` | `Module` |
| `learning_lesson` | `Lesson` |
| `learning_exercise` | `Exercise` |

### Campos

**`Language`** → `id`, `name`, `code` (ej: "EN"), `flag_icon_url`

**`Course`** → `id`, `language` (FK), `language_name`, `title`, `slug`, `description`, `difficulty_level` (A1–C2), `image_url`, `is_active`, `created_at`

**`Module`** → `id`, `course` (FK), `course_title`, `title`, `slug`, `order`, `is_active`

**`Lesson`** → `id`, `module` (FK), `module_title`, `title`, `content_type` (video/text/interactive/audio), `order`, `xp_reward`, `is_active`

**`Exercise`** → Para estudiantes: `id`, `lesson`, `lesson_title`, `question_text`, `exercise_type`, `options`, `audio_url` *(sin `correct_answer`)*. Para staff: incluye `correct_answer`.

### APIs

#### Idiomas
```
GET /api/languages/              → lista todos
GET /api/languages/?search=eng   → busca por nombre/código
GET /api/languages/{id}/         → detalle
```

#### Cursos
```
GET /api/courses/                                  → todos los cursos
GET /api/courses/?language=1                       → por idioma
GET /api/courses/?difficulty_level=A1              → por nivel
GET /api/courses/?language=1&difficulty_level=B1   → combinado
GET /api/courses/?search=english                   → búsqueda
GET /api/courses/{id}/                             → detalle
```

#### Módulos
```
GET /api/modules/?course=5    → módulos de un curso específico
GET /api/modules/{id}/        → detalle
```

#### Lecciones
```
GET /api/lessons/?module=3              → lecciones de un módulo
GET /api/lessons/?content_type=video    → por tipo
GET /api/lessons/{id}/                  → detalle
GET /api/lessons/{id}/stats/            → estadísticas (éxito, score promedio)
```

**`/api/lessons/{id}/stats/` responde:**
```json
{
  "lesson_id": 3,
  "lesson_title": "Saludos básicos",
  "content_type": "interactive",
  "total_attempts": 45,
  "completed": 38,
  "success_rate": 84.4,
  "average_score": 76.2
}
```

#### Ejercicios
```
GET /api/exercises/?lesson=7               → ejercicios de la lección
GET /api/exercises/?exercise_type=match    → por tipo
GET /api/exercises/{id}/                   → detalle (sin correct_answer para estudiantes)
```

#### Validar respuesta de ejercicio
```json
POST /api/exercises/{id}/validar/
{ "respuesta_usuario": "Hello" }

// RESPONSE
{
  "es_correcto": true,
  "retroalimentacion": "¡Excelente trabajo! Respuesta correcta."
}
// Si es correcto: suma 10 XP automáticamente y actualiza la racha
```

**Tipos de ejercicio y cómo mostrarlos en Flutter:**
| `exercise_type` | UI recomendada |
|---|---|
| `multiple_choice` | Botones con las opciones del campo `options` (JSON array) |
| `translate` | Campo de texto libre |
| `listen` | Reproduce `audio_url` → campo de texto |
| `fill_blank` | Texto con espacio en blanco |
| `match` | Arrastrar y soltar (dos columnas) |

---

## 3. Progreso y Gamificación

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_userprogress` | `UserProgress` |
| `learning_userstats` | `UserStats` |
| `learning_achievement` | `Achievement` |
| `learning_userachievement` | `UserAchievement` |

### Campos

**`UserProgress`** → `id`, `user`, `user_email`, `lesson`, `lesson_title`, `lesson_xp`, `course_title`, `language_code`, `status` (in_progress/completed), `score` (0-100), `completed_at`

**`UserStats`** → `id`, `user`, `total_xp`, `level` *(calculado: xp//100+1)*, `xp_for_next_level`, `xp_progress_in_level` *(xp%100)*, `current_streak`, `longest_streak`, `last_activity_date`

**`Achievement`** → `id`, `name`, `description`, `icon_url`, `required_xp`, `trigger_type`, `required_value`, `is_active`

**`UserAchievement`** → `id`, `user`, `achievement` *(objeto completo)*, `unlocked_at`

### APIs

#### Reportar progreso (el más importante)
```json
POST /api/progress/
{
  "lesson": 5,
  "status": "completed",
  "score": 90
}
// RESPONSE 201
{
  "id": 12,
  "user": 5,
  "user_email": "juan@test.com",
  "lesson": 5,
  "lesson_title": "Saludos básicos",
  "lesson_xp": 20,
  "course_title": "English A1",
  "language_code": "EN",
  "status": "completed",
  "score": 90,
  "completed_at": "2024-01-15T10:30:00Z"
}
```
**Lógica automática que dispara este POST:**
1. Se suma `lesson.xp_reward` al `UserStats.total_xp`
2. Se actualiza la racha diaria
3. Se verifican todos los logros → los que cumple se desbloquean
4. Se envía notificación WebSocket por cada logro nuevo
5. El estudiante recibe en tiempo real: `🏅 Logro: Primer Paso`

#### Resumen de progreso
```
GET /api/progress/summary/
```
```json
{
  "total_lessons": 120,
  "lessons_completed": 45,
  "lessons_in_progress": 3,
  "courses_started": 2,
  "courses_completed": 1,
  "percentage": 37.5,
  "total_xp": 900,
  "level": 10,
  "xp_for_next_level": 1000,
  "xp_progress_in_level": 0,
  "current_streak": 5,
  "longest_streak": 12,
  "last_activity_date": "2024-01-15",
  "achievements_count": 3
}
```

#### Progreso por idioma
```
GET /api/progress/by-language/
```
```json
[
  {
    "language_id": 1,
    "language_name": "English",
    "language_code": "EN",
    "flag_url": "https://...",
    "total_lessons": 60,
    "completed": 30,
    "percentage": 50.0
  }
]
```

#### Stats del usuario
```
GET /api/stats/
```
```json
{
  "id": 5,
  "user": 5,
  "user_email": "juan@test.com",
  "total_xp": 900,
  "level": 10,
  "xp_for_next_level": 1000,
  "xp_progress_in_level": 0,
  "current_streak": 5,
  "longest_streak": 12,
  "last_activity_date": "2024-01-15"
}
```

#### Ranking
```
GET /api/ranking/
GET /api/ranking/?language=EN
```
```json
{
  "my_position": 15,
  "my_xp": 900,
  "my_level": 10,
  "ranking": [
    {
      "position": 1,
      "user_id": 3,
      "username": "maria99",
      "email": "maria@test.com",
      "total_xp": 2500,
      "level": 26,
      "current_streak": 30,
      "longest_streak": 45,
      "is_me": false
    }
  ]
}
```

#### Logros
```
GET /api/achievements/                   → catálogo completo
GET /api/achievements/?trigger_type=xp  → filtrar por tipo
GET /api/my-achievements/                → mis logros desbloqueados
```

#### Dashboards
```
GET /api/dashboard/student/
```
```json
{
  "total_xp": 900,
  "level": 10,
  "xp_progress": 0,
  "xp_for_next_level": 1000,
  "current_streak": 5,
  "longest_streak": 12,
  "progress_percentage": 37.5,
  "completed_lessons": 45,
  "total_lessons": 120,
  "achievements_count": 3,
  "certificates_count": 1,
  "active_classrooms": 2
}
```

---

## 4. Aulas Virtuales

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_classroom` | `Classroom` |
| `learning_classroomenrollment` | `ClassroomEnrollment` |

### Campos

**`Classroom`** → `id`, `uuid`, `teacher` (FK), `course` (FK), `name`, `description`, `access_code` (8 chars, auto), `is_active`, `created_at`

**`ClassroomEnrollment`** → `id`, `classroom` (FK), `student` (FK), `enrolled_at`, `is_active`

### APIs

#### Ver aulas (por rol)
```
GET /api/classrooms/     → teacher: sus aulas | admin: todas | student: las suyas
GET /api/classrooms/?course=5   → filtrar por curso
GET /api/classrooms/?search=ingles
GET /api/classrooms/{id}/       → detalle con lista de estudiantes
GET /api/classrooms/mine/       → mis aulas como estudiante
```

#### Crear aula (teacher/admin)
```json
POST /api/classrooms/
{
  "course": 3,
  "name": "Inglés A1 - Grupo Mañana",
  "description": "Clase virtual de inglés básico"
}
// RESPONSE: incluye access_code generado automáticamente "A3FX9K2T"
```

#### Unirse a un aula (student)
```json
POST /api/classrooms/join/
{ "access_code": "A3FX9K2T" }
// RESPONSE: datos del aula
// Lógica: si ya estaba inscrito, reactiva la inscripción
```

#### Expulsar estudiante (teacher/admin)
```json
POST /api/classrooms/{id}/remove-student/
{ "student_id": 5 }
// RESPONSE: { "detail": "Estudiante removido de la clase." }
```

---

## 5. Certificados

### Tabla: `learning_certificate`

### Campos
`id`, `uuid`, `student` (FK), `issued_by` (FK), `level` (A1–C2), `title`, `description`, `certificate_code` (ej: `CERT-A1-3F9K2T`), `certificate_file` (FK MediaFile), `status` (pending/issued/revoked), `issued_at`, `created_at`

**Restricción:** solo 1 certificado por nivel por estudiante (unique_together).

### APIs

```
GET /api/certificates/             → student: los suyos | teacher: los que emitió | admin: todos
GET /api/certificates/?level=A1    → filtrar por nivel
GET /api/certificates/?status=issued
GET /api/certificates/{id}/        → detalle

POST /api/certificates/            → crear (teacher/admin)
{
  "student": 5,
  "level": "B1",
  "title": "Certificado de Inglés B1 — JumpUp"
}

PATCH /api/certificates/{id}/issue/   → emitir (cambia pending→issued, envía email)
PATCH /api/certificates/{id}/revoke/  → revocar

// Verificación PÚBLICA (sin autenticación)
GET /api/certificates/verify/CERT-A1-3F9K2T/
```
```json
// Respuesta de verificación pública
{
  "valid": true,
  "certificate_code": "CERT-A1-3F9K2T",
  "student_name": "Juan Pérez",
  "level": "A1",
  "title": "Certificado de Inglés A1",
  "status": "issued",
  "issued_at": "2024-01-15T10:30:00Z"
}
```

---

## 6. E-Commerce

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_catalogo` | `Catalogo` |
| `learning_carrito` | `Carrito` |
| `learning_carritoitem` | `CarritoItem` |
| `learning_ordencompra` | `OrdenCompra` → en código se llama `Orden` |
| `learning_ordendetalle` | `OrdenDetalle` |

### Campos

**`Catalogo`** → `id`, `titulo`, `tipo` (curso/libro), `precio`, `contenido_url`, `curso` (FK), `curso_info` (objeto), `creado_at`

**`Carrito`** → `id`, `estudiante_email`, `items` (array), `creado_at`

**`OrdenCompra`** → `id`, `estudiante_email`, `total`, `estado` (pendiente/pagada/cancelada), `detalles` (array), `fecha_creacion`

### APIs y flujo completo

```
1. Ver catálogo:
GET /api/catalogo/
→ [{ "id":1, "titulo":"Inglés A1 Completo", "tipo":"curso", "precio":"25.00", "curso_info":{...} }]

2. Ver carrito actual:
GET /api/carrito/
→ { "items": [...], "estudiante_email": "..." }

3. Agregar al carrito:
POST /api/carrito/agregar/
{ "producto_id": 1, "cantidad": 1 }

4. Eliminar del carrito:
POST /api/carrito/eliminar/
{ "producto_id": 1 }

5. Comprar (crea la orden y vacía el carrito):
POST /api/carrito/comprar/
→ devuelve la OrdenCompra creada con estado "pagada"
```

**Lógica al comprar:** crea `OrdenCompra` + `OrdenDetalle` por cada item, vacía el carrito. La orden se crea directamente como `pagada`. El signal `on_order_compra_approved` notifica al profesor del curso por WebSocket y email.

```
Ver mis órdenes:
GET /api/ordenes-compra/       → student: sus órdenes | admin: todas
GET /api/ordenes-compra/{id}/  → detalle
```

---

## 7. Mensajería

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_messagethread` | `MessageThread` |
| `learning_message` | `Message` |
| `learning_messageattachment` | `MessageAttachment` |

### Campos

**`MessageThread`** → `id`, `participants` (M2M), `subject`, `created_at`, `updated_at`, `is_active`

**`Message`** → `id`, `thread` (FK), `sender` (FK), `body`, `is_read`, `read_at`, `created_at`

**`MessageAttachment`** → `id`, `message` (FK), `file_url`, `attachment_type` (image/audio/document/other), `filename`

### APIs

```
GET /api/threads/           → mis hilos activos
POST /api/threads/          → crear hilo
DELETE /api/threads/{id}/   → desactivar hilo

GET  /api/threads/{id}/messages/   → mensajes (los marca como leídos automáticamente)
POST /api/threads/{id}/messages/   → enviar mensaje REST (también notifica por WS)

POST /api/messages/{id}/read/      → marcar mensaje específico como leído
```

```json
// Crear hilo con otro usuario
POST /api/threads/
{
  "subject": "Consulta sobre gramática",
  "participant_ids": [3]   // IDs de otros participantes
}

// Crear hilo con el Tutor IA
POST /api/threads/
{
  "subject": "Tutor IA",
  "participant_ids": []
}
```

**Lógica al enviar mensaje via REST:** envía notificación WebSocket a cada participante del hilo con `type: "message"`.

**Para chat en tiempo real → usar WebSocket** `ws/chat/{thread_id}/` (ver sección 15).

---

## 8. Foro

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_forumcategory` | `ForumCategory` |
| `learning_forumthread` | `ForumThread` |
| `learning_forumpost` | `ForumPost` |
| `learning_forumreaction` | `ForumReaction` |
| `learning_forumreport` | `ForumReport` |

### Campos

**`ForumCategory`** → `id`, `name`, `description`, `icon` (emoji o nombre), `order`, `is_active`

**`ForumThread`** → `id`, `category` (FK), `author` (FK), `title`, `body`, `is_pinned`, `is_closed`, `views`, `created_at`, `updated_at`

**`ForumPost`** → `id`, `thread` (FK), `author` (FK), `parent` (FK self, nullable), `body`, `is_deleted`, `created_at`

**`ForumReaction`** → `id`, `user`, `post`, `reaction` (like/love/helpful/confused)

**`ForumReport`** → `id`, `reporter`, `post`, `reason`, `status` (pending/reviewed/resolved)

### APIs

```
GET /api/forum-categories/            → categorías activas
GET /api/forum-categories/?search=    → buscar

GET /api/forum-threads/                     → todos los hilos
GET /api/forum-threads/?category=2          → por categoría
GET /api/forum-threads/?is_pinned=true      → fijados primero
GET /api/forum-threads/?search=gramática
GET /api/forum-threads/?ordering=-views     → más vistos
GET /api/forum-threads/{id}/                → detalle (incrementa vistas)

POST /api/forum-threads/
{ "category": 1, "title": "¿Cómo se usa el present perfect?", "body": "Hola..." }

// Solo admin:
POST /api/forum-threads/{id}/pin/     → fijar/desfijar
POST /api/forum-threads/{id}/close/   → cerrar/abrir

GET /api/forum-posts/?thread=5        → posts de un hilo
GET /api/forum-posts/?parent=12       → respuestas a un post (anidación)

POST /api/forum-posts/
{
  "thread": 5,
  "body": "Mi respuesta...",
  "parent": null   // o ID de otro post para anidar
}

// Reaccionar a un post (upsert — actualiza si ya existe)
POST /api/forum-reactions/
{ "post": 8, "reaction": "like" }   // like | love | helpful | confused

// Reportar post
POST /api/forum-reports/
{ "post": 8, "reason": "Contenido inapropiado" }
```

---

## 9. Feed Social

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_socialpost` | `SocialPost` |
| `learning_socialcomment` | `SocialComment` |
| `learning_socialreaction` | `SocialReaction` |

### Campos

**`SocialPost`** → `id`, `author` (FK), `post_type` (achievement/certificate/progress/xp/general), `content`, `image_url`, `is_public`, `created_at`

**`SocialComment`** → `id`, `post` (FK), `author` (FK), `body`, `created_at`

**`SocialReaction`** → `id`, `user`, `post`, `reaction` (like/love/clap/fire/star)

### APIs

```
GET /api/social-posts/               → feed público (publicaciones públicas + las mías)
GET /api/social-posts/mine/          → solo mis publicaciones
GET /api/social-posts/?post_type=achievement
GET /api/social-posts/{id}/          → detalle con comentarios y reacciones

POST /api/social-posts/
{
  "post_type": "achievement",
  "content": "¡Desbloqueé mi primer logro!",
  "image_url": "https://...",
  "is_public": true
}

GET /api/social-comments/?post=15    → comentarios de un post
POST /api/social-comments/
{ "post": 15, "body": "¡Felicitaciones!" }

// Reaccionar (upsert)
POST /api/social-reactions/
{ "post": 15, "reaction": "clap" }   // like | love | clap | fire | star

DELETE /api/social-reactions/{id}/   → quitar reacción
```

---

## 10. Sesiones en Vivo

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_livesession` | `LiveSession` |
| `learning_liveparticipant` | `LiveParticipant` |

### Campos

**`LiveSession`** → `id`, `teacher` (FK), `course` (FK), `title`, `description`, `scheduled_at`, `duration_min`, `meeting_url`, `status` (scheduled/live/ended/cancelled), `max_students`, `created_at`

**`LiveParticipant`** → `id`, `session` (FK), `student` (FK), `joined_at`, `left_at`, `is_active`

### Estados del ciclo de vida
```
scheduled → live → ended
    ↓
cancelled
```

Voy a leer todos los modelos y views que faltaron en el informe anterior.

Ahora tengo todo. Aquí está el informe completo de las **19 tablas y módulos faltantes**:

---

# Informe Completo — Parte 2: Las 19 Tablas Faltantes

---

## 10. Sesiones en Vivo (continuación)

### APIs completas

```
GET /api/live-sessions/                          → student: solo las de sus cursos inscritos
                                                    teacher/admin: todas
GET /api/live-sessions/?status=scheduled         → filtrar por estado
GET /api/live-sessions/?course=3                 → por curso
GET /api/live-sessions/?search=gramática
GET /api/live-sessions/{id}/                     → detalle con participantes
```

```json
// Crear sesión — solo teacher/admin
POST /api/live-sessions/
{
  "course": 3,
  "title": "Clase de gramática avanzada",
  "description": "Veremos el present perfect",
  "scheduled_at": "2025-08-10T18:00:00Z",
  "duration_min": 60,
  "meeting_url": "https://meet.google.com/abc-xyz",
  "max_students": 25
}
```

**Lógica al crear:** notifica automáticamente por WebSocket a todos los estudiantes inscritos en el curso.

```
POST /api/live-sessions/{id}/join/        → estudiante se une (verifica max_students)
POST /api/live-sessions/{id}/leave/       → registra left_at
POST /api/live-sessions/{id}/start/       → scheduled → live  (solo teacher)
POST /api/live-sessions/{id}/end/         → live → ended       (solo teacher)
GET  /api/live-sessions/{id}/participants/ → lista activa
DELETE /api/live-sessions/{id}/           → cancela (status → cancelled)
```

**Respuesta de `/join/`:**
```json
{
  "id": 12,
  "session": 5,
  "student": 8,
  "joined_at": "2025-08-10T18:02:00Z",
  "left_at": null,
  "is_active": true
}
```

---

## 11. Notificaciones

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_announcement` | `Announcement` |
| `learning_notification` | `Notification` |
| `learning_usernotificationpreference` | `UserNotificationPreference` |

### Campos exactos

**`Announcement`** → `id`, `author` (FK), `title`, `content`, `start_date`, `end_date`, `is_active`, `created_at`

**`Notification`** → `id`, `uuid`, `user` (FK), `title`, `message`, `type` (system/course/payment/certificate/subscription/message/forum/live_session), `type_display`, `is_read`, `created_at`, `updated_at`

**`UserNotificationPreference`** → `email_notifications` (bool), `app_notifications` (bool), `sms_notifications` (bool)

### APIs

```
GET /api/announcements/              → anuncios activos vigentes
GET /api/announcements/{id}/         → detalle

GET /api/notifications/              → mis notificaciones (más recientes primero)
GET /api/notifications/?is_read=false → solo no leídas
GET /api/notifications/?type=course   → por tipo
GET /api/notifications/?type=achievement
```

**Tipos de notificación válidos para el filtro `?type=`:**
`system` · `course` · `payment` · `certificate` · `subscription` · `message` · `forum` · `live_session`

```json
// Estructura de una notificación
{
  "id": 45,
  "uuid": "abc123-...",
  "user": 5,
  "title": "🏅 Logro desbloqueado: Primer Paso",
  "message": "Completaste tu primera lección",
  "type": "system",
  "type_display": "Sistema",
  "is_read": false,
  "created_at": "2025-01-15T10:30:00Z"
}

// Marcar una como leída
POST /api/notifications/{id}/read/
→ { "detail": "Notificación marcada como leída." }

// Marcar TODAS como leídas
POST /api/notifications/read-all/
→ { "detail": "12 notificaciones marcadas como leídas." }

// Obtener conteo de no leídas (para badge en la app)
GET /api/notifications/unread-count/
→ { "unread_count": 5 }
```

**Preferencias de notificación:**
```json
GET /api/preferences/
→ {
    "email_notifications": true,
    "app_notifications": true,
    "sms_notifications": false
  }

PATCH /api/preferences/{id}/
{ "sms_notifications": true }
```

---

## 12. Multimedia (MediaFile + MediaProgress)

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_mediafile` | `MediaFile` |
| `learning_mediaprogress` | `MediaProgress` |

### Campos exactos

**`MediaFile`** → `id`, `uuid`, `original_name`, `file` (campo de archivo), `mime_type`, `extension`, `size` (bytes), `width`, `height`, `file_url` *(calculado)*, `thumbnail_url` *(calculado)*, `storage_provider` (local/s3/cloudinary), `status` (uploaded/processing/active/deleted), `uploaded_by` (FK), `uploaded_by_email`, `created_at`

**`MediaProgress`** → `id`, `lesson` (FK), `lesson_title`, `position_sec` (segundos actuales), `duration_sec` (duración total), `completed` (bool), `percentage` *(calculado: position/duration×100)*, `last_watched`

### APIs

#### MediaFile — Subir y gestionar archivos
```
GET /api/media-files/                          → lista archivos (todos autenticados)
GET /api/media-files/?status=active
GET /api/media-files/?mime_type=image/jpeg
GET /api/media-files/?search=logo
GET /api/media-files/{id}/                     → detalle
```

```
// Subir archivo — multipart/form-data — solo teacher/admin
POST /api/media-files/
Content-Type: multipart/form-data

file = <binario del archivo>
```

**Respuesta al subir:**
```json
{
  "id": 22,
  "uuid": "abc123-...",
  "original_name": "portada_ingles.png",
  "mime_type": "image/webp",          // convertido automáticamente
  "extension": "webp",
  "size": 48200,                       // bytes
  "width": 800,
  "height": 600,
  "file_url": "https://.../media/...",
  "thumbnail_url": "https://.../thumbnails/...",
  "storage_provider": "local",
  "status": "active",
  "uploaded_by_email": "teacher@test.com",
  "created_at": "2025-01-15T10:30:00Z"
}
```

**Lógica automática al guardar:** calcula SHA-256 checksum (evita duplicados), convierte imagen a WebP 85% calidad máx 2048×2048, genera thumbnail 300×300 WebP al 70%.

```
DELETE /api/media-files/{id}/   → soft-delete (marca deleted_at, no borra físico)
```

#### MediaProgress — Progreso de video/audio

**Uso típico en Flutter:** cuando el usuario pausa un video, envía la posición actual. Al volver a abrir la lección, solicita reanudar desde donde lo dejó.

```json
// Registrar / actualizar posición (upsert por usuario+lección)
POST /api/media-progress/
{
  "lesson": 7,
  "position_sec": 145,
  "duration_sec": 320,
  "completed": false
}
// Si ya existe progreso para esa lección, lo ACTUALIZA en lugar de duplicar

// Actualizar solo la posición
PATCH /api/media-progress/{id}/
{ "position_sec": 200 }

// Reanudar lección — obtener posición guardada
GET /api/media-progress/resume/7/    // 7 = lesson_id
→ {
    "id": 3,
    "lesson": 7,
    "lesson_title": "Present Perfect",
    "position_sec": 145,
    "duration_sec": 320,
    "completed": false,
    "percentage": 45.3,
    "last_watched": "2025-01-15T10:30:00Z"
  }
// Si no hay progreso:
→ { "detail": "No hay progreso...", "position_sec": 0, "completed": false }
```

**Filtros:**
```
GET /api/media-progress/?lesson=7
GET /api/media-progress/?completed=false   → lecciones de video sin terminar
```

---

## 13. Recursos del Profesor (TeacherResource)

### Tabla: `learning_teacherresource`

### Campos exactos
`id`, `teacher` (FK), `teacher_email`, `course` (FK, **obligatorio**), `course_title`, `lesson` (FK, opcional), `lesson_title`, `title`, `description`, `resource_type` (pdf/audio/video/word/image/link/other), `resource_type_display`, `file_url`, `is_public`, `created_at`, `updated_at`

### APIs

```
GET /api/resources/                     → student: solo públicos | teacher: suyos + públicos | admin: todos
GET /api/resources/?resource_type=pdf
GET /api/resources/?course=3
GET /api/resources/?lesson=7
GET /api/resources/?is_public=true
GET /api/resources/?search=gramática
GET /api/resources/{id}/                → detalle
```

```json
// Crear recurso — solo teacher/admin
POST /api/resources/
{
  "course": 3,
  "lesson": 7,           // opcional
  "title": "Ejercicios Present Perfect",
  "description": "PDF con 20 ejercicios",
  "resource_type": "pdf",
  "file_url": "https://drive.google.com/...",
  "is_public": true
}
// Validación: si se indica lesson, debe pertenecer al course indicado
```

**Tipos de recurso para el filtro y la UI:**
| `resource_type` | Icono sugerido |
|---|---|
| `pdf` | 📄 |
| `audio` | 🎵 |
| `video` | 🎬 |
| `word` | 📝 |
| `image` | 🖼️ |
| `link` | 🔗 |
| `other` | 📦 |

---

## 14. Seguridad y Dispositivos

### Tablas (app `seguridad_acceso`)
| Tabla | Modelo | Campos |
|---|---|---|
| `password_resets` | `PasswordReset` | `id`, `user`, `token` (PIN 6 dígitos), `is_used`, `expires_at`, `created_at` |
| `login_attempts` | `LoginAttempt` | `id`, `user`, `email`, `ip_address`, `attempts`, `created_at` |
| `active_sessions` | `ActiveSession` | `id` (PK string), `user`, `device_name`, `browser`, `ip_address`, `last_activity`, `is_active` |
| `blocked_ips` | `BlockedIp` | `id`, `ip_address`, `reason`, `blocked_until`, `created_at` |
| `api_tokens` | `ApiToken` | `id`, `user`, `token`, `expires_at`, `is_active`, `created_at` |
| `biometric_devices` | `BiometricDevice` | `id`, `user`, `device_id`, `biometric_token`, `is_active`, `created_at`, `last_used` |

### Tablas (app `dispositivos_alertas`)
| Tabla | Modelo | Campos |
|---|---|---|
| `user_devices` | `UserDevice` | `id`, `user`, `device_name`, `operating_system`, `browser`, `last_login`, `is_trusted` |
| `user_locations` | `UserLocation` | `id`, `user`, `country`, `city`, `latitude`, `longitude`, `created_at` |
| `security_alerts` | `SecurityAlert` | `id`, `user`, `alert_type`, `description`, `severity` (LOW/MEDIUM/HIGH/CRITICAL), `created_at` |

**Estas tablas no tienen endpoints REST públicos en la app móvil.** Son gestionadas internamente por el backend o desde el admin de Django. La biometría sí tiene endpoints (ya documentados en el módulo de Autenticación).

---

## 15. Interacciones del Usuario

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_report` | `Report` |
| `learning_userfeedback` | `UserFeedback` |
| `learning_mediaasset` | `MediaAsset` |
| `learning_userfavorite` | `UserFavorite` |
| `learning_useractivitylog` | `UserActivityLog` |

### Campos exactos

**`Report`** → `id`, `user`, `report_type` (texto libre, ej: "Content Abuse"), `description`, `status` (OPEN/IN_PROGRESS/RESOLVED/REJECTED), `created_at`

**`UserFeedback`** → `id`, `user`, `subject`, `message`, `status` (PENDING/REVIEWED/ARCHIVED), `created_at`

**`MediaAsset`** → `id`, `uploaded_by`, `file_name`, `file_type` (MIME), `file_url`, `created_at`

**`UserFavorite`** → `id`, `user`, `course` (FK, nullable), `lesson` (FK, nullable), `created_at`

**`UserActivityLog`** → `id`, `user`, `module` (FK), `lesson` (FK), `created_at`

### APIs

```
// REPORTES — el usuario solo ve los suyos
GET /api/reports/
POST /api/reports/
{ "report_type": "Content Abuse", "description": "Este contenido es ofensivo" }

// FEEDBACK
GET /api/feedbacks/
POST /api/feedbacks/
{ "subject": "Sugerencia de mejora", "message": "Sería útil tener modo oscuro" }

// ASSETS (archivos subidos por el usuario, URL externa)
GET /api/media/
POST /api/media/
{ "file_name": "mi_imagen.jpg", "file_type": "image/jpeg", "file_url": "https://..." }

// FAVORITOS
GET /api/favorites/
POST /api/favorites/
{ "course": 3 }        // marcar curso favorito
POST /api/favorites/
{ "lesson": 7 }        // marcar lección favorita
DELETE /api/favorites/{id}/

// LOGS DE ACTIVIDAD
GET /api/activity-logs/
POST /api/activity-logs/
{ "module": 2, "lesson": 5 }    // registrar que el usuario visitó esta lección
```

**Nota de seguridad:** el campo `user` nunca se envía desde Flutter. El backend lo inyecta automáticamente desde el token JWT. Si lo envías, es ignorado.

---

## 16. Sistema Admin (solo administradores)

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_maintenancelog` | `MaintenanceLog` |
| `learning_backuphistory` | `BackupHistory` |

### Campos exactos

**`MaintenanceLog`** → `id`, `performed_by` (FK), `description`, `status` (SUCCESS/FAILED/IN_PROGRESS), `created_at`

**`BackupHistory`** → `id`, `backup_name`, `file_path`, `size` (bytes), `created_at`

### APIs (requieren `is_staff=true`)

```json
GET  /api/maintenance/
POST /api/maintenance/
{
  "description": "Limpieza de logs antiguos",
  "status": "IN_PROGRESS"
}
PATCH /api/maintenance/{id}/
{ "status": "SUCCESS" }

GET  /api/backups/
POST /api/backups/
{
  "backup_name": "backup_2025_01_15",
  "file_path": "/backups/db_2025_01_15.sql",
  "size": 1048576
}
```

---

## 17. Gestión de Usuarios (solo admin)

### Tablas usadas: `learning_user` + `learning_role`

### APIs

```
// Gestionar teachers y admins
GET    /api/users/
GET    /api/users/{id}/
POST   /api/users/
PATCH  /api/users/{id}/
DELETE /api/users/{id}/

// Gestionar estudiantes
GET    /api/admin-students/
GET    /api/admin-students/{id}/
PATCH  /api/admin-students/{id}/
DELETE /api/admin-students/{id}/
```

```json
// Crear un profesor nuevo
POST /api/users/
{
  "username": "prof_maria",
  "email": "maria@jumpup.com",
  "password": "Clave1234!",
  "first_name": "María",
  "last_name": "García",
  "role_id": 2,        // ID del role "teacher"
  "is_active": true
}
// Lógica: User.save() sincroniza is_staff=true, is_superuser=false automáticamente

// Cambiar rol de student a teacher
PATCH /api/users/{id}/
{ "role_id": 2 }
// → is_staff pasa a true automáticamente
```

**Respuesta de usuario:**
```json
{
  "id": 8,
  "username": "prof_maria",
  "email": "maria@jumpup.com",
  "first_name": "María",
  "last_name": "García",
  "role": { "id": 2, "name": "teacher" },
  "is_staff": true,
  "is_superuser": false,
  "is_active": true
}
```

---

## 18. Emails (tablas de auditoría)

### Tablas
| Tabla | Modelo |
|---|---|
| `learning_emaillog` | `EmailLog` |
| `learning_broadcastemail` | `BroadcastEmail` |

Estas tablas **no tienen endpoints REST** para la app móvil. Son exclusivas del panel admin de Django. Se gestionan automáticamente por el `email_service`.

**`EmailLog`** → registra cada correo enviado: `recipient`, `subject`, `template_name`, `status` (pending/sent/failed), `response`, `sent_at`

**`BroadcastEmail`** → campañas masivas creadas desde el admin: `subject`, `message`, `audience` (all/students/teachers/course), `target_course`, `action_url`, `action_text`, `sent_count`, `is_sent`, `sent_at`

---

## 19. Búsqueda Global

No tiene tabla propia — consulta varios modelos a la vez.

```
GET /api/search/?q=inglés
GET /api/search/?q=inglés&type=cursos
GET /api/search/?q=inglés&type=lecciones
GET /api/search/?q=inglés&type=usuarios      // solo admin
GET /api/search/?q=inglés&type=recursos
GET /api/search/?q=inglés&type=foro
GET /api/search/?q=inglés&type=sesiones
GET /api/search/?q=inglés&limit=10           // máx 20, default 5
```

**Respuesta:**
```json
{
  "query": "inglés",
  "total": 8,
  "results": {
    "cursos": [
      { "id": 1, "title": "English A1", "description": "...", "difficulty_level": "A1", "language__name": "English" }
    ],
    "lecciones": [
      { "id": 5, "title": "Saludos en inglés", "module__title": "Módulo 1", "module__course__title": "English A1" }
    ],
    "recursos": [
      { "id": 2, "title": "PDF gramática", "resource_type": "pdf", "course__title": "English A1" }
    ],
    "foro": [
      { "id": 3, "title": "¿Cómo usar present perfect?", "category__name": "Gramática", "views": 45 }
    ],
    "sesiones": [
      { "id": 1, "title": "Clase avanzada", "status": "scheduled", "scheduled_at": "..." }
    ]
  }
}
```

---

## 20. WebSockets — Los 3 Canales Completos

### Autenticación en WebSocket
El JWT se pasa por query string. **Nunca en el body.**
```
wss://guaman-idiomas-ute.online/ws/chat/15/?token=eyJhbGci...
wss://guaman-idiomas-ute.online/ws/notifications/?token=eyJhbGci...
wss://guaman-idiomas-ute.online/ws/live-session/5/?token=eyJhbGci...
```

---

### WS Canal 1: Chat + Tutor IA (`/ws/chat/{thread_id}/`)

**Códigos de cierre:**
- `4001` → usuario no autenticado
- `4003` → no es participante del hilo

```
Flutter → Servidor:
{ "type": "chat_message",  "body": "Hello, how are you?" }
{ "type": "typing",        "is_typing": true }
{ "type": "typing",        "is_typing": false }
{ "type": "read_message",  "message_id": 42 }

Servidor → Flutter:
{ "type": "chat_message",  "message": { "id":1, "thread":15, "sender_id":5, "sender":"juan@...", "body":"Hello!", "is_read":false, "created_at":"..." } }
{ "type": "typing",        "user_id": 3, "username": "maria", "is_typing": true }
{ "type": "read_receipt",  "message_id": 42, "reader_id": 3 }
{ "type": "error",         "detail": "El mensaje no puede estar vacío." }
```

**Tutor IA — flujo completo:**
```
1. Crea hilo: POST /api/threads/ { "subject": "Tutor IA", "participant_ids": [] }
2. Conecta WS: wss://.../ws/chat/15/?token=...
3. Envías: { "type": "chat_message", "body": "What is the difference between will and going to?" }
4. Recibes: { "type": "typing", "username": "Tutor IA", "is_typing": true }
5. Recibes: { "type": "typing", "username": "Tutor IA", "is_typing": false }
6. Recibes: { "type": "chat_message", "message": { "sender": "ia@jumpup.com", "body": "Great question!..." } }
```

---

### WS Canal 2: Notificaciones (`/ws/notifications/`)

**Código de cierre:** `4001` → no autenticado

```
// Al conectar, recibes inmediatamente:
{ "type": "unread_count", "count": 3 }

// Cuando ocurre un evento en el backend (logro, mensaje, pago, etc.):
{
  "type": "new_notification",
  "notification": {
    "id": 45,
    "title": "🏅 Logro: Primer Paso",
    "message": "Completaste tu primera lección",
    "type": "system",
    "is_read": false,
    "created_at": "2025-01-15T10:30:00Z"
  }
}
// Seguido de:
{ "type": "unread_count", "count": 4 }

// Flutter → Servidor (marcar como leída):
{ "type": "mark_read", "notification_id": 45 }
{ "type": "mark_all_read" }

// Servidor responde con conteo actualizado:
{ "type": "unread_count", "count": 0 }
```

---

### WS Canal 3: Sesión en Vivo / WebRTC (`/ws/live-session/{session_id}/`)

**Código de cierre:** `4001` = no auth, `4404` = sesión no disponible

```
// Al conectar, recibes participantes ya conectados:
{ "type": "participants", "users": [3, 7] }   // user_ids ya en la sala

// Cuando alguien más se conecta:
{ "type": "user_joined", "user_id": 9, "username": "pedro" }

// Cuando alguien sale:
{ "type": "user_left", "user_id": 9 }

// Señalización WebRTC (Flutter → Servidor):
{ "type": "offer",         "sdp": { "type":"offer","sdp":"v=0..." }, "target": 9 }
{ "type": "answer",        "sdp": { "type":"answer","sdp":"v=0..." }, "target": 3 }
{ "type": "ice_candidate", "candidate": { "candidate":"candidate:...", "sdpMid":"0" }, "target": 9 }
{ "type": "leave_room" }   // cierra la conexión

// Si target no se envía → broadcast a todos los de la sala
// Servidor reenvía al target como:
{ "type": "offer",         "sdp": {...}, "from": 5 }
{ "type": "answer",        "sdp": {...}, "from": 5 }
{ "type": "ice_candidate", "candidate": {...}, "from": 5 }
```

---

## 21. Flujos Clave de Flutter — Resumen Práctico

### Flujo 1: Onboarding completo
```
1. POST /api/auth/register/               → guarda access + refresh + role
2. GET  /api/languages/                   → mostrar idiomas disponibles
3. PATCH /api/auth/profile/update-languages/  → guardar selección del idiante
4. GET  /api/courses/?language=1          → cursos del idioma elegido
5. Conectar WS: /ws/notifications/?token= → escuchar notificaciones desde ya
```

### Flujo 2: Completar una lección (el más importante)
```
1. GET /api/lessons/?module=3             → listar lecciones
2. GET /api/exercises/?lesson=5           → cargar ejercicios
   (correct_answer NO viene para estudiantes)
3. POST /api/exercises/{id}/validar/      → validar cada respuesta individual
   → si es correcta: +10 XP automático
4. POST /api/progress/                    → marcar lección como completada
   { "lesson": 5, "status": "completed", "score": 85 }
   → signal dispara XP + racha + logros
   → WS envía notificación si hay logro nuevo
5. GET /api/progress/summary/             → actualizar la UI de progreso
```

### Flujo 3: Sistema de videos con reanudación
```
1. GET /api/media-progress/resume/{lesson_id}/ → posición guardada
2. Reproducir video desde position_sec
3. Cada 10 segundos:
   PATCH /api/media-progress/{id}/
   { "position_sec": 150 }
4. Al terminar:
   PATCH /api/media-progress/{id}/
   { "position_sec": 320, "duration_sec": 320, "completed": true }
```

### Flujo 4: Comprar un curso
```
1. GET  /api/catalogo/                    → ver productos
2. POST /api/carrito/agregar/             → { "producto_id": 1, "cantidad": 1 }
3. GET  /api/carrito/                     → ver resumen del carrito
4. POST /api/carrito/comprar/             → genera OrdenCompra (estado: pagada)
   → signal notifica al profesor por WS + email
5. GET  /api/ordenes-compra/              → confirmar la orden
```

### Flujo 5: Tutor IA
```
1. POST /api/threads/ { "subject": "Tutor IA", "participant_ids": [] }
2. wss://.../ws/chat/{thread_id}/?token=...
3. { "type": "chat_message", "body": "Explícame el subjuntivo" }
4. Escuchar: typing → message del bot
5. GET /api/threads/{id}/messages/    → historial completo si se reconecta
```

### Flujo 6: Unirse a un aula
```
1. POST /api/classrooms/join/ { "access_code": "A3FX9K2T" }
2. GET  /api/classrooms/mine/                → ver mis aulas
3. GET  /api/resources/?course=3&is_public=true  → ver materiales del curso
4. GET  /api/live-sessions/?course=3         → ver sesiones programadas
5. POST /api/live-sessions/{id}/join/        → unirse a una sesión
6. wss://.../ws/live-session/{id}/?token=... → señalización WebRTC
```

### Flujo 7: Notificaciones en tiempo real
```
// En el inicio de la app:
1. wss://.../ws/notifications/?token=...
2. Escuchar type="unread_count"  → mostrar badge
3. Escuchar type="new_notification" → mostrar toast/push local

// Al abrir bandeja de notificaciones:
4. GET /api/notifications/?is_read=false
5. POST /api/notifications/read-all/
6. El WS responde con unread_count: 0 → badge desaparece
```

---

