**FREE

Ctl-Opt NOMAIN;

/copy QCOPYBOOK,PROTOTYPE

Dcl-PROC Subject_IsOk Export;
    Dcl-PI Subject_IsOk Ind End-PI;
    Return (SQLSTATE = '00000');
End-Proc;

Dcl-Proc Subject_Open Export;
    Dcl-PI Subject_Open Ind End-PI;

    EXEC SQL
        DECLARE Subject_Cursor CURSOR FOR
            SELECT SubjectID, Subname
            FROM SubMaster;

    EXEC SQL OPEN Subject_Cursor;

    Return (SQLSTATE = '00000');
End-Proc;

Dcl-Proc Subject_FetchNext Export;
    Dcl-PI Subject_FetchNext LikeDS(Subject_t) End-PI;
    Dcl-DS returningSubject LikeDS(Subject_t);

    EXEC SQL FETCH Subject_Cursor
        INTO :returningSubject.id,
            :returningSubject.name;

    Return returningSubject;
End-Proc;

Dcl-Proc Subject_Close Export;
    Dcl-PI Subject_Close End-PI;
    EXEC SQL CLOSE Subject_Cursor;
    CLOSE SubMaster;
End-Proc;

Dcl-Proc get_last_courseId Export;
  Dcl-PI get_last_courseId Like(Course_t.id) End-PI;
  Dcl-S lastId Like(Course_t.id) Inz(-1);

  EXEC SQL
    SELECT CourseID INTO :lastId
      FROM CORMASTER ORDER BY CourseID DESC LIMIT 1;

  IF SQLCODE = 100;
    Return -1;
  ENDIF;

  Return lastId;
END-PROC;

Dcl-Proc is_new_course Export;
  Dcl-PI is_new_course ind;
    inputCrsId Like(Course_t.id) const;
    inputSemId Like(Semester_t.id) const;
  End-PI;

  Dcl-S foundCrsId LIKE(Course_t.name);
  Dcl-S foundSemId Like(Semester_t.term);

  EXEC SQL
    SELECT COURSEID, SEMID
     INTO :foundCrsId, :foundSemId
     FROM SUBCOURSE
    WHERE COURSEID = :inputCrsId AND SemID = :inputSemId
    LIMIT 1;

  IF SQLCODE = 100 OR SQLCODE <> 0;
    Return *ON;
  ENDIF;

  Return *OFF;
END-PROC;

// Get Semester ID by name
Dcl-Proc get_semId Export;
  Dcl-PI get_semId Like(Semester_t.id);
    inputSemester Like(Semester_t.term) const;
  END-PI;

  Dcl-S foundID Like(Semester_t.id);

  EXEC SQL
    SELECT SemId INTO :foundID
      FROM SemMaster
     WHERE Semester = :inputSemester;

  IF SQLCODE = 100 OR SQLCODE <> 0;
    Return -1;
  ENDIF;

  Return foundID;
END-PROC;

// Get Course ID by name
Dcl-Proc get_CourseId Export;
  Dcl-PI get_CourseId Like(Course_t.id);
    inputCourse Like(Course_t.name) const;
  END-PI;
  Dcl-S foundID Like(Course_t.id);

  EXEC SQL
    SELECT CourseID INTO :foundID
      FROM CorMaster
     WHERE CourseName = :inputCourse;
  IF SQLCODE = 100 OR SQLCODE <> 0;
    Return -1;
  ENDIF;

  Return foundID;
END-PROC;

// Add new course to CorMaster PF
Dcl-Proc add_new_course Export;
  Dcl-PI add_new_course ind;
    newCourseId   Like(Course_t.id) const;
    newCourseName Like(Course_t.name) const;
  END-PI;

  EXEC SQL
    INSERT INTO CorMaster
    VALUES (:newCourseId, :newCourseName);

  Return (SQLCODE = 0);
END-PROC;

// Add new entry to SubCourse PF
Dcl-Proc add_new_subCourse Export;
  Dcl-PI add_new_subCourse ind;
     subCrsId    Like(Course_t.id)   const;
     subSubjId   Like(Subject_t.id)  const;
     subSemId    Like(Semester_t.id) const;
  END-PI;

  EXEC SQL
    INSERT INTO SubCourse
    VALUES (:subCrsId, :subSubjId, :subSemId);

  Return (SQLCODE = 0);
END-PROC;

// Delete existing combo in SubCourse PF
Dcl-Proc remove_subCourse_combo Export;
  Dcl-PI remove_subCourse_combo ind;
    subCrsId    Like(Course_t.id)   const;
    subSemId    Like(Semester_t.id) const;
  END-PI;

  EXEC SQL
    DELETE FROM SubCourse
    WHERE CourseID = :subCrsId AND SemID = :subSemId;

  Return (SQLCODE = 0);
END-PROC;
