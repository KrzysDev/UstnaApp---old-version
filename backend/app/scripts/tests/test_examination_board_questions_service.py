from app.services.examination_board_questions_service import ExaminationBoardQuestionsService
from app.services.ai_service import AiService

service = AiService()

if __name__ == "__main__":
    service = ExaminationBoardQuestionsService(ai_service=service)

    student_answer = """
    W swojej wypowiedzi odniosłem się do dwóch tekstów kultury: „Lalki” Bolesława Prusa oraz „Dziadów cz. IV” Adama Mickiewicza.

    W „Lalce” Wokulski jest przykładem bohatera rozdartego między romantycznym uczuciem a pozytywistycznym pragmatyzmem. Jego miłość do Izabeli Łęckiej prowadzi go do działań irracjonalnych, które ostatecznie powodują jego wewnętrzny kryzys i samotność. Wskazuje to na konflikt między ideałami a rzeczywistością społeczną.

    W „Dziadach cz. IV” Mickiewicz przedstawia Gustawa jako bohatera romantycznego, którego nieszczęśliwa miłość prowadzi do cierpienia i refleksji nad naturą uczucia. Gustaw buntuje się przeciwko światu i racjonalności, uznając miłość za siłę absolutną, która determinuje jego życie i śmierć.
    """

    result = service.generate_questions(
        "Konflikt między romantyzmem a pozytywizmem w literaturze",
        "Motyw nieszczęśliwej miłości i jego konsekwencje w literaturze romantycznej",
        student_answer
    )

    print(result)