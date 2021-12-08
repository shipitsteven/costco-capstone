**FREE

Ctl-Opt DFTACTGRP(*No) ACTGRP(*NEW) BNDDIR('CAPSTONE');

/copy QCOPYBOOK,PROTOTYPE

// Global variables
// --- login ---
Dcl-Ds currentCourse LikeDs(Course_t);
Dcl-S loggedIn ind inz(*Off);
Dcl-S foundID packed(5:0) inz(-1);
Dcl-S confirmExit ind inz(*Off);
dcl-s sessionUser char(10) inz(*user);

// --- add subject ---
Dcl-Ds currentSubject LikeDs(Subject_t);
Dcl-S foundSubject packed(5:0) inz(-1);
Dcl-S newSubjectID packed(5:0);

// --- add course ---
Dcl-S currentCourseId Like(Course_t.id);
Dcl-S newCourseSemCombo ind inz(*Off);
Dcl-S foundSemId Like(Semester_t.id);
Dcl-S opSuccessful ind inz(*Off);
Dcl-S selectedSub ind inz(*Off);
Dcl-S subjectCounter packed(5:0) inz(0);
Dcl-S firstSubjIdCache Like(Subject_t.id);
Dcl-S addOrUpdate char(10);

// --- add student ---
Dcl-S foundStuId Like(Student_t.id);
Dcl-S selectedCrs packed(5:0) inz(0);
Dcl-S selectedCrsId Like(Course_t.id);
Dcl-S addSuccessful ind inz(*Off);
Dcl-S lastStuId Like(Student_t.id);

// --- student detail ---
Dcl-DS foundStudent LikeDS(ViewStud_t);
Dcl-S searchType CHAR(25);
Dcl-DS qCourse LikeDS(Course_t);
Dcl-DS qSemester LikeDS(Semester_t);
Dcl-S validSemester ind inz(*Off);
Dcl-S updatingSubId Like(Subject_t.id);
Dcl-S dupSubject ind inz(*Off);
Dcl-S inSubCourse ind inz(*Off);
Dcl-S addCrsId Like(Course_t.id);
Dcl-S addSemId Like(SEMESTER_t.id);
Dcl-S updatedSubName Like(Subject_t.name);
Dcl-S updatedMarks Like(ViewStud_t.Marks);
Dcl-S updatedSub ind inz(*Off);
Dcl-S updatedSemId Like(SEMESTER_t.id);
Dcl-S updatedSem ind inz(*Off);
Dcl-S updatedSemName Like(Semester_t.term);
Dcl-S numOfSubjects Packed(5:0);
Dcl-DS searchParams LikeDS(SearchParams_t);
Dcl-S numOfMarksUpdated packed(5:0);
Dcl-S deletedSubId Like(Subject_t.id);
Dcl-S deletedStuId Like(Student_t.id);

// --- Trimmed string values ---
Dcl-S tStuName Like(Student_t.name);
Dcl-S tCrsName Like(Course_t.name);
Dcl-S tSemName Like(Semester_t.term);
Dcl-S tSubName Like(Subject_t.name);

// --- alphabet translation ---
Dcl-C lo 'abcdefghijklmnopqrstuvwxyz';
Dcl-C up 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

// Main program starts here
DOU indicators.exit = *ON AND loggedIn = *Off;
  EXSR $LoginSR;
ENDDO;

*Inlr = *ON;

// ***************
// LOGIN
// ***************

BegSr $LoginSR;
  CURUSER = sessionUser;
  Write Header;
  Write Footer_M;
  Exfmt LOGIN;
  IF indicators.refresh = *ON;
    clear MSG_LOGIN;
    clear USRNAME;
    clear USRPWD;
    MSG_LOGIN = 'Page refreshed';
  ELSEIF indicators.exit = *ON;
    loggedIn = *Off;
    *INLR = *ON;
  ELSE;
    IF ( %TRIM(USRNAME) = ' ' OR %TRIm(USRPWD) = ' ' );
      MSG_LOGIN = 'User name and/or password cannot be empty';
    Else;

      foundID = getID_by_username(USRNAME);

      If foundID <> -1;
        Chain foundID Users;
        If Password = USRPWD;
          loggedIn = *On;
          CURUSER = USRNAME;
          Clear USRNAME;
          Clear USRPWD;
          Exsr $SelectTable;
        Else;
          MSG_LOGIN = 'Wrong password!';
          clear USRPWD;
        EndIf;
      Else;
        MSG_LOGIN = 'User not found.';
        clear USRPWD;
      EndIf;
    EndIf;
  ENDIF;
ENDSR;

