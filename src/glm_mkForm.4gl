
&include "dynMaint.inc"

PUBLIC DEFINE m_fld_props DYNAMIC ARRAY OF t_fld_props
PUBLIC DEFINE m_formName STRING
PUBLIC DEFINE m_w ui.Window
PUBLIC DEFINE m_f ui.Form
DEFINE m_tab STRING
DEFINE m_key_fld SMALLINT
DEFINE m_fld_per_page SMALLINT
DEFINE m_fields DYNAMIC ARRAY OF t_fields
--------------------------------------------------------------------------------
# Build a form based on an array of field names and an array of properties.
#+ @param l_db Database name
#+ @param l_tab Table name
#+ @param l_key_fld The index no of the key field in the tab
#+ @param l_fld_per_page Fields per page ( folder tabs )
#+ @param l_fields Array of field names / types
#+ @param l_fld_props Array of field properties.
FUNCTION init_form(
	l_db STRING,
	l_tab STRING,
	l_key_fld SMALLINT,
	l_fld_per_page SMALLINT, 
	l_fields DYNAMIC ARRAY OF t_fields
	)
	DEFINE l_n om.DomNode
	DEFINE l_nl om.NodeList
	DEFINE x, y SMALLINT
	LET m_tab = l_tab
	LET m_key_fld = l_key_fld
	LET m_fld_per_page = l_fld_per_page
	LET m_fields = l_fields
	LET m_w = ui.Window.getCurrent()
	LET m_formName = "dm_"||l_db.trim().toLowerCase()||"_"||l_tab.trim().toLowerCase()
	TRY
		OPEN FORM dynMaint FROM m_formName
	CATCH
		CALL mk_form()
		RETURN
	END TRY
	DISPLAY FORM dynMaint 
	LET m_f = m_w.getForm()
	LET l_n = m_f.getNode()
	LET l_nl = l_n.selectByTagName("FormField")
	FOR x = 1 TO l_fields.getLength()
		CALL setProperties(x)
		FOR y = 1 TO l_nl.getLength()
			LET l_n = l_nl.item(y)
			IF l_n.getAttribute("name") = m_fld_props[x].name THEN
				LET m_fld_props[x].formFieldNode = l_n
			END IF
		END FOR
	END FOR
	CALL ui.Interface.getRootNode().writeXml("aui_"||l_tab||"_static.xml")
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION mk_form()
	DEFINE l_n_form, l_n_grid,l_n_formfield, l_n_widget, l_folder, l_container om.DomNode
	DEFINE x, y, l_first_fld, l_last_fld, l_maxlablen SMALLINT
	DEFINE l_pages DECIMAL(3,1)
	DEFINE l_widget STRING

	DISPLAY "Creating Form ..."
	LET l_n_form = m_w.getNode()
	CALL l_n_form.setAttribute("style","main2")
	LET m_f = m_w.createForm(m_formName)
	LET l_n_form = m_f.getNode()
	CALL l_n_form.setAttribute("windowStyle","main2")

	FOR x = 1 TO m_fields.getLength()
		CALL setProperties(x)
		IF m_fld_props[x].label.getLength() > l_maxlablen THEN LET l_maxlablen = m_fld_props[x].label.getLength() END IF
	END FOR
	CALL custom_form_init() -- set custom labels or widgets

	LET l_pages =  m_fields.getLength() / m_fld_per_page
	IF l_pages > 1 THEN -- Folder Tabs
		LET l_folder = l_n_form.createChild("Folder")
	ELSE
		LET l_container = l_n_form.createChild("VBox")
		LET l_last_fld = m_fields.getLength()
	END IF
	LET l_first_fld = 1
	DISPLAY "Fields:",m_fields.getLength()," Pages:",l_pages
	FOR y = 1 TO (l_pages+1)
		IF l_pages > 1 THEN
			LET l_container = l_folder.createChild("Page")
			CALL l_container.setAttribute("text","Page "||y)
			LET l_last_fld = l_last_fld + m_fld_per_page
			IF l_last_fld > m_fields.getLength() THEN LET l_last_fld = m_fields.getLength() END IF
		END IF

		LET l_n_grid = l_container.createChild("Grid")
		CALL m_w.setText(SFMT(%"Dynamic Maintenance for %1",m_tab))

		FOR x = l_first_fld TO l_last_fld
			LET l_n_formfield = l_n_grid.createChild("Label")
			CALL l_n_formfield.setAttribute("text", m_fld_props[x].label )
			CALL l_n_formfield.setAttribute("posY", x )
			CALL l_n_formfield.setAttribute("posX", "1" )
			CALL l_n_formfield.setAttribute("gridWidth", m_fld_props[x].label.getLength() )

			LET l_n_formfield = l_n_grid.createChild("FormField")
			LET m_fld_props[x].formFieldNode = l_n_formfield
			CALL l_n_formfield.setAttribute("name", m_fld_props[x].name )
			CALL l_n_formfield.setAttribute("colName", m_fields[x].colname )
			CALL l_n_formfield.setAttribute("sqlType", m_fields[x].type )
			CALL l_n_formfield.setAttribute("fieldId", x - 1 )
			CALL l_n_formfield.setAttribute("sqlTabName", m_fld_props[x].tabname )
			CALL l_n_formfield.setAttribute("tabIndex", x )
			CALL l_n_formfield.setAttribute("numAlign", m_fld_props[x].numeric)
			IF m_fld_props[x].iskey THEN
				CALL l_n_formfield.setAttribute("notNull", TRUE )
				CALL l_n_formfield.setAttribute("required", TRUE )
			END IF
			IF m_fields[x].type = "DATE" THEN
				LET l_widget = "DateEdit"
			ELSE
				LET l_widget = "Edit"
			END IF
			IF m_fld_props[x].widget IS NOT NULL THEN -- handle custom widget
				LET l_widget = m_fld_props[x].widget
			END IF
			LET l_n_widget = l_n_formField.createChild(l_widget)
			CALL l_n_widget.setAttribute("width", m_fld_props[x].len)
			IF m_fld_props[x].widget = "ComboBox" THEN
				CALL l_n_widget.setAttribute("initializer", m_fld_props[x].widget_props)
			END IF
			CALL l_n_widget.setAttribute("posY", x )
			CALL l_n_widget.setAttribute("posX", l_maxlablen+1 )
			CALL l_n_widget.setAttribute("gridWidth", m_fld_props[x].len )
			CALL l_n_widget.setAttribute("comment", "Type:"||m_fields[x].type )
			IF m_fld_props[x].numeric THEN
				CALL l_n_widget.setAttribute("justify", "right")
			END IF
		END FOR
		LET l_first_fld = l_first_fld + m_fld_per_page
	END FOR
	LET l_n_formfield = l_n_form.createChild("RecordView")
	CALL l_n_formfield.setAttribute("tabName",m_tab)
	FOR x = 1 TO m_fld_props.getLength()
		LET l_n_widget = l_n_formfield.createChild("Link")
		CALL l_n_widget.setAttribute("colName",m_fld_props[x].colname )
		CALL l_n_widget.setAttribute("fieldIdRef", x-1 )
	END FOR
	DISPLAY "Form Created."
	CALL glm_combos() -- do combobox initializer calls
