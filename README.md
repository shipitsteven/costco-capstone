# costco-capstone

## Display file variables

### LOGIN

-   `USRNAME` - Both - Character(10)
-   `USRPWD` - Both - Character(10)
-   `MSG_LOGIN` - Both - Character(50)

### MAINMENU

-   `OPT_NEWSUB` - Input - Character(1)
-   `OPT_NEWCRS` - Input - Character(1)
-   `OPT_NEWSTU` - Input - Character(1)
-   `OPT_VIEWST` - Input - Character(1)
-   `MSG_MENU` - Output - Character(50)

### NEWSUBJECT

-   `NEWSUBNAME` - Both - Character(25)
-   `MSG_NEWSUB` - Output - Character(50)

### NEWCOURSE

-   `CRSNAME` - Both - Character(25)
-   `SEMESTER` - Both - Character(10)

#### SUBSFL

-   `SUB_ID` - Output - Zoned(5,0)
-   `SUB_NAME` - Output - Character(25)
-   `OPT_SUB` - Input - Character(1)

### NEWSTUDENT

-   `NSTUDNAME` - Both - Character(25)
-   `NSTUDADDR` - Both - Character(25)

#### CRSSFL

-   `CRS_ID` - Output - Zoned(5,0)
-   `CRS_NAME` - Output - Character(25)
-   `OPT_CRS` - Input - Character(1)

### STUDDETAIL

-   `ST_INPID` - Both - Zoned(5,0)
-   `ST_INPNAME` - Both - Character(25)
-   `ST_INPCRS` - Both - Zoned(5,0)
-   `ST_INPCRSN` - Both - Character(25)
-   `ST_INPSEM` - Both - Character(10)

#### STUDSFL

-   `OPT_STUD` - Both - Character(1)
-   `ST_ID` - Output - Zoned(5,0)
-   `ST_NAME` - Output - Character(25)
-   `ST_CRSID` - Output - Zoned(5,0)
-   `ST_SEMEST` - Output - Character(10)
-   `ST_SUBID` - Output - Zoned(5,0)
-   `ST_MARKS` - Both - Zoned(5,0)
-   `ST_ADDR` - Output - Character(25)
-   `ST_SUBJECT` - Output - Character(25)
-   `ST_CRSNAME` - Output - Character(25)

### ADDDETAIL

-   `DT_STID` - Output - Zoned(5,0)
-   `DT_STNAME` - Output - Character(25)
-   `DT_CRSNAME` - Output - Character(5,0)
-   `DT_SEMEST` - Output - Character(10)
-   `DT_SUBNAME` - Both - Character(25)
-   `DT_MARKS` - Both - Zoned(5,0)

### CHGSMST

-   `CS_STID` - Output - Zoned(5,0)
-   `CS_STNAME` - Output - Character(25)
-   `CS_CRSNAME` - Output - Character(25)
-   `CS_SEMEST` - Both - Character(10)