//***********************************************************
// Select Tables
//***********************************************************
BegSr $SelectTable;
  DOW indicators.exit = *OFF;
    Write Header;
    Write Footer_M;
    Exfmt MAINMENU;
    IF indicators.refresh = *ON;
      Clear OPT_NEWSUB;
      Clear OPT_NEWCRS;
      Clear OPT_NEWSTU;
      Clear OPT_VIEWST;
      MSG_MENU = 'Page refreshed';
    ELSE;
      SELECT;
        WHEN (OPT_NEWSUB = '1' AND OPT_NEWCRS = ' ' AND OPT_NEWSTU = ' ' AND OPT_VIEWST = ' ');
          Exsr $NewSubOpt;
          Clear MSG_MENU;
        WHEN (OPT_NEWCRS = '1' AND OPT_NEWSUB = ' ' AND OPT_NEWSTU = ' ' AND OPT_VIEWST = ' ');
          Exsr $NewCrsOpt;
          Clear MSG_MENU;
        WHEN (OPT_NEWSTU = '1' AND OPT_NEWSUB = ' ' AND OPT_NEWCRS = ' ' AND OPT_VIEWST = ' ');
          Exsr $NewStuOpt;
          Clear MSG_MENU;
        WHEN (OPT_VIEWST = '1' AND OPT_NEWCRS = ' ' AND OPT_NEWSTU = ' ' AND OPT_NEWSUB = ' ');
          Exsr $ViewStuOpt;
          Clear MSG_MENU;
        OTHER;
          MSG_Menu = 'Invalid option';
      ENDSL;
    ENDIF;
  ENDDO;
  Clear MSG_MENU;
  MSG_LOGIN = 'Logged out, you can log in again now';
ENDSR;

//***********************************************************
// Add New Subject
//***********************************************************
BegSr $NewSubOpt;
  DOW indicators.exit = *OFF;
    Write Header;
    Write Footer_Add;
    Exfmt NEWSUBJECT;
    IF indicators.back = *ON;
      Clear MSG_NEWSUB;
      LeaveSr;
    ELSEIF indicators.refresh = *ON;
      Clear NEWSUBNAME;
      Clear MSG_NEWSUB;
      MSG_NEWSUB = 'Fields cleared';
    ELSEIF indicators.save = *ON;
      IF NEWSUBNAME = ' ';
        MSG_NEWSUB = 'Subject name cannot be empty';
      ELSE;
        foundSubject = -1;
        SETLL *loval SUBMASTER;
        READ(N) SUBMASTER;
        DOW NOT %EOF(SUBMASTER);
          If %TRIM(NEWSUBNAME) = SUBNAME;
            MSG_NEWSUB = 'Subject already exists.';
            foundSubject = SUBJECTID;
            Leave;
          ENDIF;
          READ(N) SUBMASTER;
        ENDDO;
        IF foundSubject = -1;
          SETGT *hival SUBMASTER;
          READP(E) SUBMAFMT;
          IF %ERROR = '1';
            SUBJECTID = 10;
          ELSE;
            SUBJECTID += 10;
          EndIf;
          SUBNAME = %TRIM(NEWSUBNAME);
          WRITE SUBMAFMT;
          MSG_NEWSUB = 'Subject ' + %trim(%CHAR(NEWSUBNAME))+' ID ' + %CHAR(SUBJECTID) + ' added';
          Clear NEWSUBNAME;
        ENDIF;
      ENDIF;
    ELSE;
      // do nothing
      MSG_NEWSUB = 'Use F8 to add new Subject';
    Endif;
  ENDDO;
  Clear MSG_NEWSUB;
EndSr;

