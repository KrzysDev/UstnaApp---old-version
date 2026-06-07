from fastapi import APIRouter
import random

router = APIRouter(prefix="/set-of-questions", tags=["set-of-questions"])


@router.get("/")
def get_random_set_of_questions():
    with open("app/data/questions.txt", "r", encoding="utf-8") as file:
        questions = file.read().splitlines()
    
    random_question = questions[random.randint(1, len(questions))]
    
    return {
        "question1" : random_question,
        "question2" : questions[random.randint(1, len(questions))]
    }