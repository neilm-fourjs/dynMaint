
IMPORT FGL gl_lib
&include "genero_lib.inc"

IMPORT FGL glm_setActions
IMPORT FGL glm_sql
IMPORT FGL glm_mkForm
&include "dynMaint.inc"

DEFINE m_dialog ui.Dialog
PUBLIC DEFINE m_bi_func t_bi_func
--------------------------------------------------------------------------------
FUNCTION glm_menu(l_allowedActions STRING)

	MENU
		BEFORE MENU
			CALL glm_setActions.setActions(glm_sql.m_row_cur, glm_sql.m_row_count, l_allowedActions)
		ON ACTION insert		CALL glm_inpt(1)
		ON ACTION update		IF glm_sql.m_row_cur > 0 THEN CALL glm_inpt(0) END IF
		ON ACTION delete		IF glm_sql.m_row_cur > 0 THEN CALL glm_sql.glm_SQLdelete() END IF
		ON ACTION find			CALL glm_constrct()
			CALL glm_setActions.setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION firstrow	CALL glm_sql.glm_getRow(SQL_FIRST)
			CALL glm_setActions.setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION prevrow		CALL glm_sql.glm_getRow(SQL_PREV)
			CALL glm_setActions.setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION nextrow		CALL glm_sql.glm_getRow(SQL_NEXT)
			CALL glm_setActions.setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION lastrow		CALL glm_sql.glm_getRow(SQL_LAST)
			CALL glm_setActions.setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION quit			EXIT MENU
		ON ACTION close			EXIT MENU
		GL_ABOUT
	END MENU

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION glm_constrct()
	DEFINE m_dialog ui.Dialog
	DEFINE x SMALLINT
	DEFINE l_query, l_sql STRING

	LET m_dialog = ui.Dialog.createConstructByName(glm_sql.m_fields)

	CALL m_dialog.addTrigger("ON ACTION close")
	CALL m_dialog.addTrigger("ON ACTION cancel")
	CALL m_dialog.addTrigger("ON ACTION accept")
	LET int_flag = FALSE
	WHILE TRUE
		CASE m_dialog.nextEvent()
			WHEN "ON ACTION close"
				LET int_flag = TRUE
				EXIT WHILE
			WHEN "ON ACTION accept"
				EXIT WHILE
			WHEN "ON ACTION cancel"
				LET int_flag = TRUE
				EXIT WHILE
		END CASE
	END WHILE
	IF int_flag THEN RETURN END IF

	FOR x = 1 TO glm_sql.m_fields.getLength()
		LET l_query = m_dialog.getQueryFromField(glm_sql.m_fields[x].colname)
		IF l_query.getLength() > 0 THEN
			IF l_sql IS NOT NULL THEN LET l_sql = l_sql.append(" AND ") END IF
			LET l_sql = l_sql.append(l_query)
		END IF
	END FOR

	CALL glm_sql.glm_mkSQL( l_sql )
	CALL glm_sql.glm_getRow(SQL_FIRST)

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION glm_inpt(l_new BOOLEAN)
	DEFINE x SMALLINT

	CALL ui.Dialog.setDefaultUnbuffered(TRUE)
	LET m_dialog = ui.Dialog.createInputByName(glm_sql.m_fields)

	IF l_new THEN
	ELSE
		IF glm_sql.m_row_cur = 0 THEN RETURN END IF
		FOR x = 1 TO m_fields.getLength()
			CALL m_dialog.setFieldValue(glm_mkForm.m_fld_props[x].tabname||"."||glm_sql.m_fields[x].colname, glm_sql.m_sql_handle.getResultValue(x))
			IF x = glm_sql.m_key_fld THEN
				CALL m_dialog.setFieldActive(glm_sql.m_fields[x].colname, FALSE )
			END IF
		END FOR
	END IF

	CALL m_dialog.addTrigger("ON ACTION close")
	CALL m_dialog.addTrigger("ON ACTION cancel")
	CALL m_dialog.addTrigger("ON ACTION accept")
	LET int_flag = FALSE
	WHILE TRUE
		CASE m_dialog.nextEvent()
			WHEN "BEFORE INPUT"
				IF m_bi_func IS NOT NULL THEN CALL m_bi_func(l_new) END IF
			WHEN "ON ACTION close"
				LET int_flag = TRUE
				EXIT WHILE
			WHEN "ON ACTION accept"
				IF l_new THEN 
					CALL glm_sql.glm_SQLinsert(m_dialog)
				ELSE
					CALL glm_sql.glm_SQLupdate(m_dialog)
				END IF
				EXIT WHILE
			WHEN "ON ACTION cancel"
				LET int_flag = TRUE
				EXIT WHILE
		END CASE
	END WHILE
END FUNCTION
--------------------------------------------------------------------------------