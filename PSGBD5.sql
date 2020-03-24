-- comanda pentru a adauga constrangerea UNIQUE
ALTER TABLE note ADD CONSTRAINT unique_grade UNIQUE (id_student, id_curs);
/
-- Prima metoda de a incerca inserarea unei note la materia Logica
CREATE OR REPLACE FUNCTION insert_if_exists(
id_stud IN CHAR, nota_logica IN CHAR)
RETURN VARCHAR2
AS
  mesaj VARCHAR2(32767); -- mesajul care va fi returnat
  counter INTEGER; -- variabila in care imi pastrez cate note are studentul la materia logica
  grade_id INTEGER; -- variabila in care retin ID-ul ultimei note existente a unui student
  course_id INTEGER; -- variabila in care retin ID-ul ultimului curs inregistrat in baza de date
  notation_date DATE; -- am presupus cele 3 variabile care stocheaza date ca fiind data inserarii noii note
  creat_la_data DATE;
  update_la DATE;
BEGIN
  SELECT COUNT(*) INTO counter FROM studenti s JOIN note n on s.ID = n.ID_STUDENT
  JOIN cursuri c on n.ID_CURS = c.ID WHERE c.TITLU_CURS = 'Logicã' and s.ID = id_stud;
  -- numar cate note are studentul cu id-ul dat ca argument la materia Logica 
  IF counter = 0 THEN -- daca nu are note
    SELECT MAX(n.ID) INTO grade_id FROM studenti s JOIN note n on s.ID = n.ID_STUDENT WHERE s.ID = id_stud;
    -- iau id ul ultimei note inserate
	SELECT MAX(n.ID_CURS) INTO course_id FROM studenti s JOIN note n on s.ID = n.ID_STUDENT WHERE s.ID = id_stud;
    -- iau id-ul ultimului curs inserat
	SELECT SYSDATE INTO notation_date FROM DUAL;
    SELECT SYSDATE INTO creat_la_data FROM DUAL;
    SELECT SYSDATE INTO update_la FROM DUAL;
	-- asignez variabilelor data curenta
    INSERT INTO NOTE (ID, ID_STUDENT, ID_CURS, VALOARE, DATA_NOTARE, CREATED_AT, UPDATED_AT)
    VALUES(grade_id + 1, id_stud , course_id +1, nota_logica, notation_date, creat_la_data, update_la);
    -- inserez noua nota avand ca id-ul 'urmatoarei' note (daca ultima nota inserata avea id-ul 100 , aceasta noua nota are id-ul 101)
	-- am folosit aceasi metoda si pentru id-ul cursului
	mesaj := 'Studentului cu matricolul' || id_stud || ' i s-a adaugat nota' || nota_logica ||
    ' la materia Logicã';
    RETURN mesaj;
  END IF;
  IF counter = 1 THEN
    mesaj := 'Studentul cu matricolul ' || id_stud || ' are deja nota la materia Logicã!';
    RETURN mesaj;
  END IF;
END insert_if_exists;

-- A doua metoda de a incerca inserarea unei note la materia Logica
CREATE OR REPLACE FUNCTION catch_insert_grade(
id_stud IN CHAR, nota_logica IN CHAR)
RETURN VARCHAR2
AS
-- am folosit aceleasi nume de variabile cu aceleasi functionalitati, pentru a evita eventuale erori sintactice 
  mesaj VARCHAR2(32767);
  grade_id INTEGER;
  course_id INTEGER;
  notation_date DATE := SYSDATE;
  creat_la_data DATE := SYSDATE;
  update_la DATE := SYSDATE;
BEGIN
  SELECT MAX(n.ID) INTO grade_id FROM studenti s JOIN note n on s.ID = n.ID_STUDENT WHERE s.ID = id_stud;
  SELECT MAX(n.ID_CURS) INTO course_id FROM studenti s JOIN note n on s.ID = n.ID_STUDENT WHERE s.ID = id_stud;
  INSERT INTO NOTE (ID, ID_STUDENT, ID_CURS, VALOARE, DATA_NOTARE, CREATED_AT, UPDATED_AT)
  VALUES(grade_id + 1, id_stud , course_id +1, nota_logica, notation_date, creat_la_data, update_la);
  -- am folosit aceasi metoda de inserare a unei noi note. In cazul in care aceasta comanda va esua, se va arunca automat exceptia DUP_VAL_ON_INDEX
  mesaj := 'Studentului cu matricolul' || id_stud || ' i s-a adaugat nota' || nota_logica ||
    ' la materia Logicã';
  RETURN mesaj;
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    mesaj := 'Studentul cu matricolul ' || id_stud || ' are deja nota la materia Logicã!';
    RETURN mesaj;
