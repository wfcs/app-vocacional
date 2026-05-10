"""Entrypoint para deploy serverless na Vercel."""
import sys
from pathlib import Path

# Garante que o pacote `app/` (na raiz do backend/) seja importável no runtime da Vercel
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.main import app  # noqa: E402, F401