//***********************************************************
// Add New Course
//***********************************************************
BegSr $NewCrsOpt;
  Exsr $Load_Subject_SFL;
  DOW indicators.exit = *Off;
    Write Header;
    Write Footer_Add;
    Exfmt SUBCTL;
    IF indicators.back = *ON;
      Clear SUBCTL;
      LeaveSr;
    ELSEIF indicators.refresh = *ON;
      Exsr $Load_Subject_SFL;
      Clear CRSNAME;
      Clear SEMESTER;
      MSG_NEWCRS = 'Page refreshed, fields cleared';
    ELSEIF indicators.save = *ON;
      IF CRSNAME = ' ';
        MSG_NEWCRS = 'Course name cannot be empty';
      ELSEIF  SEMESTER = ' ';
        MSG_NEWCRS = 'Semester cannot be empty';
      ELSEIF get_semId(SEMESTER) = -1;
        MSG_NEWCRS = 'Semester not found';
      ELSE;
      // validate course for existing course
        currentCourseId = get_courseId(%TRIM(CRSNAME));
        IF currentCourseID <> -1;
         // check for new combo
          newCourseSemCombo = is_new_course(currentCourseId:get_semId(SEMESTER));
         IF newCourseSemCombo = *OFF;
           // Update existing combo in SubCourse
           opSuccessful = *Off;
           selectedSub = *Off;
           Exsr $validate_and_add_first_subj;
           IF selectedSub = *Off;
             MSG_NEWCRS = 'Please select at least one subject';
           ELSE;
             // First delete all matching combo in SubCourse
             opSuccessful = remove_subCourse_combo(currentCourseId:get_semId(SEMESTER));
             // Add the updated combo back in
             add_new_subCourse((currentCourseId):firstSubjIdCache:get_semId(SEMESTER));
             addOrUpdate = 'UPDATED';
             Exsr $add_remaining_subj;
           ENDIF;
         ELSE;
           // Add new combo in SubCourse, but don't add new course in CorMaster
           Exsr $validate_and_add_first_subj;
           IF selectedSub = *Off;
             MSG_NEWCRS = 'Please select at least one subject';
           ELSE;
             addOrUpdate = 'ADDED';
             Exsr $add_remaining_subj;
           ENDIF;
         ENDIF;
        ELSE;
         // Brand new course, add to CorMaster then SubCourse
          currentCourseId = get_last_courseId();
          IF currentCourseId = -1;
            currentCourseId = 0;
          ENDIF;
          // Check if user actually selected any subjects
          currentCourseId += 10;
          Exsr $validate_and_add_first_subj;

          IF selectedSub = *Off;
            MSG_NEWCRS = 'Please select at least one subject';
          ELSE;
            // insert new course into CorMaster
            opSuccessful = *Off;
            opSuccessful = add_new_course((currentCourseId):%TRIM(CRSNAME));

            // insert all selected option into SubCourse
            addOrUpdate = 'ADDED';
            Exsr $add_remaining_subj;
          ENDIF;
        ENDIF;
      ENDIF;
    ElSE;
      MSG_NEWCRS = 'Use F8 to add new Course';
    EndIF;
  ENDDO;
ENDSR;

// **********************
// Validate subject selection and add first subject
// **********************
BegSr $validate_and_add_first_subj;
  Clear MSG_NEWCRS;
  opSuccessful = *Off;
  selectedSub = *Off;
  subjectCounter = 0;
  READC SUBSFL;
  DOW NOT %EOF();
    IF OPT_SUB = '1';
       selectedSub = *On;
       subjectCounter += 1;
       firstSubjIdCache = SUB_ID;
       opSuccessful = add_new_subCourse((currentCourseId):
                                                   SUB_ID:get_semId(SEMESTER));
       Leave;
    ENDIF;
    Clear OPT_SUB;
    READC SUBSFL;
  ENDDO;
ENDSR;

// **********************
// Add remaining selection to SubCourse
// **********************
BegSr $add_remaining_subj;
  opSuccessful = *Off;
  READC SUBSFL;
  DOW NOT %EOF();
    IF OPT_SUB = '1';
      subjectCounter += 1;
      opSuccessful = add_new_subCourse((currentCourseId):
                                       SUB_ID:get_semId(SEMESTER));
    ENDIF;
    Clear OPT_SUB;
    READC SUBSFL;
  ENDDO;

  Exsr $Load_Subject_SFL;

  MSG_NEWCRS = %TRIM(addOrUpdate) +' - Course ID ' + %CHAR(currentCourseId) + ' in '
            + %TRIM(SEMESTER) + ' with ' + %CHAR(subjectCounter)
            +' subject(s) successfully';
ENDSR;

// **********************
// Load Subject Subfile
// **********************
BegSr $Load_Subject_SFL;
  indicators.subClear = *Off;
  Write SUBCTL;
  SubRRN = 0;
  indicators.subClear = *On;

  IF Subject_Open();
    currentSubject = Subject_FetchNext();
    DOW Subject_IsOk();
      SubRRN += 1;
      SUB_ID = currentSubject.id;
      SUB_NAME = currentSubject.name;
      Write SUBSFL;
      currentSubject = Subject_FetchNext();
    ENDDO;
    Subject_Close();
  ENDIF;
ENDSR;

