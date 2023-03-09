/* function to extract the connection information of a workstation */
/* used with Netware NETX.COM and IPX.COM */
/* the caller should make sure IPX and NETX are loaded */
#include <stdio.h>
#include <dos.h>

void Connection_ID_Table(char *ID_table) {
   char far *Connection_ID_Table;
   union   REGS    regs;
   struct  SREGS   segregs;
   int      i;

   regs.h.ah = 0xEF;
   regs.h.al = 0x03;
   segregs.es = 0x0000;
   int86x(0x21,&regs,&regs,&segregs);
   Connection_ID_Table = MK_FP(segregs.es,regs.x.si);
   for (i=1;i<=256;i++) {
       *ID_table = *Connection_ID_Table;
       ID_table++;
       Connection_ID_Table++;
   }
}

void Server_Name_Table(char *name_table) {
   char far *Server_Name_Table;
   union   REGS    regs;
   struct  SREGS   segregs;
   int      i;

   regs.h.ah = 0xEF;
   regs.h.al = 0x04;
   segregs.es = 0x0000;
   int86x(0x21,&regs,&regs,&segregs);
   Server_Name_Table = MK_FP(segregs.es,regs.x.si);
   for (i=1;i<=384;i++) {
       *name_table = *Server_Name_Table;
       name_table++;
       Server_Name_Table++;
   }
}
