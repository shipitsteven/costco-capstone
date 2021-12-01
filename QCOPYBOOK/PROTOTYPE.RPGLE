**FREE

// File imports
Dcl-F SISDisplay Workstn indds(indicators) sfile(SUBSFL:SubRRN) sfile(CRSSfl:CrsRRN)
sfile(StudSFL:StudRRN);
Dcl-F Users Disk Keyed Usage(*Update);
Dcl-F Submaster Disk Keyed Usage(*Update:*Input:*Output);
//Dcl-F CorMaster Disk Keyed Usage(*Update:*Input:*Output);
//Dcl-F SubCourse Disk Keyed Usage(*Update:*Input:*Output);
Dcl-F StuMaster Disk Keyed Usage(*Update:*Input:*Output);
//Dcl-F SemMaster Disk Keyed Usage(*Update:*Input:*Output);
Dcl-F ViewStudJF Disk Keyed Usage(*Input);

// Indicators for display file
Dcl-ds indicators len(99) qualified;
  exit        ind pos(3);
  refresh     ind pos(5);
  save        ind pos(8);
  back        ind pos(12);
  subClear    ind pos(50);
  subCrsClear ind pos(55);
  sflNxtChg   ind pos(60);
  sflDspData  ind pos(51);
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

Dcl-DS Student_t Qualified Template;
  id       packed(5:0);
  name     char(25);
  addr     char(25);
  crsid    packed(5:0);
  semid    packed(2:0);
End-Ds;

Dcl-DS ViewStud_t Qualified Template;
  id         Like(Student_t.id);
  name       Like(Student_t.name);
  crsid      Like(Student_t.crsid);
  CourseName Like(Course_t.name);
  SemId      Like(Student_t.semid);
  Semester   Like(Semester_t.term);
  SubjectID  Like(Subject_t.id);
  SubName    Like(Subject_t.name);
  Marks      packed(5:0);
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

// --- Load Course ---
Dcl-Pr Course_FetchNext LikeDS(Course_t) END-Pr;

Dcl-Pr Course_IsOk Ind End-Pr;
Dcl-Pr Course_Open Ind End-Pr;
Dcl-Pr Course_Close End-Pr;

// --- Student ---
Dcl-PR is_new_student Like(Student_t.id) ExtProc;
    inputName Like(Student_t.name);
End-PR;

Dcl-PR get_last_stuId Like(Student_t.id) End-PR;

Dcl-PR add_new_Student ind ExtProc;
    newStudentId   Like(Student_t.id) const;
    newStudentName Like(Student_t.name) const;
    newStudentAddr Like(Student_t.addr) const;
    newStudentCrs  Like(Student_t.crsid) const;
END-PR;

// --- Student Detail ---
Dcl-PR find_by_StudentID LikeDS(ViewStud_t);
    inputId Like(Student_t.id);
End-PR;
