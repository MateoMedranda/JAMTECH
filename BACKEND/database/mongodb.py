from motor.motor_asyncio import AsyncIOMotorClient
from config import MONGO_URI, MONGO_DB

client: AsyncIOMotorClient = None
db = None

def connect_to_mongo():
    global client, db
    client = AsyncIOMotorClient(MONGO_URI)
    db = client[MONGO_DB]
    print("✅ Conectado a MongoDB")

def close_mongo_connection():
    client.close()
    print("🔴 MongoDB desconectado")

def get_db():
    return db
