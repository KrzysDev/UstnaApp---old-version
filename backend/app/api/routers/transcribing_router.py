from app.services.transcribing_service import TranscribingService
from fastapi import APIRouter, UploadFile, File

router = APIRouter(prefix="/transcribing", tags=["transcribing"])

transcribing_service = TranscribingService()

@router.post("/")
async def transcribe_audio(file: UploadFile = File(...)):
    return transcribing_service.transcribe(transcribing_service, file)