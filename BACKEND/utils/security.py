from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import os

# Utilizamos HTTPBearer para que Swagger UI solo pida el token directamente
security = HTTPBearer()

# Contraseña maestra para acceder a la API en la Demo
MASTER_PASSWORD = os.getenv("API_PASSWORD", "demo123")

def verify_password(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Verifica que la contraseña enviada en el header sea la correcta.
    """
    if credentials.credentials != MASTER_PASSWORD:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Contraseña incorrecta",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return True

