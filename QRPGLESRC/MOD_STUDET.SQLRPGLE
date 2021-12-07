**FREE

Ctl-Opt NOMAIN;

/copy QCOPYBOOK,PROTOTYPE

Dcl-Proc ViewStud_Open Export;
   Dcl-PI ViewStud_Open Ind End-PI;
   EXEC SQL
        DECLARE ViewStud_Cursor CURSOR FOR
            SELECT *
            FROM ViewStudJF;

    EXEC SQL OPEN ViewStud_Cursor;

    Return (SQLSTATE = '00000');
END-PROC;

Dcl-PROC ViewStud_IsOk Export;
    Dcl-PI ViewStud_IsOk Ind End-PI;
    Return (SQLSTATE = '00000');
End-Proc;

Dcl-Proc ViewStud_FetchNext Export;
    Dcl-PI ViewStud_FetchNext LikeDS(ViewStud_t) End-PI;
    Dcl-DS foundStud LikeDS(ViewStud_t);

    EXEC SQL FETCH ViewStud_Cursor
        INTO
         :foundStud.StuId,
         :foundStud.StuName,
         :foundStud.StuCrsId,
         :foundStud.StuAddr,
         :foundStud.CourseName,
         :foundStud.SemId,
         :foundStud.Semester,
         :foundStud.SubjectId,
         :foundStud.SubName,
         :foundStud.Marks;

    Return foundStud;
End-Proc;

Dcl-Proc ViewStud_Close Export;
    Dcl-PI ViewStud_Close End-PI;
    EXEC SQL CLOSE ViewStud_Cursor;
End-Proc;

Dcl-Proc get_student_by_ID Export;
  Dcl-PI get_student_by_ID Like(Student_t.id);
    inputId Like(Student_t.id);
  END-PI;

  Dcl-S sStuId LIke(Student_t.id);

  EXEC SQL
   SELECT StuId INTO :sStuId
    FROM StuMaster
    WHERE StuId = :inputId;

  IF SQLCODE = 100 OR SQLCODE <> 0;
    sStuId = -1;
  ENDIF;

  Return sStuId;
END-PROC;

Dcl-Proc get_course_by_ID Export;
  Dcl-PI get_course_by_ID Like(Course_t);
    inputCrsId Like(Course_t.id);
  END-PI;

  Dcl-DS sCourse LikeDS(Course_t);

  EXEC SQL
     Select CourseID, CourseName
      INTO :sCourse.id, :sCourse.name
     FROM CorMaster
     WHERE CourseId = :inputCrsId;

  IF SQLCODE = 100 OR SQLCODE <> 0;
    sCourse.id = -1;
  ENDIF;

  return sCourse;
END-PROC;

Dcl-Proc get_semester_by_ID Export;
  Dcl-PI get_semester_by_ID Like(Semester_t);
    inputSemId Like(Semester_t.id);
  END-PI;

  Dcl-DS sSem LikeDS(Semester_t);

  EXEC SQL
     Select SemId, Semester
      INTO :sSem.id, :sSem.term
     FROM SemMaster
     WHERE SemId = :inputSemId;

  IF SQLCODE = 100 OR SQLCODE <> 0;
    sSem.id = -1;
  ENDIF;

  return sSem;
END-PROC;

Dcl-Proc valid_Semester_by_name Export;
  Dcl-PI valid_Semester_by_name ind;
    inputSemName Like(Semester_t.term);
    newSemName Like(Semester_t.term);
  END-PI;

  Dcl-S tempSemId Like(Semester_t.id);
  Dcl-S newSemId Like(Semester_t.id);
  EXEC SQL
    Select SemId INTO :tempSemId
     FROM SemMaster
     WHERE Semester = :inputSemName;

  EXEC SQL
    Select SemId INTO :newSemId
     FROM SemMaster
     WHERE Semester = :newSemName;

  IF SQLCODE <> 0;
    Return *OFF;
  ENDIF;

  Return (newSemId > tempSemId);

END-PROC;

Dcl-Proc update_Student_semester Export;
   Dcl-PI update_Student_semester;
      inputStuId Like(Student_t.id);
      inputSemId Like(Semester_t.id);
   END-PI;

   EXEC SQL
      UPDATE StuMaster
      SET SemID = :inputSemId
      WHERE StuId = :inputStuId;

END-PROC;

Dcl-Proc update_Marks Export;
  Dcl-PI update_Marks ind;
    inpStuId Like(Student_t.id);
    inpSubId Like(Subject_t.id);
    inpMarks Like(VIEWSTUD_t.Marks);
  END-PI;

  EXEC SQL
    UPDATE StuDetails
    SET Marks = :inpMarks
    WHERE StuID = :inpStuId AND SUBJECTID = :inpSubId;

  Return (SQLCODE = 0);
END-PROC;

Dcl-Proc get_subject_id Export;
  Dcl-PI get_subject_id Like(Subject_t.id);
    inputSubName Like(Subject_t.name);
  END-PI;

  Dcl-S foundSubID Like(Subject_t.id) inz(-1);

  EXEC SQL
    Select SubjectId INTO :foundSubID
     FROM SubMaster
     WHERE SubName = :inputSubName;

  IF SQLCODE = 100 OR SQLCODE <> 0;
    Return -1;
  ENDIF;

  Return foundSubId;
