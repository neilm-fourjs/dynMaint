
TYPE t_fields RECORD
		name STRING,
		type STRING
	END RECORD
TYPE t_fld_props RECORD
		label STRING,
		len SMALLINT,
		numeric BOOLEAN,
		formFieldNode om.DomNode
	END RECORD
