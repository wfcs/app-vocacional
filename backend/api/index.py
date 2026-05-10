"""Entrypoint para deploy serverless na Vercel.

IMPORTANTE: o `app` precisa ser um binding top-level (sem try/except em volta)
para o analisador estatico do @vercel/python detectar.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

# top-level import — necessário para @vercel/python detectar o `app`
from app.main import app  # noqa: E402, F401
