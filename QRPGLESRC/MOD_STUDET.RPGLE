**FREE

Ctl-Opt NOMAIN;

/copy QCOPYBOOK,PROTOTYPE

Dcl-PROC find_by_StudentID Export;
    Dcl-PI find_by_StudentID LikeDS(ViewStud_t);
      inputId Like(Student_t.id);
    End-PI;

    Dcl-DS returnStud LikeDS(ViewStud_t);

    returnStud.id = -1;

    // Check if student exists in StuMaster
    SETLL *loval StuMaster;
    READ StuMaster;
    DOW NOT %EOF(StuMaster);
      IF inputId = StuID;
         returnStud.id = StuID;
         returnStud.name = StuName;
         returnStud.crsid = StuCrsID;
         returnStud.SemId = SemId;
      ENDIF;
      READ StuMaster;
    ENDDO;

    // Retrieve student's subject information
    SETLL *start VIEWSTUDJF;
    READ VIEWSTUDJF;
    DOW NOT %EOF(VIEWSTUDJF);
      IF inputId = StuID;
         returnStud.CourseName = CourseName;
         returnStud.Semester = Semester;
         returnStud.SubjectId = SubjectId;
         returnStud.SubName = SubName;
         returnStud.Marks = Marks;
         Leave;
      ENDIF;
      READ VIEWSTUDJF;
    ENDDO;

    Return returnStud;
End-Proc;
