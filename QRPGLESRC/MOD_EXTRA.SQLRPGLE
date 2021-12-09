**FREE

Ctl-Opt NOMAIN;

/copy QCOPYBOOK,PROTOTYPE

Dcl-Proc AvaSubject_Open Export;
   Dcl-PI AvaSubject_Open Ind;
      inputCrsId Like(Course_t.id);
      inputSemId Like(Semester_t.id);
   End-PI;

   EXEC SQL
        DECLARE AvaSubject_Cursor CURSOR FOR
            SELECT SubjectId
            FROM SubCourse
            WHERE CourseId = :inputCrsId AND SemId = :inputSemId;

    EXEC SQL OPEN AvaSubject_Cursor;

    Return (SQLSTATE = '00000');
END-PROC;

Dcl-PROC AvaSubject_IsOk Export;
    Dcl-PI AvaSubject_IsOk Ind End-PI;
    Return (SQLSTATE = '00000');
End-Proc;

Dcl-Proc AvaSubject_FetchNext Export;
    Dcl-PI AvaSubject_FetchNext Like(Subject_t.id) End-PI;
    Dcl-S foundSubId Like(Subject_t.id);

    EXEC SQL FETCH AvaSubject_Cursor
        INTO
         :foundSubId;

    Return foundSubId;
End-Proc;

Dcl-Proc AvaSubject_Close Export;
    Dcl-PI AvaSubject_Close End-PI;
    EXEC SQL CLOSE AvaSubject_Cursor;
End-Proc;

Dcl-Proc get_subName_from_id Export;
  Dcl-PI get_subName_from_id Like(Subject_t.name);
    inputSubId Like(Subject_t.id);
  END-PI;

  Dcl-S foundSubName Like(Subject_t.name);

  EXEC SQL
    Select SubName INTO :foundSubName
     FROM SubMaster
     WHERE SubjectId = :inputSubId;

  Return foundSubName;
END-PROC;
