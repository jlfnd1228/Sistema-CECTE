# -*- coding: utf-8 -*-
from django.db.models import Count, Q
from rest_framework import viewsets, status, permissions
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.authtoken.models import Token

from .models import Usuario, Programa, Materia, Estudiante, Inscripcion
from .serializers import (
    LoginSerializer, UsuarioSerializer, RegistroUsuarioSerializer,
    RegistroEstudiantePublicoSerializer,
    ProgramaSerializer, MateriaSerializer,
    EstudianteSerializer, InscripcionSerializer,
)


class EsAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.es_admin()


class EsAdminOLectura(permissions.BasePermission):
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user.es_admin()


# ── AUTH ───────────────────────────────────────────────────────────────────

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    serializer = LoginSerializer(data=request.data)
    if not serializer.is_valid():
        return Response({'error': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
    user = serializer.validated_data['user']
    token, _ = Token.objects.get_or_create(user=user)
    return Response({'token': token.key, 'user': UsuarioSerializer(user).data})


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    try:
        request.user.auth_token.delete()
    except Exception:
        pass
    return Response({'ok': True})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def perfil_view(request):
    return Response(UsuarioSerializer(request.user).data)


@api_view(['POST'])
@permission_classes([AllowAny])
def registro_estudiante_view(request):
    serializer = RegistroEstudiantePublicoSerializer(data=request.data)
    if serializer.is_valid():
        resultado = serializer.save()
        user = resultado['user']
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user': UsuarioSerializer(user).data,
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([EsAdmin])
def crear_usuario_view(request):
    serializer = RegistroUsuarioSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response(UsuarioSerializer(user).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ── DASHBOARD ──────────────────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_stats(request):
    return Response({
        'total_estudiantes':   Estudiante.objects.filter(activo=True).count(),
        'total_programas':     Programa.objects.filter(activo=True).count(),
        'total_materias':      Materia.objects.filter(activa=True).count(),
        'total_inscripciones': Inscripcion.objects.filter(estado='activa').count(),
        'por_programa': list(
            Programa.objects.filter(activo=True).values('nombre').annotate(
                cantidad=Count('estudiantes', filter=Q(estudiantes__activo=True))
            )
        ),
    })


# ── ESTUDIANTE ─────────────────────────────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def mi_perfil_estudiante(request):
    try:
        estudiante = request.user.perfil_estudiante
        return Response(EstudianteSerializer(estudiante).data)
    except Estudiante.DoesNotExist:
        return Response({'error': 'No tienes perfil de estudiante.'}, status=404)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def mis_inscripciones(request):
    try:
        estudiante = request.user.perfil_estudiante
        inscripciones = Inscripcion.objects.filter(
            estudiante=estudiante
        ).select_related('materia', 'materia__programa')
        return Response(InscripcionSerializer(inscripciones, many=True).data)
    except Estudiante.DoesNotExist:
        return Response([], status=200)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def inscribirse_materia(request):
    try:
        estudiante = request.user.perfil_estudiante
    except Estudiante.DoesNotExist:
        return Response({'error': 'No tienes perfil de estudiante.'}, status=404)

    materia_id = request.data.get('materia_id')
    if not materia_id:
        return Response({'error': 'Falta materia_id.'}, status=400)

    try:
        materia = Materia.objects.get(id=materia_id, activa=True)
    except Materia.DoesNotExist:
        return Response({'error': 'Materia no encontrada.'}, status=404)

    if Inscripcion.objects.filter(estudiante=estudiante, materia=materia).exists():
        return Response({'error': 'Ya estas inscrito en esta materia.'}, status=400)

    inscripcion = Inscripcion.objects.create(estudiante=estudiante, materia=materia)
    return Response(InscripcionSerializer(inscripcion).data, status=201)


# ── VIEWSETS ───────────────────────────────────────────────────────────────

class ProgramaViewSet(viewsets.ModelViewSet):
    queryset           = Programa.objects.all()
    serializer_class   = ProgramaSerializer

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [EsAdmin()]

    @action(detail=True, methods=['get'])
    def materias(self, request, pk=None):
        programa = self.get_object()
        materias = programa.materias.filter(activa=True)
        return Response(MateriaSerializer(materias, many=True).data)


class MateriaViewSet(viewsets.ModelViewSet):
    queryset           = Materia.objects.all()
    serializer_class   = MateriaSerializer
    permission_classes = [EsAdminOLectura]

    def get_queryset(self):
        qs = super().get_queryset()
        programa_id = self.request.query_params.get('programa')
        if programa_id:
            qs = qs.filter(programa_id=programa_id)
        return qs


class EstudianteViewSet(viewsets.ModelViewSet):
    queryset           = Estudiante.objects.select_related('programa').all()
    serializer_class   = EstudianteSerializer

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [EsAdmin()]
        return [IsAuthenticated()]

    def get_queryset(self):
        qs = super().get_queryset()
        q  = self.request.query_params.get('q', '').strip()
        if q:
            qs = qs.filter(
                Q(nombre__icontains=q) |
                Q(documento__icontains=q) |
                Q(correo__icontains=q)
            )
        programa = self.request.query_params.get('programa')
        if programa:
            qs = qs.filter(programa_id=programa)
        return qs

    def destroy(self, request, *args, **kwargs):
        estudiante = self.get_object()
        estudiante.activo = False
        estudiante.save()
        return Response({'ok': True}, status=status.HTTP_200_OK)


class InscripcionViewSet(viewsets.ModelViewSet):
    queryset           = Inscripcion.objects.select_related(
        'estudiante', 'materia', 'materia__programa'
    ).all()
    serializer_class   = InscripcionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        estudiante_id = self.request.query_params.get('estudiante')
        if estudiante_id:
            qs = qs.filter(estudiante_id=estudiante_id)
        return qs