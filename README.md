#WildSnap

# 1️⃣ Clonar el repositorio desde GitHub
git clone https://github.com/Ulisess3/WildSnap-app.git
cd WildSnap-app

# 2️⃣ Verificar que Flutter esté instalado
flutter --version

# Si NO tienes Flutter, descárgalo con:
# Linux/macOS:
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Windows (PowerShell):
# git clone https://github.com/flutter/flutter.git -b stable $env:USERPROFILE\flutter
# setx PATH "$env:PATH;$env:USERPROFILE\flutter\bin"

# 3️⃣ Verificar instalación y entorno
flutter doctor

# 4️⃣ Obtener las dependencias del proyecto
flutter pub get

# 5️⃣ (Opcional) Activar soporte para Flutter Web si usarás navegador
flutter config --enable-web

# 6️⃣ Verificar dispositivos disponibles
flutter devices

# 7️⃣ Ejecutar la aplicación:
# Para web:
flutter run -d chrome
# (o, si no tienes Chrome:)
flutter run -d web-server

# Para Android:
flutter run -d emulator-5554  # o el nombre de tu emulador

# Para iOS (macOS con Xcode):
flutter run -d ios

