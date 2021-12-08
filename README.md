# Xpanxion/Costco Apprenticeship Capstone Project

> The *Step IT Up* program is a an approved Department of Labor Apprentice Program aimed at bring veterans, women and underserved population to the IT work force. For more details, [click here.](https://www.xpanxion.com/business-solutions-alliances/accelerated-talent-development/)

For our training, we're focused on learning the technologies surrounding the **IBM iSeries**, also commonly known as `A/S 400`, alongside IBM's proprietary language called `RPG`, and its modern version `RPGLE`. Our ultimate goal is to showcase technical proficiency to become consultant software engineers for Costco Wholesale Corporation.

## STUDENT INFORMATION SYSTEM

The Objective of this project is to create a student information system that will allow the users to create subjects, add courses and students, and view the students' marks(grades).

### Technology Used

A/S 400 is not a commonly hosted environment. However, there's a free host called [PUB400](https://www.pub400.com/) that are available for educational purposes.

- Server: [PUB400](https://www.pub400.com/)
- Environment: `IBM i 7.4`
- Languages: `RPGLE` & `SQLRPGLE`
- IDE: [Rational Developer for IBM i](https://www.ibm.com/products/rational-developer-for-i)
- Emulator: [IBM i Access - Client Solutions 5250 emulator](https://www.ibm.com/support/pages/ibm-i-access-client-solutions)

## Getting Started

The entry point to the program is `SIS_MAIN.RPGLE`. All other `RPGLE` and `SQLRPGLE` files are supposed to be compiled as modules, and create service programs for each module.

The copybook for this program is called `PROTOTYPE.RPGLE` inside the source file `QCOPYBOOK`. It contains all sub procedure's prototypes, file imports, data structure for display file indicators, and a few subfile related variables

The display file is inside `QDDSSRC`, named `SISDISPLAY.DSPF`.

All data related physical files and logical files are the `PF` and `LF` in `QDDSSRC`

These include:
 - `Users.PF` - User credentials for logging in
 - `StuMaster.PF` - Student related information
 - `StuDetails.PF` - Student/subject/marks
 - `SubMaster.PF` - Subject related information
 - `SemMaster.PF` - Semester related information
 - `CorMaster.PF` - Course related information
 - `SubCourse.PF` - Details pertaining each course and what subjects it contains for a specific semester
 - `ViewStudJF.LF` - Logical file joining multiple PFs for the view student detail screen

#### Entity-Relationship Diagram for the Physical files

![Capstone-EER](https://user-images.githubusercontent.com/62415298/145132567-e7d25133-01e9-4d10-a9fe-a068e250529d.png)


## Screenshots

### Login

![login](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/login.JPG)

### Main Menu

![main menu](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/mainMenu.JPG)

### Add Subject

![add subject](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/addsubject.JPG)

### Add Course

![add course](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/addCourse.JPG)

### Add Student

![add student](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/addStudent.JPG)

### View Students

![view students](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/viewstudents.JPG)

![fold and drop](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/folddrop.JPG)

![add details](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/adddetails.JPG)

![change semester](https://github.com/shipitsteven/costco-capstone/blob/main/screencaps/changesemester.JPG)

## Acknoledgements

- This project was developed by Steven Wang and Max Ma in November & December 2021
- Our instructor was Vicky Scrubar - [LinkedIn](https://www.linkedin.com/in/vickysrubar/)
- Our coach was Myra D. Ford - [LinkedIn](https://www.linkedin.com/in/myra-d-ford-msa-dba-0a0337/)
- Abundance of knowledge and tutorials from [Yusuf4Code on YouTube](https://www.youtube.com/c/mohammedyusufm)
- *Veterans of the United States for their service*
