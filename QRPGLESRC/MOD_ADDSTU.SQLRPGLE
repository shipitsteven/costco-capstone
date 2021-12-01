**FREE

Ctl-Opt NOMAIN;

/copy QCOPYBOOK,PROTOTYPE

Dcl-PROC Course_IsOk Export;
    Dcl-PI Course_IsOk Ind End-PI;
    Return (SQLSTATE = '00000');
End-Proc;

Dcl-Proc Course_Open Export;
    Dcl-PI Course_Open Ind End-PI;

    EXEC SQL
        DECLARE Course_Cursor CURSOR FOR
            SELECT CourseID, CourseName
            FROM CORMaster;

    EXEC SQL OPEN Course_Cursor;

    Return (SQLSTATE = '00000');
End-Proc;

Dcl-Proc Course_FetchNext Export;
    Dcl-PI Course_FetchNext LikeDS(Course_t) End-PI;
    Dcl-DS returningCourse LikeDS(Course_t);

    EXEC SQL FETCH Course_Cursor
        INTO :returningCourse.id,
            :returningCourse.name;

    Return returningCourse;
End-Proc;

Dcl-Proc Course_Close Export;
    Dcl-PI Course_Close End-PI;
    EXEC SQL CLOSE Course_Cursor;
End-Proc;

Dcl-Proc is_new_student Export;
    Dcl-PI is_new_student Like(Student_t.id);
        inputName Like(Student_t.name);
    End-PI;

    Dcl-S foundID Like(Student_t.id);

    EXEC SQL
       SELECT STUID INTO :foundID
       FROM StuMaster
       WHERE StuName = :inputName;

    IF SQLCODE = 100 OR SQLCODE <> 0;
      Return -1;
    ENDIF;

    Return foundID;
END-PROC;

Dcl-Proc get_last_stuId Export;
  Dcl-PI get_last_stuId Like(Student_t.id) End-PI;

  Dcl-S lastId Like(Student_t.id);

  EXEC SQL
    SELECT STUID INTO :lastId
     FROM StuMaster
     ORDER BY STUID DESC LIMIT 1;

  IF SQLCODE = 100;
    lastId = -1;
  ENDIF;

  Return lastId;
END-PROC;

Dcl-Proc add_new_Student Export;
  Dcl-PI add_new_Student ind;
    newStudentId   Like(Student_t.id) const;
    newStudentName Like(Student_t.name) const;
    newStudentAddr Like(Student_t.addr) const;
    newStudentCrs  Like(Student_t.crsid) const;
  END-PI;

  Dcl-S semester Like(Student_t.semid) inz(1);

  EXEC SQL
    INSERT INTO StuMaster
    VALUES (:newStudentId, :newStudentName, :newStudentAddr, :newStudentCrs, :semester);

  EXEC SQL
    INSERT INTO StuDetails
    VALUES (:newStudentId, 0, 0);

  Return (SQLCODE = 0);
END-PROC;


