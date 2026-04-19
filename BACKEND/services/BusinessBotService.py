import os
from langchain_groq import ChatGroq
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain_community.document_loaders import TextLoader, DirectoryLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_classic.chains import create_history_aware_retriever, create_retrieval_chain
from langchain_classic.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_mongodb.chat_message_histories import MongoDBChatMessageHistory
from datetime import datetime
from pymongo import DESCENDING
import json
from bson import ObjectId
from config import GROQ_API_KEY, MONGO_URI, MONGO_DB

from langchain_classic.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.tools import create_retriever_tool
from services.bot_tools import (
    calcular_resumen_financiero,
    consultar_metricas_clientes,
    consultar_transacciones_recientes
)

# configuración para obtener la base de datos vectorial y los datos del bot que son archivos de texto
# OJO: los datos del bot son opcionales, el bot puede funcionar sin ellos pero se recomienda el uso de textos de negocio
PERSIST_DIRECTORY = "./chroma_db"
DATA_PATH = "./ChatbotData"

# Variable global para crear el RAG conversasional
conversational_rag_chain = None


def get_session_history(session_id: str):
    # Automaticamente lagchain usa esta función para obtener el historial de mensajes
    return MongoDBChatMessageHistory(
        connection_string=MONGO_URI,
        session_id=session_id,
        database_name=MONGO_DB,
        collection_name="chat_histories"
    )


def initialize_chatbot():
    global conversational_rag_chain
    print("🔄 Inicializando Business Bot (Groq + RAG)...")
    api_key = GROQ_API_KEY
    if not api_key:
        print("⚠️ ADVERTENCIA: GROQ_API_KEY no encontrada.")
        return

    # ======= configuración del chat de groq, embeddings y base de datos vectorial ======
    # llama-3.3-70b-versatile: único modelo de Groq confiable para tool-calling
    # Usamos max_tokens=500 para reducir el consumo diario de tokens
    llm = ChatGroq(api_key=api_key,
                   model="llama-3.3-70b-versatile", temperature=0.3, max_tokens=500)
    embeddings = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")

    # Cargar o crear la base de datos vectorial con Chroma
    if os.path.exists(PERSIST_DIRECTORY) and os.listdir(PERSIST_DIRECTORY):
        print("📂 Cargando base de datos vectorial existente...")
        vectorstore = Chroma(
            persist_directory=PERSIST_DIRECTORY, embedding_function=embeddings)
    else:
        print("📚 Procesando documentos de negocio...")
        if not os.path.exists(DATA_PATH):
            os.makedirs(DATA_PATH)
        loader = DirectoryLoader(
            DATA_PATH, glob="*.txt", loader_cls=TextLoader, loader_kwargs={'encoding': 'utf-8'})
        docs = loader.load()
        if not docs:
            print(
                "⚠️ No hay documentos en ChatbotData. El bot funcionará sin conocimiento de negocio específico.")
            vectorstore = Chroma(embedding_function=embeddings,
                                 persist_directory=PERSIST_DIRECTORY)
        else:
            text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=400, chunk_overlap=80)  # Chunks pequeños = menos tokens
            splits = text_splitter.split_documents(docs)
            vectorstore = Chroma.from_documents(
                documents=splits, embedding=embeddings, persist_directory=PERSIST_DIRECTORY)
            print("✅ Documentos procesados.")

    retriever = vectorstore.as_retriever(search_kwargs={"k": 1})  # 1 chunk = menos tokens
    retriever_tool = create_retriever_tool(
        retriever,
        "busqueda_base_conocimiento",
        "Busca en la base de conocimientos del negocio para responder dudas sobre procedimientos, historia de la empresa o reglas de negocio."
    )
    
    tools = [
        retriever_tool,
        calcular_resumen_financiero,
        consultar_metricas_clientes,
        consultar_transacciones_recientes
    ]

    # Prompt corto = menos tokens de sistema en cada llamada
    system_prompt = (
        "Usuario: {user_name}. Fecha: {current_date}. Comercio: 'comercio_kevin_01'.\n"
        "Eres un asistente de negocios. Usa datos exactos de las herramientas.\n"
        "REGLAS:\n"
        "1. Si el usuario saluda o hace preguntas generales, responde de forma amigable SIN usar herramientas.\n"
        "2. Para preguntas sobre el negocio/procedimientos, usa 'busqueda_base_conocimiento'.\n"
        "3. Para datos numéricos/reportes/transacciones, usa las herramientas de MongoDB.\n"
        "4. Nunca inventes datos. Sé directo y conciso."
    )

    agent_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
            MessagesPlaceholder("agent_scratchpad"),
        ]
    )

    agent = create_tool_calling_agent(llm, tools, agent_prompt)
    agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

    conversational_rag_chain = RunnableWithMessageHistory(
        agent_executor,
        get_session_history,
        input_messages_key="input",
        history_messages_key="chat_history",
        output_messages_key="output",
    )
    print("🤖 Business Bot listo (Agente ReAct).")


