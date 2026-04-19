from langchain_core.tools import tool
from database.mongodb import get_db
import json
from bson import json_util
from typing import Optional

# Variable global para el comercio de demo (como especificó el usuario)
ID_COMERCIO_DEFAULT = "comercio_kevin_01"

@tool
async def calcular_resumen_financiero(mes_anio: Optional[str] = None) -> str:
    """
    Útil SOLAMENTE para preguntas explícitas sobre dinero, ventas, ganancias o ingreso neto:
    - ¿Cómo me fue este mes o el mes pasado?
    - ¿Cuál es mi ingreso neto?
    - ¿Cuánto he gastado o cuánto he vendido?
    
    Argumentos opcionales: 
    - mes_anio: cadena en formato 'YYYY-MM'. Si el usuario dice "este mes", envia el mes actual. Si se omite, se intentará usar el mes actual.
    
    IMPORTANTE: NO uses esta herramienta para preguntas generales o saludos.
    """
    db = get_db()
    try:
        from datetime import datetime
        if not mes_anio:
            mes_anio = datetime.now().strftime("%Y-%m")
            
        # 1. Calcular Ingresos Brutos (suma de transacciones tipo "ingreso")
        pipeline_ingresos = [
            {"$match": {"id_comercio": ID_COMERCIO_DEFAULT, "metadata_temporal.mes_anio": mes_anio, "tipo_transaccion": "ingreso"}},
            {"$group": {"_id": None, "total": {"$sum": "$monto"}}}
        ]
        res_ingresos = await db.transacciones.aggregate(pipeline_ingresos).to_list(1)
        ingresos_brutos = res_ingresos[0]["total"] if res_ingresos else 0.0

        # 2. Calcular Gastos Variables (suma de la coleccion gastos)
        pipeline_gastos = [
            {"$match": {"id_comercio": ID_COMERCIO_DEFAULT, "metadata_temporal.mes_anio": mes_anio}},
            {"$group": {"_id": None, "total": {"$sum": "$monto"}}}
        ]
        res_gastos = await db.gastos.aggregate(pipeline_gastos).to_list(1)
        gastos_variables = res_gastos[0]["total"] if res_gastos else 0.0

        # 3. Calcular Gastos Fijos (de la coleccion gastos_fijos_mensuales)
        gastos_fijos_doc = await db.gastos_fijos_mensuales.find_one({
            "id_comercio": ID_COMERCIO_DEFAULT, 
            "mes_anio": mes_anio
        })
        gastos_fijos = gastos_fijos_doc.get("total_gastos_fijos", 0.0) if gastos_fijos_doc else 0.0

        # 4. Calcular Ingreso Neto
        ingreso_neto = ingresos_brutos - (gastos_variables + gastos_fijos)
        
        resultado = {
            "mes_anio": mes_anio,
            "resumen": {
                "ingresos_brutos": round(ingresos_brutos, 2),
                "gastos_variables": round(gastos_variables, 2),
                "gastos_fijos": round(gastos_fijos, 2),
                "ingreso_neto": round(ingreso_neto, 2)
            },
            "mensaje": "Cálculo realizado exitosamente."
        }
        return json.dumps(resultado, ensure_ascii=False)
    except Exception as e:
        return f"Error al calcular resumen financiero: {str(e)}"

@tool
async def consultar_metricas_clientes() -> str:
    """
    Útil SOLAMENTE para datos de clientes y perfiles:
    - ¿Cuántos clientes tuve o tengo?
    - ¿Cuántos clientes son nuevos o no han vuelto?
    - ¿Cuánto gasta en promedio cada cliente (ticket promedio)?
    - Perfil del comprador (edad, demografía, gustos, buyer persona).
    
    IMPORTANTE: NO uses esta herramienta para saludar o para responder preguntas abiertas sobre qué sabes hacer.
    """
    db = get_db()
    try:
        perfil = await db.comercio_perfiles.find_one({"id_comercio": ID_COMERCIO_DEFAULT})
        # Reducir a 10 clientes para no saturar tokens, ya que solo necesitamos un resumen o promedio general
        cursor_clientes = db.clientes.find({"id_comercio": ID_COMERCIO_DEFAULT}).limit(10)
        clientes = await cursor_clientes.to_list(length=10)
        
        resultado = {
            "perfil_comercio": perfil,
            "resumen_clientes": clientes,
            "nota": "Se muestran solo hasta 10 clientes como muestra representativa para no saturar. Para conteos totales confía en el perfil general."
        }
        return json.dumps(resultado, default=json_util.default, ensure_ascii=False)
    except Exception as e:
        return f"Error al consultar la base de datos: {str(e)}"

@tool
async def consultar_transacciones_recientes(limite: Optional[int] = 10) -> str:
    """
    Útil SOLAMENTE para buscar datos específicos de transacciones recientes:
    - ¿Cuándo fue la última vez que vendí más de $X?
    - ¿Qué pasó esta semana con transacciones individuales?
    
    IMPORTANTE: NO uses esta herramienta para preguntas generales. Devuelve máximo 10 transacciones.
    """
    db = get_db()
    try:
        cursor = db.transacciones.find({"id_comercio": ID_COMERCIO_DEFAULT}).sort("fecha_hora", -1).limit(limite)
        docs = await cursor.to_list(length=limite)
        if not docs:
            return "No se encontraron transacciones."
        return json.dumps(docs, default=json_util.default, ensure_ascii=False)
    except Exception as e:
        return f"Error al consultar la base de datos: {str(e)}"
