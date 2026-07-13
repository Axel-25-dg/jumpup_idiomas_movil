# JumpUp Idiomas - App Móvil

Aplicación móvil de aprendizaje de idiomas desarrollada con Flutter, con integración a backend Django REST Framework.

## Características principales

- 📚 Aprendizaje interactivo con cursos, módulos y lecciones
- 🏆 Gamificación: XP, niveles, rachas y logros
- 🛒 E-commerce: Catálogo de productos, carrito de compras
- 📖 Biblioteca: Acceso a productos comprados
- 💬 Chat en tiempo real y Tutor IA
- 📋 Foro comunitario
- 📺 Sesiones en vivo con WebRTC
- 📊 Perfil y progreso personalizado
- 🎯 Ejercicios con repetición de errores y temporizador

---

## Requisitos previos

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode para emuladores
- Git (para clonar el repositorio)

---

## Instalación

1. Clona el repositorio:
```bash
git clone <url-del-repositorio>
cd jumpup_idiomas_movil
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura las variables de entorno (ver sección a continuación).

4. Ejecuta la aplicación:
```bash
# Para Android
flutter run

# Para iOS
flutter run -d ios
```

---

## Variables de entorno y configuración

### URL de la API
La aplicación se conecta al backend en: `https://guaman-idiomas-ute.online/`

No es necesario configurar archivos adicionales para la URL base, ya está hardcodeada en `lib/core/constants/app_constants.dart` o en el repositorio correspondiente.

### Firebase (opcional)
Para notificaciones push y otras funcionalidades de Firebase, configura los archivos:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

---

## Credenciales de prueba (para desarrollo)

Para probar la aplicación, puedes usar las siguientes credenciales de prueba:

| Rol | Email | Contraseña |
|-----|-------|------------|
| Estudiante | test@student.com | Clave1234! |
| Profesor | test@teacher.com | Clave1234! |
| Administrador | admin@jumpup.com | Clave1234! |

*Nota: Las credenciales reales deben ser proporcionadas por el equipo de desarrollo.*

---

## Conexión a la API

Todos los endpoints están documentados en el informe completo del proyecto. A continuación, los endpoints principales:

### Autenticación
- `POST /api/auth/register/` - Registro de usuario
- `POST /api/auth/login/` - Inicio de sesión
- `POST /api/auth/token/refresh/` - Refrescar token JWT
- `GET /api/auth/me/` - Obtener datos del usuario autenticado

### Contenido educativo
- `GET /api/languages/` - Listado de idiomas
- `GET /api/courses/` - Cursos disponibles
- `GET /api/lessons/?module=<id>` - Lecciones de un módulo
- `GET /api/exercises/?lesson=<id>` - Ejercicios de una lección
- `POST /api/exercises/<id>/validar/` - Validar respuesta de ejercicio
- `POST /api/progress/` - Registrar progreso de lección

### Progreso y gamificación
- `GET /api/progress/summary/` - Resumen de progreso
- `GET /api/stats/` - Estadísticas del usuario (XP, rachas, nivel)
- `GET /api/achievements/` - Logros disponibles
- `GET /api/my-achievements/` - Mis logros desbloqueados

### E-commerce
- `GET /api/catalogo/` - Catálogo de productos
- `GET /api/carrito/` - Ver carrito
- `POST /api/carrito/agregar/` - Agregar producto al carrito
- `POST /api/carrito/eliminar/` - Eliminar producto del carrito
- `POST /api/carrito/comprar/` - Realizar compra
- `GET /api/ordenes-compra/` - Ver órdenes de compra

### Biblioteca
- La biblioteca muestra productos comprados filtrando órdenes con estado `pagada`.

---

## Comandos útiles

```bash
# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Generar archivos de traducción
flutter gen-l10n

# Build de producción (Android)
flutter build apk --release

# Build de producción (iOS)
flutter build ios --release
```

---

## Estructura del proyecto

```
lib/
├── core/                    # Utilidades y constantes
├── data/                    # Capa de datos (repositorios, DTOs)
├── domain/                  # Capa de dominio (modelos, casos de uso)
├── presentation/            # Capa de presentación (UI, providers, navegación)
└── main.dart                # Punto de entrada
```

---

## Soporte y contacto

Para consultas o problemas, contacta al equipo de desarrollo.
