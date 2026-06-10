import speech_recognition as sr

class TranscribingService:
    def __init__(self):
        self.recognizer = sr.Recognizer()

    async def transcribe(self, file) -> str:
        audio_bytes = await file.read()

        audio_data = sr.AudioData(
            audio_bytes,
            sample_rate=16000,
            sample_width=2
        )

        try:
            return self.recognizer.recognize_google(
                audio_data,
                language="pl-PL"
            )

        except sr.UnknownValueError:
            raise ValueError("Could not understand audio")

        except sr.RequestError as e:
            raise RuntimeError(f"Speech recognition service error: {e}")