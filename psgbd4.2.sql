ALTER TABLE note ADD CONSTRAINT unique_grade UNIQUE (id_student, id_curs);
/
CREATE OR REPLACE FUNCTION insert_if_exists(
id_stud IN CHAR, nota_logica IN CHAR)
RETURN VARCHAR2
AS
  mesaj VARCHAR2(32767);
  counter INTEGER;
  grade_id INTEGER;
  course_id INTEGER;
  notation_date DATE;
  creat_la_data DATE;
  update_la DATE;
BEGIN
  SELECT COUNT(*) INTO counter FROM studenti s JOIN note n on s.ID = n.ID_STUDENT
  JOIN cursuri c on n.ID_CURS = c.ID WHERE c.TITLU_CURS = 'Logicã' and s.ID = id_stud;
  IF counter = 0 THEN
    SELECT MAX(n.ID) INTO grade_id FROM studenti s JOIN note n on s.ID = n.ID_STUDENT WHERE s.ID = id_stud;
    SELECT MAX(n.ID_CURS) INTO course_id FROM studenti s JOIN note n on s.ID = n.ID_STUDENT WHERE s.ID = id_stud;
    SELECT SYSDATE INTO notation_date FROM DUAL;
    SELECT SYSDATE INTO creat_la_data FROM DUAL;
    SELECT SYSDATE INTO update_la FROM DUAL;
    INSERT INTO NOTE (ID, ID_STUDENT, ID_CURS, VALOARE, DATA_NOTARE, CREATED_AT, UPDATED_AT)
    VALUES(grade_id + 1, id_stud , course_id +1, nota_logica, notation_date, creat_la_data, update_la);
    mesaj := 'Studentului cu matricolul' || id_stud || ' i s-a adaugat nota' || nota_logica ||
    ' la materia Logicã';
    RETURN mesaj;
  END IF;
  IF counter = 1 THEN
    mesaj := 'Studentul cu matricolul ' || id_stud || ' are deja nota la materia Logicã!';
    RETURN mesaj;
  END IF;
END insert_if_exists;

CREATE OR REPLACE FUNCTION catch_insert_grade(
id_stud IN CHAR, nota_logica IN CHAR)
RETURN VARCHAR2
AS
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
  mesaj := 'Studentului cu matricolul' || id_stud || ' i s-a adaugat nota' || nota_logica ||
    ' la materia Logicã';
  RETURN mesaj;
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    mesaj := 'Studentul cu matricolul ' || id_stud || ' are deja nota la materia Logicã!';
    RETURN mesaj;
END catch_insert_grade;

set SERVEROUTPUT OFF;
DECLARE 
  v_mesaj_prima_metoda VARCHAR2(32767);
  v_mesaj_a_doua_metoda VARCHAR2(32767);
BEGIN
  for i in 1..1000000 LOOP
    v_mesaj_prima_metoda := insert_if_exists(100, 5);
  END LOOP;
  
  for i in 1..1000000 LOOP
    v_mesaj_a_doua_metoda := catch_insert_grade(100, 5);
  END LOOP;
END;

--Prima metoda a rulat in 27.326 secunde
--A doua metoda a rulat in 959.874 secunde