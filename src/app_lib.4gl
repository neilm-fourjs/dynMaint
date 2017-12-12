
IMPORT FGL gl_lib
--------------------------------------------------------------------------------
-- Setup actions based on a allowed actions
FUNCTION setActions(l_row INT, l_max INT,l_allowedActions CHAR(6))
	DEFINE d ui.Dialog
&define ACT_FIND l_allowedActions[1]
&define ACT_UPD l_allowedActions[2]
&define ACT_INS l_allowedActions[3]
&define ACT_DEL l_allowedActions[4]
&define ACT_SAM l_allowedActions[5]
&define ACT_LIST l_allowedActions[6]
	LET d = ui.Dialog.getCurrent()
	CALL d.setActionActive("update",FALSE)
	CALL d.setActionActive("delete",FALSE)
	CALL d.setActionActive("lastrow",FALSE)
	CALL d.setActionActive("nextrow",FALSE)
	CALL d.setActionActive("prevrow",FALSE)
	CALL d.setActionActive("firstrow",FALSE)
	IF ACT_FIND = "N" THEN CALL d.setActionActive("find",FALSE) END IF
--	IF ACT_LIST = "N" THEN CALL d.setActionActive("list",FALSE) END IF
	IF ACT_INS = "N" THEN CALL d.setActionActive("insert",FALSE) END IF
	IF l_row > 0 THEN
		IF ACT_UPD = "Y" THEN CALL d.setActionActive("update",TRUE) END IF
		IF ACT_DEL = "Y" THEN CALL d.setActionActive("delete",TRUE) END IF
	END IF
	IF l_row > 0 AND l_row < l_max THEN
		CALL d.setActionActive("nextrow",TRUE)
		CALL d.setActionActive("lastrow",TRUE)
	END IF
	IF l_row > 1 THEN
		CALL d.setActionActive("prevrow",TRUE)
		CALL d.setActionActive("firstrow",TRUE)
	END IF 
END FUNCTION