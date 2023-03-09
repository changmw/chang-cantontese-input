#include <stdio.h>
#include <dos.h>
//
// check if a Chinese System is running
// Chun Hon and Eten are considered Eten by this program
//
// In the days of MS DOS, there were a few famous Chinese input system,
// all of them came from Taiwan.
// 
//
enum { NOCHINESE, ET, ZERO, DRAGON, KC };

int et();
int zero();
int dragon();
int kc();

void main()
{
   if (et() == ET) printf("Eten Chinese System is running.\n");
   else if (zero() == ZERO) printf("Zero-One Chinese System is running.\n");
   else if (dragon() == DRAGON)
        printf("Dragon-Disk Chinese System is running.\n");
   else if (kc() == KC) printf("Kuo Chiau Chinese System is running.\n");
   else printf("No Chinese System is running.\n");
}

int et()
{
  union REGS r;

  r.x.ax = 0x9100;
  int86(0x10, &r, &r);
  if (r.x.ax != 0x9100)
    return(ET);
  else
    return(NOCHINESE);
}

int zero()
{
  union REGS r;

  r.x.ax = 0x59ff;
  int86(0x10, &r, &r);
  if (r.h.al != 0xff)
    return (ZERO);
  else
    return(NOCHINESE);
}

int dragon()
{
  unsigned char far *pj;

  pj = MK_FP(peek(0,0x5a), peek(0,0x58));
  if (*pj == 0x90)
    return(DRAGON);
  else
    return(NOCHINESE);
}

int kc()
{
  union REGS r;

  r.x.ax = 0x9100; /* if it does not work, try r.x.ax = 0xcc00 */
  int86(0x16, &r, &r);
  r.h.al ^= r.h.al;
  if ((r.h.ah - 0x05) == 0x00)
    return(KC);
  else
    return(NOCHINESE);
}