// **********************
// New Student
// **********************
BegSr $NewStuOpt;
   Exsr $Load_Course_SFL;
   DOW indicators.exit = *OFF;
      Write Header;
      Write Footer_Add;
      Exfmt CRSCTL;
      IF indicators.back = *ON;
        Clear NSTUDNAME;
        Clear NSTUDADDR;
        Clear CRSCTL;
        LeaveSr;
      ELSEIF indicators.refresh = *ON;
        Exsr $Load_Course_SFL;
        Clear NSTUDNAME;
        Clear NSTUDADDR;
        Clear CRSCTL;
        MSG_NEWSTU = 'Page refreshed, fields cleared';
      ELSEIF indicators.save = *ON;
         IF NSTUDNAME = ' ' OR NSTUDADDR = ' ';
           MSG_NEWSTU = 'Student name or address cannot be empty';
         ELSE;
           // check for existing student
          tStuName = %TRIM(NSTUDNAME);
          foundStuId = is_new_student(tStuName);
          IF foundStuId <> -1;
            MSG_NEWSTU = 'Student already exist. Their ID is ' + %CHAR(foundStuId);
          ELSE;
            // make sure only one option is selected
            selectedCrs = 0;
            READC CRSSFL;
            DOW NOT %EOF;
              IF OPT_CRS = '1';
                selectedCrs += 1;
              ENDIF;
              READC CRSSFL;
            ENDDO;
            // Selected multiple courses, invalid input
            IF selectedCrs > 1;
               Exsr $Load_Course_SFL;
               MSG_NEWSTU = 'Please select ONLY ONE course. You selected ' + %CHAR(selectedCrs)
              + ' courses';
            ELSEIF selectedCrs = 0;
               MSG_NEWSTU = 'Please select a course for the new student';
            ELSE;
              // add new student with selected course
              lastStuId = get_last_stuId();
              IF lastStuId = -1;
                lastStuId = 1;
              Else;
               lastStuId += 1;
              ENDIF;
              addSuccessful = *Off;
              addSuccessful = add_new_student(lastStuId:%TRIM(NSTUDNAME):%TRIM(NSTUDADDR):CRS_ID);
              MSG_NEWSTU = 'Student ID ' + %CHAR(lastStuId) + ' ' + %TRIM(NSTUDNAME)
              + ' successfully enrolled in ' + %TRIM(CRS_NAME);
              Exsr $Load_Course_SFL;
            ENDIF;
          ENDIF;
         ENDIF;
      ELSE;
      ENDIF;
   ENDDO;
ENDSR;


// **********************
// Load Course Subfile
// **********************
BegSr $Load_Course_SFL;
  indicators.subCrsClear = *Off;
  Write CRSCTL;
  CrsRRN = 0;
  indicators.subCrsClear = *On;

  IF Course_Open();
    currentCourse = Course_FetchNext();
    DOW Course_IsOk();
      CrsRRN += 1;
      CRS_ID = currentCourse.id;
      CRS_NAME = currentCourse.name;
      Write CrsSFL;
      currentCourse = Course_FetchNext();
    ENDDO;
    Course_Close();
  ENDIF;
ENDSR;

// **********************
// View Student Details
// **********************
BegSr $ViewStuOpt;
   // load empty subfile
  MSG_STUDET = 'Enter some search criteria to begin';
  Exsr $clearSearchSfl;
  Write Header;
  Write Footer_Up;
  Write NORESULT;

  searchParams.StuId = 0;
  searchParams.StuName = ' ';
  searchParams.CourseId = 0;
  searchParams.CourseName = ' ';
  searchParams.Semester = ' ';

  DOW indicators.exit = *Off;
    Write NORESULT;

    indicators.sflFold = '0' ; //=2 lines
    indicators.sflFold = '1' ; //=1 lines
    Mode = indicators.sflFold;
    Exfmt STUDCTL; // keep, because it shows the screen
    indicators.sflFold = Mode;

    IF indicators.back = *ON;
      Exsr $clearSearchParams;
      LeaveSr;
    ELSEIF indicators.refresh = *ON;
      searchParams.StuId = 0;
      searchParams.StuName = ' ';
      searchParams.CourseId = 0;
      searchParams.CourseName = ' ';
      searchParams.Semester = ' ';
      Exsr $clearSearchParams;
      Exsr $clearSearchSfl;
      MSG_STUDET = 'Page refreshed, fields cleared';
    ELSE;
         tStuName = %TRIM(ST_INPNAM);
         tCrsName = %TRIM(ST_INPCRSN);
         tSemName = %TRIM(ST_INPSEM);
      IF searchParams.StuId <> St_INPID OR searchParams.StuName <> tStuName OR
        searchParams.CourseId <> ST_INPCRS OR searchParams.CourseName <> tCrsName OR
        searchParams.Semester <> tSemName;

        searchType = get_search_type(ST_INPID:tStuName:ST_INPCRS:tCrsName:tSemName);
        MSG_STUDET = 'Search type: ' + %TRIM(searchType);

        SELECT;
           When searchType = 'Invalid';
            MSG_STUDET = 'Invalid search parameters, please input only 1 or all 3 search fields';
            Exsr $clearSearchSfl;
           When searchType = 'InvalidStu';
            MSG_STUDET = 'Invalid search parameters, please only put ID or Name';
            Exsr $clearSearchSfl;
           When searchType = 'InvalidCrs';
            MSG_STUDET = 'Invalid search parameters, please only put ID or Name';
            Exsr $clearSearchSfl;
           When searchType = 'StuId';
            Exsr $searchByStudentId;
           When searchType = 'StuName';
            Exsr $searchByStudentName;
           When searchType = 'CourseId';
            Exsr $searchByCourseId;
           When searchType = 'CourseName';
            Exsr $searchByCourseName;
           When searchType = 'Semester';
            Exsr $searchBySemester;
           When searchType = 'StuId+CrsId+Sem';
            Exsr $searchByStuIdCrsIdSem;
           When searchType = 'StuId+CrsName+Sem';
            Exsr $searchByStuIdCrsNameSem;
           When searchType = 'StuName+CrsId+Sem';
            Exsr $searchByStuNameCrsIdSem;
           When searchType = 'StuName+CrsName+Sem';
            Exsr $searchByStuNameCrsNameSem;
           Other;
            Exsr $clearSearchSfl;
        ENDSL;

        searchParams.StuId = ST_INPID;
        searchParams.StuName = %TRIM(ST_INPNAM);
        searchParams.CourseId = ST_INPCRS;
        searchParams.CourseName = %TRIM(ST_INPCRSN);
        searchParams.Semester = %TRIM(ST_INPSEM);

      ELSE;
        Exsr $StudentSubjectOptions;
      ENDIF;
   ENDIF;
  ENDDO;
