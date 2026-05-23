import speech_recognition as sr


class TranscribingService:
    def __init__(self):
        self.recognizer = sr.Recognizer()

    def transcribe(
        self,
        audio_data: sr.AudioData
    ) -> str:
        try:
            return self.recognizer.recognize_google(
                audio_data,
                language="pl-PL"
            )

        except sr.UnknownValueError:
            raise ValueError(
                "Could not understand audio"
            )

        except sr.RequestError as e:
            raise RuntimeError(
                f"Speech recognition service error: {e}"
            )