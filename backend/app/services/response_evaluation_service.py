
from app.models.prompts import CONTEXT_SYNTHESIS_PROMPT
from app.services.ai_service import AiService
from app.services.vector_db_service import VectorDBService
from app.models.prompts import *

class ResponseEvaluationService:
    def __init__(self):
        self.ai_service = AiService()
        self.vector_db_service = VectorDBService()

    def evaluate(
        self,
        question: str,
        response: str,
        examination_board_question1: str = "",
        examination_board_question11_answer: str = "",
        examination_board_question2: str = "",
        examination_board_question12_answer: str = "",
        question2: str = "",
        response2: str = ""
    ) -> str:
        print("Generating retrieval queries...")
        retrival_queries = self.ai_service.ask(
            RETRIEVAL_QUERY_GENERATION_PROMPT.format(
                exam_question=question,
                student_answer=response,
                exam_question2=question2,
                student_answer2=response2,
                examination_board_question1=examination_board_question1,
                examination_board_question11_answer=examination_board_question11_answer,
                examination_board_question2=examination_board_question2,
                examination_board_question12_answer=examination_board_question12_answer
            )
        )
        print("Retrieving documents...")
        documents = self.vector_db_service.retrieve(
            retrival_queries
        )

        print("Reranking documents...")
        reranked_retrival = self.ai_service.ask(
           CONTEXT_SYNTHESIS_PROMPT.format(
               exam_question=question,
               student_answer=response,
               exam_question2=question2,
               student_answer2=response2,
               filtered_chunks=documents,
               examination_board_question1=examination_board_question1,
               examination_board_question11_answer=examination_board_question11_answer,
               examination_board_question2=examination_board_question2,
               examination_board_question12_answer=examination_board_question12_answer
           )
        )

        print("Evaluating...")
        evaluation_prompt = EVALUATION_PROMPT.format(
                exam_question=question,
                student_answer=response,
                exam_question2=question2,
                student_answer2=response2,
                rag_context=reranked_retrival,
                examination_board_question1=examination_board_question1,
                examination_board_question11_answer=examination_board_question11_answer,
                examination_board_question2=examination_board_question2,
                examination_board_question12_answer=examination_board_question12_answer
            )
        print("="*100)
        print(evaluation_prompt)
        print("="*100)

        evaluation = self.ai_service.ask(
            evaluation_prompt
        )

        return evaluation