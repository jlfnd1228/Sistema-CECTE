# -*- coding: utf-8 -*-
from django.db import models
from django.contrib.auth.models import AbstractUser


class Usuario(AbstractUser):
    ROL_ADMIN      = 'admin'
    ROL_USUARIO    = 'usuario'
    ROL_ESTUDIANTE = 'estudiante'
    ROLES = [
        (ROL_ADMIN,      'Administrador'),
        (ROL_USUARIO,    'Usuario'),
        (ROL_ESTUDIANTE, 'Estudiante'),
    ]
    rol = models.CharField(max_length=15, choices=ROLES, default=ROL_ESTUDIANTE)

    def es_admin(self):
        return self.rol == self.ROL_ADMIN

    def es_estudiante(self):
        return self.rol == self.ROL_ESTUDIANTE

    def __str__(self):
        return f"{self.username} ({self.get_rol_display()})"


class Programa(models.Model):
    nombre = models.CharField(max_length=200, unique=True)
    codigo = models.CharField(max_length=20, unique=True)
    activo = models.BooleanField(default=True)

    class Meta:
        ordering = ['nombre']

    def __str__(self):
        return self.nombre


class Materia(models.Model):
    nombre      = models.CharField(max_length=200)
    codigo      = models.CharField(max_length=20, unique=True)
    programa    = models.ForeignKey(Programa, on_delete=models.CASCADE, related_name='materias')
    creditos    = models.PositiveSmallIntegerField(default=3)
    descripcion = models.TextField(blank=True)
    activa      = models.BooleanField(default=True)

    class Meta:
        ordering = ['programa', 'nombre']

    def __str__(self):
        return f"{self.codigo} - {self.nombre}"


class Estudiante(models.Model):
    usuario        = models.OneToOneField(
        Usuario, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='perfil_estudiante'
    )
    nombre         = models.CharField(max_length=200)
    documento      = models.CharField(max_length=20, unique=True)
    correo         = models.EmailField(unique=True)
    telefono       = models.CharField(max_length=20, blank=True)
    programa       = models.ForeignKey(
        Programa, on_delete=models.SET_NULL,
        null=True, blank=True, related_name='estudiantes'
    )
    fecha_registro = models.DateTimeField(auto_now_add=True)
    activo         = models.BooleanField(default=True)

    class Meta:
        ordering = ['-fecha_registro']

    def __str__(self):
        return f"{self.nombre} - {self.documento}"


class Inscripcion(models.Model):
    ESTADO_ACTIVA   = 'activa'
    ESTADO_RETIRADA = 'retirada'
    ESTADO_APROBADA = 'aprobada'
    ESTADOS = [
        (ESTADO_ACTIVA,   'Activa'),
        (ESTADO_RETIRADA, 'Retirada'),
        (ESTADO_APROBADA, 'Aprobada'),
    ]
    estudiante        = models.ForeignKey(Estudiante, on_delete=models.CASCADE, related_name='inscripciones')
    materia           = models.ForeignKey(Materia, on_delete=models.CASCADE, related_name='inscripciones')
    estado            = models.CharField(max_length=10, choices=ESTADOS, default=ESTADO_ACTIVA)
    fecha_inscripcion = models.DateTimeField(auto_now_add=True)
    nota_final        = models.DecimalField(max_digits=4, decimal_places=2, null=True, blank=True)

    class Meta:
        unique_together = ('estudiante', 'materia')
        ordering = ['-fecha_inscripcion']

    def __str__(self):
        return f"{self.estudiante.nombre} -> {self.materia.nombre}"