from fastapi import APIRouter
from fastapi.responses import JSONResponse
import json

from services.bot_tools import (
    calcular_resumen_financiero,
    consultar_metricas_clientes,
    consultar_transacciones_recientes
)

router = APIRouter(prefix="/analytics", tags=["Analytics Data (Tools test)"])

@router.get("/resumen_financiero")
async def get_resumen_financiero(mes_anio: str = None):
    # Las tools de Langchain pueden ser invocadas asíncronamente con ainvoke
    resultado = await calcular_resumen_financiero.ainvoke({"mes_anio": mes_anio} if mes_anio else {})
    try:
        data = json.loads(resultado)
        return JSONResponse(content=data)
    except:
        return {"result": resultado}

@router.get("/clientes")
async def get_clientes():
    resultado = await consultar_metricas_clientes.ainvoke({})
    try:
        data = json.loads(resultado)
        return JSONResponse(content=data)
    except:
        return {"result": resultado}

@router.get("/transacciones")
async def get_transacciones(limite: int = 20):
    resultado = await consultar_transacciones_recientes.ainvoke({"limite": limite})
    try:
        data = json.loads(resultado)
        return JSONResponse(content=data)
    except:
        return {"result": resultado}
