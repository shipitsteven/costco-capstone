**FREE

Ctl-Opt NOMAIN;

/copy QCOPYBOOK,PROTOTYPE

Dcl-Proc getID_by_username Export;
  Dcl-PI getID_by_username Like(Users_t.id);
    userInput Like(Users_t.username) const;
  END-PI;

  Dcl-F Users Disk Keyed Usage(*Update);
  Dcl-S foundID packed(5:0) inz(-1);
  Dcl-DS currentUser LikeRec(USERSFMT:*all);

  SETLL *loval Users;
  READ(N) Users currentUser;
  DoW Not %EOF(Users);
    IF currentUser.username = userInput;
      foundID = currentUser.uid;
      Leave;
    ENDIF;
    READ(N) Users currentUser;
  EndDo;
  Close Users;

  return foundID;

END-PROC;
