//
// GETQ.C
// 
// List print queues of Novell Netware 386
//
// 1. Menu functions and Queue Name collection routines by Adam Chan
// 2. Printer capture routines by Chang Man Wai
// 
//  NetWare C Interface-DOS v1.2 required!
//
#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <stdlib.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <nitq.h>
#include <npt.h>
#include "server.h"

/***********************************************************************/
#define ESC			'\x1B'
#define ENTERKEY	'\x0D'
#define HOMEKEY   '\xC7'
#define ENDKEY	   '\xCF'
#define UPKEY	   '\xC8'
#define DOWNKEY   '\xD0'
#define PGUPKEY   '\xC9'
#define PGDNKEY   '\xD1'	/*209*/
#define RIGHTKEY  '\xCD'	/*205*/
#define LEFTKEY   '\xCB'	/*203*/
#define INSKEY	   '\xD2'	/*210*/
#define DELKEY	   '\xD3'	/*211*/
#define screen_Height	21
#define TABLE_SIZE 12

/*** table for storing all print queues in the network ***/
struct Global_Q_Rec {
	char     			server_name[48];
	int      			server_ID;
	long     			Q_ID;
	char     			Q_name[48];
} globalQList[20];

/***********************************************************************/
unsigned    max_server_ID = 8;
const WORD	MAXJOB = 250;
int			no_of_queue;
WORD        jobList[250], SPXConnection;
BYTE        accessCode;
char        PSName[50];
BYTE        oldConnectionID;
BYTE        local_printer;

/***********************************************************************/
extern void Connection_ID_Table(char *);
extern void Server_Name_Table(char *);

extern struct Connection_ID_Rec ID_table[8];
extern struct Server_Name_Rec server_table[8];

void    DisplayQueue();
void    ShowBox(int, int, int, int);
int     RunCapture(int);
int     GetQueueChoice();
char	GetKey();
char    getkey(char);
void    ErrorHandler(int, char *);
void    exitout(int);
char    *logical_name(char *, char *);

/***********************************************************************/
void main(int argc, char *argv[]) {
	unsigned	jobfile;
	int      i, j, status, selectedQNumber;
	BYTE		queueStatus, numberOfJobs, numberOfServers;
	long		selectedQID, serverIDList[1];
	WORD		objType, serverStationList[1], maxNumberOfServers;
	union 	REGS		regs;
	struct	SREGS		sregs;
	struct 	text_info	ti;

    if (argc == 1) {
        printf("\nGETQ v1.0");
        printf("\nUsage: GETQ [Printer Port]\n");
		exit(0);
	}

    local_printer=atoi(argv[1])-1;

    if (local_printer>2) {
      printf("\nInvalid printer port number!\n");
      printf("\nGETQ v1.0");
      printf("\nUsage: GETQ [Printer Port]\n");
      exit(0);
    }

	directvideo = 1;
	gettextinfo(&ti);
/******* find all the valid connections *******/
    Server_Name_Table((char *) &server_table[0]);
	Connection_ID_Table((char *) &ID_table[0]);
/******* build a lookup table for queues and attached servers *******/
    no_of_queue = fillGQTable();
/******* main processing loop start here *******/
	do {
        switch (local_printer) {
        case 0: selectedQNumber = ShowGQPopup(" Select Printer for LPT1 ");
                break;
        case 1: selectedQNumber = ShowGQPopup(" Select Printer for LPT2 ");
                break;
        case 2: selectedQNumber = ShowGQPopup(" Select Printer for LPT3 ");
                break;
        }
		if (selectedQNumber) {   				/** 0 indicate ESCAPE **/
			selectedQNumber--;               /** adjustment to access array **/
            SetPreferredConnectionID(globalQList[selectedQNumber].server_ID);
            clrscr();
            status = RunCapture(selectedQNumber);
		}
        else {
          status = 0x1b;
          textattr(ti.attribute);
          clrscr();
        }
	} while(status!=0x1b);
    exit(0);
}

/***********************************************************************/
int fillGQTable() {

	int      ccode, i, j;
	long     objectID = -1;
	char     objectName[48];
	char     searchName[48];
	WORD     searchType;
	WORD     objectType;
	char     HasProperties;
	char     objectFlag;
	char     Security;

	strcpy(searchName,"*");
	searchType = 0x03;
	j = 0;
	for(i=0;i<max_server_ID;i++) {
		if (ID_table[i].in_use_flag) {
			SetPreferredConnectionID(i+1);
			for (objectID=-1,ccode=0;!ccode;) {
                ccode = ScanBinderyObject(searchName,searchType,&objectID,objectName,
                                          &objectType,&HasProperties,&objectFlag,
                                          &Security);
				if (ccode == 0) {
					strcpy(globalQList[j].server_name, server_table[i].server_name);
					strcpy(globalQList[j].Q_name,objectName);
					globalQList[j].server_ID = i+1;
					globalQList[j].Q_ID = objectID;
					j++;
				} /* end if inner */
			} /* end for inner*/
		} /* end if */
	} /* end for outer*/
	return(j);
}

