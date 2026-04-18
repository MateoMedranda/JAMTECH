
# Usar una imagen base ligera de Python
FROM python:3.10-slim

# Establecer directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema necesarias para OpenCV y otras bibliotecas de imagen
# En Debian 12/Trixie, libgl1-mesa-glx a veces da problemas, reemplazamos con libgl1
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Instalar PyTorch CPU PRIMERO para evitar descargar la version CUDA (que pesa GBs)
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Copiar el archivo de requerimientos
COPY requirements.txt .

# Instalar dependencias de Python
# OJO: Al instalar desde requirements.txt, pip vera que torch ya esta instalado y no lo reinstalara si la version coincide
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código de la aplicación
COPY . .

# Exponer el puerto donde corre FastAPI
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