ENDSR;

// **********************
// Change Semester
// **********************
BegSr $ChangeSemester;
  DOW indicators.exit = *OFF;
    CS_STID = ST_ID;
    CS_STNAME = ST_NAME;
    CS_CRSNAM = ST_CRSNAME;
    IF updatedSem = *ON;
      CS_SEMEST = updatedSemName;
    ELSE;
      CS_SEMEST = ST_SEMEST;
    ENDIF;
    Write Footer_ADD;
    Exfmt CHGSMST;

    IF indicators.back = *ON;
      Clear CS_STID;
      Clear CS_STNAME;
      Clear CS_CRSNAM;
      Clear CS_SEMEST;
      Clear MSG_CHGSEM;
      Exsr $reloadSearchResult;
      LeaveSr;
    ELSEIF indicators.refresh = *ON;
      IF updatedSem = *ON;
        CS_SEMEST = updatedSemName;
      ELSE;
        CS_SEMEST = ST_SEMEST;
      ENDIF;
      MSG_CHGSEM = 'Page refreshed, fields cleared';
    ELSEIF indicators.save = *ON;
      updatedSem = *OFF;
      // is semester valid? is it greater than current semester?
      tSemName = %TRIM(CS_SEMEST);
      validSemester = valid_Semester_by_name(ST_SEMEST:tSemName);
      IF validSemester = *ON;
        updatedSemId = get_SemId(tSemName);
        update_Student_semester(CS_STID:updatedSemId);
        updatedSemName = CS_SEMEST;
        MSG_CHGSEM = 'Student semester updated to: ' + %TRIM(CS_SEMEST);
        updatedSem = *ON;
      Else;
        MSG_CHGSEM = 'Invalid Semester name or Semester not greater than current semester';
      ENDIF;
    ELSE;
     // nothing
    ENDIF;

  ENDDO;
ENDSR;

