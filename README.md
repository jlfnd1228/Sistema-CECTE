# CECTE — Sistema de Registro Academico

Sistema web para el Centro de Educacion para el Trabajo y el Desarrollo Humano, Girardot, Cundinamarca.

## Tecnologias

| Capa | Tecnologia |
|------|-----------|
| Backend | Python · Django · Django REST Framework |
| Frontend | Flutter Web |
| Base de datos | SQLite (desarrollo) |
| Despliegue | Railway |

## Estructura del proyecto

```
CECTE_Web/          ← Backend Django
cecte_flutter/      ← Frontend Flutter
```

---

## Instalacion y ejecucion local

### 1. Backend Django

```bash
cd CECTE_Web
pip install -r requirements.txt
python manage.py makemigrations
python manage.py migrate
python manage.py shell < core/datos_iniciales.py
python manage.py runserver
```

El servidor queda en: http://127.0.0.1:8000

**Usuario por defecto:** `admin` / `cecte2024`

### 2. Frontend Flutter

```bash
cd cecte_flutter
flutter pub get
flutter run -d chrome
```

---

## API REST — Endpoints

| Metodo | Endpoint | Descripcion | Rol requerido |
|--------|----------|-------------|---------------|
| POST | /api/auth/login/ | Iniciar sesion | Publico |
| POST | /api/auth/logout/ | Cerrar sesion | Autenticado |
| GET | /api/auth/perfil/ | Ver perfil | Autenticado |
| POST | /api/auth/crear-usuario/ | Crear usuario | Admin |
| GET | /api/dashboard/ | Estadisticas | Autenticado |
| GET/POST | /api/estudiantes/ | Listar / Crear | GET: todos · POST: admin |
| GET/PUT/DELETE | /api/estudiantes/{id}/ | Ver / Editar / Eliminar | Admin |
| GET/POST | /api/programas/ | Programas | GET: todos · POST: admin |
| GET/POST | /api/materias/ | Materias | GET: todos · POST: admin |
| GET/POST | /api/inscripciones/ | Inscripciones | Autenticado |

---

## Despliegue en Railway

1. Crear cuenta en https://railway.app
2. Nuevo proyecto → Deploy from GitHub repo
3. Seleccionar la carpeta `CECTE_Web`
4. Railway detecta el `Procfile` automaticamente
5. Agregar variable de entorno: `SECRET_KEY=una-clave-segura-larga`
6. Agregar variable: `DEBUG=False`
7. En la consola de Railway ejecutar:
   ```
   python manage.py migrate
   python manage.py shell < core/datos_iniciales.py
   ```
8. Copiar la URL publica que asigna Railway
9. En `cecte_flutter/lib/services/auth_service.dart` cambiar:
   ```dart
   const String kBaseUrl = 'https://TU-URL.railway.app/api';
   ```
10. Recompilar Flutter: `flutter build web`

---

## Roles del sistema

- **Administrador:** CRUD completo de estudiantes, crear usuarios, ver todo.
- **Usuario:** Ver listado de estudiantes y materias. No puede registrar ni eliminar.
