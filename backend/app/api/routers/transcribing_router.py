from app.services.transcribing_service import TranscribingService
from fastapi import APIRouter, UploadFile, File

router = APIRouter(prefix="/transcribing", tags=["transcribing"])

transcribing_service = TranscribingService()

@router.post("/")
async def transcribe_audio(file: UploadFile = File(...)):
    return await transcribing_service.transcribe(file)