# pip install aiofiles
import aiofiles
import asyncio
import random
import json
import base64
import mimetypes
from pathlib import Path
from fastapi import APIRouter
from app.models.schemas import Question, SetOfQuestionsResponse

router = APIRouter(prefix="/set-of-questions", tags=["set-of-questions"])


async def image_to_base64(image_path: Path) -> tuple[str, str] | tuple[None, None]:
    if not image_path.exists():
        print(f"[ERROR] File does not exist: {image_path}")
        return None, None

    mime_type, _ = mimetypes.guess_type(str(image_path))
    if mime_type is None:
        mime_type = "image/jpeg"

    async with aiofiles.open(image_path, "rb") as f:       
        content = await f.read()
        return base64.b64encode(content).decode("utf-8"), mime_type


@router.get("/")
async def get_random_set_of_questions() -> SetOfQuestionsResponse:  
    questions_file = "app/data/questions.txt"

    async with aiofiles.open(questions_file, "r", encoding="utf-8") as file:   
        content = await file.read()
    questions = [line for line in content.splitlines() if line.strip()]

    public_question_text = random.choice(questions)

    secret_file = "app/assets/questions/secret_questions.json"

    async with aiofiles.open(secret_file, "r", encoding="utf-8") as file:      
        content = await file.read()
    secret_questions = json.loads(content)

    secret = random.choice(secret_questions)

    question2 = Question(
        question=secret["question"],
        question_type=secret.get("question_type", "poem"),
        image_base64=None,
        image_mime_type=None,
        image_filename=None
    )

    if question2.question_type == "image" and secret.get("image_path"):
        relative_path = secret["image_path"].lstrip("/")
        img_path = Path(relative_path)

        base64_str, mime_type = await image_to_base64(img_path)     

        if base64_str:
            question2.image_base64 = base64_str
            question2.image_mime_type = mime_type
            question2.image_filename = img_path.name

    elif question2.question_type == "poem" and secret.get("poem"):
        question2.question = f"{secret['question']}\n\n{secret['poem']}"

    question1 = Question(
        question=public_question_text,
        question_type="poem",
        image_base64=None,
        image_mime_type=None,
        image_filename=None
    )

    return SetOfQuestionsResponse(question1=question1, question2=question2)