// **********************
// Add Subjects for Students
// **********************
BegSr $AddSubjectToStudent;
  DOW indicators.exit = *OFF;
    DT_STID = ST_ID;
    DT_STNAME = ST_NAME;
    DT_CRSNAME = ST_CRSNAME;
    DT_SEMEST = ST_SEMEST;
    IF updatedSub = *ON;
      DT_SUBNAME = updatedSubName;
      DT_Marks = updatedMarks;
    ELSE;
      DT_SUBNAME = ST_SUBJECT;
      DT_MARKS = ST_MARKS;
    ENDIF;
    Write Footer_ADD;
    Exfmt ADDDETAIL;

    IF indicators.back = *ON;
      Clear DT_STID;
      Clear DT_STNAME;
      Clear DT_CRSNAME;
      Clear DT_SEMEST;
      Clear DT_SUBNAME;
      Clear DT_MARKS;
      Clear MSG_ADDDET;
      Exsr $reloadSearchResult;
      LeaveSr;
    ELSEIF indicators.refresh = *ON;
      Clear DT_SUBNAME;
      Clear DT_MARKS;
      MSG_ADDDET = 'Page refreshed, fields cleared';
    ELSEIF indicators.save = *ON;
      dupSubject = *OFF;
      inSubCourse = *OFF;
      // check if subject is in subcourse with matching course id
      tSubName = %TRIM(DT_SUBNAME);
      updatingSubId = get_subject_id(tSubName);
      IF updatingSubId = -1;
        MSG_ADDDET = 'Invalid subject - Subject does not exist';
        ITER;
      ENDIF;

      dupSubject = is_duplicate_subject(DT_STID:updatingSubId);
      IF dupSubject = *ON;
        update_Marks(DT_STID:updatingSubId:DT_MARKS);
        updatedSubName = %TRIM(DT_SUBNAME);
        updatedMarks = DT_Marks;
        MSG_ADDDET = 'Student already enrolled. Updating Marks to ' + %CHAR(DT_MARKS);
        ST_MARKS = updatedMarks;
        updatedSub = *ON;
      ELSE;
        updatedSub = *OFF;
        addCrsId = get_CourseId(DT_CRSNAME);
        addSemId = get_SemId(DT_SEMEST);
        inSubCourse = is_subject_in_SubCourse(addCrsId:updatingSubId:addSemId);

        IF inSubCourse = *ON;
          add_subject_to_StuDetails(DT_STID:updatingSubId:DT_Marks);
          MSG_ADDDET = 'BINGO! Student added to new subject';
          updatedSubName = %TRIM(DT_SUBNAME);
          updatedMarks = DT_Marks;
          updatedSub = *ON;
        ELSE;
          MSG_ADDDET = 'Subject is not in the right Course or Semester';
        ENDIF;
      ENDIF;
    ENDIF;
  ENDDO;

ENDSR;

BegSr $DeleteSubject;
   numOfSubjects = has_num_of_subjects(ST_ID);
   deletedStuId = ST_ID;
   deletedSubId = ST_SUBID;
   // check if student has more than 1 subject
   IF numOfSubjects > 1;
     del_StuId = deletedStuId;
     del_SubId = deletedSubId;
     Exfmt WIN_DEL;
      SELECT;
        WHEN DEL_SEL = 1;
         delete_subject_from_Studetails(ST_ID:ST_SUBID);
         Exsr $clearSearchSfl;
         Exsr $reloadSearchResult;
         MSG_STUDET = 'Delete subject ID ' + %CHAR(deletedSubId) + ' from Student ID '
         + %CHAR(deletedStuId);
        WHEN DEL_SEL = 2;
         MSG_STUDET = 'Chose not to proceed with deletion';
         OPT_STUD = ' ';
         Update STUDSFL;
        WHEN DEL_SEL = 3;
         MSG_STUDET = 'Deletion cancelled';
         OPT_STUD = ' ';
         Update STUDSFL;
        OTHER;
         MSG_STUDET = 'Deletion cancelled';
         OPT_STUD = ' ';
         Update STUDSFL;
      ENDSL;
   ELSE;
     delrm_StID = deletedStuId;
     Exfmt WIN_DELRM;
     SELECT;
        WHEN DELRM_SEL = 1;
         reset_last_subj_to_default(deletedStuId);
         Exsr $clearSearchSfl;
         Exsr $reloadSearchResult;
         MSG_STUDET = 'Reset subject ID ' + %CHAR(deletedSubId) + ' to 0 for Student ID '
         + %CHAR(deletedStuId);
        WHEN DELRM_SEL = 2;
         delete_subject_from_Studetails(ST_ID:ST_SUBID);
         delete_Student_from_Stumaster(ST_ID);
         Exsr $clearSearchSfl;
         Exsr $reloadSearchResult;
         MSG_STUDET = 'Delete Student ID ' + %CHAR(deletedStuId);
        WHEN DELRM_SEL = 3;
         MSG_STUDET = 'Deletion cancelled';
         OPT_STUD = ' ';
         Update STUDSFL;
        OTHER;
         MSG_STUDET = 'Deletion cancelled';
         OPT_STUD = ' ';
         Update STUDSFL;
      ENDSL;

   ENDIF;
ENDSR;


BegSr $clearSearchSfl;
  indicators.subClear = *Off;
  Write STUDCTL;
  STUDRRN = 0;
  indicators.subClear = *On;
  indicators.sflDspData = *OFF;
ENDSR;

BegSr $clearSearchParams;
  Clear STUDCTL;
  Clear ST_INPID;
  Clear ST_INPNAM;
  Clear ST_INPCRS;
  Clear ST_INPCRSN;
  Clear ST_INPSEM;
ENDSR;

