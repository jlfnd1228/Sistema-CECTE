# -*- coding: utf-8 -*-
from core.models import Usuario, Programa, Materia

# ── Programas reales de CECTE ──────────────────────────────────────────────
programas_data = [
    {'nombre': 'Tecnico Laboral en Auxiliar de Enfermeria',         'codigo': 'ENF'},
    {'nombre': 'Tecnico Laboral en Servicios Farmaceuticos',        'codigo': 'FAR'},
    {'nombre': 'Tecnico Laboral en Salud Oral',                     'codigo': 'SAO'},
    {'nombre': 'Tecnico Laboral en Auxiliar en Preescolar',         'codigo': 'PRE'},
    {'nombre': 'Tecnico Laboral en Educacion Fisica Recreacion y Deportes', 'codigo': 'EFD'},
    {'nombre': 'Tecnico Laboral en Administracion Hotelera y Turistica',    'codigo': 'AHT'},
]

# ── Modulos reales por programa ────────────────────────────────────────────
materias_data = {
    'ENF': [
        # Semestre I
        ('ENF-101', 'Induccion de Valores',              1, 'Semestre I'),
        ('ENF-102', 'Tecnicas de Estudio',               1, 'Semestre I'),
        ('ENF-103', 'Matematicas',                       1, 'Semestre I'),
        ('ENF-104', 'Bioseguridad y Control de Infecciones', 2, 'Semestre I'),
        ('ENF-105', 'Morfofisiologia',                   2, 'Semestre I'),
        ('ENF-106', 'Salud Publica y Comunitaria',       2, 'Semestre I'),
        ('ENF-107', 'Enfermeria Basica',                 5, 'Semestre I'),
        # Semestre II
        ('ENF-201', 'Seguridad Social en Salud',         1, 'Semestre II'),
        ('ENF-202', 'Apoyo Diagnostico',                 1, 'Semestre II'),
        ('ENF-203', 'Laboratorio Clinico',               1, 'Semestre II'),
        ('ENF-204', 'Enfermeria del Adulto Mayor',       1, 'Semestre II'),
        ('ENF-205', 'Administracion de Medicamentos',    2, 'Semestre II'),
        ('ENF-206', 'Enfermeria Medico Quirurgico',      5, 'Semestre II'),
        # Semestre III
        ('ENF-301', 'Servicio al Cliente',               1, 'Semestre III'),
        ('ENF-302', 'Etica Profesional',                 1, 'Semestre III'),
        ('ENF-303', 'PAI',                               1, 'Semestre III'),
        ('ENF-304', 'Salud Ocupacional',                 1, 'Semestre III'),
        ('ENF-305', 'Patologia',                         1, 'Semestre III'),
        ('ENF-306', 'Admision en Servicios de Salud',    1, 'Semestre III'),
        ('ENF-307', 'Enfermeria Materno Infantil',       5, 'Semestre III'),
    ],
    'FAR': [
        ('FAR-101', 'Induccion de Valores',              1, 'Semestre I'),
        ('FAR-102', 'Matematicas',                       1, 'Semestre I'),
        ('FAR-103', 'Bioseguridad',                      2, 'Semestre I'),
        ('FAR-104', 'Morfofisiologia',                   2, 'Semestre I'),
        ('FAR-105', 'Farmacologia Basica',               3, 'Semestre I'),
        ('FAR-106', 'Legislacion Farmaceutica',          2, 'Semestre I'),
        ('FAR-201', 'Dispensacion de Medicamentos',      3, 'Semestre II'),
        ('FAR-202', 'Almacenamiento y Control',          2, 'Semestre II'),
        ('FAR-203', 'Salud Publica',                     2, 'Semestre II'),
        ('FAR-204', 'Seguridad Social en Salud',         1, 'Semestre II'),
        ('FAR-205', 'Farmacia Hospitalaria',             3, 'Semestre II'),
        ('FAR-301', 'Servicio al Cliente',               1, 'Semestre III'),
        ('FAR-302', 'Etica Profesional',                 1, 'Semestre III'),
        ('FAR-303', 'Salud Ocupacional',                 1, 'Semestre III'),
        ('FAR-304', 'Gestion de Calidad Farmaceutica',   2, 'Semestre III'),
        ('FAR-305', 'Practica Farmaceutica',             5, 'Semestre III'),
    ],
    'SAO': [
        ('SAO-101', 'Induccion de Valores',              1, 'Semestre I'),
        ('SAO-102', 'Anatomia Dental',                   2, 'Semestre I'),
        ('SAO-103', 'Bioseguridad Oral',                 2, 'Semestre I'),
        ('SAO-104', 'Morfofisiologia',                   2, 'Semestre I'),
        ('SAO-105', 'Instrumentacion Dental',            3, 'Semestre I'),
        ('SAO-201', 'Salud Publica Oral',                2, 'Semestre II'),
        ('SAO-202', 'Higiene Oral',                      3, 'Semestre II'),
        ('SAO-203', 'Radiologia Dental Basica',          2, 'Semestre II'),
        ('SAO-204', 'Asistencia en Cirugia Oral',        3, 'Semestre II'),
        ('SAO-301', 'Etica Profesional',                 1, 'Semestre III'),
        ('SAO-302', 'Salud Ocupacional',                 1, 'Semestre III'),
        ('SAO-303', 'Ortodoncia Basica',                 2, 'Semestre III'),
        ('SAO-304', 'Practica Clinica Oral',             5, 'Semestre III'),
    ],
    'PRE': [
        ('PRE-101', 'Induccion de Valores',              1, 'Semestre I'),
        ('PRE-102', 'Desarrollo Infantil',               3, 'Semestre I'),
        ('PRE-103', 'Ludica y Creatividad',              2, 'Semestre I'),
        ('PRE-104', 'Psicologia del Nino',               2, 'Semestre I'),
        ('PRE-105', 'Primeros Auxilios',                 2, 'Semestre I'),
        ('PRE-201', 'Didactica Preescolar',              3, 'Semestre II'),
        ('PRE-202', 'Estimulacion Temprana',             3, 'Semestre II'),
        ('PRE-203', 'Nutricion Infantil',                2, 'Semestre II'),
        ('PRE-204', 'Legislacion Educativa',             1, 'Semestre II'),
        ('PRE-301', 'Etica Profesional',                 1, 'Semestre III'),
        ('PRE-302', 'Salud Ocupacional',                 1, 'Semestre III'),
        ('PRE-303', 'Proyecto Pedagogico',               3, 'Semestre III'),
        ('PRE-304', 'Practica en Preescolar',            5, 'Semestre III'),
    ],
    'EFD': [
        ('EFD-101', 'Induccion de Valores',              1, 'Semestre I'),
        ('EFD-102', 'Anatomia y Fisiologia del Ejercicio', 3, 'Semestre I'),
        ('EFD-103', 'Fundamentos de Educacion Fisica',   2, 'Semestre I'),
        ('EFD-104', 'Primeros Auxilios Deportivos',      2, 'Semestre I'),
        ('EFD-105', 'Deportes Individuales',             2, 'Semestre I'),
        ('EFD-201', 'Deportes Colectivos',               3, 'Semestre II'),
        ('EFD-202', 'Recreacion y Tiempo Libre',         2, 'Semestre II'),
        ('EFD-203', 'Actividad Fisica y Salud',          3, 'Semestre II'),
        ('EFD-204', 'Metodologia del Entrenamiento',     2, 'Semestre II'),
        ('EFD-301', 'Etica Profesional',                 1, 'Semestre III'),
        ('EFD-302', 'Salud Ocupacional',                 1, 'Semestre III'),
        ('EFD-303', 'Gestion Deportiva',                 2, 'Semestre III'),
        ('EFD-304', 'Practica Deportiva',                5, 'Semestre III'),
    ],
    'AHT': [
        ('AHT-101', 'Induccion de Valores',              1, 'Semestre I'),
        ('AHT-102', 'Fundamentos de Turismo',            2, 'Semestre I'),
        ('AHT-103', 'Servicio al Cliente',               2, 'Semestre I'),
        ('AHT-104', 'Matematicas Financieras',           2, 'Semestre I'),
        ('AHT-105', 'Ingles Turistico',                  2, 'Semestre I'),
        ('AHT-201', 'Gestion Hotelera',                  3, 'Semestre II'),
        ('AHT-202', 'Alimentos y Bebidas',               3, 'Semestre II'),
        ('AHT-203', 'Mercadeo Turistico',                2, 'Semestre II'),
        ('AHT-204', 'Legislacion Turistica',             1, 'Semestre II'),
        ('AHT-301', 'Etica Profesional',                 1, 'Semestre III'),
        ('AHT-302', 'Salud Ocupacional',                 1, 'Semestre III'),
        ('AHT-303', 'Ecoturismo y Turismo Cultural',     2, 'Semestre III'),
        ('AHT-304', 'Practica Hotelera y Turistica',     5, 'Semestre III'),
    ],
}

