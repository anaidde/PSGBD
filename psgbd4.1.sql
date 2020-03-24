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
  IF counter = 0 THEN
    raise student_inexistent;
  END IF;
SELECT AVG(valoare) INTO medie FROM note n JOIN studenti s on n.id_student = s.id
WHERE s.nume = nume_stud AND s.prenume = prenume_stud;
  mesaj := 'Media studentului ' || nume_stud || ' ' || prenume_stud || ' este ' || medie || '.';
  RETURN mesaj;
  EXCEPTION
  WHEN student_inexistent THEN
    mesaj := '-20001' || ' Studentul ' || nume_stud || ' ' || prenume_stud ||
    ' nu exista in baza de date.';
    return mesaj;
END medie_student;

set SERVEROUTPUT ON;
DECLARE
  TYPE nume IS TABLE OF varchar2(15);
  TYPE prenume IS TABLE OF varchar2(15);
  nume_student nume;
  prenume_student prenume;
  v_mesaj varchar2(32767) := ' Facultatea de Informatica';
BEGIN
  prenume_student := prenume('Paula', 'Alex', 'Teodora', 'Diana', 'Marius', 'Darius');
  nume_student := nume('Patras', 'Toader', 'Cumpata', 'Antal', 'Gaborescu', 'Popescovici');
  for i in 1..6 LOOP
    v_mesaj := medie_student(nume_student(i), prenume_student(i));
    DBMS_OUTPUT.PUT_LINE(v_mesaj);
  END LOOP;
END;