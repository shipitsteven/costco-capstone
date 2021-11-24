**FREE

// File imports
Dcl-F SISDisplay Workstn indds(indicators) sfile(SUBSFL:SubRRN) sfile(CRSSfl:CrsRRN)
sfile(StudSFL:StudRRN);
Dcl-F Users Disk Keyed Usage(*Update);
Dcl-F Submaster Disk Keyed Usage(*Update:*Input:*Output);
Dcl-F CorMaster Disk Keyed Usage(*Update:*Input:*Output);
Dcl-F SubCourse Disk Keyed Usage(*Update:*Input:*Output);

// Indicators for display file
Dcl-ds indicators len(99) qualified;
  exit      ind pos(3);
  refresh   ind pos(5);
  save      ind pos(8);
  back      ind pos(12);
  subClear  ind pos(50);
  sflNxtChg ind pos(60);
End-ds;

// Relative record numbers
Dcl-S SubRRN Packed(5:0);
Dcl-S CrsRRN Packed(5:0);
Dcl-S StudRRN Packed(5:0);

// File related data structures
Dcl-DS Users_t Qualified Template;
  id       packed(5:0);
  username char(10);
  password char(10);
END-DS;

Dcl-DS Subject_t Qualified Template;
  id       packed(5:0);
  name     char(25);
END-DS;

Dcl-DS Course_t Qualified Template;
  id       packed(5:0);
  name     char(25);
END-DS;

Dcl-DS Semester_t Qualified Template;
  id       packed(2:0);
  term     char(10);
END-DS;

// Functions related prototypes
// ---Login---
Dcl-Pr getID_by_username Like(Users_t.id) ExtProc;
  userInput Like(Users_t.username) const;
END-PR;

// ---Load Subject---

Dcl-Pr Subject_FetchNext LikeDS(Subject_t) END-Pr;

Dcl-Pr Subject_IsOk Ind End-Pr;
Dcl-Pr Subject_Open Ind End-Pr;
Dcl-Pr Subject_Close End-Pr;

// ---Course---
Dcl-Pr get_last_courseId Like(Course_t.id) End-Pr;

Dcl-Pr is_new_course ind ExtProc;
  inputCrsId Like(Course_t.id) const;
  inputSemId Like(Semester_t.id) const;
End-Pr;

Dcl-Pr get_semId Like(Semester_t.id) ExtProc;
  inputSemester Like(Semester_t.term) const;
End-Pr;

Dcl-Pr get_CourseId Like(Course_t.id) ExtProc;
  inputCourse Like(Course_t.name) const;
End-Pr;

Dcl-Pr add_new_course ind ExtProc;
  newCourseId   Like(Course_t.id) const;
  newCourseName Like(Course_t.name) const;
END-PR;

Dcl-PR add_new_subCourse ind ExtProc;
   subCrsId    Like(Course_t.id)   const;
   subSubjId   Like(Subject_t.id)  const;
   subSemId    Like(Semester_t.id) const;
END-PR;

Dcl-Pr remove_subCourse_combo ind ExtProc;
    subCrsId    Like(Course_t.id)   const;
    subSemId    Like(Semester_t.id) const;
END-Pr;
