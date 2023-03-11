      * USTRING.PRG
      *
      *      Create a Unique Character String
      *
      *   Usage: ? USTRING()
      *          Store USTRING() TO memvar
      *          REPLACE <field> WITH USTRING()                
      *
      *   Author: Pat Adams
      *   Date: 4/16/92
      *   Copyright 1992 DB Unlimited
      * * * * * * * * * * * * * * * * * * * * * * * * * *
      PARAMETERS sendback
      STORE SUBSTR(SYS(3), 4, 4) + ;
        SUBSTR(SYS(2015),7,4) TO sendback
      RETURN sendback  