BegSr $populateSflFields;
  StudRRN += 1;
  OPT_STUD = ' ';
  ST_ID = foundStudent.StuId;
  ST_NAME = foundStudent.StuName;
  ST_CRSID = foundStudent.StuCrsId;
  ST_ADDR = foundStudent.StuAddr;
  ST_SEMEST = foundStudent.Semester;
  ST_SUBID = foundStudent.SubjectID;
  ST_SUBJECT = foundStudent.SubName;
  ST_CRSNAME = foundStudent.CourseName;
  ST_MARKS = foundStudent.Marks;

  Exsr $DisplaySflAndFold;
  Write STUDSFL;
ENDSR;

BegSr $DisplaySflAndFold;
  IF StudRRN > 0;
    indicators.sflDspData = *ON;
  ENDIF;
ENDSR;

BegSr $StudentSubjectOptions;
IF indicators.sflDspData = *ON;
  READC STUDSFL;
  IF OPT_STUD = 'A';
    Exsr $AddSubjectToStudent;
  ELSEIF OPT_STUD = 'C';
    Exsr $ChangeSemester;
  ELSEIF OPT_STUD = 'D';
    Exsr $DeleteSubject;
  ELSEIF indicators.save = *ON;
    numOfMarksUpdated = 0;
    update_Marks(ST_ID:ST_SUBID:ST_Marks);
    DOW NOT %EOF();
      READC STUDSFL;
      update_Marks(ST_ID:ST_SUBID:ST_MARKS);
      numOfMarksUpdated += 1;
    ENDDO;
    IF numOfMarksUpdated = 1;
      MSG_STUDET = 'Marks for Subject ID ' + %TRIM(%CHAR(ST_SUBID)) + ' updated to ' +
      %TRIM(%CHAR(ST_Marks));
    ELSEIF numOfMarksUpdated = 0;
      MSG_STUDET = 'No marks changed, no need for update';
    ELSE;
      MSG_STUDET = 'Updated marks on ' + %CHAR(numOfMarksUpdated) + ' subjects';
    ENDIF;

  ELSEIF indicators.exit = *ON;
    LeaveSr;
  ELSE;
    MSG_STUDET = 'Invalid option. Please enter only A, C, D or use F8 to update Marks';
  ENDIF;
ENDIF;
ENDSR;

BegSr $searchByStudentId;
  Exsr $clearSearchSfl;
  foundStudent.StuId = get_student_by_ID(ST_INPID);
  IF foundStudent.StuId = -1;
    MSG_STUDET = 'Student with ID ' + %CHAR(ST_INPID) + ' not found';
  ELSE;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
      IF foundStudent.StuId = ST_INPID;
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
  ENDIF;
ENDSR;

BegSr $searchByStudentName;
  Exsr $clearSearchSfl;
//  foundStudent.StuId = is_new_student(ST_INPNAM);
//  IF foundStudent.StuId = -1;
//    MSG_STUDET = 'Student with name: ' + %TRIM(ST_INPNAM) + ' not found';
//  ELSE;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
//      IF foundStudent.StuName = %TRIM(ST_INPNAM);
      IF %SCAN(%TRIM(ST_INPNAM):foundStudent.StuName) <> 0 OR
        %XLATE(lo:up:%TRIM(ST_INPNAM)) = '*ALL';
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
    Exsr $DisplaySflAndFold;
//  ENDIF;
ENDSR;

BegSr $searchByCourseId;
  Exsr $clearSearchSfl;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
      IF foundStudent.StuCrsId = ST_INPCRS;
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
    IF StudRRN <> 0;
      Exsr $DisplaySflAndFold;
    ELSE;
      MSG_STUDET = 'Course does not exist or has no associated students';
    ENDIF;
ENDSR;

BegSr $searchByCourseName;
  Exsr $clearSearchSfl;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
      IF %SCAN(%TRIM(ST_INPCRSN):foundStudent.CourseName) <> 0 OR
        %XLATE(lo:up:%TRIM(ST_INPCRSN)) = '*ALL';
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
    IF StudRRN <> 0;
      Exsr $DisplaySflAndFold;
    ELSE;
      MSG_STUDET = 'Course does not exist or has no associated students';
    ENDIF;
ENDSR;

BegSr $searchBySemester;
  Exsr $clearSearchSfl;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
//      IF foundStudent.Semester = ST_INPSEM;
      IF %SCAN(%TRIM(ST_INPSEM):foundStudent.Semester) <> 0
        OR %XLATE(lo:up:%TRIM(ST_INPSEM)) = '*ALL';
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
    IF StudRRN <> 0;
      Exsr $DisplaySflAndFold;
    ELSE;
      MSG_STUDET = 'Semester does not exist or has no associated students';
    ENDIF;