END catch_insert_grade;

--functia pentru al doilea subpunct
CREATE OR REPLACE FUNCTION medie_student(
nume_stud IN CHAR, prenume_stud IN CHAR)
RETURN VARCHAR2
AS
  medie FLOAT; 
  mesaj VARCHAR2(32767) := 'Facultatea de Informatica';
  counter INTEGER;
  student_inexistent EXCEPTION;
  PRAGMA EXCEPTION_INIT(student_inexistent, -20001);
BEGIN
  SELECT COUNT(*) INTO counter FROM studenti WHERE studenti.nume = nume_stud AND
  studenti.prenume = prenume_stud;
  -- cu ajutorul variabilei counter in care mi-am salvat numarul de atribute pentru studentul cu numele si prenumele dar prin argument
  IF counter = 0 THEN
    raise student_inexistent;
	-- daca acesta nu exista, atunci arunc exceptia 'student_inexistent'
  END IF;
  -- daca exceptia mea nu este aruncata atunci in variabila medie imi voi salva media studentului 
SELECT AVG(valoare) INTO medie FROM note n JOIN studenti s on n.id_student = s.id
WHERE s.nume = nume_stud AND s.prenume = prenume_stud;
  mesaj := 'Media studentului ' || nume_stud || ' ' || prenume_stud || ' este ' || medie || '.';
  RETURN mesaj;
  -- returnez mesajul 
  EXCEPTION
  WHEN student_inexistent THEN
    mesaj := '-20001' || ' Studentul ' || nume_stud || ' ' || prenume_stud ||
    ' nu exista in baza de date.';
    return mesaj;
	-- in cazul exceptiei, returnez un mesaj in loc de 'raise_application_error ' pentru a putea arata functionalitatea exceptiilor in mod explicit
	-- raise_application_error va forta programul sa se opreasca in momentul intampinarii primei exceptii
END medie_student;

-- bloc pentru primul subpunct
set SERVEROUTPUT OFF; -- nu am afisat nimic in cadrul acestor teste intr-un cat la un numar (aproximatic 15000) acesta avea overflow si se oprea fortat
DECLARE 
  v_mesaj_prima_metoda VARCHAR2(32767);
  v_mesaj_a_doua_metoda VARCHAR2(32767);
BEGIN
-- cand am testat cele doua metode, le-am testat separat, punandu-le impreuna in acelasi bloc doar pentru predarea exercitiului
  for i in 1..1000000 LOOP
    v_mesaj_prima_metoda := insert_if_exists(100, 5);
	-- incerc inserarea notei 5 studentului cu matricolul 100
  END LOOP;
  
  for j in 1..1000000 LOOP
    v_mesaj_a_doua_metoda := catch_insert_grade(100, 5);
  END LOOP;
END;

--Prima metoda a rulat in 27.326 secunde
--A doua metoda a rulat in 959.874 secunde

-- bloc pentru al doilea subpunct 

set SERVEROUTPUT ON; 
-- am ales sa pun cele doua subpuncte in blocuri diferite intr-un cat pentru a exemplifica in totalitate functionalitatea 
-- functiei 'medie_student', am afisat rezultatele functiei in 6 cazuri : 3 studenti existenti, 3 inexistenti in baza de date
DECLARE
  TYPE nume IS TABLE OF varchar2(15);
  TYPE prenume IS TABLE OF varchar2(15);
  -- am folosit doua tipuri
  nume_student nume;
  prenume_student prenume;
  v_mesaj varchar2(32767) := ' Facultatea de Informatica';
BEGIN
  prenume_student := prenume('Paula', 'Alex', 'Teodora', 'Diana', 'Marius', 'Darius');
  nume_student := nume('Patras', 'Toader', 'Cumpata', 'Antal', 'Gaborescu', 'Popescovici');
  for i in 1..6 LOOP
  -- desi este usor 'hardcodat', am initializat listele in asa fel incat numele si prenumele de pe pozitia i sa fie un student care apare sau nu in baza de date
    v_mesaj := medie_student(nume_student(i), prenume_student(i));
    DBMS_OUTPUT.PUT_LINE(v_mesaj);
  END LOOP;
END;