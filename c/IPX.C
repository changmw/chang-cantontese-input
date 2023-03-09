#include <stdlib.h>
#include <dos.h>
#include <mem.h>
#include <string.h>
#include "ipx.h"

void main() {
  struct {
	 unsigned char uname[50];
	 unsigned char network_number[50];
	 unsigned char physical_node[50];
  } userlist[100];
  int i;

  for (i=0;i<50;i++) {
	 get_user_id(i, userlist[i].uname);
	 get_internet_address(i,
								 userlist[i].network_number,
								 userlist[i].physical_node);
	 printf("%d %s %s %s\n", i, userlist[i].uname,
										 userlist[i].network_number,
										 userlist[i].physical_node);
  }
}
