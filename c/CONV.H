/*
  To convert a C type Double to & from a Pascal type Real
  Format of the floating point refer to  Turbo Pascal.
  Note that the double of C and Pascal are the same.

  Mario 14 June 91                  NEWC2P.H & NEWP2C.H
  Daniel Chu 20/05/92               PAS2C.H
  Chang Man Wai 3/6/92              CONV.H
----------------------------------------------------------------
 temp_int1 == C Double exponent 11 bits from bit 52 to 62 biased 1023
              valid range for double exponent part is from  0  - 2047

 Pascal real type -- exponent is 8 bits and excess 129
                     therefore range from 0 to 255

   For a valid C Double to Pascal Real conversion
   the C Double exponent part is valid from range
             (1-129) + 1023 = 895
                to
             (255- 129) + 1023 = 1149

 temp_int2 == Pascal Real exponent  from 0 < temp_int2 <=255
*/
#include <alloc.h>

#define REAL_LENGTH   6
#define DOUBLE_LENGTH 8

char *dtor(double d, char *Outreal ) {
  char Pas_Real[REAL_LENGTH];
  int i, temp_int1, temp_int2;
  char *C_Double=(char *)&d;

  /* get 11 bits of exponent of double */
  temp_int1 = ((C_Double[7] & 0x7F)  << 4) | ((C_Double[6] & 0xF0)  >> 4);

  /* get 11 bits end */
  if (temp_int1 > 1149 || temp_int1 < 895)  {
  /* Infinity/NaNs/zero/too small/too large
     NOT to be represented by Pascal Real */

        Pas_Real[5] = Pas_Real[4] = Pas_Real[3] = 0;
        Pas_Real[2] = Pas_Real[1] = Pas_Real[0] = 0;
  }
  else {                                             /* begin conversion */
        temp_int2 = temp_int1 - 1023 + 129;          /* 0 < temp_int2 <= 255 */
        Pas_Real[0] = (char)(temp_int2 & 0x00FF);    /* assign exponent */
        Pas_Real[5] = C_Double[7] & 0x80 |           /* assign significant bit */
                      ((C_Double[6] & 0x0F) << 3) |
                      ((C_Double[5] & 0xE0) >> 5);

        Pas_Real[4] = ((C_Double[5] & 0x1F) << 3) |
                      ((C_Double[4] & 0xE0) >> 5);

        Pas_Real[3] = ((C_Double[4] & 0x1F) << 3) |
                      ((C_Double[3] & 0xE0) >> 5);

        Pas_Real[2] = ((C_Double[3] & 0x1F) << 3) |
                      ((C_Double[2] & 0xE0) >> 5);

        Pas_Real[1] = ((C_Double[2] & 0x1F) << 3) |
                      ((C_Double[1] & 0xE0) >> 5);
  }
  for (i=0;i<REAL_LENGTH; i++) Outreal[i] = Pas_Real[i];
  return(Outreal);
}

double rtod(char *Pas_Real) {
  char *C_Double=(char *)malloc(DOUBLE_LENGTH);
  unsigned int temp_int1;
  double Out_C_Double;
  int i;

  if (Pas_Real[0] != 0) {
          temp_int1  = ((unsigned int)Pas_Real[0] & 0x00FF) + 1023 - 129;
                  /* temp_int1 contain exponent of double of 11 bits */

          C_Double[7] = ((char) (temp_int1 >> 4)) | (Pas_Real[5] & 0x80);
                  /* higher 7 bits of exponent    sign bit of Pas_Real */

          C_Double[6] = ((char) (temp_int1 & 0x000F)) << 4 |
                        ((char) Pas_Real[5] & 0x78) >> 3;
	  C_Double[5] = (Pas_Real[5] & 0x07) << 5 | (Pas_Real[4] & 0xF8) >> 3;
          C_Double[4] = (Pas_Real[4] & 0x07) << 5 | (Pas_Real[3] & 0xF8) >> 3;
          C_Double[3] = (Pas_Real[3] & 0x07) << 5 | (Pas_Real[2] & 0xF8) >> 3;
          C_Double[2] = (Pas_Real[2] & 0x07) << 5 | (Pas_Real[1] & 0xF8) >> 3;
          C_Double[1] = (Pas_Real[1] & 0x07) << 5;
          C_Double[0] = 0;
  }
  else { 			/* v = 0 */
          C_Double[7] = C_Double[6] = C_Double[5] = C_Double[4] = 0;
          C_Double[3] = C_Double[2] = C_Double[1] = C_Double[0] = 0;
  }
  memmove(&Out_C_Double,C_Double,DOUBLE_LENGTH);
  free(C_Double);
  return(Out_C_Double);
}
