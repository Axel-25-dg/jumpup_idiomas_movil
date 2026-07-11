# JumpUp Idiomas — App Móvil Flutter

Aplicación móvil desarrollada en **Flutter** que consume una API REST construida en **Django**.  
Plataforma de aprendizaje de idiomas con sección pública, autenticación JWT y panel privado con control de acceso por roles.

---

## Tabla de contenidos

1. [Descripción del proyecto](#descripción-del-proyecto)
2. [Tecnologías](#tecnologías)
3. [Requisitos previos](#requisitos-previos)
4. [Instalación y configuración](#instalación-y-configuración)
5. [Variables de entorno / Configuración de la API](#variables-de-entorno)
6. [Cómo correr el proyecto](#cómo-correr-el-proyecto)
7. [Credenciales de prueba](#credenciales-de-prueba)
8. [Arquitectura del proyecto](#arquitectura-del-proyecto)
9. [Roles y reglas de negocio](#roles-y-reglas-de-negocio)
10. [Módulos CRUD consumidos](#módulos-crud-consumidos)

---

## Descripción del proyecto

JumpUp Idiomas es una plataforma educativa para el aprendizaje de idiomas. La app móvil permite:

- **Sección pública:** catálogo de cursos, pantalla de inicio, registro y login.
- **Sección privada:** dashboard personalizado según rol, gestión de aulas, cursos, lecciones, ejercicios, sesiones en vivo y más.
- **Control por roles:** `student`, `teacher` y `admin`, cada uno con acceso y permisos diferenciados.

---

## Tecnologías

| Capa | Tecnología |
|---|---|
| Frontend móvil | Flutter 3.x (Dart) |
| Gestión de estado | Riverpod |
| Navegación | GoRouter |
| HTTP / Interceptores | Dio |
| Almacenamiento seguro de token | flutter_secure_storage |
| Variables de entorno | flutter_dotenv |
| Backend | Django REST Framework |
| Autenticación | JWT (SimpleJWT) |

---

## Requisitos previos

- Flutter SDK `>=3.0.0` — [Instalar Flutter](https://docs.flutter.dev/get-started/install)
- Dart SDK `>=3.0.0` (incluido con Flutter)
- Android Studio o VS Code con extensión Flutter
- Emulador Android (AVD) o dispositivo físico
- API Django corriendo localmente o en servidor

---

## Instalación y configuración

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/jumpup_idiomas_movil.git
cd jumpup_idiomas_movil

# 2. Instalar dependencias
flutter pub get

# 3. Configurar variables de entorno
cp .env.example .env.dev
# Editar .env.dev con la URL de tu API (ver sección siguiente)
```

---

## Variables de entorno

El archivo `.env.dev` controla la URL base de la API. **No necesitas tocar ningún archivo de código** para cambiar el servidor.

```dotenv
# .env.dev
API_BASE_URL=http://10.0.2.2:8000/api
```

| Escenario | Valor de `API_BASE_URL` |
|---|---|
| Emulador Android (AVD) | `http://10.0.2.2:8000/api` |
| Dispositivo físico (red local) | `http://192.168.X.X:8000/api` |
| Producción | `https://api.jumpup.com/api` |

> `10.0.2.2` es la IP especial que usa el emulador Android para referirse al `localhost` de la máquina host.

---

## Cómo correr el proyecto

```bash
# Verificar dispositivos disponibles
flutter devices

# Correr en modo debug (emulador o dispositivo)
flutter run --dart-define-from-file=.env.dev

# Correr en dispositivo específico
flutter run -d <device-id> --dart-define-from-file=.env.dev

# Build APK de release
flutter build apk --dart-define-from-file=.env.dev
```

> **Nota:** El proyecto usa `flutter_dotenv`, asegúrate de que el archivo `.env.dev` esté en la raíz del proyecto antes de correr.

---

## Credenciales de prueba

| Rol | Email | Contraseña |
|---|---|---|
| Admin | `admin@jumpup.com` | `Admin1234!` |
| Teacher | `profesor@jumpup.com` | `Profe1234!` |
| Student | `estudiante@jumpup.com` | `Student1234!` |

> Si las credenciales no funcionan, créalas desde el panel de Django Admin en `http://localhost:8000/admin/`.

---

## Arquitectura del proyecto

```
lib/
├── main.dart
├── core/
│   ├── config/
│   │   └── app_config.dart          ← URL base desde .env
│   ├── error/
│   │   └── api_exception.dart       ← Excepción compartida
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
├── data/
│   ├── local/
│   │   └── token_storage.dart       ← flutter_secure_storage
│   ├── remote/
│   │   ├── dio_client.dart          ← instancia Dio + interceptores
│   │   └── interceptor/
│   │       └── auth_interceptor.dart ← JWT, refresh, 401
│   └── repository/
│       ├── auth/                    ← AuthService
│       ├── teacher_admin/           ← TeacherRepository y sub-repos
│       └── social/                  ← SocialMediaRepository
├── domain/
│   ├── model/                       ← Modelos de dominio
│   └── repository/                  ← Interfaces abstractas
│       ├── auth_repository.dart
│       ├── catalog_repository.dart
│       ├── classroom_repository.dart
│       ├── admin_repository.dart
│       ├── social_repository.dart
│       └── resource_repository.dart
├── presentation/
│   ├── navigation/
│   │   └── app_router.dart          ← GoRouter con guards por rol
│   ├── providers/                   ← Riverpod providers
│   ├── screens/
│   │   ├── auth/                    ← Login, Register, ForgotPassword
│   │   ├── student/                 ← Dashboard, Cursos, AI Tutor, etc.
│   │   ├── admin/                   ← Teacher y Admin panels
│   │   ├── social/                  ← Feed, Chat, Sesiones en vivo
│   │   └── catalog/                 ← Catálogo público
│   └── widgets/                     ← Componentes reutilizables
└── theme/
    ├── colors.dart
    ├── text_styles.dart
    └── app_theme.dart
```

---

## Roles y reglas de negocio

El rol se obtiene del endpoint `GET /api/auth/me/` después del login.  
GoRouter redirige automáticamente según el rol:

| Rol | Ruta inicial | Permisos |
|---|---|---|
| `student` | `/student` | Ver cursos, lecciones, ejercicios, AI Tutor, chat |
| `teacher` | `/teacher` | CRUD aulas, lecciones, módulos, ejercicios, recursos, sesiones en vivo |
| `admin` | `/admin` | Todo lo de teacher + gestión de usuarios, idiomas, reportes, anuncios, suscripciones |

**Restricciones visibles en la UI:**
- El menú inferior y las opciones de acción cambian según el rol.
- Un `student` no puede acceder a `/teacher` ni `/admin` (GoRouter redirige al login o a su dashboard).
- Un `teacher` no puede acceder a `/admin`.
- Botones de eliminar usuarios y cambiar roles solo aparecen para `admin`.

---

## Módulos CRUD consumidos

| Módulo | Endpoints Django | Operaciones |
|---|---|---|
| **Cursos** | `/api/courses/` | Listar, Crear, Eliminar |
| **Aulas Virtuales** | `/api/classrooms/` | Listar, Crear, Editar, Eliminar |
| **Módulos** | `/api/modules/` | Listar, Crear |
| **Lecciones** | `/api/lessons/` | Listar, Crear |
| **Ejercicios** | `/api/exercises/` | Listar, Crear |
| **Recursos** | `/api/resources/` | Listar, Crear |
| **Sesiones en vivo** | `/api/live-sessions/` | Listar, Crear, Iniciar, Finalizar |
| **Usuarios** | `/api/users/` | Listar, Editar rol/estado |
| **Idiomas** | `/api/languages/` | Listar, Crear |
| **Anuncios** | `/api/announcements/` | Listar, Crear |
| **Reportes** | `/api/reports/` | Listar, Actualizar estado |
| **Suscripciones** | `/api/subscriptions/` | Listar, Checkout (Stripe) |
| **Autenticación** | `/api/auth/login/`, `/api/auth/me/`, `/api/auth/register/` | Login, Perfil, Registro, Logout, Refresh |
