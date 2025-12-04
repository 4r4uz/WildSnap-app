#!/usr/bin/env python3
"""
Script para descargar modelos YOLOv8 y EfficientNetB0, y convertirlos a TFLite
para usar en Flutter con WildSnap
"""

import os
import sys
import subprocess
import urllib.request
import tensorflow as tf
from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras.applications.efficientnet import preprocess_input
import numpy as np

def install_dependencies():
    """Instala las dependencias necesarias"""
    print("=== INSTALANDO DEPENDENCIAS ===")

    dependencies = [
        "tensorflow",
        "ultralytics",
        "numpy",
        "Pillow"
    ]

    for dep in dependencies:
        try:
            print(f"Instalando {dep}...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", dep])
            print(f"✅ {dep} instalado correctamente")
        except subprocess.CalledProcessError:
            print(f"❌ Error instalando {dep}")
            return False

    print("✅ Todas las dependencias instaladas")
    return True

def download_and_convert_yolo():
    """Descarga YOLOv8n y lo convierte a TFLite"""
    print("\n=== DESCARGANDO Y CONvirtiendo YOLOv8 ===")

    try:
        from ultralytics import YOLO

        # Cargar modelo YOLOv8n pre-entrenado
        print("Descargando YOLOv8n...")
        model = YOLO('yolov8n.pt')  # Descarga automáticamente

        # Exportar a TFLite con configuración óptima para móviles
        print("Convirtiendo a TFLite...")
        model.export(
            format='tflite',
            imgsz=640,  # Tamaño estándar para móviles
            int8=False,  # Usar float32 para compatibilidad
            simplify=True  # Simplificar el modelo
        )

        # El archivo se guarda como 'yolov8n_saved_model/yolov8n_float32.tflite'
        # Lo movemos a deteccion.tflite
        import shutil
        source = 'yolov8n_saved_model/yolov8n_float32.tflite'
        target = 'assets/deteccion.tflite'

        if os.path.exists(source):
            shutil.move(source, target)
            print(f"✅ Modelo YOLO guardado como: {target}")

            # Limpiar directorio temporal
            shutil.rmtree('yolov8n_saved_model')
            print("✅ Archivos temporales limpiados")
        else:
            print("❌ No se encontró el archivo convertido")
            return False

    except ImportError:
        print("❌ Ultralytics no está instalado")
        return False
    except Exception as e:
        print(f"❌ Error convirtiendo YOLO: {e}")
        return False

    return True

def download_and_convert_efficientnet():
    """Descarga EfficientNetB0 y lo convierte a TFLite"""
    print("\n=== DESCARGANDO Y CONvirtiendo EfficientNetB0 ===")

    try:
        # Cargar modelo EfficientNetB0 pre-entrenado
        print("Cargando EfficientNetB0...")
        model = EfficientNetB0(weights='imagenet', include_top=True)

        # Crear convertidor TFLite
        print("Convirtiendo a TFLite...")
        converter = tf.lite.TFLiteConverter.from_keras_model(model)

        # Optimizaciones para móviles
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float32]  # Mantener float32

        # Convertir
        tflite_model = converter.convert()

        # Guardar
        os.makedirs('assets', exist_ok=True)
        with open('assets/clasificacion.tflite', 'wb') as f:
            f.write(tflite_model)

        print("✅ EfficientNetB0 convertido y guardado como: assets/clasificacion.tflite")

    except Exception as e:
        print(f"❌ Error convirtiendo EfficientNet: {e}")
        return False

    return True

def create_labels_files():
    """Crea los archivos de etiquetas necesarios"""
    print("\n=== CREANDO ARCHIVOS DE ETIQUETAS ===")

    # COCO labels (80 clases estándar)
    coco_labels = [
        "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat",
        "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat",
        "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "backpack",
        "umbrella", "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball",
        "kite", "baseball bat", "baseball glove", "skateboard", "surfboard", "tennis racket",
        "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple",
        "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake",
        "chair", "couch", "potted plant", "bed", "dining table", "toilet", "tv", "laptop",
        "mouse", "remote", "keyboard", "cell phone", "microwave", "oven", "toaster", "sink",
        "refrigerator", "book", "clock", "vase", "scissors", "teddy bear", "hair drier", "toothbrush"
    ]

    # ImageNet labels (1000 clases) - descargamos desde TensorFlow
    try:
        print("Descargando etiquetas ImageNet...")
        labels_path = tf.keras.utils.get_file(
            'ImageNetLabels.txt',
            'https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt'
        )

        with open(labels_path, 'r') as f:
            imagenet_labels = f.read().splitlines()

        # Remover 'background' si existe
        if imagenet_labels[0] == 'background':
            imagenet_labels = imagenet_labels[1:]

    except:
        print("❌ Error descargando etiquetas ImageNet, usando versión simplificada")
        # Versión simplificada si falla la descarga
        imagenet_labels = [f"class_{i}" for i in range(1000)]

    # Guardar archivos
    os.makedirs('assets', exist_ok=True)

    with open('assets/coco_labels.txt', 'w') as f:
        f.write('\n'.join(coco_labels))

    with open('assets/imagenet_labels.txt', 'w') as f:
        f.write('\n'.join(imagenet_labels))

    print("✅ Archivos de etiquetas creados:")
    print(f"   - coco_labels.txt: {len(coco_labels)} clases")
    print(f"   - imagenet_labels.txt: {len(imagenet_labels)} clases")

def verify_models():
    """Verifica que los modelos se crearon correctamente"""
    print("\n=== VERIFICANDO MODELOS ===")

    models = [
        ('assets/deteccion.tflite', 'YOLOv8'),
        ('assets/clasificacion.tflite', 'EfficientNetB0')
    ]

    for path, name in models:
        if os.path.exists(path):
            size = os.path.getsize(path) / 1024 / 1024
            print(f"✅ {name}: {size:.2f} MB")
        else:
            print(f"❌ {name}: No encontrado")

    labels = [
        ('assets/coco_labels.txt', 'COCO'),
        ('assets/imagenet_labels.txt', 'ImageNet')
    ]

    for path, name in labels:
        if os.path.exists(path):
            with open(path, 'r') as f:
                count = len(f.read().splitlines())
            print(f"✅ {name} labels: {count} clases")
        else:
            print(f"❌ {name} labels: No encontrado")

def main():
    print("=== WILDSNAP - DESCARGA Y CONVERSIÓN DE MODELOS ===\n")

    # Verificar TensorFlow
    print(f"TensorFlow version: {tf.__version__}")
    print(f"Python version: {sys.version}")

    # Instalar dependencias
    if not install_dependencies():
        print("❌ Error instalando dependencias")
        return

    # Crear directorio assets
    os.makedirs('assets', exist_ok=True)

    # Convertir modelos
    yolo_success = download_and_convert_yolo()
    efficientnet_success = download_and_convert_efficientnet()

    # Crear etiquetas
    create_labels_files()

    # Verificar
    verify_models()

    if yolo_success and efficientnet_success:
        print("\n🎉 ¡CONVERSIÓN COMPLETADA EXITOSAMENTE!")
        print("\nLos archivos están listos para Flutter:")
        print("- assets/deteccion.tflite (YOLOv8)")
        print("- assets/clasificacion.tflite (EfficientNetB0)")
        print("- assets/coco_labels.txt")
        print("- assets/imagenet_labels.txt")
        print("\nAhora puedes ejecutar: flutter run")
    else:
        print("\n❌ Algunos modelos no se pudieron convertir")
        print("Revisa los errores arriba e intenta nuevamente")

if __name__ == "__main__":
    main()
