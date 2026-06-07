from fastapi import APIRouter
import random
import json
from app.models.schemas import Question, SetOfQuestionsResponse
router = APIRouter(prefix="/set-of-questions", tags=["set-of-questions"])


@router.get("/")
def get_random_set_of_questions() -> SetOfQuestionsResponse:
    with open("app/data/questions.txt", "r", encoding="utf-8") as file:
        questions = file.read().splitlines()
    
    public_question = questions[random.randint(0, len(questions)-1)]
    with open("app/data/questions/secret_questions.json", "r", encoding="utf-8") as file:
        secret_questions = json.load(file)

    secret_question_index = random.randint(0, len(secret_questions)-1)
    secret_question = secret_questions[secret_question_index]

    return SetOfQuestionsResponse(
        question1=Question(
            question=public_question,
            question_type="text"
        ),
        question2=Question(
            question=secret_question["question"],
            question_type="image",
            image_path=secret_question['image_path']
        )
    )