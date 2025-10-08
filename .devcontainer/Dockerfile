# Imagen base con Flutter estable
FROM ghcr.io/cirruslabs/flutter:stable

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git curl wget unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario vscode
RUN useradd -ms /bin/bash vscode
USER vscode
WORKDIR /workspace

# Asegurarse que Flutter esté actualizado
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter doctor

# Comando por defecto
CMD [ "bash" ]