class BusinessBotService:

    def __init__(self, db):
        self.db = db

    async def create_conversation(self, session_id: str, user_id: str, title: str):
        current_time = datetime.utcnow()
        new_conversation = {
            "session_id": session_id,
            "user_id": user_id,
            "title": title,
            "created_at": current_time,
            "updated_at": current_time
        }
        await self.db["conversations"].insert_one(new_conversation)

    async def update_conversation_timestamp(self, session_id: str):
        current_time = datetime.utcnow()
        await self.db["conversations"].update_one(
            {"session_id": session_id},
            {"$set": {"updated_at": current_time}}
        )

    async def delete_conversation(self, session_id: str):
        # Eliminar la conversación
        delete_conversation = await self.db["conversations"].delete_one({"session_id": session_id})
        
        # Eliminar todos los mensajes de esta conversación
        delete_messages = await self.db["chat_histories"].delete_many({"SessionId": session_id})
        
        print(f"🗑️ Conversación eliminada: {delete_conversation.deleted_count}")
        print(f"🗑️ Mensajes eliminados: {delete_messages.deleted_count}")
        
        return delete_conversation.deleted_count > 0

    async def get_all_conversations(self, user_id: str):
        conversations = []
        cursor = self.db["conversations"].find(
            {"user_id": user_id}).sort("updated_at", -1)
        async for convo in cursor:
            conversations.append({
                "session_id": convo["session_id"],
                "title": convo.get("title", "Conversación sin título"),
                "date": convo.get("updated_at") or convo.get("created_at")
            })
        return {"status": "success", "conversations": conversations}

    async def get_chat_messages(self, session_id: str):
        messages = []
        cursor = self.db["chat_histories"].find({"SessionId": session_id}).sort("_id", 1)
        async for doc in cursor:
            try:
                if "History" in doc:
                    msg_content = json.loads(doc["History"])

                    messages.append({
                        "type": msg_content["type"],
                        "content": msg_content["data"]["content"]
                    })
            except Exception as e:
                print(f"Error parseando mensaje: {e}")
                continue
        if not messages:
            return []
        return messages

    async def get_user_name(self, user_id: str):
        # user_id puede ser un email o un ObjectId
        try:
            user = await self.db.usuarios.find_one({"_id": ObjectId(user_id)})
            if user:
                return user.get("nombre", "Usuario")
        except:
            pass
        
        # Si no es un ObjectId válido, buscar por email
        user = await self.db.usuarios.find_one({"email": user_id})
        if user:
            return user.get("nombre", "Usuario")
        
        # Si no encuentra, retornar el email como nombre
        return user_id.split('@')[0] if '@' in user_id else "Usuario"

    async def chat_with_bot(self, message: str, session_id: str, user_id: str):
        global conversational_rag_chain
        if conversational_rag_chain is None:
            initialize_chatbot()
        conversation_ref = await self.db["conversations"].find_one({"session_id": session_id})
        if not conversation_ref:
            title = message[:40] + "..." if len(message) > 40 else message
            await self.create_conversation(session_id, user_id, title)
        else:
            await self.update_conversation_timestamp(session_id)
        
        user_name = await self.get_user_name(user_id)
        current_date = datetime.now().strftime("%Y-%m-%d")

        try:
            response = await conversational_rag_chain.ainvoke(
                {
                    "input": message,
                    "user_name": user_name,
                    "current_date": current_date
                },
                config={"configurable": {"session_id": session_id}},
            )
            return {"content": response["output"]}
        except Exception as e:
            err_str = str(e)
            # Si el modelo falló al intentar llamar una herramienta en un mensaje
            # conversacional, reintentamos con el LLM directamente sin agente
            if "Failed to call a function" in err_str or "failed_generation" in err_str:
                print("⚠️ Tool-call fallido, reintentando como conversación directa...")
                from langchain_groq import ChatGroq
                from langchain_core.messages import HumanMessage, SystemMessage
                fallback_llm = ChatGroq(
                    api_key=GROQ_API_KEY,
                    model="llama3-groq-8b-8192-tool-use-preview",
                    temperature=0.3,
                    max_tokens=600
                )
                # Recuperar historial reciente para contexto
                history = get_session_history(session_id)
                messages_history = history.messages[-6:] if len(history.messages) > 6 else history.messages
                fallback_messages = [
                    SystemMessage(content=f"Usuario: {user_name}. Fecha: {current_date}. Eres un asistente de negocios. Responde de forma directa y concisa en español.")
                ] + messages_history + [HumanMessage(content=message)]
                fallback_response = await fallback_llm.ainvoke(fallback_messages)
                return {"content": fallback_response.content}
            raise

    async def generate_tts_audio(self, text: str):
        import requests
        api_key = os.environ.get("ELEVENLABS_API_KEY")
        if not api_key:
            raise Exception("ELEVENLABS_API_KEY no configurado")
        
        voice_id = "hpp4J3VqNfWAUOO0d1Us" # Voz femenina elegida por el usuario
        url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
        headers = {
            "xi-api-key": api_key,
            "Content-Type": "application/json"
        }
        data = {
            "text": text,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": {
                "stability": 0.35, # Más expresiva
                "similarity_boost": 0.8
            }
        }
        
        import asyncio
        loop = asyncio.get_event_loop()
        def fetch():
            return requests.post(url, headers=headers, json=data)
        response = await loop.run_in_executor(None, fetch)
        
        if response.status_code != 200:
            raise Exception(f"Error TTS: {response.text}")
            
        return response.content

    async def transcribe_audio(self, audio_bytes: bytes, filename: str = "audio.wav"):
        import requests
        api_key = os.environ.get("ELEVENLABS_API_KEY")
        if not api_key:
            raise Exception("ELEVENLABS_API_KEY no configurado")
            
        import mimetypes
        mime_type, _ = mimetypes.guess_type(filename)
        if not mime_type:
            mime_type = "audio/wav"
            
        url = "https://api.elevenlabs.io/v1/speech-to-text"
        headers = {"xi-api-key": api_key}
        data = {"model_id": "scribe_v1"}
        files = {"file": (filename, audio_bytes, mime_type)}
        
        import asyncio
        loop = asyncio.get_event_loop()
        def fetch():
            return requests.post(url, headers=headers, data=data, files=files)
        response = await loop.run_in_executor(None, fetch)
            
        if response.status_code != 200:
            raise Exception(f"Error STT: {response.text}")
            
        return response.json().get("text", "")
