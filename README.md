# Sistema CECTE

Sistema de automatización de registro académico desarrollado como proyecto universitario PGC para la Universidad de Cundinamarca Seccional Girardot.

---

## Integrantes

* Julian Steven Fandiño Duque
* Juan Diego Diaz Diaz

---

## Universidad

Universidad de Cundinamarca
Seccional Girardot

---

## Descripción del proyecto

CECTE es un sistema de automatización académica diseñado para gestionar procesos de registro de estudiantes, programas, materias e inscripciones de manera organizada y eficiente.

El sistema cuenta con un panel administrativo y un panel para estudiantes, permitiendo administrar información académica mediante una arquitectura cliente-servidor utilizando Flutter y Django REST Framework.

---

## Tecnologías utilizadas

### Frontend

* Flutter
* Dart
* Provider

### Backend

* Python
* Django
* Django REST Framework

### Base de Datos

* SQLite

### Otras herramientas

* Git
* GitHub
* Token Authentication REST API

---

## Funcionalidades principales

* Registro de estudiantes
* Inicio de sesión autenticado
* Gestión de programas académicos
* Gestión de materias
* Inscripción de estudiantes a materias
* Administración de notas
* Dashboard administrativo
* Gestión de usuarios
* API REST funcional
* Interfaz responsive en Flutter

---

## Arquitectura del sistema

El proyecto se encuentra dividido en dos partes principales:

### Backend — Django REST API

Encargado de:

* lógica del sistema
* autenticación
* gestión de base de datos
* endpoints REST

Carpeta:

```bash
CECTE_Web
```

---

### Frontend — Flutter

Encargado de:

* interfaz gráfica
* experiencia del usuario
* conexión con la API REST

Carpeta:

```bash
cecte_flutter
```

---

## Ejecución del proyecto

### Backend

Ingresar a:

```bash
CECTE_Web
```

Ejecutar:

```bash
python manage.py runserver
```

---

### Frontend Flutter

Ingresar a:

```bash
cecte_flutter
```

Ejecutar:

```bash
flutter pub get
flutter run -d chrome
```

---

## Base de datos

El sistema utiliza SQLite como gestor de base de datos durante el desarrollo.

La estructura relacional incluye las siguientes entidades:

* Usuarios
* Estudiantes
* Programas
* Materias
* Inscripciones

El backend administra las relaciones mediante modelos relacionales de Django ORM.

---

## Repositorio público

Repositorio oficial del proyecto:

https://github.com/jlfnd1228/Sistema-CECTE

---

## Estado del proyecto

Proyecto funcional desarrollado con fines académicos para automatización de procesos de registro y administración estudiantil.
