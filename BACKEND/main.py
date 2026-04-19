from fastapi import FastAPI
from contextlib import asynccontextmanager
import config  # Importar config para cargar las variables de entorno
from routers.BusinessBotRouter import router as business_bot_router
from routers.AnalyticsRouter import router as analytics_router
from database.mongodb import connect_to_mongo, close_mongo_connection
from services.BusinessBotService import initialize_chatbot
from fastapi.middleware.cors import CORSMiddleware
import asyncio

@asynccontextmanager
async def lifespan(app: FastAPI):
    connect_to_mongo()
    print("🚀 Servidor levantado, inicializando servicios en background...")

    async def init_services():
        print("⏳ Iniciando carga de modelos...")
        await asyncio.to_thread(initialize_chatbot)
        print("✅ Modelos de IA listos")

    asyncio.create_task(init_services())

    yield

    print("🛑 Apagando servidor...")
    close_mongo_connection()

app = FastAPI(title="Business API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(business_bot_router)
app.include_router(analytics_router)

@app.get("/")
def read_root():
    return {"message": "Business API is running 🤖"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
