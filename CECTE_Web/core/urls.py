# -*- coding: utf-8 -*-
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()

router.register(r'programas', views.ProgramaViewSet, basename='programas')
router.register(r'materias', views.MateriaViewSet, basename='materias')
router.register(r'estudiantes', views.EstudianteViewSet, basename='estudiantes')
router.register(r'inscripciones', views.InscripcionViewSet, basename='inscripciones')

urlpatterns = [
    path('auth/login/', views.login_view, name='login'),
    path('auth/logout/', views.logout_view, name='logout'),
    path('auth/perfil/', views.perfil_view, name='perfil'),
    path('auth/registro/', views.registro_estudiante_view, name='registro-publico'),
    path('auth/crear-usuario/', views.crear_usuario_view, name='crear-usuario'),

    path('dashboard/', views.dashboard_stats, name='dashboard'),

    path('estudiante/perfil/', views.mi_perfil_estudiante, name='mi-perfil'),
    path('estudiante/materias/', views.mis_inscripciones, name='mis-inscripciones'),
    path('estudiante/inscribirse/', views.inscribirse_materia, name='inscribirse'),

    path('', include(router.urls)),
]