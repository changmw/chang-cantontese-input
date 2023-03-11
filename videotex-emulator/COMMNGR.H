/* header file for communication manager COMMNGR.C */
/*
   Constants used in defining the protocol to be used in 8250 UART
*/

/*  constant and types for COM port */
#define COM1 1       /* 'enumerated' type for COM port ID */
#define COM2 2
#define COM3 3
#define COM4 4

/* segment and offset of location in BIOS holding COM port I/O addresses */
#define COM1_S 0
#define COM1_R 0x400
#define COM2_S 0
#define COM2_R 0x402
#define COM3_S 0
#define COM3_R 0x404
#define COM4_S 0
#define COM4_R 0x406

/* offset from base I/O address of COM port */
#define TX 0
#define RX 0
#define InterruptEna 1
#define InterruptID  2
#define LineControl  3
#define ModemControl 4
#define LineStatus   5
#define ModemStatus  6
#define DivLatchLSB 0
#define DivLatchMSB 1

/* Line Control */
#define WordLength5   0x00
#define WordLength6   0x01
#define WordLength7   0x02
#define WordLength8   0x03
#define OneStopBit    0x00
#define TwoStopBits   0x04
#define ParityEnable  0x08
#define NoParity      0x00
#define EvenParity    0x10
#define OddParity     0x00
#define StuckParity   0x20
#define SetBreak      0x40
#define DLAB          0x80
#define DLABoff       0x00

/* baud rate divisor */
#define BaudFactor 115200

/* interrupt control */
#define EnableDataReady   0x01
#define EnableXmitReady   0x02
#define EnableLineStatus  0x04
#define EnableModemStatus 0x08

/* interrupt ID */
#define NonePending          0x01
#define DataReadyInterrupt   0x04
#define XmitReadyInterrupt   0x02
#define LineStatusInterrupt  0x06
#define ModemStatusInterrupt 0x00

/* Modem Control */
#define DataTerminalReady 0x01
#define RequestToSend     0x02
#define Out1              0x04
#define Out2              0x08
#define Loop              0x10

/* Line Status */
#define DataReady       0x01
#define OverrunError    0x02
#define ParityError     0x04
#define FramingError    0x08
#define BreakInterrupt  0x10
#define XmitReady       0x20
#define XmitSHR_ready   0x40

/* Modem Status */
#define DeltaCTS          0x01
#define DeltaDSR          0x02
#define TrailEdgeRI       0x04
#define DeltaDCD          0x08
#define ClearToSend       0x10
#define DataSetReady      0x20
#define RingIndicator     0x40
#define DataCarrierDetect 0x80

#define EOI        0x20    /* non-specific End Of Interrupt    */
#define INTA01     0x21    /* 8259 port: OCW1 */
#define INTA00     0x20    /* 8259 port: OCW2 */

#define COM1_base  0x3f8   /* port address of COM1 */
#define COM2_base  0x2f8   /* port address of COM2 */

#define IRQ4_IntrNo 0x0C   /* COM1 Asyn Interrupt Number */
#define IRQ3_IntrNo 0x0B   /* COM2 Asyn Interrupt Number */

#define ENABLE_ASYN  0xE7  /* interrupt mask for 8259 */
#define DISABLE_ASYN 0x18  /* disable asyn interrupt */

/* global variables used by communication managers */
extern char modemconnect[21], modembusy[21], modeminit[41],
            modemreset[21], modemhangup[21], dialprefix[21];
extern int termbaudrate, termcom, dialtime;
extern char termstopbit, termparity, termwordlength, termlocalecho;
extern int parityerr, overrunerr, framingerr;
extern int cts, dsr, dcd, ri, xhrfree;   /* flag for status of 8250 */

void setup8250();
int sendchar(unsigned char a);
int sendstring(char *s);
int receivechar(char *a);
void init_8250_int(unsigned char mask);
void init_MCR(unsigned char mask);
void init_modem();
void capture_int(int intno, void interrupt (*func)());
void reset_int(int intno, void interrupt (*func)());
void interrupt com_int_handler();
void setcombaud(int br);
void setstopbit(unsigned char sb);
void setparity(unsigned char p);
void setwordlen(unsigned char wl);
void reset8250int();
void hook8250int();
void dial(char *nodename, char *phoneno, int times);
void hang_up();
int portbase(int comport);
