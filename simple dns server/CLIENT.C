/*

CS1292 WorkShop II
A Simple Name Server

Name:       Chan Ming Lap (91856134)
            Chang Man Wai (91857801)
Course:     M.Sc. in Computer Science (54802-1)
Date:       Sept 11, 1992

*/
#include "nserver.h"

MSGTYPE msg;

usage() 
{
    printf("\nCLIENT");
    printf("\nUsage: CLIENT <host> <port> <cmd> <name> <address>\n");
    printf("\n<cmd> = %d for DELETE",   DELETE);
    printf("\n<cmd> = %d for MODIFY",   MODIFY);
    printf("\n<cmd> = %d for ENQUIRE",  ENQUIRE);
    printf("\n<cmd> = %d for REGISTER\n\n", REGISTER);
    exit(1);
}

main(argc,argv)
int argc;
char *argv[];
{
    int sock, msgsock;
    int rval, result;
    struct sockaddr_in server;
    struct hostent *hp, *gethostbyname();
    ADDRESS name_addr;
 
    if (argc < 5) usage();

    msg.command = atoi(argv[3]);
    strcpy(msg.details.name, argv[4]);

    if ( ((msg.command==MODIFY) || (msg.command==REGISTER))  && (argc < 6) )
        usage();
 
    /* open socket */
    sock = socket(PF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("client: Error opening stream socket");
        exit(1);
    }

    /* obtain client's host address */
    server.sin_family = PF_INET;
    hp = gethostbyname(argv[1]);
    if (hp == 0) {
        fprintf(stderr, "client: Unknown host %s\n", argv[1]);
        exit(2);
    }
    memcpy((char *)&server.sin_addr, (char *)hp->h_addr, hp->h_length);
    server.sin_port = htons(atoi(argv[2]));
    if ((msg.command == MODIFY) || (msg.command == REGISTER))
      strcpy(msg.details.address, argv[5]);

    /* connect client socket to name server */
    if (connect(sock, (struct sockaddr *)&server, sizeof server ) < 0) {
        perror("client: Error connecting stream socket");
        exit(1);
    }

    /* send request to server */
    if (writen(sock, &msg , sizeof msg) < 0)
         perror("client: Error writing on stream socket");

    /* wait result */
    if (msg.command == ENQUIRE) {
      rval = readn(sock, name_addr, ADDRESS_LEN);
      if (name_addr[0] == 0)
        printf("client: Name does not exist!\n");
      else
        printf("client: Name <%s> sits at address <%s>\n",
               msg.details.name, name_addr);
    }
    else {
      rval = readn(sock, &result, sizeof(result));
      switch (result) {
        case OK            : printf("client: Request processed\n");
                             break;
        case ALREADY_EXIST : printf("client: Name already exist\n");
                             break;
        case NOT_EXIST     : printf("client: Name does not exist\n");
                             break;
        }
    }

    /* close socket */
    if (rval < 0) perror("client: Error reading stream message");
    close (sock);
    exit(0);
}
