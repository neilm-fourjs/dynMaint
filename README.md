# dynMaint
Simple dynamic table maintenance program.


Does: find, update, insert, delete
To Do: locking, sample, listing report


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