END-PROC;

Dcl-Proc is_duplicate_subject Export;
  Dcl-PI is_duplicate_subject ind;
      inputStuId Like(Student_t.id);
      inputSubId Like(Subject_t.id);
  END-PI;

  Dcl-S tempSubId Like(Subject_t.id);

  EXEC SQL
    SELECT SubjectID INTO :tempSubId
     FROM StuDetails
     WHERE SubjectID = :inputSubId AND StuId = :inputStuId;

  Return (SQLCODE = 0);
END-PROC;

Dcl-Proc is_subject_in_SubCourse Export;
  Dcl-PI is_subject_in_SubCourse ind;
    inputCourseId Like(Course_t.id);
    inputSubId Like(Subject_t.id);
    inputSemId Like(Semester_t.id);
  END-PI;

  Dcl-S foundSubId Like(Subject_t.id);

  EXEC SQL
    Select SubjectID INTO :foundSubId
     FROM SubCourse
     WHERE CourseId = :inputCourseId AND SubjectID = :inputSubId
        AND SemId = :inputSemId;

  Return (SQLCODE = 0);
END-PROC;

Dcl-Proc add_subject_to_StuDetails Export;
   Dcl-PI add_subject_to_StuDetails;
     inputStuId Like(Student_t.id);
     inputSubId Like(Subject_t.id);
     inputMarks Like(ViewStud_t.Marks);
   END-PI;

   EXEC SQL
     INSERT INTO StuDetails
     VALUES (:inputStuId, :inputSubId, :inputMarks);

END-PROC;

Dcl-Proc has_num_of_subjects Export;
   Dcl-PI has_num_of_subjects Packed(5:0);
      inputStuId Like(Student_t.id);
   END-PI;

   Dcl-S numSubjects Packed(5:0) inz(-1);

   EXEC SQL
     Select Count(SubjectID) INTO :numSubjects
      FROM StuDetails
      WHERE StuId = :inputStuId;

   Return numSubjects;
END-PROC;

Dcl-Proc delete_subject_from_StuDetails Export;
   Dcl-PI *N;
     inputStuId Like(Student_t.id);
     inputSubId Like(Subject_t.id);
   End-PI;

   // TODO: finish delete sql statement
    EXEC SQL
      DELETE FROM StuDetails
      WHERE StuID = :inputStuId AND SubjectID = :inputSubId;

END-PROC;

Dcl-Proc delete_Student_from_Stumaster Export;
   Dcl-PI *N;
     inputStuId Like(Student_t.id);
   End-PI;

   EXEC SQL
     DELETE FROM StuMaster
     WHERE StuId = :inputStuId;

END-PROC;

Dcl-Proc get_search_type Export;
  Dcl-PI get_search_type CHAR(25);
     sStuId       Like(Student_t.id);
     sStuName     Like(Student_t.name);
     sCourseId    Like(Course_t.id);
     sCourseName  Like(Course_t.name);
     sSemester    Like(Semester_t.term);
  END-PI;

  Dcl-S searchType CHAR(25);

  SELECT;
    When sStuId <> 0 AND sStuName = ' ' AND sCourseId = 0 AND sCourseName = ' '
      AND sSemester = ' ';
      searchType = 'StuId';
    When sStuId = 0 AND sStuName <> ' ' AND sCourseId = 0 AND sCourseName = ' '
      AND sSemester = ' ';
      searchType = 'StuName';
    When sStuId <> 0 AND sStuName <> ' ' AND sCourseId = 0 AND sCourseName = ' '
      AND sSemester = ' ';
      searchType = 'InvalidStu';
    When sStuId = 0 AND sStuName = ' ' AND sCourseId <> 0 AND sCourseName = ' '
      AND sSemester = ' ';
      searchType = 'CourseId';
    When sStuId = 0 AND sStuName = ' ' And sCourseId = 0 AND sCourseName <> ' '
      AND sSemester = ' ';
      searchType = 'CourseName';
    When sStuId = 0 AND sStuName = ' ' And sCourseId <> 0 And sCourseName <> ' '
      AND sSemester = ' ';
      searchType = 'InvalidCrs';
    When sStuId = 0 AND sStuName = ' ' AND sCourseId = 0 AND sCourseName = ' '
      AND sSemester <> ' ';
      searchType = 'Semester';
    When sStuId <> 0 AND sStuName = ' ' And sCourseId <> 0 And sCourseName = ' '
      AND sSemester <> ' ';
      searchType = 'StuId+CrsId+Sem';
    When sStuId <> 0 AND sStuName = ' ' And sCourseId = 0 And sCourseName <> ' '
      AND sSemester <> ' ';
      searchType = 'StuId+CrsName+Sem';
    When sStuId = 0 AND sStuName <> ' ' And sCourseId <> 0 And sCourseName = ' '
      AND sSemester <> ' ';
      searchType = 'StuName+CrsId+Sem';
    When sStuId = 0 AND sStuName <> ' ' And sCourseId = 0 And sCourseName <> ' '
      AND sSemester <> ' ';
      searchType = 'StuName+CrsName+Sem';
    Other;
      searchType = 'Invalid';
  ENDSL;

  return searchType;
END-PROC;
