/*

CS1292 WorkShop II
A Simple Name Server

Name:       Chan Ming Lap (91856134)
            Chang Man Wai (91857801)
Course:     M.Sc. in Computer Science (54802-2)
Date:       Sept 11, 1992

*/
#include <stdlib.h>
#include "nserver.h"

#define DEBUG

NAMEPTR namehead;
MSGTYPE msg; 

/* list the name table */
void print_dir()
{
    NAMEPTR work;

    printf("----- NAME TABLE ---\n");
    for (work=namehead; work!=NULL; work=work->next)
         printf("%s %s\n", work->name, work->address);
    printf("--- END OF TABLE ---\n");
}

/* obtain the address of a name */
int enquire(name)
char name[];
{
     NAMEPTR work;
    
     for (work=namehead;work!=NULL;work=work->next)
     {
         if (strcmp(work->name,name)==0) {
            strcpy(msg.details.address, work->address);
            return(OK);
         }
     }
     return(NOT_EXIST);
}

/* change the address of the name */
int modify(name, address)
char name[];
char address[];
{
    NAMEPTR work;

    /* change the name of an entry in a table */
    for (work=namehead;work!=NULL;work=work->next)
    {
        if (strcmp(work->name, name)==0)
        {     
	     strcpy(work->address, address);
             return(OK);
        }
    }
    return(NOT_EXIST);
}

/* remove a name */
int delete(name)
char name[];
{
     NAMEPTR work, temp, last;
 
     for (work=namehead;work!=NULL;last=work,work=work->next)
     {
         if (strcmp(work->name,name)==0)
         {
               if (work == namehead) {
                   temp=namehead;
                   namehead=namehead->next;
               }
               else {
                   temp = work;
                   last->next=work->next;
               }
               free(temp);
               return(OK);
         }
     }
     return(NOT_EXIST);
}

int reg(new_name)
NAMEPTR new_name;
/* 
insert new name name into the table with sorting
*/
{
  NAMEPTR i, j;

  if (namehead == NULL) /* list is empty */
  {
    namehead = new_name;
    namehead->next = NULL;
  }
  else if (strcmp(namehead->name, new_name->name) > 0)
  {
    /* the new table entry is smaller than head of list */
    new_name->next = namehead;
    namehead = new_name;
  }
  else
  {
    i = namehead;
    j = i;

    /* append to end or middle of list */
    while ((i != NULL) && (strcmp(i->name, new_name->name) < 0))
    {
      j = i;
      i = i->next;
    }

    if (i == NULL)
    {
      j->next = new_name;
      new_name->next = i;
    }
    else   /* new name has the same name as the last entry of the table */
      return(ALREADY_EXIST);
  }
  return(OK);
}

main()
{
   int sock, length;
   struct sockaddr_in server;
   int msgsock;
   int rval;
   int result;
   NAMEPTR temp;

   namehead = NULL;

   /* open socket */
   sock = socket(PF_INET, SOCK_STREAM , 0);
   if (sock < 0) {
        perror("server: Error opening stream socket");
        exit(1);
   }

   server.sin_family = PF_INET;
   server.sin_addr.s_addr = INADDR_ANY;
   server.sin_port = 0;
   if (bind(sock, (struct sockaddr *)&server, sizeof server) < 0) {
        perror("server: Error binding server socket to message socket");
        exit(1);
   }

   /* obtain the first availble port */
   length = sizeof server;
   if (getsockname(sock, (struct sockaddr *)&server, &length)<0) {
        perror("server: Error obtaining socket name");
        exit(1);
   }
   listen(sock,5);

   do {
      printf("\nserver: Socket is <%d>\n",ntohs(server.sin_port));

      /* wait for client to call */
      msgsock = accept (sock, (struct sockaddr *)0,(int *) 0);

      if (msgsock < 0)
         perror("server: Error connecting with client");
      else {
         /* client requests arrive */
         if ((rval = readn(msgsock, &msg, sizeof msg)) < 0)
           perror("server: Error reading stream message");

         /* handle the request and replies to client */
         switch (msg.command) {
           case REGISTER :
             /* create new node */
             temp = (NAMEPTR) malloc(sizeof(NAMETYPE));
             strcpy(temp->name, msg.details.name);
             strcpy(temp->address, msg.details.address);
             temp->next = NULL;

             result = reg(temp);
             if (result == ALREADY_EXIST) free(temp);
             rval = writen(msgsock, &result, sizeof result);
             break;
           case ENQUIRE :
             result = enquire(msg.details.name);
             rval = writen(msgsock, msg.details.address, ADDRESS_LEN);
             break;
           case MODIFY :
             result = modify(msg.details.name, msg.details.address);
             rval = writen(msgsock, &result, sizeof result);
             break;
           case DELETE :
             result = delete(msg.details.name);
             rval = writen(msgsock, &result, sizeof result);
             break;
         }
         if (rval < 0) perror("Error writing on stream socket");
         /* display the content of the name table */
         close(msgsock);
         print_dir();
      }
   } while (TRUE);
   close(sock);
   exit(0);
}
