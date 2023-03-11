#include <stdio.h>
unsigned int code=1;
long offset,offset2;
unsigned int off,off1;

main()
{
 while (code!=0)
 {
     printf("Enter internal code : ");
     scanf("%x",&code);

     if (code>=0xaaef)
     {
        offset=(code-0xaaef)/0x100*0x9d; /* 0x9d valid characters in  0x100 address */
        offset2=(code-0xaaef)% 0x100;
        if (offset2<0x11)                /* check if address >=ef and <=fe */
	   offset+=offset2;
        else
	   if (offset2<0x90)             /* check if address >=40 and <=7e */
	      offset+=offset2-0x41;
           else
	      offset+=offset2-0x63;      /* address >=a1 and <=ee */
        if (code>0xc93f)
	   offset-=0x198;  /* compensate for the 408 reserved words */
     }
     else
     {
        offset=(code-0xa440)/0x100*0x9d;
        offset2=(code-0xa440)% 0x100;
        if (offset2<0x3f)                /* check if address >=40 and <=7e */
   	   offset+=offset2;
        else
	   if (offset2<0xbf)             /* address >=a1 and <=fe */
	      offset+=offset2-0x22;
     }

     if (code>=0xaaef)
        offset+=1083;
     if (code>=0xc940)
        offset-=5401;
     off=offset/95+33;
     off1=offset%95+33;
     printf("%u  %u  %i\n",off,off1,offset);
     getch();
 }
}