ENDSR;

BegSr $searchByStuIdCrsIdSem;
  Exsr $clearSearchSfl;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
      IF %SCAN(%TRIM(ST_INPSEM):foundStudent.Semester) <> 0 AND foundStudent.StuId = ST_INPID
        AND foundStudent.StuCrsId = ST_INPCRS;
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
    IF StudRRN <> 0;
      Exsr $DisplaySflAndFold;
    ELSE;
      MSG_STUDET = 'No students exist with the search parameter combination';
    ENDIF;
ENDSR;

BegSr $searchByStuIdCrsNameSem;
  Exsr $clearSearchSfl;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
      IF %SCAN(%TRIM(ST_INPSEM):foundStudent.Semester) <> 0 AND foundStudent.StuId = ST_INPID
        AND %SCAN(%TRIM(ST_INPCRSN):foundStudent.CourseName) <> 0;
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
    IF StudRRN <> 0;
      Exsr $DisplaySflAndFold;
    ELSE;
      MSG_STUDET = 'No students exist with the search parameter combination';
    ENDIF;
ENDSR;

BegSr $searchByStuNameCrsIdSem;
  Exsr $clearSearchSfl;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
      IF %SCAN(%TRIM(ST_INPSEM):foundStudent.Semester) <> 0
        AND %SCAN(%TRIM(ST_INPNAM):foundStudent.StuName) <> 0
        AND foundStudent.StuCrsId = ST_INPCRS;
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
    IF StudRRN <> 0;
      Exsr $DisplaySflAndFold;
    ELSE;
      MSG_STUDET = 'No students exist with the search parameter combination';
    ENDIF;
ENDSR;

BegSr $searchByStuNameCrsNameSem;
  Exsr $clearSearchSfl;
    IF ViewStud_Open();
    foundStudent = ViewStud_FetchNext();
    DOW ViewStud_IsOk();
      IF %SCAN(%TRIM(ST_INPSEM):foundStudent.Semester) <> 0
        AND %SCAN(%TRIM(ST_INPNAM):foundStudent.StuName) <> 0
        AND %SCAN(%TRIM(ST_INPCRSN):foundStudent.CourseName) <> 0;
        Exsr $populateSflFields;
      ENDIF;
      foundStudent = ViewStud_FetchNext();
    ENDDO;
    ViewStud_Close();
    ENDIF;
    IF StudRRN <> 0;
      Exsr $DisplaySflAndFold;
    ELSE;
      MSG_STUDET = 'No students exist with the search parameter combination';
    ENDIF;
ENDSR;

BegSr $reloadSearchResult;
    tStuName = %TRIM(ST_INPNAM);
    tCrsName = %TRIM(ST_INPCRSN);
    tSemName = %TRIM(ST_INPSEM);
    searchType = get_search_type(ST_INPID:tStuName:ST_INPCRS:tCrsName:tSemName);

    SELECT;
       When searchType = 'Invalid';
        MSG_STUDET = 'Invalid search parameters, please input only 1 or all 3 search fields';
        Exsr $clearSearchSfl;
       When searchType = 'InvalidStu';
        MSG_STUDET = 'Invalid search parameters, please only put ID or Name';
        Exsr $clearSearchSfl;
       When searchType = 'InvalidCrs';
        MSG_STUDET = 'Invalid search parameters, please only put ID or Name';
        Exsr $clearSearchSfl;
       When searchType = 'StuId';
        Exsr $searchByStudentId;
       When searchType = 'StuName';
        Exsr $searchByStudentName;
       When searchType = 'CourseId';
        Exsr $searchByCourseId;
       When searchType = 'CourseName';
        Exsr $searchByCourseName;
       When searchType = 'Semester';
        Exsr $searchBySemester;
       When searchType = 'StuId+CrsId+Sem';
        Exsr $searchByStuIdCrsIdSem;
       When searchType = 'StuId+CrsName+Sem';
        Exsr $searchByStuIdCrsNameSem;
       When searchType = 'StuName+CrsId+Sem';
        Exsr $searchByStuNameCrsIdSem;
       When searchType = 'StuName+CrsName+Sem';
        Exsr $searchByStuNameCrsNameSem;
       Other;
        Exsr $clearSearchSfl;
    ENDSL;

    IF updatedSub = *ON;
       MSG_STUDET = 'Subject related information updated';
    ELSEIF updatedSem = *ON;
       MSG_STUDET = 'Student Semester updated';
    ELSE;
       MSG_STUDET = 'Welcome back, search type: ' + %TRIM(searchType);
    ENDIF;

    updatedSub = *OFF;
    updatedSem = *OFF;

ENDSR;

