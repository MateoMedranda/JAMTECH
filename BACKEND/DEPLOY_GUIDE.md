
# Guía de Despliegue en AWS EC2 (Capa Gratuita)

Esta guía te permitirá desplegar tu backend FastAPI en una instancia EC2 de AWS gastando **cero o casi nada** (usando la capa gratuita).

## Prerrequisitos
1.  Cuenta de AWS activa.
2.  Git instalado en tu computadora.

## Paso 1: Crear la Instancia EC2

1.  Ve a la consola de AWS -> **EC2**.
2.  Haz clic en **Lanzar instancia** (Launch Instance).
3.  **Nombre**: `Healthfy-Backend`.
4.  **Imagen (AMI)**: Selecciona **Ubuntu Server 24.04 LTS** (Free tier eligible).
5.  **Tipo de instancia**:
    *   Selecciona `t2.micro` o `t3.micro` (ambas son "Free tier eligible").
    *   *Nota: Estas tienen 1GB de RAM. Configuraremos "Swap Memory" para que no colapsen con los modelos de IA.*
6.  **Par de claves (Key pair)**:
    *   Crea uno nuevo (`healthfy-key`).
    *   Descarga el archivo `.pem` y guárdalo seguro.
7.  **Configuración de red (Network settings)**:
    *   Marca las casillas:
        *   ✅ Allow SSH traffic from Anywhere (0.0.0.0/0).
        *   ✅ Allow HTTPS traffic from the internet.
        *   ✅ Allow HTTP traffic from the internet.
8.  **Almacenamiento (Storage)**:
    *   Sube de 8 GB a **20 GB** (gp3). La capa gratuita te da hasta 30GB gratis.
9.  Haz clic en **Lanzar instancia**.

## Paso 2: Configurar Seguridad (Puertos)

1.  En el panel de EC2, ve a **Security Groups** (Grupos de seguridad).
2.  Selecciona el grupo de seguridad creado para tu instancia (mira el ID en los detalles de la instancia).
3.  Haz clic en **Edit inbound rules** (Editar reglas de entrada).
4.  Añade una regla:
    *   **Type**: `Custom TCP`
    *   **Port range**: `8000` (El puerto de tu FastAPI)
    *   **Source**: `Anywhere-IPv4` (`0.0.0.0/0`)
5.  Guarda las reglas.

## Paso 3: Conectarse al Servidor

Abre tu terminal (PowerShell o Git Bash) en la carpeta donde guardaste tu llave `.pem`.

```bash
# Cambiar permisos de la llave (solo lectura), si estás en Linux/Mac
# chmod 400 healthfy-key.pem

# Conectarse (Reemplaza TU_IP_PUBLICA con la IP de tu instancia en AWS)
ssh -i "healthfy-key.pem" ubuntu@TU_IP_PUBLICA
```

## Paso 4: Instalar Docker y Configurar Memoria Swap

Una vez dentro del servidor (verás `ubuntu@ip-...`), ejecuta estos comandos uno por uno o copia y pega el bloque.

### A. Aumentar Memoria (Swap)
Como `t2.micro` solo tiene 1GB RAM y tus modelos IA consumen mucho, esto es **OBLIGATORIO** para evitar errores.

```bash
# Crear un archivo de swap de 4GB
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### B. Instalar Docker
```bash
# Actualizar sistema
sudo apt-get update

# Instalar Docker
sudo apt-get install -y docker.io docker-compose

# Dar permisos a tu usuario para usar Docker (para no usar sudo siempre)
sudo usermod -aG docker $USER
```
*Ahora desconéctate y vuelve a conectarte para aplicar los permisos de Docker:*
`exit`
*(Vuelve a hacer ssh...)*

## Paso 5: Desplegar la Aplicación

1.  **Clonar tu repositorio**:
    *(Te recomiendo subir tu proyecto a GitHub primero. Si no puedes, puedes usar SCP para copiar los archivos, pero Git es mejor).*
    ```bash
    git clone https://github.com/TU_USUARIO/HealthfyAI.git
    cd HealthfyAI/Backend
    ```

2.  **Crear el archivo .env**:
    Crea tus variables de entorno en el servidor.
    ```bash
    nano .env
    ```
    *Pega ahí el contenido de tu `.env` local (Click derecho para pegar). Presiona `Ctrl+O`, `Enter` para guardar, y `Ctrl+X` para salir.*

3.  **Iniciar el contenedor**:
    ```bash
    docker-compose up -d --build
    ```

## Paso 6: Verificar

Tu backend debería estar corriendo en:
`http://TU_IP_PUBLICA:8000/docs`

¡Listo! 🚀

## Comandos Útiles

- **Ver logs del servidor**:
  ```bash
  docker-compose logs -f
  ```
- **Reiniciar servidor**:
  ```bash
  docker-compose restart
  ```
- **Detener servidor**:
  ```bash
  docker-compose down
  ```
