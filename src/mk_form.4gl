
&include "dynMaint.inc"

# Build a form based on an array of field names and an array of properties.
#+ @param l_tab Table name
#+ @param l_fld_per_page Fields per page ( folder tabs )
#+ @param l_fields Array of field names / types
#+ @param l_fld_props Array of field properties.
PUBLIC DEFINE m_fld_props DYNAMIC ARRAY OF t_fld_props
--------------------------------------------------------------------------------
FUNCTION mk_form(
	l_tab STRING, 
	l_fld_per_page SMALLINT, 
	l_fields DYNAMIC ARRAY OF t_fields
	)

	DEFINE l_w ui.Window
	DEFINE l_f ui.Form
	DEFINE l_n_form, l_n_tb, l_n_grid,l_n_formfield, l_n_widget, l_folder, l_container  om.DomNode
	DEFINE x, y, l_first_fld, l_last_fld, l_maxlablen SMALLINT
	DEFINE l_pages DECIMAL(3,1)

	LET l_w = ui.Window.getCurrent()
	LET l_n_form = l_w.getNode()
	CALL l_n_form.setAttribute("style","main2")

	LET l_f = l_w.createForm("dyn_"||l_tab)
	LET l_n_form = l_f.getNode()
	CALL l_n_form.setAttribute("windowStyle","main2")

{ Now using dynmaint.4tb instead
	LET l_n_tb = l_n_form.createChild("ToolBar")
	CALL add_toolbarItem(l_n_tb, "quit","Quit","quit")
	CALL add_toolbarItem(l_n_tb, "accept","Accept","accept")
	CALL add_toolbarItem(l_n_tb, "cancel","Cancel","cancel")
	CALL add_toolbarItem(l_n_tb, "find","Find","find")
	CALL add_toolbarItem(l_n_tb, "insert","Insert","new")
	CALL add_toolbarItem(l_n_tb, "update","Update","pen")
	CALL add_toolbarItem(l_n_tb, "delete","Delete","delete")
	CALL add_toolbarItem(l_n_tb, "firstrow","","")
	CALL add_toolbarItem(l_n_tb, "prevrow","","")
	CALL add_toolbarItem(l_n_tb, "nextrow","","")
	CALL add_toolbarItem(l_n_tb, "lastrow","","")
}
	LET l_pages =  l_fields.getLength() / l_fld_per_page
	IF l_pages > 1 THEN -- Folder Tabs
		LET l_folder = l_n_form.createChild("Folder")
	ELSE
		LET l_container = l_n_form.createChild("VBox")
		LET l_last_fld = l_fields.getLength()
	END IF
	LET l_first_fld = 1
	DISPLAY "Fields:",l_fields.getLength()," Pages:",l_pages

	FOR y = 1 TO (l_pages+1)
		IF l_pages > 1 THEN
			LET l_container = l_folder.createChild("Page")
			CALL l_container.setAttribute("text","Page "||y)
			LET l_last_fld = l_last_fld + l_fld_per_page
			IF l_last_fld > l_fields.getLength() THEN LET l_last_fld = l_fields.getLength() END IF
		END IF

		LET l_n_grid = l_container.createChild("Grid")
		CALL l_w.setText(SFMT(%"Dynamic Maintenance for %1",l_tab))

		FOR x = l_first_fld TO l_last_fld
			CALL setProperties(x, l_fields, m_fld_props)
			LET l_n_formfield = l_n_grid.createChild("Label")
			CALL l_n_formfield.setAttribute("text", m_fld_props[x].label )
			CALL l_n_formfield.setAttribute("posY", x )
			CALL l_n_formfield.setAttribute("posX", "1" )
			CALL l_n_formfield.setAttribute("gridWidth", m_fld_props[x].label.getLength() )
			IF m_fld_props[x].label.getLength() > l_maxlablen THEN LET l_maxlablen = m_fld_props[x].label.getLength() END IF
		END FOR
		FOR x = l_first_fld TO l_last_fld
			LET l_n_formfield = l_n_grid.createChild("FormField")
			LET m_fld_props[x].formFieldNode = l_n_formfield
			CALL l_n_formfield.setAttribute("colName", l_fields[x].name )
			CALL l_n_formfield.setAttribute("name", l_tab||"."||l_fields[x].name )
			IF l_fields[x].type = "DATE" THEN
				LET l_n_widget = l_n_formField.createChild("DateEdit")
			ELSE
				LET l_n_widget = l_n_formField.createChild("Edit")
			END IF
			CALL l_n_widget.setAttribute("posY", x )
			CALL l_n_widget.setAttribute("posX", l_maxlablen+1 )
			CALL l_n_widget.setAttribute("gridWidth", m_fld_props[x].len )
			CALL l_n_widget.setAttribute("width", m_fld_props[x].len)
			CALL l_n_widget.setAttribute("comment", "Type:"||l_fields[x].type )
		END FOR
		LET l_first_fld = l_first_fld + l_fld_per_page
	END FOR

END FUNCTION
--------------------------------------------------------------------------------
-- set the screen field nodes value to the values from the db
FUNCTION update_form_value(l_sql_handle base.SqlHandle)
	DEFINE x SMALLINT
	FOR x = 1 TO m_fld_props.getLength() -- 
		CALL m_fld_props[x].formFieldNode.setAttribute("value", l_sql_handle.getResultValue(x))
	END FOR
	CALL ui.Interface.refresh()
END FUNCTION
--------------------------------------------------------------------------------
-- add a toolbar item
FUNCTION add_toolbarItem( l_n, l_nam, l_txt, l_img )
	DEFINE l_n om.DomNode
	DEFINE l_nam, l_txt, l_img STRING
	LET l_n = l_n.createChild("ToolBarItem")
	CALL l_n.setAttribute("name", l_nam )
	IF l_txt IS NOT NULL THEN
		CALL l_n.setAttribute("text", l_txt )
	END IF
	IF l_img IS NOT NULL THEN
		CALL l_n.setAttribute("image", l_img )
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setProperties( 
	l_fldno SMALLINT,
	l_fields DYNAMIC ARRAY OF t_fields,
	l_fld_props DYNAMIC ARRAY OF t_fld_props
 )

	DEFINE l_typ, l_typ2 STRING
	DEFINE l_len SMALLINT
	DEFINE x, y SMALLINT
	DEFINE l_num BOOLEAN

	LET l_num = TRUE
	LET l_typ =  l_fields[l_fldno].type
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
	LET l_fld_props[l_fldno].label = pretty_lab(l_fields[l_fldno].name)
	LET l_fld_props[l_fldno].len = l_len
	LET l_fld_props[l_fldno].numeric = l_num
END FUNCTION
--------------------------------------------------------------------------------
-- Upshift 1st letter : replace _ with space : split capitalised names
FUNCTION pretty_lab( l_lab VARCHAR(60) ) RETURNS STRING
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