import speech_recognition as sr
from app.services.transcribing_service import TranscribingService

service = TranscribingService()

with sr.Microphone() as source:
    print("Say something!")

    service.recognizer.adjust_for_ambient_noise(
        source,
        duration=1
    )

    audio = service.recognizer.record(
        source,
        duration=60
    )

text = service.transcribe(audio)
print(text)