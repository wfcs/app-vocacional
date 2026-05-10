"""Aplicação FastAPI."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.routers import admin, assessments, cities, leads, results

settings = get_settings()

app = FastAPI(
    title="App Vocacional API",
    version="0.1.0",
    description="Backend do teste de aptidão vocacional (RIASEC).",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*", "Authorization"],
)


@app.get("/health", tags=["meta"])
def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(cities.router)
app.include_router(leads.router)
app.include_router(assessments.router)
app.include_router(results.router)
app.include_router(admin.router)