/***********************************************************************/
int ShowGQPopup(char *message) {
	int	queueNumber;
	short up, left, right;

    textattr(LIGHTGREEN + (BLACK << 4));
	clrscr();
	gotoxy(1,1);
	textattr(BLACK + (LIGHTGRAY << 4));
	clreol();
    cputs(" Select Netware Print Queue For Printer Port v1.0");
	gotoxy(1,25);
	clreol();
	cputs(message);
    textattr(WHITE + (BLACK << 4));
	up = 13 - (no_of_queue + 3) / 2;
	left = 24;
	right = left + 31;
	ShowBox(left,up,right,no_of_queue+up+1);
	queueNumber = GetQueueChoice();
	window(1,1,80,25);
	return(queueNumber);
}

/***********************************************************************/
void	ShowBox(int left, int up, int right, int down) {
	int	i;
	char	string[82];

	window(left,up,right,down);
	memset(string,'\0',82);
	string[0] = '?;
	for (i=1;i<right-left;i++)
		strcat(string,"?);
	strcat(string,"?);
	gotoxy(1,down-up);
	cprintf("%s",string);
	memset(string,'\0',82);
	string[0] = '?;
	for (i=1;i<right-left;i++)
		strcat(string,"?);
	strcat(string,"?);
	gotoxy(1,1);
	cprintf("%s",string);
	memset(string,'\0',82);
	string[0] = '?;
	for (i=1;i<right-left;i++)
		strcat(string," ");
	strcat(string,"?);
	for(i=2;i<down-up;i++) {
		gotoxy(1,i);
		cprintf("%s",string);
	}
	insline();
	cprintf("%s",string);
	window(left+1,up+1,right,down-1);
}

/***********************************************************************/
int	GetQueueChoice() {
	static	int	previousBar, currentBar = 1;
	char		keystroke;

    textattr(LIGHTGRAY+(BLACK << 4));
	DisplayQueue();         /* <-- assume queue never > 23 */
	if (!currentBar) currentBar = 1;
	do {
		textattr(BLACK + (LIGHTGRAY << 4));
		gotoxy(1,currentBar);
		cprintf("%-30s",globalQList[currentBar-1].Q_name);
		previousBar = currentBar;
		keystroke = GetKey('U');
		switch(keystroke) {
			case HOMEKEY	:	currentBar = 1; break;
			case ENDKEY		:	currentBar = no_of_queue; break;
			case UPKEY		:	if (currentBar > 1) currentBar--; break;
            case DOWNKEY    :   if (currentBar < no_of_queue) currentBar++; break;
			case ESC			:	currentBar = 0; break;
			case ENTERKEY	:  break;
		}
		gotoxy(1,previousBar);
        textattr(LIGHTGRAY+(BLACK << 4));
		cprintf("%-30s",globalQList[previousBar-1].Q_name);
	} while ((keystroke != ESC) && (keystroke != ENTERKEY));
	return(currentBar);
}

/***********************************************************************/
void	DisplayQueue() {
	int	i;

	for (i=0; i<no_of_queue; i++) {
		gotoxy(1,i+1);
        cprintf("%-30s",globalQList[i].Q_name);
	}
}

/***********************************************************************/
char GetKey(char mode)
{
	char	ch;

	ch = getch();
	do {
		if (ch == NULL) {
			ch = getch();
			if (toascii(ch) > 127) ch = NULL;
			else ch = toupper(toascii(ch) + 128);
		}
		else switch (mode) {
			case 'U':
			case 'u':
				ch = toupper(ch); break;
			case 'L':
			case 'l':
				ch = tolower(ch); break;
			};
	} while (ch == NULL);
	return (ch);
}

/***********************************************************************/
void	ErrorHandler(int errorCode, char *functionCall) {

	struct	text_info	ti;
    char    messageString[50];

	gettextinfo(&ti);
	textattr(WHITE + (RED << 4));
	ShowBox(18,9,61,16);
	switch(errorCode) {
    case 64:   strcpy(messageString,"No available SPX Connection"); break;
    case 65:   strcpy(messageString,"SPX not Initialized"); break;
    case 66:   strcpy(messageString,"No Such Print Server"); break;
    case 67:   strcpy(messageString,"Unable to get Server address"); break;
    case 68:   strcpy(messageString,"Cannot connect to Server"); break;
    case 69:   strcpy(messageString,"No available IPX socket"); break;
    case 70:   strcpy(messageString,"Already attach to Print Server"); break;
    case 150:  strcpy(messageString,"Server Out of Memory"); break;
    case 153:  strcpy(messageString,"Directory Full"); break;
    case 156:  strcpy(messageString,"Invalid Path"); break;
    case 208:  strcpy(messageString,"Queue Error"); break;
    case 209:  strcpy(messageString,"No such Queue"); break;
    case 210:  strcpy(messageString,"No Queue Server"); break;
    case 211:  strcpy(messageString,"No Queue Rights"); break;
    case 212:  strcpy(messageString,"Queue Full"); break;
    case 213:  strcpy(messageString,"No Queue Job"); break;
    case 214:  strcpy(messageString,"No Job Rights"); break;
    case 215:  strcpy(messageString,"Queue Servicing"); break;
    case 216:  strcpy(messageString,"Queue Not Active"); break;
    case 218:  strcpy(messageString,"Queue Halted"); break;
    case 219:  strcpy(messageString,"Maximum Queue Server"); break;
    case 237:  strcpy(messageString,"SPX Connection Terminated"); break;
    case 238:  strcpy(messageString,"Object Already Exists"); break;
    case 239:  strcpy(messageString,"Invalid Name"); break;
    case 241:  strcpy(messageString,"Invalid Bindery Security"); break;
    case 252:  strcpy(messageString,"No such Object"); break;
    case 254:  strcpy(messageString,"Server Bindery Locked"); break;
    case 255:  strcpy(messageString,"Bindery Failure"); break;
    case 769:  strcpy(messageString,"Not Enough Memory"); break;
    case 770:  strcpy(messageString,"No such Printer"); break;
    case 771:  strcpy(messageString,"Invalid Parameter"); break;
    case 773:  strcpy(messageString,"Cannot detach from Server"); break;
    case 774:  strcpy(messageString,"Print Server Going Down"); break;
    case 775:  strcpy(messageString,"Print Server Not connected"); break;
    case 777:  strcpy(messageString,"No Job Active"); break;
    case 780:  strcpy(messageString,"Print server down"); break;
    case 782:  strcpy(messageString,"No Rights"); break;
    case 1024: strcpy(messageString,"Unable to verify Identity"); break;
    default:   strcpy(messageString,"Unknown"); break;
	}
	gotoxy(2,2);
	cprintf("Function: %s,\n\n\r Returns: %s",functionCall,messageString);
	getch();
	window(ti.winleft, ti.wintop, ti.winright, ti.winbottom);
	textattr(ti.attribute);
	clrscr();
}

/***********************************************************************/
int RunCapture(int QNumber) {
  CAPTURE_FLAGS setCaptureFlags, getCaptureFlags;
  int retCode, i;
  char fsName[80], queueName[48];
  WORD objectType;
  char objectName[48], fs_Name[48];
  BYTE loginTime[7];
  WORD captureFileConnectionID, printServerConnectionID, serverNumber;
  long objectID, queueID;

  // initialize default capture settings
  setCaptureFlags.status = 0x00;
  setCaptureFlags.flags = 0x00;
  setCaptureFlags.tabSize = 0x08;
  setCaptureFlags.serverPrinter = 0x00;
  setCaptureFlags.numberOfCopies = 0x01;
  setCaptureFlags.formType = 0x00;
  setCaptureFlags.localLPTDevice = local_printer;
  setCaptureFlags.flushCaptureTimeoutCount = 0x00;
  setCaptureFlags.flushCaptureOnDeviceClose = FALSE;
  setCaptureFlags.maxLines = 66;
  setCaptureFlags.maxChars = 132;
  setCaptureFlags.formName[0] = '\0';
  setCaptureFlags.LPTCaptureFlag = FALSE;
  setCaptureFlags.fileCaptureFlag = FALSE;
  setCaptureFlags.printQueueFlag = FALSE;
  setCaptureFlags.printQueueID = 0x00;

  oldConnectionID = GetDefaultConnectionID();

  // server
  strcpy(fs_Name, globalQList[QNumber].server_name);
  retCode = GetConnectionID(fs_Name, &printServerConnectionID);
  SetPreferredConnectionID(printServerConnectionID);
  GetConnectionInformation(GetConnectionNumber(), objectName, &objectType,
                           &objectID, loginTime);
  if (objectID == 0)
  {
     printf("Not logged in %s\n", fs_Name);
     exitout(1);
  }
  SetPreferredConnectionID(oldConnectionID);

  // Queue
  strcpy(queueName, globalQList[QNumber].Q_name);

  // NAM=
  retCode = SetBannerUserName(getenv("USERID"));

  // no autoendcap
  setCaptureFlags.flushCaptureOnDeviceClose = TRUE;

  // no banner
  setCaptureFlags.flags = setCaptureFlags.flags & (~0x80);
  for (i=0; i<13; i++) setCaptureFlags.bannerText[i] = 0x00;

  // no automatic form feed
  setCaptureFlags.flags = setCaptureFlags.flags | 0x08;

  // automatic form feed
  // setCaptureFlags.flags = setCaptureFlags.flags & (~0x08);

  // no notification
  setCaptureFlags.flags = setCaptureFlags.flags & (~0x10);

  // no tab conversion
  setCaptureFlags.flags = setCaptureFlags.flags & (~0x40);

  // timeout value
  setCaptureFlags.flushCaptureTimeoutCount = IntSwap(atoi("8")*18);

  EndSpecificLPTCapture(local_printer);

  SetPreferredConnectionID(printServerConnectionID);
  retCode = GetBinderyObjectID(queueName, OT_PRINT_QUEUE, &queueID);
  if (retCode != 0) {
     printf("Error 0x%X getting object id for: %s\n", retCode, queueName);
     exitout(1);
  }

  setCaptureFlags.LPTCaptureFlag = FALSE;
  retCode = SetCapturePrintQueue(local_printer, printServerConnectionID, queueID);
  if (retCode != 0) {
     printf("Error 0x%X setting print queue\n", retCode);
     exitout(1);
  }

  retCode = SetDefaultCaptureFlags((SET_CAPTURE_FLAGS *)&setCaptureFlags);
  if (retCode != 0) {
     printf("Error setting capture flags: 0x%X\n", retCode);
     exitout(1);
  }

  // Start the capture
  retCode = StartSpecificLPTCapture(local_printer);
  if (retCode != 0 && retCode != 255) {
     printf("Error starting capture: 0x%X\n", retCode);
     EndLPTCapture();
     exitout(1);
  }

  // Report to user what we just captured
  GetDefaultCaptureFlags(&getCaptureFlags);
  printf("Device LPT%d: re-routed to ", local_printer+1);
  GetFileServerName(printServerConnectionID, fsName);
  if (getCaptureFlags.printQueueFlag)
  {
     GetBinderyObjectName(getCaptureFlags.printQueueID,
        queueName, &objectType);
     printf("queue %s ", queueName);
  }
  else
     printf("printer %d ", getCaptureFlags.serverPrinter);
  printf("on server %s.\n", fsName);
  SetPreferredConnectionID(oldConnectionID);

  return(0x1b);
}

void exitout(int retCode)
{
   if (oldConnectionID != 0) SetPreferredConnectionID(oldConnectionID);
   exit(retCode);
}

char *logical_name(char *physical_name, char *logical name) {
  char name_map[TABLE_SIZE][2] = {
    { "DP_1050",      "[ DP         ]..Epson LQ-1050 .....[ Label / Continous form ]"  },
    { "DP_ANGEL",     "[ DP         ]..Angel's LQ-1050 ...[ Label / Continous form ]"  },
    { "DP_IIISI",     "[ DP         ]..HP-LaserJet IIISi .[ A4 paper ]"                },
    { "DP_P300",      "[ DP         ] .Printronix P300....[ Continuous form ]"         },
    { "III_FIN",      "[ FINANCE    ]..HP-LaserJet III ...[ A4 paper ]"                },
    { "1050_FIN",     "[ FINANCE    ]..Epson LQ-1050 .....[ Label / Continuous form ]" },
    { "130E_SEC",     "[ PAT        ]..Cannon BJ-130E ....[ A4 paper ]"                },
    { "IID_SEC",      "[ QUANTI 1+2 ]..HP-LaserJet IID ...[ A4 & F4 paper]"            },
    { "PLOT_SEC",     "[ QUANTI 3+4 ]..HP-Plotter ........[ A4 paper/transparency ]"   },
    { "PAINTJET_SEC", "[ QUANTI 3+4 ]..HP-PaintJet XL ....[ Special stationary ]"      },
    { "QT_III",       "[ QUANTI 3+4 ]..HP-LaserJet III ...[ A4 paper ]"                },
    { "RA_III",       "[ RA         ]..HP-LaserJet III....[ A4 Paper ]"                }
  };
  int i;

  for (i=0;i<TABLE_SIZE;i++)
    if (strcmp(physical_name, name_map[i][0])==0) {
      strcpy(logical_name, name_map[i][1]);
      return(logical_name);
    }
  return(" ");
}
