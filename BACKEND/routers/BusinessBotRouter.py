import io
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from database.mongodb import get_db
from services.BusinessBotService import BusinessBotService
from utils.security import verify_password

router = APIRouter(prefix="/business-bot", tags=["Chat with Business Bot"])

class ChatRequest(BaseModel):
    message: str

def get_businessbot_service(db = Depends(get_db)):
    return BusinessBotService(db)

@router.post("/chat/{session_id}")
async def chat_endpoint(session_id: str, request: ChatRequest, user_id: str, 
                        service: BusinessBotService = Depends(get_businessbot_service),
                        authorized: bool = Depends(verify_password)):
         
    try:
        response_text = await service.chat_with_bot(message=request.message, session_id=session_id, user_id=user_id)
        return {"status": "success", "bot_response": response_text}
    except Exception as e:
        print(f"Error en chat: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/chat-messages/{session_id}")
async def get_chat_messages_endpoint(session_id: str, service: BusinessBotService = Depends(get_businessbot_service),
                                     authorized: bool = Depends(verify_password)):
    try:
        messages_response = await service.get_chat_messages(session_id=session_id)
        return {"status": "success", "messages": messages_response}
    except Exception as e:
        print(f"Error obteniendo mensajes: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/conversations/{user_id}")
async def get_user_conversations(user_id: str, service: BusinessBotService = Depends(get_businessbot_service),
                                 authorized: bool = Depends(verify_password)):
    try:
        conversations = await service.get_all_conversations(user_id=user_id)
        return conversations
    except Exception as e:
        print(f"Error obteniendo conversaciones: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/conversations/{session_id}")
async def delete_conversation_endpoint(session_id: str, service: BusinessBotService = Depends(get_businessbot_service),
                                       authorized: bool = Depends(verify_password)):
    try:
        print(f"🗑️ Eliminando conversación {session_id}")
        result = await service.delete_conversation(session_id=session_id)
        if result:
            return {"status": "success", "message": "Conversación eliminada"}
        else:
            raise HTTPException(status_code=404, detail="Conversación no encontrada")
    except Exception as e:
        print(f"Error eliminando conversación: {e}")
        raise HTTPException(status_code=500, detail=str(e))

class TTSRequest(BaseModel):
    text: str

@router.post("/tts")
async def tts_endpoint(request: TTSRequest, service: BusinessBotService = Depends(get_businessbot_service)):
    try:
        audio_bytes = await service.generate_tts_audio(request.text)
        return StreamingResponse(io.BytesIO(audio_bytes), media_type="audio/mpeg")
    except Exception as e:
        print(f"Error en TTS: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/stt")
async def stt_endpoint(file: UploadFile = File(...), service: BusinessBotService = Depends(get_businessbot_service)):
    try:
        audio_bytes = await file.read()
        text = await service.transcribe_audio(audio_bytes, filename=file.filename)
        return {"status": "success", "text": text}
    except Exception as e:
        print(f"Error en STT: {e}")
        raise HTTPException(status_code=500, detail=str(e))