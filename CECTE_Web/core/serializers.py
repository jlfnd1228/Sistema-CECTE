# -*- coding: utf-8 -*-
from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import Usuario, Programa, Materia, Estudiante, Inscripcion


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = authenticate(username=data['username'], password=data['password'])
        if not user:
            raise serializers.ValidationError('Credenciales incorrectas.')
        if not user.is_active:
            raise serializers.ValidationError('Usuario inactivo.')
        data['user'] = user
        return data


class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Usuario
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'rol']


class RegistroUsuarioSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model  = Usuario
        fields = ['username', 'email', 'first_name', 'last_name', 'password', 'rol']

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = Usuario(**validated_data)
        user.set_password(password)
        user.save()
        return user


class RegistroEstudiantePublicoSerializer(serializers.Serializer):
    username   = serializers.CharField(max_length=150)
    password   = serializers.CharField(write_only=True)
    first_name = serializers.CharField(max_length=150)
    last_name  = serializers.CharField(max_length=150)
    email      = serializers.EmailField()
    documento  = serializers.CharField(max_length=20)
    telefono   = serializers.CharField(max_length=15, required=False, allow_blank=True)
    programa   = serializers.PrimaryKeyRelatedField(
        queryset=Programa.objects.all(), required=False, allow_null=True
    )

    def validate_username(self, value):
        if Usuario.objects.filter(username=value).exists():
            raise serializers.ValidationError('Ese nombre de usuario ya existe.')
        return value

    def validate_email(self, value):
        if Usuario.objects.filter(email=value).exists():
            raise serializers.ValidationError('Ese correo ya esta registrado.')
        return value

    def validate_documento(self, value):
        if Estudiante.objects.filter(documento=value).exists():
            raise serializers.ValidationError('Ese documento ya esta registrado.')
        return value

    def create(self, validated_data):
        programa  = validated_data.pop('programa', None)
        telefono  = validated_data.pop('telefono', '')
        documento = validated_data.pop('documento')

        user = Usuario(
            username   = validated_data['username'],
            email      = validated_data['email'],
            first_name = validated_data['first_name'],
            last_name  = validated_data['last_name'],
            rol        = Usuario.ROL_ESTUDIANTE,
        )
        user.set_password(validated_data['password'])
        user.save()

        estudiante = Estudiante.objects.create(
            usuario   = user,
            nombre    = f"{validated_data['first_name']} {validated_data['last_name']}",
            documento = documento,
            correo    = validated_data['email'],
            telefono  = telefono,
            programa  = programa,
        )
        return {'user': user, 'estudiante': estudiante}


class ProgramaSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Programa
        fields = '__all__'


class MateriaSerializer(serializers.ModelSerializer):
    programa_nombre = serializers.CharField(source='programa.nombre', read_only=True)

    class Meta:
        model  = Materia
        fields = '__all__'


class EstudianteSerializer(serializers.ModelSerializer):
    programa_nombre = serializers.CharField(source='programa.nombre', read_only=True)

    class Meta:
        model  = Estudiante
        fields = '__all__'


class InscripcionSerializer(serializers.ModelSerializer):
    materia_nombre    = serializers.CharField(source='materia.nombre',    read_only=True)
    estudiante_nombre = serializers.CharField(source='estudiante.nombre', read_only=True)
    programa_nombre   = serializers.CharField(source='materia.programa.nombre', read_only=True)

    class Meta:
        model  = Inscripcion
        fields = '__all__'