-- for debug only
	CALL ui.Interface.refresh()
	CALL ui.Interface.getRootNode().writeXml("aui_"||m_tab||"_dynamic.xml")
END FUNCTION
--------------------------------------------------------------------------------
-- attempt to handle any comboboxes
FUNCTION glm_combos()
	DEFINE x SMALLINT
	DEFINE l_cb ui.ComboBox
	FOR x = 1 TO m_fld_props.getLength()
		IF m_fld_props[x].widget = "ComboBox" AND m_fld_props[x].widget_callback IS NOT NULL THEN
			DISPLAY "Looking for cb of: ", m_fld_props[x].name
			LET l_cb = ui.ComboBox.forName( m_fld_props[x].name )
			CALL m_fld_props[x].widget_callback( l_cb )
		END IF
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
-- set a specific field to a specific widget
FUNCTION setWidget(l_fldName STRING, l_widget STRING, l_widget_prop STRING, f_init_cb t_init_cb) --l_widget_props STRING)
	DEFINE x SMALLINT
	FOR x = 1 TO m_fld_props.getLength()
		IF m_fld_props[x].colname = l_fldName THEN
			LET m_fld_props[x].widget = l_widget
			LET m_fld_props[x].widget_props = l_widget_prop
			LET m_fld_props[x].widget_callback = f_init_cb
			RETURN
		END IF
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
-- set the screen field nodes value to the values from the db
FUNCTION update_form_value(l_sql_handle base.SqlHandle)
	DEFINE x SMALLINT
	FOR x = 1 TO m_fld_props.getLength()
		IF  m_fld_props[x].formFieldNode IS NOT NULL THEN
			CALL m_fld_props[x].formFieldNode.setAttribute("value", l_sql_handle.getResultValue(x))
		END IF
	END FOR
	CALL ui.Interface.refresh()
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION setProperties(l_fldno SMALLINT)
	DEFINE l_typ, l_typ2 STRING
	DEFINE l_len SMALLINT
	DEFINE x, y SMALLINT
	DEFINE l_num BOOLEAN

	LET l_num = TRUE
	LET l_typ =  m_fields[l_fldno].type
	IF l_typ = "SMALLINT" THEN LET l_len = 5 END IF
	IF l_typ = "INTEGER" OR l_typ = "SERIAL" THEN LET l_len = 10 END IF
	IF l_typ = "DATE" THEN LET l_len = 10 END IF
	LET l_typ2 = l_typ

	LET x = l_typ.getIndexOf("(",1)
	IF x > 0 THEN
		LET l_typ2 = l_typ.subString(1, x-1 )
		LET y = l_typ.getIndexOf(",",x)
		IF y = 0 THEN
			LET y = l_typ.getIndexOf(")",x)
		END IF
		LET l_len = l_typ.subString(x+1,y-1)
	END IF

	IF l_typ2 = "CHAR" OR l_typ2 = "VARCHAR" OR l_typ2 = "DATE" THEN
		LET l_num = FALSE
	END IF
	LET m_fld_props[l_fldno].name = m_tab.trim()||"."||m_fields[l_fldno].colname
	LET m_fld_props[l_fldno].tabname = m_tab
	LET m_fld_props[l_fldno].colname = m_fields[l_fldno].colname
	LET m_fld_props[l_fldno].label = pretty_lab(m_fields[l_fldno].colname)
	LET m_fld_props[l_fldno].len = l_len
	LET m_fld_props[l_fldno].numeric = l_num
	LET m_fld_props[l_fldno].iskey = (l_fldno = m_key_fld)
END FUNCTION
--------------------------------------------------------------------------------
-- Upshift 1st letter : replace _ with space : split capitalised names
PRIVATE FUNCTION pretty_lab( l_lab VARCHAR(60) ) RETURNS STRING
	DEFINE x,l_len SMALLINT
	LET l_len = LENGTH( l_lab )
	FOR x = 2 TO l_len
		IF l_lab[x] >= "A" AND l_lab[x] <= "Z" THEN 
			LET l_lab = l_lab[1,x-1]||" "||l_lab[x,60]
			LET l_len = l_len + 1
			LET x = x + 1
		END IF
		IF l_lab[x] = "_" THEN LET l_lab[x] = " " END IF
	END FOR
	LET l_lab[1] = UPSHIFT(l_lab[1])
	RETURN (l_lab CLIPPED)||":"
END FUNCTION