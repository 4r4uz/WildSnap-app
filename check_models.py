#!/usr/bin/env python3
"""
Script para verificar si los modelos TFLite son válidos
"""

import os
import sys

def check_tflite_model(filepath):
    """Verifica si un archivo es un modelo TFLite válido"""
    try:
        # Leer primeros bytes para verificar header TFLite
        with open(filepath, 'rb') as f:
            header = f.read(8)

        # TFLite models start with specific magic bytes
        # Check for TFLITE magic (0x54, 0x46, 0x4C, 0x33) or similar
        if len(header) >= 4:
            # Convert to hex for checking
            header_hex = header.hex()
            print(f"Header hex: {header_hex}")

            # Check for common TFLite signatures - buscar en cualquier posición
            if '54464c33' in header_hex.upper():  # TFL3
                print("[OK] Modelo TFLite valido (TFL3)")
                return True
            elif '54464c' in header_hex.upper():  # TFL
                print("[OK] Modelo TFLite valido")
                return True
            else:
                print("[ERROR] No parece ser un modelo TFLite valido")
                print(f"Header completo: {header_hex}")
                print("Nota: Los modelos pueden ser validos aunque el script diga lo contrario")
                return False
        else:
            print("[ERROR] Archivo demasiado pequeno para ser un modelo TFLite")
            return False

    except Exception as e:
        print(f"[ERROR] Error al leer el archivo: {e}")
        return False

def main():
    print("=== VERIFICADOR DE MODELOS TFLITE ===\n")

    models_to_check = [
        'assets/deteccion.tflite',
        'assets/clasificacion.tflite'
    ]

    for model_path in models_to_check:
        print(f"Verificando: {model_path}")
        if os.path.exists(model_path):
            file_size = os.path.getsize(model_path)
            print(f"Tamano: {file_size} bytes ({file_size/1024/1024:.2f} MB)")

            if check_tflite_model(model_path):
                print("[OK] Modelo valido")
            else:
                print("[ERROR] Modelo invalido")
        else:
            print("[ERROR] Archivo no encontrado")

        print("-" * 50)

if __name__ == "__main__":
    main()
