**FREE

Ctl-Opt DFTACTGRP(*No) BNDDIR('CAPSTONE');

/copy QCOPYBOOK,PROTOTYPE

// Global variables
Dcl-S loggedIn ind inz(*Off);
Dcl-S foundID packed(5:0) inz(-1);
Dcl-S foundSubject packed(5:0) inz(-1);
Dcl-S newSubjectID packed(5:0);
Dcl-Ds currentSubject LikeDs(Subject_t);
Dcl-S currentCourseId Like(Course_t.id);
Dcl-S newCourseSemCombo ind inz(*Off);
Dcl-S foundSemId packed(2:0);
Dcl-S opSuccessful ind inz(*Off);
Dcl-S selectedSub ind inz(*Off);
Dcl-S subjectCounter packed(5:0) inz(0);
Dcl-S firstSubjIdCache Like(Subject_t.id);
Dcl-S addOrUpdate char(10);


// Main program starts here
DOU indicators.exit = *ON AND loggedIn = *Off;
  Write Header;
  Write Footer_M;
  Exfmt LOGIN;
  EXSR $LoginSR;
ENDDO;

*Inlr = *ON;

// ***************
// LOGIN
// ***************

BegSr $LoginSR;
  IF indicators.refresh = *ON;
    clear MSG_LOGIN;
    clear USRNAME;
    clear USRPWD;
    MSG_LOGIN = 'Page refreshed';
  ELSE;
    IF ( %TRIM(USRNAME) = ' ' OR %TRIm(USRPWD) = ' ' );
      MSG_LOGIN = 'User name and/or password cannot be empty';
    Else;

      foundID = getID_by_username(USRNAME);

      If foundID <> -1;
        Chain foundID Users;
        If Password = USRPWD;
          loggedIn = *On;
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
//          Exsr $NewStuOpt;
        WHEN (OPT_VIEWST = '1' AND OPT_NEWCRS = ' ' AND OPT_NEWSTU = ' ' AND OPT_NEWSUB = ' ');
//          Exsr $ViewStuOpt;
        OTHER;
          MSG_Menu = 'Invalid option';
      ENDSL;
    ENDIF;
  ENDDO;
  MSG_LOGIN = 'Logged out, you can log in again now';
  Exfmt LOGIN;
  loggedIn = *Off;
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
      OPT_SUB = '';
      Write SUBSFL;
      currentSubject = Subject_FetchNext();
    ENDDO;
    Subject_Close();
  ENDIF;
ENDSR;
