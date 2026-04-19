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
    # Crear el LLM de Groq, modificar temperatura para regular creatividad, alternar modelos si es necesario
    llm = ChatGroq(api_key=api_key,
                   model="llama-3.3-70b-versatile", temperature=0.3)
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
                chunk_size=1000, chunk_overlap=200)
            splits = text_splitter.split_documents(docs)
            vectorstore = Chroma.from_documents(
                documents=splits, embedding=embeddings, persist_directory=PERSIST_DIRECTORY)
            print("✅ Documentos procesados.")

    retriever = vectorstore.as_retriever()

    # ======= configuración de prompts y cadenas de RAG ======
    contextualize_q_system_prompt = (
        "Given a chat history and the latest user question "
        "which might reference context in the chat history, "
        "formulate a standalone question which can be understood "
        "without the chat history. Do NOT answer the question, "
        "just reformulate it if needed and otherwise return it as is."
    )

    # recuperación del contexto permitiendo tener memoria de chat
    contextualize_q_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", contextualize_q_system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )

    # prompt principal del bot con contexto de negocio
    system_prompt = (
        "El nombre del usuario es {user_name}. Siempre responde solo con el nombre no con el apellido. "
        "Eres un asistente experto en negocios, emprendimiento y análisis del estado empresarial. "
        "Tu objetivo es ayudar al usuario a comprender el estado de su negocio, estrategias, finanzas, y áreas de mejora. "
        "\n\n"
        "Debes hacer preguntas relevantes sobre la situación de su negocio si falta información, para darle las mejores recomendaciones. "
        "Además, no redactes respuestas tan largas, solo responde con lo que sea necesario, siendo conciso y directo. "
        "Utiliza los siguientes fragmentos de contexto recuperado (RAG) "
        "para responder a la pregunta de negocio. Si no sabes, dilo, no inventes nada y que no haya redundancia, sé claro con las respuestas. "
        "Compórtate como un asesor de negocios experto, pero si no sabes la respuesta, no inventes."
        "\n\n"
        "{context}"
    )

    # prompt de preguntas y respuestas con contexto
    qa_prompt = ChatPromptTemplate.from_messages(
        [
            ("system", system_prompt),
            MessagesPlaceholder("chat_history"),
            ("human", "{input}"),
        ]
    )

    history_aware_retriever = create_history_aware_retriever(
        llm, retriever, contextualize_q_prompt)
    question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)
    rag_chain = create_retrieval_chain(
        history_aware_retriever, question_answer_chain)
    conversational_rag_chain = RunnableWithMessageHistory(
        rag_chain,
        get_session_history,
        input_messages_key="input",
        history_messages_key="chat_history",
        output_messages_key="answer",
    )
    print("🤖 Business Bot listo.")


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

        response = conversational_rag_chain.invoke(
            {
                "input": message,
                "user_name": user_name
            },
            config={"configurable": {"session_id": session_id}},
        )
        return {"content": response["answer"]}

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
