import os
from fastapi import APIRouter, Path, HTTPException
from fastapi.responses import PlainTextResponse

router = APIRouter(prefix="/questions", tags=["questions"])

class QuestionsManager:
    """Manages public oral Polish matura questions loaded from questions.txt."""
    _questions: list[str] = []

    @classmethod
    def load_questions(cls):
        """Loads questions from file into the global list."""
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
        """Returns all questions joined by a newline."""
        return "\n".join(cls._questions)

    @classmethod
    def get_by_index(cls, index: int) -> str:
        """Returns a 1-indexed question by its index with range validation."""
        if index < 1 or index > len(cls._questions):
            raise HTTPException(
                status_code=404,
                detail=f"Nie znaleziono pytania o indeksie {index}. Dostepny zakres to 1-{len(cls._questions)}."
            )
        return cls._questions[index - 1]

    @classmethod
    def get_all_list(cls) -> list[str]:
        """Returns the list of all questions."""
        return cls._questions


# Initialize the global list on module import
QuestionsManager.load_questions()


@router.get("/all", response_class=PlainTextResponse)
def get_all_questions_as_string():
    """Returns all questions as a single multiline string."""
    return QuestionsManager.get_all_as_string()


@router.get("/{index}")
def get_question_by_index(
    index: int = Path(..., description="1-based index of the question (1 to 76)")
):
    """Returns a single question by its 1-based index."""
    question = QuestionsManager.get_by_index(index)
    return {
        "index": index,
        "question": question
    }


@router.get("/")
def get_all_questions():
    """Returns all questions as a JSON array."""
    return {
        "count": len(QuestionsManager.get_all_list()),
        "questions": QuestionsManager.get_all_list()
    }

