import os
from fastapi import APIRouter, Path, HTTPException
from fastapi.responses import PlainTextResponse

router = APIRouter(prefix="/questions", tags=["questions"])


class QuestionsManager:
    _questions: list[str] = []

    @classmethod
    def load_questions(cls):
        if cls._questions:
            return

        router_dir = os.path.dirname(os.path.abspath(__file__))
        file_path = os.path.abspath(os.path.join(router_dir, "..", "..", "data", "questions.txt"))

        if not os.path.exists(file_path):
            raise RuntimeError(f"Questions file not found at: {file_path}")

        try:
            with open(file_path, "r", encoding="utf-8") as file:
                for line in file:
                    cleaned_line = line.strip()
                    if cleaned_line:
                        cls._questions.append(cleaned_line)
        except Exception as e:
            raise RuntimeError(f"Error reading questions file: {e}")

    @classmethod
    def get_all_as_string(cls) -> str:
        return "\n".join(cls._questions)

    @classmethod
    def get_by_index(cls, index: int) -> str:
        if index < 1 or index > len(cls._questions):
            raise HTTPException(
                status_code=404,
                detail=f"Nie znaleziono pytania o indeksie {index}. Dostepny zakres to 1-{len(cls._questions)}."
            )
        return cls._questions[index - 1]

    @classmethod
    def get_all_list(cls) -> list[str]:
        return cls._questions


QuestionsManager.load_questions()


# Bez rate limitera — endpointy czytają wyłącznie z pamięci, są błyskawiczne
@router.get("/all", response_class=PlainTextResponse)
def get_all_questions_as_string():
    return QuestionsManager.get_all_as_string()


@router.get("/{index}")
def get_question_by_index(
    index: int = Path(..., description="1-based index of the question (1 to 76)")
):
    return {"index": index, "question": QuestionsManager.get_by_index(index)}


@router.get("/")
def get_all_questions():
    return {"count": len(QuestionsManager.get_all_list()), "questions": QuestionsManager.get_all_list()}