# ── Crear programas ────────────────────────────────────────────────────────
for p in programas_data:
    obj, created = Programa.objects.get_or_create(
        codigo=p['codigo'], defaults={'nombre': p['nombre']}
    )
    print(f"Programa: {obj.nombre} ({'creado' if created else 'ya existia'})")

# ── Crear materias ─────────────────────────────────────────────────────────
for codigo_prog, modulos in materias_data.items():
    try:
        programa = Programa.objects.get(codigo=codigo_prog)
        for codigo, nombre, creditos, descripcion in modulos:
            obj, created = Materia.objects.get_or_create(
                codigo=codigo,
                defaults={
                    'nombre': nombre,
                    'programa': programa,
                    'creditos': creditos,
                    'descripcion': descripcion,
                }
            )
            print(f"  Modulo: {obj.codigo} - {obj.nombre} ({'creado' if created else 'ya existia'})")
    except Programa.DoesNotExist:
        print(f"  ERROR: Programa {codigo_prog} no encontrado")

# ── Usuario admin ──────────────────────────────────────────────────────────
if not Usuario.objects.filter(username='admin').exists():
    admin = Usuario.objects.create_superuser(
        username='admin',
        password='cecte2024',
        email='admin@cecte.edu.co',
        first_name='Administrador',
        last_name='CECTE',
    )
    admin.rol = 'admin'
    admin.save()
    print('Usuario admin creado: admin / cecte2024')
else:
    print('Usuario admin ya existe')

print('Datos iniciales cargados correctamente.')