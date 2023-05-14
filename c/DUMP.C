#include <stdio.h>
#include <string.h>
#include "turcbtrv.h"
#include "btrdef.h"
#include "conv.h"

/*
BTRV (Btrieve) parameters

Survey Resaerch Group (HQ) had Pascal programs that used Btrieve
to speed up file processing.

This C program aimed to access those data files using C library 
for Btrieve.
*/
char POS_BLK[128];
int KEY_NUM;

typedef char real[6];

char pos_rec[4];

struct r_in_rec_format {
  char mkt_code[3],   stub_code[4];
  real sales_vol,     p_sales_vol,
       sales_value,   p_sales_value,
       average_price, price_index,
       rtn_pur_vol,   p_rtn_pur_vol,
       pur_dist_num,  pur_dist_wgt,
       total_stock,   f_stock,        r_stock,
       s_duration,
       is_dist_num,   is_dist_wgt,
       os_dist_num,   os_dist_wgt,
       ts_dist_num,   ts_dist_wgt;
};

struct w_in_rec_format {
  char   mkt_code[4], stub_code[5];
  double sales_vol, p_sales_value;
};

struct r_in_rec_format r_in_rec;
struct w_in_rec_format w_in_rec;

int rec_len;

void disp_rec();
void r_to_w();

void main() {
  int rc;
  char *file="TEST.DAT";
  rec_len = sizeof(struct r_in_rec_format);

  if (!b_open(file)) {
    rc=BTRV(B_STEP_FIRST, POS_BLK, &r_in_rec, &rec_len, 0, 0);
    while (!rc && !kbhit()) {
      r_to_w();
      disp_rec(w_in_rec);
      rc = BTRV(B_STEP_NEXT, POS_BLK, &r_in_rec, &rec_len, 0, 0);
    }
    b_close(file);
  }
  getch();
}

void disp_rec(struct w_in_rec_format rec) {
  static int i=0;
  printf("Record#%4d %s %s %f %f\n", i++,
                              rec.mkt_code,
                              rec.stub_code,
                              rec.sales_vol,
                              rec.p_sales_value);
}

int b_open(char *file) {
  int rc;

  rc=BTRV(B_OPEN, POS_BLK, &r_in_rec, &rec_len, file, 1);
  printf("File opened, rc=%d\n", rc);
  return(rc);
}

int b_close(char *file) {
  int rc;

  rc = BTRV(B_CLOSE, POS_BLK, &r_in_rec, &rec_len, file, 1);
  printf("File closed, rc=%d\n", rc);
  return(rc);
}

void r_to_w() {
  int i;

  for (i=0;i<3;i++) w_in_rec.mkt_code[i]=r_in_rec.mkt_code[i];
  w_in_rec.mkt_code[i]='\0';
  for (i=0;i<4;i++) w_in_rec.stub_code[i]=r_in_rec.stub_code[i];
  w_in_rec.stub_code[i]='\0';
  w_in_rec.sales_vol=rtod(r_in_rec.sales_vol);
  w_in_rec.p_sales_value=rtod(r_in_rec.p_sales_value);
}
