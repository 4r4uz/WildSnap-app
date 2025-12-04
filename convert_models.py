#!/usr/bin/env python3
"""
Script para convertir modelos de YOLO y EfficientNet a formato TFLite compatible con Flutter
"""

import tensorflow as tf
import numpy as np
import os
import sys

def convert_yolo_to_tflite(yolo_model_path, output_path):
    """
    Convierte un modelo YOLOv8 de PyTorch a TFLite
    """
    try:
        from ultralytics import YOLO

        # Cargar modelo YOLOv8
        print(f"Cargando modelo YOLO desde: {yolo_model_path}")
        model = YOLO(yolo_model_path)

        # Exportar a TFLite
        print(f"Convirtiendo a TFLite: {output_path}")
        model.export(format='tflite', imgsz=640)

        # El archivo se guarda automáticamente con extensión .tflite
        print("✅ Modelo YOLO convertido exitosamente")

    except ImportError:
        print("❌ Error: ultralytics no está instalado")
        print("Instala con: pip install ultralytics")
        return False
    except Exception as e:
        print(f"❌ Error convirtiendo YOLO: {e}")
        return False

    return True

def convert_efficientnet_to_tflite(model_path, output_path):
    """
    Convierte un modelo EfficientNet de TensorFlow/Keras a TFLite
    """
    try:
        print(f"Convirtiendo EfficientNet desde: {model_path}")

        if model_path.endswith('.h5') or model_path.endswith('.keras'):
            # Cargar modelo Keras
            model = tf.keras.models.load_model(model_path)
        elif os.path.isdir(model_path):
            # Cargar SavedModel
            model = tf.saved_model.load(model_path)
        else:
            print(f"❌ Formato de modelo no reconocido: {model_path}")
            return False

        # Crear convertidor TFLite
        converter = tf.lite.TFLiteConverter.from_keras_model(model)

        # Optimizaciones para móviles
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float32]

        # Convertir
        tflite_model = converter.convert()

        # Guardar
        with open(output_path, 'wb') as f:
            f.write(tflite_model)

        print(f"✅ EfficientNet convertido y guardado en: {output_path}")

    except Exception as e:
        print(f"❌ Error convirtiendo EfficientNet: {e}")
        return False

    return True

def main():
    print("=== CONVERSOR DE MODELOS PARA WILDSNAP ===\n")

    # Verificar TensorFlow
    print(f"TensorFlow version: {tf.__version__}")

    # Preguntar por rutas de modelos
    yolo_path = input("Ruta al modelo YOLOv8 (.pt): ").strip()
    efficientnet_path = input("Ruta al modelo EfficientNet (.h5, .keras o directorio SavedModel): ").strip()

    if not os.path.exists(yolo_path):
        print(f"❌ Modelo YOLO no encontrado: {yolo_path}")
        return

    if not os.path.exists(efficientnet_path):
        print(f"❌ Modelo EfficientNet no encontrado: {efficientnet_path}")
        return

    # Convertir modelos
    print("\n=== CONVERSIÓN YOLO ===")
    yolo_success = convert_yolo_to_tflite(yolo_path, 'deteccion.tflite')

    print("\n=== CONVERSIÓN EFFICIENTNET ===")
    efficientnet_success = convert_efficientnet_to_tflite(efficientnet_path, 'clasificacion.tflite')

    if yolo_success and efficientnet_success:
        print("\n✅ ¡CONVERSIÓN COMPLETADA!")
        print("Los archivos deteccion.tflite y clasificacion.tflite están listos para Flutter")
        print("Copialos a la carpeta assets/ de tu proyecto Flutter")
    else:
        print("\n❌ Algunos modelos no se pudieron convertir")

if __name__ == "__main__":
    main()
