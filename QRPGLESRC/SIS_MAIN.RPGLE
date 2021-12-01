**FREE

Ctl-Opt DFTACTGRP(*No) BNDDIR('CAPSTONE');

/copy QCOPYBOOK,PROTOTYPE

// Global variables
// --- login ---
Dcl-Ds currentCourse LikeDs(Course_t);
Dcl-S loggedIn ind inz(*Off);
Dcl-S foundID packed(5:0) inz(-1);
Dcl-S confirmExit ind inz(*Off);

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


// Main program starts here
DOU indicators.exit = *ON AND loggedIn = *Off;
  EXSR $LoginSR;
ENDDO;

*Inlr = *ON;

// ***************
// LOGIN
// ***************

BegSr $LoginSR;
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
          Clear USRNAME;
          Clear USRPWD;
          Exsr $SelectTable;
        Else;
          MSG_LOGIN = 'Wrong password!';
        EndIf;
      Else;
        MSG_LOGIN = 'User not found.';
      EndIf;
    EndIf;
  ENDIF;
ENDSR;

//***********************************************************
// Select Tables
//***********************************************************
BegSr $SelectTable;
  DOW indicators.exit = *OFF;
    Write Footer_M;
    Exfmt MAINMENU;
    Clear MSG_MENU;
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
        WHEN (OPT_NEWCRS = '1' AND OPT_NEWSUB = ' ' AND OPT_NEWSTU = ' ' AND OPT_VIEWST = ' ');
          Exsr $NewCrsOpt;
        WHEN (OPT_NEWSTU = '1' AND OPT_NEWSUB = ' ' AND OPT_NEWCRS = ' ' AND OPT_VIEWST = ' ');
          Exsr $NewStuOpt;
        WHEN (OPT_VIEWST = '1' AND OPT_NEWCRS = ' ' AND OPT_NEWSTU = ' ' AND OPT_NEWSUB = ' ');
          Exsr $ViewStuOpt;
        OTHER;
          MSG_Menu = 'Invalid option';
      ENDSL;
    ENDIF;
  ENDDO;
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
          If NEWSUBNAME = SUBNAME;
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
          SUBNAME = NEWSUBNAME;
          WRITE SUBMAFMT;
          MSG_NEWSUB = 'Subject ' + %trim(%CHAR(NEWSUBNAME))+' ID.' + %CHAR(SUBJECTID) + ' added';
          Clear NEWSUBNAME;
        ENDIF;
      ENDIF;
    ELSE;
      // do nothing
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
        currentCourseId = get_courseId(CRSNAME);
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
          Exsr $validate_and_add_first_subj;

          IF selectedSub = *Off;
            MSG_NEWCRS = 'Please select at least one subject';
          ELSE;
            // insert new course into CorMaster
            currentCourseId += 10;
            opSuccessful = *Off;
            opSuccessful = add_new_course((currentCourseId):CRSNAME);

            // insert all selected option into SubCourse
            addOrUpdate = 'ADDED';
            Exsr $add_remaining_subj;
          ENDIF;
        ENDIF;
      ENDIF;
    ElSE;
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

  MSG_NEWCRS = %TRIM(addOrUpdate) +' - Course ID.' + %CHAR(currentCourseId) + ' in '
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
          foundStuId = is_new_student(NSTUDNAME);
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
              addSuccessful = add_new_student(lastStuId:NSTUDNAME:NSTUDADDR:CRS_ID);
              Exsr $Load_Course_SFL;
              MSG_NEWSTU = 'Student ID.' + %CHAR(lastStuId) + ' ' + %TRIM(NSTUDNAME)
              + ' successfully enrolled in ' + %TRIM(CRS_NAME);
            ENDIF;
          ENDIF;
         ENDIF;
      ELSE;
      ENDIF;
   ENDDO;
   // BUG: Pressing F3 still shows subfile on Login page
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
   indicators.subClear = *Off;
   Write STUDCTL;
   StudRRN = 0;
   indicators.subClear = *On;
   indicators.sflDspData = *Off;
   MSG_STUDET = 'Enter some search criteria to begin';
   DOW indicators.exit = *Off;
     Write Header;
     Write Footer_Up;
     Exfmt STUDCTL;
     foundStudent = find_by_StudentId(ST_INPID);
     IF foundStudent.id = -1;
       MSG_STUDET = 'Student doesn''t exist';
     ELSE;
       MSG_STUDET = 'Found student name: ' + %TRIM(foundStudent.name);
     ENDIF;
   ENDDO;


ENDSR;
