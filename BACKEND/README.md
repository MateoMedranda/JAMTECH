# 🩺 HealthfyAI Backend

¡Bienvenido a **HealthfyAI**! Este proyecto es el backend de una innovadora plataforma de salud que combina inteligencia artificial, procesamiento de lenguaje natural y visión computacional para brindar asistencia médica personalizada, diagnósticos preliminares y recomendaciones inteligentes.

---

## 🚀 ¿Qué es HealthfyAI?
HealthfyAI es una API desarrollada en **FastAPI** que permite:
- Gestionar usuarios y sus historiales médicos.
- Chatear con un bot médico inteligente (RAG + LLM) que responde preguntas, analiza síntomas y genera recomendaciones.
- Registrar y consultar diagnósticos clínicos, incluyendo análisis dermatológicos, nutricionales y generales.
- Integrar modelos de visión para análisis de imágenes médicas (en desarrollo).

---

## 🧠 Tecnologías principales
- **FastAPI**: Framework web asíncrono y ultrarrápido para Python.
- **MongoDB**: Base de datos NoSQL para almacenar usuarios, historiales y chats.
- **LangChain + Groq**: Orquestación de modelos LLM y RAG para el chatbot médico.
- **HuggingFace Embeddings**: Para procesamiento semántico de textos médicos.
- **ChromaDB**: Vector store para recuperación eficiente de información.
- **Vision AI**: (Próximamente) Análisis de imágenes médicas.

---

## 📦 Estructura del Backend
```
Backend/
├── main.py                # Punto de entrada FastAPI
├── config.py              # Configuración y variables de entorno
├── requeriments.txt       # Dependencias Python
├── database/              # Conexión y utilidades MongoDB
├── models/                # Modelos Pydantic (Usuario, Bot, Imagen, etc.)
├── routers/               # Endpoints REST (usuarios, bot, imágenes)
├── services/              # Lógica de negocio y AI
├── utils/                 # Utilidades (hashing, etc.)
├── ChatbotData/           # Datos y corpus para el bot
└── chroma_db/             # Base de datos vectorial
```

---

## 🔥 Características destacadas
- **Chat Médico Inteligente**: Basado en LLMs y recuperación de contexto clínico.
- **Historial Evolutivo**: Guarda y resume la evolución del paciente.
- **Gestión de Usuarios**: Registro seguro, actualización y consulta.
- **Preparado para IA de Imágenes**: Estructura lista para análisis dermatológico y más.
- **API moderna y documentada**: Swagger UI disponible por defecto.

---

## ⚡ Instalación y uso rápido
1. Clona el repositorio y entra al directorio Backend:
   ```bash
   git clone https://github.com/MateoMedranda/HealthfyAI.git
   cd HealthfyAI/Backend
   ```
2. Instala las dependencias:
   ```bash
   pip install -r requeriments.txt
   ```
3. Configura tus variables de entorno en un archivo `.env`:
   ```env
   MONGO_URI=
   MONGO_DB=
   GROQ_API_KEY=

   LANGCHAIN_TRACING_V2=
   LANGCHAIN_ENDPOINT=
   LANGCHAIN_API_KEY=
   LANGCHAIN_PROJECT=
   MODEL_PATH=
   ...
   ```
4. Ejecuta el servidor:
   ```bash
   fastapi dev main.py
   ```
5. Accede a la documentación interactiva en: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## 🛡️ Seguridad
- Contraseñas hasheadas con bcrypt.
- CORS habilitado para desarrollo.
- Validaciones estrictas en modelos y endpoints.

---


## 🤖 Endpoints principales

### 👤 Usuarios (`/api/users`)
- `POST /api/users/` — Crear un nuevo usuario
- `GET /api/users/` — Listar todos los usuarios
- `GET /api/users/{email}` — Obtener usuario por email
- `PUT /api/users/{email}` — Actualizar usuario por email
- `DELETE /api/users/{email}` — Eliminar usuario por email

### 💬 Chat Médico (`/medical-bot`)
- `POST /medical-bot/chat/{session_id}?user_id=...` — Enviar mensaje al bot médico (requiere `user_id` y `session_id`)
- `GET /medical-bot/chat-messages/{session_id}` — Obtener historial de mensajes de chat de una sesión
- `GET /medical-bot/conversations/{user_id}` — Listar todas las conversaciones de un usuario
- `GET /medical-bot/clinical-summary/{session_id}` — Obtener resumen clínico generado por el bot para una sesión
- `GET /medical-bot/clinical-records/{session_id}?limit=5` — Obtener últimos registros clínicos de la sesión (parámetro `limit` opcional)

### 🖼️ Detección de Imágenes (`/image-prediction`)
- `POST /image-prediction/` — Analizar imagen médica (subir archivo en `form-data` como `file`)

Todos los endpoints devuelven respuestas en formato JSON y gestionan errores con códigos HTTP apropiados.

---

## 📚 Créditos y agradecimientos
- [FastAPI](https://fastapi.tiangolo.com/)
- [LangChain](https://www.langchain.com/)
- [MongoDB](https://www.mongodb.com/)
- [Groq](https://groq.com/)
- [HuggingFace](https://huggingface.co/)

---

## 🏥 HealthfyAI — ¡Tu salud, potenciada por IA!
