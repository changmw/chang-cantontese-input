/***************************************************************************
PURPOSE:   Show active network printer queue name
DATE:      03/24/92
ENVIRON:   Turbo C++ v3.0, Small model (w/packed structures) or
           Link w/SNIT.LIB of NetWare C Interface-DOS v1.2
Adopted from Novell by Chang Man Wai
****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "nit.h"
#include <niterror.h>
#ifdef __TURBOC__
   #include <dir.h>
#else
   #include <direct.h>
#endif

// Generic, non-compiler-specific macros to build and split far pointers
#define xMK_FP( seg,ofs )( (void _far * )((unsigned long)((unsigned long)(seg) << 16 ) +( unsigned long)( (ofs) & 0xFFFF )))
#define xFP_SEG( fp )((unsigned)( (unsigned long)(void far *)(fp) >> 16))
#define xFP_OFF( fp )(((unsigned)( (unsigned long)(void far *)(fp) & 0xFFFF)))

// Globals
char fsName[80], queueName[48];
BYTE majorVersion, minorVersion, revisionLevel, oldLPT;
WORD objectType, oldConnectionID;
CAPTURE_FLAGS setCaptureFlags;
CAPTURE_FLAGS getCaptureFlags;

// Prototypes
void exitout(int);
void ShowSettings(void);

void main(int argc, char **argv)
{
   int retCode = 0, count, count2;
   char *tempArg;
   char fileName[255], vName[16];
   char dirName[255], VOLPath[255];
   char objectName[48];
   BYTE localPrinterToCaptureTo;
   WORD captureFileConnectionID, printServerConnectionID, serverNumber;
   long objectID;

   printf("\nSHOWP v1.1\n\n");

   oldConnectionID = GetDefaultConnectionID();
   oldLPT = localPrinterToCaptureTo = GetDefaultLocalPrinter();

   // Get shell version to handle problems in certain shells
   retCode = GetNetWareShellVersion(&majorVersion, &minorVersion, &revisionLevel);
   if (retCode == 0)
   {
      printf("\nShell version too old\n");
      exit(1);
   }

   // Process the command line options so we know the LPT of concern right away
   for (count=1; count<argc; count++)
   {
      if (argv[count][0] == '-' || argv[count][0]=='/')
         argv[count]++;  // Remove option prefix
      if (toupper(argv[count][0]) == 'L')
      {
         if (argv[count][1] == '=')
            localPrinterToCaptureTo = atoi(&argv[count][2]) - 1;
         else
            localPrinterToCaptureTo = atoi(&argv[count][1]) - 1;
         if (localPrinterToCaptureTo >2)
         {
            printf("Device out of range: %s\n", localPrinterToCaptureTo+1);
            exitout(1);
         }
      }
   }

   // Now that we know the LPT of concern, lets set up the default printer, etc.
   SetDefaultLocalPrinter(localPrinterToCaptureTo);
   GetDefaultCaptureFlags(&setCaptureFlags);

   retCode = GetLPTCaptureStatus(&serverNumber);
   retCode = 0;
   if (retCode == 0)  // Reset flags if not currently captured
   {
      setCaptureFlags.status = 0x00;
      setCaptureFlags.flags = 0x00;
      setCaptureFlags.tabSize = 0x08;
      setCaptureFlags.serverPrinter = 0x00;
      setCaptureFlags.numberOfCopies = 0x01;
      setCaptureFlags.formType = 0x00;
      setCaptureFlags.localLPTDevice = 0x00;
      setCaptureFlags.flushCaptureTimeoutCount = 0x00;
      setCaptureFlags.flushCaptureOnDeviceClose = FALSE;
      setCaptureFlags.maxLines = 66;
      setCaptureFlags.maxChars = 132;
      setCaptureFlags.formName[0] = '\0';
      setCaptureFlags.LPTCaptureFlag = FALSE;
      setCaptureFlags.fileCaptureFlag = FALSE;
      setCaptureFlags.printQueueFlag = FALSE;
      setCaptureFlags.printQueueID = 0x00;
   }
   retCode = GetLPTCaptureStatus(&printServerConnectionID);
   ShowSettings();
}

/****************************************************************************
 ShowSettings: Process /SH parameter by showing capture settings for each
               printer
 ****************************************************************************/
void ShowSettings(void)
{
   int count, retCode;
   WORD currentConnectionID;
   char temp[64];

   // Check each printer port we can capture
   printf("%-5s%-20s%-10s%-10s%-20s\n","LPT","QUEUE","TIMEOUT","FORMFEED","SERVER");
   for (count = 0; count < 3; count++)
   {
      // Show LPT port number
      printf("%-5d", count + 1);

      SetDefaultLocalPrinter(count);
      retCode = GetLPTCaptureStatus(&currentConnectionID);
      // Are we capturing?
      if (retCode != 0)
      {
         GetDefaultCaptureFlags(&getCaptureFlags);
         SetPreferredConnectionID(currentConnectionID);
         GetFileServerName(currentConnectionID, fsName);

         // Display what we're capturing to (server queue/file name)
         // printf("Capturing data to %s ", fsName);
         if (getCaptureFlags.fileCaptureFlag)
            printf("%-20s", "** FILE **");
         else
         {
            if (getCaptureFlags.printQueueFlag)
            {
               GetBinderyObjectName(getCaptureFlags.printQueueID,
                  queueName, &objectType);
               // printf("queue %s.\n", queueName);
               printf("%-20s", queueName);
            }
            else
               printf("printer %d.\n", getCaptureFlags.serverPrinter);
         }
         // get Timeout setting
         if (getCaptureFlags.flushCaptureTimeoutCount == 0)
            printf("%-10s","Disabled");
         else
            printf("%-10u", IntSwap(getCaptureFlags.flushCaptureTimeoutCount)/18);

         // Do we send form feeds at the end of a job?
         printf("%-10s", (getCaptureFlags.flags & 0x08) ? "no" : "yes");
         printf("%-20s\n", fsName);
      }
      else
         printf("%-20s", "*** LOCAL ***\n");

   }
   putch('\n');
   SetDefaultLocalPrinter(oldLPT);
   exitout(0);
}

/****************************************************************************
 exitout: Cleanup routine
 ****************************************************************************/
void exitout(int retCode)
{
   if (oldConnectionID != 0)
      SetPreferredConnectionID(oldConnectionID);
   exit(retCode);
}
