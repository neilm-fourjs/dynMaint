# dynMaint
Simple dynamic table maintenance program.

Does: find, update, insert, delete
To Do: locking, sample, listing report

This demos also uses the g2_lib and njm_demo_db for the database and library code, so make sure to also check that out.

You can build using the GeneroStudio project file or on Linux you can use the makefile ( which will use the GeneroStudio project file )


Command Args:
------
* 1: Windows Mode: M = MDI Container / C = MDI Child / S = SDI(default)
* 2: Database name
* 3: Table name
* 4: Primary Key name
* 5: Allowed actions


Allowed Actions: 
------
* Find / Update / Insert / Delete / Sample / List  
* eg: 
* YNNNNN = enquiry only.
* YYNNNN = enquire and update only

The program will attempt to open a form with the name of dm_<dbname>_<tabname> if it fails it will generate a screen form dynamically.
This means you can create some nice forms for important tables and have others to be dynamically generated.

# Building:
Set the Genero Environment then:
```
git clone git@github.com:neilm-fourjs/g2_lib.git
git clone git@github.com:neilm-fourjs/njm_demo_db.git
git clone git@github.com:neilm-fourjs/dynMaint.git
cd dynMaint/
make run
```
