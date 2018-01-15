
-- A Basic dynamic stock maintenance program.
-- Does: find, update, insert, delete
-- To Do: locking, sample, listing report

IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL glm_setActions
IMPORT FGL glm_mkForm
IMPORT FGL glm_sql
IMPORT FGL glm_ui

&include "genero_lib.inc"
&include "dynMaint.inc"

SCHEMA njm_demo310

CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "Dynamic Stock Maintenance Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_APP_SPLASH = "njm_demo_logo_256"
CONSTANT C_APP_ICON = "njm_demo_icon"

DEFINE m_dbname STRING
DEFINE m_allowedActions CHAR(6)
MAIN
	CALL gl_lib.gl_setInfo(C_VER, C_APP_SPLASH, C_APP_ICON, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),"default",TRUE)
	LET gl_lib.gl_toolBar = "dynmaint"
	LET gl_lib.gl_topMenu = "dynmaint"

	CALL init_args()

-- setup DB
	LET m_dbname = "njm_demo310"
	CALL gl_db.gldb_connect( m_dbname )

-- setup SQL
	LET glm_sql.m_key_fld = 0
	LET glm_sql.m_row_cur = 0
	LET glm_sql.m_row_count = 0
	LET glm_sql.m_tab = "stock"
	LET glm_sql.m_key_nam = "stock_code"
	CALL glm_sql.glm_mkSQL("1=2") -- not fetching any data.

-- create Form
	CALL glm_mkForm.init_form(m_dbname, m_tab, 12, glm_sql.m_fields) -- 10 fields by folder page
	CALL gl_lib.gl_titleWin( gl_lib.gl_progdesc )
	CALL ui.Interface.setText( gl_lib.gl_progdesc )

-- start UI
	LET glm_ui.m_bi_func = FUNCTION my_before_inp
	CALL glm_ui.glm_menu(m_allowedActions)

	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
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
	CALL glm_mkForm.setWidget("stock_cat","ComboBox", "init_cb", f_init_cb)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION init_cb( l_cb ui.ComboBox )
	DEFINE l_sc RECORD LIKE stock_cat.*
	IF l_cb IS NULL THEN
		DISPLAY "init_cb passed NULL!"
		RETURN
	END IF
	DISPLAY "Loading stock_cat cb ..."
	DECLARE cb_cur CURSOR FOR SELECT * FROM stock_cat
	FOREACH cb_cur INTO l_sc.*
		CALL l_cb.addItem( l_sc.catid CLIPPED, l_sc.cat_name CLIPPED )
	END FOREACH
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION my_before_inp(l_new BOOLEAN)
	DISPLAY "BEFORE INPUT : ",l_new

END FUNCTION