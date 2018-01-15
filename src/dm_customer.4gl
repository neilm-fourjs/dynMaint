
-- A Basic dynamic maintenance program.
-- Does: find, update, insert, delete
-- To Do: locking, sample, listing report

-- Command Args:
-- 1: MDI / SDI 
-- 2: Database name
-- 3: Table name
-- 4: Primary Key name
-- 5: Allowed actions: Y/N > Find / Update / Insert / Delete / Sample / List  -- eg: YNNNNN = enquiry only.

IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL glm_setActions
IMPORT FGL glm_mkForm
IMPORT FGL glm_sql
IMPORT FGL glm_ui

&include "genero_lib.inc"
&include "dynMaint.inc"

CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "Dynamic Customer Maintenance Demo"
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
	LET glm_sql.m_tab = "customer"
	LET glm_sql.m_key_nam = "customer_code"
	CALL glm_sql.glm_mkSQL("1=2") -- not fetching any data.

-- create Form
	CALL glm_mkForm.init_form(m_dbname, m_tab, 10, glm_sql.m_fields) -- 10 fields by folder page
	CALL gl_lib.gl_titleWin(NULL)
	CALL ui.Interface.setText( gl_lib.gl_progdesc )

-- start UI
	CALL glm_ui.glm_menu(m_allowedActions)

	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION init_args()
	LET m_allowedActions = NULL
	IF m_allowedActions IS NULL THEN LET m_allowedActions = "YYYYYY" END IF
END FUNCTION