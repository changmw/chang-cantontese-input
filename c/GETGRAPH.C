/*
 Detect a machine's best graphics hardware
 Written by Chang Man Wai
*/
#include <graphics.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
  int graphdriver;

  printf("\nGETGRAPH v1.0\n");
  detectgraph(&graphdriver, NULL);
  if (argc>1) {
    printf("- return machine's best graphics hardware as errorlevel"
	   "\n\n\t0 for none"
	   "\n\t%d for CGA\t\t%d for MCGA"
	   "\n\t%d for EGA\t\t%d for EGA 64 Color"
	   "\n\t%d for EGA Mono\t\t%d for VGA"
	   "\n\t%d for Hercules",
           CGA, MCGA, EGA, EGA64, EGAMONO, VGA, HERCMONO);
    printf("\n\nExit with %d\n", graphdriver);
  }
  return(graphdriver);
}
