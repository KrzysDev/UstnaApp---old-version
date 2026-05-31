from app.services.response_evaluation_service import ResponseEvaluationService

service = ResponseEvaluationService()

# Pytanie nr 8 z puli pytań maturalnych
question = "Prawa boskie a prawa ludzkie. Omów zagadnienie na podstawie Antygony Sofoklesa. W swojej odpowiedzi uwzględnij również wybrany kontekst."

# Przykładowa wypowiedź ucznia
student_answer = """
Zagadnienie praw boskich i ludzkich jest jednym z centralnych problemów tragedii Sofoklesa 
zatytułowanej „Antygona". Główna bohaterka, Antygona, staje przed trudnym wyborem – 
czy posłuchać edyktu króla Kreona, który zakazał pochówku jej brata Polinejkesa, 
czy też postąpić zgodnie z prawem boskim i tradycją, która nakazywała oddanie zmarłemu 
należnych mu obrzędów pogrzebowych.

Antygona decyduje się złamać rozkaz Kreona i pochować brata, ponieważ uważa, że prawa 
bogów są wyższe niż prawa stanowione przez ludzi. Mówi wprost, że prawa boskie są 
niepisane i niezmienne, istnieją od zawsze i żaden śmiertelnik nie może ich unieważnić. 
Dla niej obowiązek religijny wobec rodziny jest ważniejszy niż posłuszeństwo wobec władcy.

Z kolei Kreon reprezentuje stanowisko, że prawo państwowe musi być bezwzględnie 
przestrzegane, nawet jeśli wydaje się niesprawiedliwe. Uważa, że władca ma prawo 
decydować o losie poddanych, a nieposłuszeństwo wobec prawa prowadzi do anarchii. 
Kreon traktuje pochówek Polinejkesa jako zdradę państwa, ponieważ Polinejkes wystąpił 
zbrojnie przeciwko własnemu miastu Tebom.

Konflikt między Antygoną a Kreonem kończy się tragicznie – Antygona zostaje skazana 
na zamurowanie w grocie, gdzie popełnia samobójstwo. Jej śmierć pociąga za sobą 
kolejne tragedie: ginie Hajmon, syn Kreona i narzeczony Antygony, a następnie 
Eurydyka, żona Kreona. Kreon zostaje sam, złamany i świadomy swojego błędu.

Jako kontekst chciałbym przywołać postać Tomasza Morusa, kanclerza Anglii za panowania 
Henryka VIII. Morus odmówił uznania króla za głowę Kościoła anglikańskiego, ponieważ 
uważał, że prawo boskie i autorytet papieża stoją wyżej niż wola monarchy. Za swoją 
postawę został skazany na śmierć. Podobnie jak Antygona, Morus poświęcił życie w imię 
wartości, które uważał za nadrzędne wobec prawa stanowionego przez człowieka.

Podsumowując, zarówno dramat Sofoklesa, jak i historia Tomasza Morusa pokazują, 
że konflikt między prawem boskim a ludzkim jest uniwersalny i ponadczasowy. 
Ludzie od wieków stają przed dylematem, czy podporządkować się władzy świeckiej, 
czy postępować zgodnie z wyższymi wartościami moralnymi i religijnymi.
"""

# Pytanie nr 14 z puli pytań maturalnych
question2 = "Czy człowiek decyduje o własnym losie? Omów zagadnienie na podstawie Makbeta Williama Szekspira. W swojej odpowiedzi uwzględnij również wybrany kontekst."

student_answer2 = """
Problem ludzkiego losu i tego, na ile człowiek ma na niego wpływ, to jeden z głównych motywów w "Makbecie" Szekspira.
Z jednej strony pojawiają się czarownice, które przepowiadają Makbetowi władzę, co sugeruje istnienie przeznaczenia.
Jednak to sam Makbet, popychany przez własne ambicje oraz namowy żony, podejmuje zbrodnicze decyzje, by tę przepowiednię zrealizować.
Czarownice jedynie wskazały mu cel, ale to on wybrał drogę zbrodni, mordując Dunkana.
W ten sposób Szekspir pokazuje, że choć los może podsuwać pewne wizje, to człowiek ostatecznie decyduje o swoich czynach.

Jako kontekst można przywołać "Króla Edypa" Sofoklesa, w którym sytuacja jest inna – los bohatera jest z góry zaplanowany przez bogów.
Edyp stara się uciec przed przeznaczeniem, ale każda jego decyzja tylko przybliża go do klęski.
W przeciwieństwie do Edypa, Makbet miał wybór, ale jego żądza władzy okazała się silniejsza niż moralność.
To pokazuje różnicę między starożytnym fatum a renesansową odpowiedzialnością człowieka za własne czyny.
"""

# Przykładowe pytania komisji oraz odpowiedzi ucznia (rozmowa)
examination_board_question1 = "Dlaczego Kreon nie zdecydował się ułaskawić Antygony wcześniej, mimo próśb ze strony Hajmona?"
examination_board_question11_answer = "Kreon uważał, że jako władca musi dbać o powagę władzy państwowej i bezwzględne przestrzeganie prawa. Ułaskawienie Antygony, która była jego krewną, mogłoby zostać odebrane jako nepotyzm i słabość, co mogłoby doprowadzić do buntu poddanych lub anarchii w państwie. Dlatego odrzucił argumenty Hajmona i uważał porządek społeczny za absolutny priorytet."

examination_board_question2 = "Czy postawa Tomasza Morusa różni się w jakiś istotny sposób od postawy Antygony?"
examination_board_question12_answer = "Tak, istnieją pewne różnice. Tomasz Morus działał w realiach nowożytnego państwa chrześcijańskiego i powoływał się na autorytet papieża oraz Kościoła katolickiego. Antygona natomiast odwoływała się do niepisanych praw boskich związanych z tradycją religijną antycznej Grecji oraz więzami rodzinnymi. Jednak ich nadrzędny motyw – wierność sumieniu i prawu wyższemu ponad ludzki edykt – pozostał identyczny."

print("=" * 60)
print("TEST: ResponseEvaluationService")
print("=" * 60)
print(f"\nPytanie główne (1): {question}")
print(f"\nWypowiedź ucznia (1): {student_answer[:200]}...")
print(f"\nPytanie drugie (2): {question2}")
print(f"\nWypowiedź ucznia (2): {student_answer2[:200]}...")
print(f"\nPytanie komisji 1: {examination_board_question1}")
print(f"Odpowiedź ucznia 1: {examination_board_question11_answer[:150]}...")
print(f"\nPytanie komisji 2: {examination_board_question2}")
print(f"Odpowiedź ucznia 2: {examination_board_question12_answer[:150]}...")
print("\nOcenianie z uwzględnieniem rozmowy i drugiego zadania... (to może potrwać chwilę)\n")

result = service.evaluate(
    question,
    student_answer,
    examination_board_question1,
    examination_board_question11_answer,
    examination_board_question2,
    examination_board_question12_answer,
    question2,
    student_answer2
)

print("=" * 60)
print("WYNIK OCENY:")
print("=" * 60)
print(result)
