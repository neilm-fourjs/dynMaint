
-- A Basic dynamic customer maintenance program.
-- Does: find, update, insert, delete
-- To Do: locking, sample, listing report

IMPORT FGL g2_lib
IMPORT FGL g2_appInfo
IMPORT FGL g2_about
IMPORT FGL g2_db
IMPORT FGL g2_lib
IMPORT FGL g2_db

IMPORT FGL glm_mkForm
IMPORT FGL glm_sql
IMPORT FGL glm_ui
&include "dynMaint.inc"

&include "schema.inc"

CONSTANT C_PRGVER="3.1"
CONSTANT C_PRGDESC = "Dynamic Customer Maintenance Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGICON = "logo_dark"

CONSTANT C_FIELDS_PER_PAGE = 10
DEFINE m_appInfo g2_appInfo.appInfo
DEFINE m_db g2_db.dbInfo
DEFINE m_allowedActions CHAR(6)
MAIN

  CALL m_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
  CALL g2_lib.g2_init(ARG_VAL(1), "dynmaint")

	CALL init_args()

-- setup and connect to DB
  CALL m_db.g2_connect(NULL)

-- setup SQL
	LET glm_sql.m_key_fld = 0
	LET glm_sql.m_row_cur = 0
	LET glm_sql.m_row_count = 0
	LET glm_sql.m_tab = "customer"
	LET glm_sql.m_key_nam = "customer_code"
	CALL glm_sql.glm_mkSQL("*","1=2") -- not fetching any data.

-- create Form
  CALL glm_mkForm.init_form(
      m_db.name,
      glm_sql.m_tab,
      glm_sql.m_key_fld,
      C_FIELDS_PER_PAGE,
      glm_sql.m_fields,
      "main2") -- 10 fields by folder page

	CALL ui.Interface.setText( C_PRGDESC )

	CALL g2_lib.g2_loadToolBar( "dynmaint" )
	CALL g2_lib.g2_loadTopMenu( "dynmaint" )

-- start UI
  CALL glm_ui.glm_menu(m_allowedActions, m_appInfo)

  CALL g2_lib.g2_exitProgram(0, % "Program Finished")

END MAIN
--------------------------------------------------------------------------------
FUNCTION init_args()
	LET m_allowedActions = NULL
	IF m_allowedActions IS NULL THEN LET m_allowedActions = "YYYYYY" END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION custom_form_init()
	DEFINE f_init_cb t_init_cb
	DISPLAY "In custom_form_init"
	LET f_init_cb = FUNCTION init_cb
	CALL glm_mkForm.setComboBox("disc_code", f_init_cb)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION init_cb( l_cb ui.ComboBox )
	DEFINE l_sql, l_key, l_desc STRING
	IF l_cb IS NULL THEN
		DISPLAY "init_cb passed NULL!"
		RETURN
	END IF
	CASE l_cb.getColumnName()
		WHEN "disc_code"
			LET l_sql = "SELECT UNIQUE customer_disc FROM disc ORDER BY customer_disc"
	END CASE
	IF l_sql IS NOT NULL THEN
		DISPLAY "Loading ComboBox for: ",l_cb.getColumnName()
		DECLARE cb_cur CURSOR FROM l_sql
		FOREACH cb_cur INTO l_key, l_desc
			IF l_key.trim().getLength() > 1 THEN
				--DISPLAY "Key:",l_key.trim()," Desc:",l_desc.trim()
				CALL l_cb.addItem( l_key.trim(), l_desc.trim() )
			END IF
		END FOREACH
	END IF
END FUNCTION