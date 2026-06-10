from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routers.question_router import router as question_router
from app.api.routers.response_evaluation_router import router as response_evaluation_router
from app.api.routers.set_of_questions_router import router as set_of_questions_router
from app.api.routers.examination_board_questions_router import router as examination_board_questions_router
from app.api.routers.transcribing_router import router as transcribing_router

app = FastAPI(
    title="UstnaApp API",
    description="API for preparing students for the oral Polish matura exam -",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(question_router, prefix="/api")
app.include_router(response_evaluation_router, prefix="/api")
app.include_router(set_of_questions_router, prefix="/api")
app.include_router(examination_board_questions_router, prefix="/api")
app.include_router(transcribing_router, prefix="/api")

@app.get("/")
def read_root():
    """Health check endpoint."""
    return {
        "app": "UstnaApp API",
        "status": "running",
        "version": "1.0.0"
    }

