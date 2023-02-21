#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>

#define TRUE 1

#define OK            0
#define NOT_EXIST     1
#define ALREADY_EXIST 2

#define REGISTER  1
#define ENQUIRE   2
#define MODIFY    3
#define DELETE    4

#define ADDRESS_LEN 24
#define NAME_LEN 15
#define TABLE_SIZE  512

typedef char ADDRESS[ADDRESS_LEN];
typedef char NAME[NAME_LEN];

/* name server's address table */
typedef struct NAMEnode *NAMEPTR;
typedef struct NAMEnode { 
       NAME name;
       ADDRESS address;
       NAMEPTR next;
} NAMETYPE ;

/* message structure */
typedef struct MSGnode {
      int      command;
      NAMETYPE details;
} MSGTYPE, *MSGPTR ;

/*
 * read "n" bytes from a descriptor
 * Use in place of read() when fd is a stream socket
 *
 */
int readn(fd, ptr, nbytes)
register int fd;
register char *ptr;
register int nbytes;
{
  int nleft, nread;
  nleft = nbytes;
  
  while (nleft > 0)
  {
     nread = read(fd, ptr, nleft);
     if  (nread < 0)
           return(nread);  /* error, return < 0 */
     else  if (nread == 0)
               break;      /* EOF */
      nleft -= nread;
      ptr   += nread;
  }
  return (nbytes - nleft); /* return >= 0 */
}
  

/*
 * write "n" bytes from a descriptor
 * Use in place of write() when fd is a stream socket
 *
 */
int writen(fd, ptr, nbytes)
register int fd;
register char *ptr;
register int nbytes;
{
  int nleft, nwrite;
  nleft = nbytes;
  
  while (nleft > 0)
  {
     nwrite = write(fd, ptr, nleft);
     if  (nwrite < 0)
           return(nwrite);  /* error, return < 0 */
     else  if (nwrite == 0)
               break;      /* EOF */
      nleft -= nwrite;
      ptr   += nwrite;
  }
  return (nbytes - nleft); /* return >= 0 */
}
