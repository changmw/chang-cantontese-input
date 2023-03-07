/*----------------------------------------------------------------------------
 * Institution : City Polytechnic of Hong Kong
 * Course Title: M.Sc.(Computer Science)
 * Course-Year : 54802-2
 * Module Name : Workshop II
 * Module Code : CS1292
 * Group No.   : 1
 * File Name   : DBMS.C
 * Purpose     : A DBMS function package for implementation of the data
 *               manipulation functions for DB operations.
 *--------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <fcntl.h>

/*--------------------------------------------------------------------------*/
/*                Macro Constant Definitions                                */
/*--------------------------------------------------------------------------*/
#define TRUE                1           /* Boolean TRUE                     */
#define FALSE               0           /* Boolean FALSE                    */
#define FREE                0           /* Record is free                   */
#define OCCUPIED            1           /* Record is occupied               */
#define PERMS               0666        /* File RW access for owner, others */
#define SUCCESS             0           /* Successful DB operation          */
#define OPEN_ERROR          -1          /* File open error                  */
#define PUT_ERROR           -2          /* File put error                   */
#define GET_ERROR           -3          /* File get error                   */
#define DEL_ERROR           -4          /* File delete error                */
#define OUT_OF_MEM          -5          /* Out of memory heap               */
#define DB_REC_DUP          -6          /* Duplicate record found           */
#define DB_REC_NTF          -7          /* Data base record not found       */
#define IDX_REC_NTF         -8          /* Index record not found           */
#define MAX_FILES            5          /* Maximum no. of opened files      */
#define MAX_INDEX           10          /* Maximum no. of opened indices    */
#define MAX_RECLEN         256          /* Maximum record length            */
#define FNAME_LEN           13          /* File name length                 */
#define EOFLIST             -1          /* End of opened file list          */

/*--------------------------------------------------------------------------*/
/*                DBMS schema as built for Application Programs             */
/*--------------------------------------------------------------------------*/
extern char *dbfile_name[];             /* DB file names                    */
extern int item_len[];                  /* Data item lengths                */
extern int *dbfile_item[];              /* DB file descriptions             */
extern int **dbindex_item[];            /* DB inex descriptions             */

/*--------------------------------------------------------------------------*/
/*                DB File Header Structure                                  */
/*--------------------------------------------------------------------------*/
struct dbfile_header {
  int free_recno;                       /* First available deleted space    */
  int new_recno;                        /* New available record number      */
  int reclen;                           /* Record length of the file        */
};
struct dbindex_header {
  int last_recno;                       /* Last recno in the index          */
  int keylen;                           /* Key length for the index         */
};
struct dbrec_header {
  int status;                           /* Record status                    */
  int next_recno;                       /* Next free record number          */
};
struct idxrec_header {
  int status;                           /* Record status                    */
  int recno;                            /* Record number being pointed      */
};

/*--------------------------------------------------------------------------*/
/*                Declaration of Global variables                           */
/*--------------------------------------------------------------------------*/
int fhandle[MAX_FILES];                 /* File handles of opened files     */
int ihandle[MAX_INDEX];                 /* File handles of opened indices   */
struct dbfile_header fheader[MAX_FILES];  /* File headers of opened files   */
struct dbindex_header iheader[MAX_INDEX]; /* File headers of opened indices */
int curr_dbf[MAX_FILES];                /* Currently opened DB files        */
int curr_recno[MAX_FILES];              /* DB file current record numbers   */
int index_table[MAX_FILES][MAX_INDEX];  /* File index mapping table         */
int db_opened;                          /* DB file opened flag              */

/*--------------------------------------------------------------------------*/
/*                Declaration of Functions                                  */
/*--------------------------------------------------------------------------*/
void file_create(name,reclen)
char *name;
int reclen;
{
  /* Function:
   *    To create a file on the disk storage.
   *
   * Parameters:
   *    name   - Name of the file
   *    reclen - Record length of the file
   */

  int fd;                               /* File descriptor                  */
  struct dbfile_header hd;              /* File header record               */

  unlink(name);
  fd = creat(name,PERMS);
  close(fd);
  fd = open(name,O_WRONLY,0);
  hd.free_recno = 0;
  hd.new_recno  = 1;
  hd.reclen     = reclen;
  write(fd,(char *) &hd,sizeof(struct dbfile_header));
  close(fd);
}

/*--------------------------------------------------------------------------*/
int file_open(name)
char *name;
{
  /* Function:
   *    To open a file on the disk storage.
   *    After successful opening, the file descriptor and header are stored
   *    in the file handle array and file header array for future reference.
   *
   * Parameters:
   *    name   - Name of the file
   */

  int fd;                               /* File descriptor                  */

  for (fd = 0; fd < MAX_FILES; fd++) {  /* Find an unoccupied file handle   */
    if (fhandle[fd] == FREE)
      break;
  }
  if (fd == MAX_FILES)
    return(OPEN_ERROR);
  if ((fhandle[fd] = open(name,O_RDWR,0)) == -1)
    return(OPEN_ERROR);
  lseek(fhandle[fd],0L,0);
  read(fhandle[fd],(char *) &fheader[fd],sizeof(struct dbfile_header));
  return(fd);
}

/*--------------------------------------------------------------------------*/
void file_close(fd)
int fd;
{
  /* Function:
   *    To close a file on the disk storage.
   *
   * Parameters:
   *    fd - File descriptor
   */

  lseek(fhandle[fd],0L,0);
  write(fhandle[fd],(char *) &fheader[fd],sizeof(struct dbfile_header));
  close(fhandle[fd]);
  fhandle[fd] = FREE;                   /* Mark file handle slot as free    */
}

/*--------------------------------------------------------------------------*/
long dbrec_hdr_offset(fd,recno)
int fd;
int recno;
{
  /* Function:
   *    To evaluate the offset of a record header given by the record number.
   *
   * Parameters:
   *    fd    - File descriptor
   *    recno - Record number
   */

  long offset;

  offset = sizeof(struct dbfile_header) +
	   (recno - 1) * (sizeof(struct dbrec_header) + fheader[fd].reclen);
  return(offset);
}

/*--------------------------------------------------------------------------*/
long dbrec_offset(fd,recno)
int fd;
int recno;
{
  /* Function:
   *    To evaluate the offset of a record given by the record number.
   *
   * Parameters:
   *    fd    - File descriptor
   *    recno - Record number
   */

  long offset;

  offset = sizeof(struct dbfile_header) + sizeof(struct dbrec_header) +
           (recno - 1) * (sizeof(struct dbrec_header) + fheader[fd].reclen);
  return(offset);
}

/*--------------------------------------------------------------------------*/
int put_record(fd,recno,buffer)
int fd;
int recno;
char *buffer;
{
  /* Function:
   *    To write data to a data record.
   *
   * Parameters:
   *    fd     - File descriptor
   *    recno  - Record number
   *    buffer - Record buffer
   */

  if (recno > fheader[fd].new_recno)
    return(PUT_ERROR);
  lseek(fhandle[fd],dbrec_offset(fd,recno),0);
  write(fhandle[fd],buffer,fheader[fd].reclen);
  return(SUCCESS);
}

/*--------------------------------------------------------------------------*/
int get_record(fd,recno,buffer)
int fd;
int recno;
char *buffer;
{
  /* Function:
   *    To get data from a data record.
   *
   * Parameters:
   *    fd     - File descriptor
   *    recno  - Record number
   *    buffer - Record buffer
   */

  if (recno >= fheader[fd].new_recno)
    return(GET_ERROR);
  lseek(fhandle[fd],dbrec_offset(fd,recno),0);
  read(fhandle[fd],buffer,fheader[fd].reclen);
  return(SUCCESS);
}

/*--------------------------------------------------------------------------*/
int delete_record(fd,recno)
int fd;
int recno;
{
  /* Function:
   *    To delete a record on the disk storage and return the space to
   *    the deleted record space list.
   *
   * Parameters:
   *    fd    - File descriptor
   *    recno - Record number
   */

  struct dbrec_header rh;
  int rno, saverno;

  if (recno >= fheader[fd].new_recno)
    return(DEL_ERROR);
  lseek(fhandle[fd],dbrec_hdr_offset(fd,recno),0);
  read(fhandle[fd],(char *) &rh,sizeof(struct dbrec_header));
  rh.next_recno = 0;
  rh.status = FREE;
  lseek(fhandle[fd],dbrec_hdr_offset(fd,recno),0);
  write(fhandle[fd],(char *) &rh,sizeof(struct dbrec_header));
  if (fheader[fd].free_recno) {         /* Free deleted space existed       */
    rno = fheader[fd].free_recno;
    do {
      lseek(fhandle[fd],dbrec_hdr_offset(fd,rno),0);
      read(fhandle[fd],(char *) &rh,sizeof(struct dbrec_header));
      saverno = rno;
      rno = rh.next_recno;
    } while (rno != 0);
    rh.next_recno = recno;
    lseek(fhandle[fd],dbrec_hdr_offset(fd,saverno),0);
    write(fhandle[fd],(char *) &rh,sizeof(struct dbrec_header));
  } else {
    fheader[fd].free_recno = recno;
    lseek(fhandle[fd],0L,0);
    write(fhandle[fd],(char *) &fheader[fd],sizeof(struct dbfile_header));
  }
  return(SUCCESS);
}

/*--------------------------------------------------------------------------*/
int add_record(fd,buffer)
int fd;
char *buffer;
{
  /* Function:
   *    To create a new record on the disk storage by either:
   *    - reusing the deleted record space in the file or
   *    - appending a new record at the end of the file
   *
   * Parameters:
   *    fd     - File descriptor
   *    buffer - Record buffer
   */

  struct dbrec_header rh;
  int recno;

  if (fheader[fd].free_recno) {         /* Free deleted space existed       */
    recno = fheader[fd].free_recno;
    lseek(fhandle[fd],dbrec_hdr_offset(fd,recno),0);
    read(fhandle[fd],(char *) &rh,sizeof(struct dbrec_header));
    if (rh.next_recno) {                /* Next free space available        */
      fheader[fd].free_recno = rh.next_recno;
    } else {                            /* Last free record space           */
      fheader[fd].free_recno = 0;
    }
  } else {
    recno = fheader[fd].new_recno;
    fheader[fd].new_recno++;
  }
  /*------------------------------------------------------------------------*/
  /*      Update control information on the DB file header                  */
  /*------------------------------------------------------------------------*/
  lseek(fhandle[fd],0L,0);
  write(fhandle[fd],(char *) &fheader[fd],sizeof(struct dbfile_header));
  /*------------------------------------------------------------------------*/
  /*      Update control information on the DB record header                */
  /*------------------------------------------------------------------------*/
  rh.status = OCCUPIED;
  rh.next_recno = 0;
  lseek(fhandle[fd],dbrec_hdr_offset(fd,recno),0);
  write(fhandle[fd],(char *) &rh,sizeof(struct dbrec_header));
  put_record(fd,recno,buffer);          /* Write data to the added record   */
  return(recno);
}

/*--------------------------------------------------------------------------*/
void index_create(name,keylen)
char *name;
int keylen;
{
  /* Function:
   *    To create a index file on the disk storage.
   *
   * Parameters:
   *    name   - Name of the index file
   *    keylen - Key length of the index file
   */

  int id;                               /* Index descriptor                 */
  struct dbindex_header hd;             /* Index header record              */

  unlink(name);
  id = creat(name,PERMS);
  close(id);
  id = open(name,O_WRONLY,0);
  hd.last_recno = 0;
  hd.keylen     = keylen;
  write(id,(char *) &hd,sizeof(struct dbindex_header));
  close(id);
}

/*--------------------------------------------------------------------------*/
int index_open(name)
char *name;
{
  /* Function:
   *    To open an index file on the disk storage.
   *    After successful opening, the index descriptor and header are stored
   *    in the index handle array and index header array for future reference.
   *
   * Parameters:
   *    name   - Name of the index file
   */

  int id;                               /* Index descriptor                 */

  for (id = 0; id < MAX_INDEX; id++) {  /* Find an unoccupied file handle   */
    if (ihandle[id] == FREE)
      break;
  }
  if (id == MAX_INDEX)
    return(OPEN_ERROR);
  if ((ihandle[id] = open(name,O_RDWR,0)) == -1)
    return(OPEN_ERROR);
  lseek(ihandle[id],0L,0);
  read(ihandle[id],(char *) &iheader[id],sizeof(struct dbindex_header));
  return(id);
}

/*--------------------------------------------------------------------------*/
void index_close(id)
int id;
{
  /* Function:
   *    To close an index file on the disk storage.
   *
   * Parameters:
   *    id - Index descriptor
   */

  lseek(ihandle[id],0L,0);
  write(ihandle[id],(char *) &iheader[id],sizeof(struct dbindex_header));
  close(ihandle[id]);
  ihandle[id] = FREE;                   /* Mark file handle slot as free    */
}

/*--------------------------------------------------------------------------*/
long idxrec_hdr_offset(id,recno)
int id;
int recno;
{
  /* Function:
   *    To evaluate the offset of an index record header given by the
   *    record number.
   *
   * Parameters:
   *    id    - Index descriptor
   *    recno - Record number
   */

  long offset;

  offset = sizeof(struct dbindex_header) +
           (recno - 1) * (sizeof(struct idxrec_header) + iheader[id].keylen);
  return(offset);
}

/*--------------------------------------------------------------------------*/
long idxrec_offset(id,recno)
int id;
int recno;
{
  /* Function:
   *    To evaluate the offset of an index record given by the
   *    record number.
   *
   * Parameters:
   *    id    - Index descriptor
   *    recno - Record number
   */

  long offset;

  offset = sizeof(struct dbindex_header) + sizeof(struct idxrec_header) +
           (recno - 1) * (sizeof(struct idxrec_header) + iheader[id].keylen);
  return(offset);
}

/*--------------------------------------------------------------------------*/
int add_index(id,recno,key)
int id;
int recno;
char *key;
{
  /* Function:
   *    To search an index file record for a key on the disk storage.
   *
   * Parameters:
   *    id    - Index descriptor
   *    recno - Record number to be pointed
   *    key   - Key to be search
   */

  char *buffer;                         /* Buffer for storing the key value */
  char *sbuffer;                        /* Buffer for record shifting       */
  struct idxrec_header ih;              /* Index record header              */
  int rno, last, recsize;

  if (get_index(id,key) != 0)
    return(DB_REC_DUP);
  buffer = (char *) malloc(iheader[id].keylen);
  if (buffer == NULL)                   /* Insufficient memory space        */
    return(OUT_OF_MEM);
  if (iheader[id].last_recno == 0) {    /* First index record               */
    lseek(ihandle[id],idxrec_hdr_offset(id,1),0);
    iheader[id].last_recno++;
    ih.status = OCCUPIED;
    ih.recno  = recno;
    write(ihandle[id],&ih,sizeof(struct idxrec_header));
    lseek(ihandle[id],idxrec_offset(id,1),0);
    write(ihandle[id],key,iheader[id].keylen);
    lseek(ihandle[id],0L,0);
    write(ihandle[id],(char *) &iheader[id],sizeof(struct dbindex_header));
    free(buffer);
    return(SUCCESS);
  }
  lseek(ihandle[id],idxrec_offset(id,iheader[id].last_recno),0);
  read(ihandle[id],buffer,iheader[id].keylen);
  /*------------------------------------------------------------------------*/
  /*      Key value to be added > All key values in the index file          */
  /*------------------------------------------------------------------------*/
  if (strcmp(key,buffer) > 0) {
    iheader[id].last_recno++;
    ih.status = OCCUPIED;
    ih.recno  = recno;
    rno = iheader[id].last_recno;
    lseek(ihandle[id],idxrec_hdr_offset(id,rno),0);
    write(ihandle[id],&ih,sizeof(struct idxrec_header));
    lseek(ihandle[id],idxrec_offset(id,rno),0);
    write(ihandle[id],key,iheader[id].keylen);
    lseek(ihandle[id],0L,0);
    write(ihandle[id],(char *) &iheader[id],sizeof(struct dbindex_header));
    free(buffer);
    return(SUCCESS);
  }
  /*------------------------------------------------------------------------*/
  /*      Search for the position of insertion of the Key value             */
  /*------------------------------------------------------------------------*/
  rno = 0;
  do {
    rno++;
    lseek(ihandle[id],idxrec_offset(id,rno),0);
    read(ihandle[id],buffer,iheader[id].keylen);
  } while (strcmp(buffer,key) < 0);
  /*------------------------------------------------------------------------*/
  /*      Reuse deleted spaces if possible                                  */
  /*------------------------------------------------------------------------*/
  lseek(ihandle[id],idxrec_hdr_offset(id,rno),0);
  read(ihandle[id],(char *) &ih,sizeof(struct idxrec_header));
  if (ih.status == FREE) {              /* Current record is free           */
    ih.status = OCCUPIED;
    ih.recno  = recno;
    lseek(ihandle[id],idxrec_hdr_offset(id,rno),0);
    write(ihandle[id],(char *) &ih,sizeof(struct idxrec_header));
    lseek(ihandle[id],idxrec_offset(id,rno),0);
    write(ihandle[id],key,iheader[id].keylen);
    free(buffer);
    return(SUCCESS);
  }
  /*------------------------------------------------------------------------*/
  /*      Start record shifting as the last step                            */
  /*------------------------------------------------------------------------*/
  recsize = iheader[id].keylen + sizeof(struct idxrec_header);
  sbuffer = (char *) malloc(recsize);
  if (sbuffer == NULL)
    return(OUT_OF_MEM);
  last = iheader[id].last_recno;
  do {
    lseek(ihandle[id],idxrec_hdr_offset(id,last),0);
    read(ihandle[id],sbuffer,recsize);
    lseek(ihandle[id],idxrec_hdr_offset(id,last+1),0);
    write(ihandle[id],sbuffer,recsize);
    last--;
  } while (last >= rno);
  ih.status = OCCUPIED;
  ih.recno  = recno;
  lseek(ihandle[id],idxrec_hdr_offset(id,rno),0);
  write(ihandle[id],(char *) &ih,sizeof(struct idxrec_header));
  lseek(ihandle[id],idxrec_offset(id,rno),0);
  write(ihandle[id],key,iheader[id].keylen);
  iheader[id].last_recno++;
  lseek(ihandle[id],0L,0);
  write(ihandle[id],(char *) &iheader[id],sizeof(struct dbindex_header));
  free(sbuffer);
  free(buffer);
  return(SUCCESS);
}

/*--------------------------------------------------------------------------*/
int get_index(id,key)
int id;
char *key;
{
  /* Function:
   *    To search an index file for a key on the disk storage.
   *
   * Parameters:
   *    id  - Index descriptor
   *    key - Key to be search
   */

  char *buffer;                         /* Buffer for storing the key value */
  struct idxrec_header ih;              /* Index record header              */
  int search, high, low, mid, found;

  buffer = (char *) malloc(iheader[id].keylen);
  if (buffer == NULL)                   /* Insufficient memory space        */
    return(OUT_OF_MEM);
  search = 0;
  found  = FALSE;
  low    = 1;
  high   = iheader[id].last_recno;
  while (low <= high && (!found)) {
    mid = (low + high) / 2;
    lseek(ihandle[id],idxrec_offset(id,mid),0);
    read(ihandle[id],buffer,iheader[id].keylen);
    if (strcmp(key,buffer) == 0)
      found = TRUE;
    else if (strcmp(key,buffer) < 0)
      high = mid - 1;
    else
      low  = mid + 1;
  }
  if (found) {
    lseek(ihandle[id],idxrec_hdr_offset(id,mid),0);
    read(ihandle[id],(char *) &ih,sizeof(struct idxrec_header));
    if (ih.status != FREE)
      search = ih.recno;
  }
  free(buffer);
  return(search);
}

/*--------------------------------------------------------------------------*/
int delete_index(id,key)
int id;
char *key;
{
  /* Function:
   *    To delete an index record for a key on the disk storage.
   *
   * Parameters:
   *    id  - Index descriptor
   *    key - Key to be search
   */

  struct idxrec_header ih;              /* Index record header              */
  int recno;

  recno = get_index(id,key);
  if (recno == 0)
    return(IDX_REC_NTF);
  lseek(ihandle[id],idxrec_hdr_offset(id,recno),0);
  read(ihandle[id],(char *) &ih,sizeof(struct idxrec_header));
  ih.status = FREE;
  ih.recno  = 0;
  lseek(ihandle[id],idxrec_hdr_offset(id,recno),0);
  write(ihandle[id],(char *) &ih,sizeof(struct idxrec_header));
  return(SUCCESS);
}

/*--------------------------------------------------------------------------*/
int item_offset(item,itemlist)
int item;
int *itemlist;
{
  /* Function:
   *    To find the relative of a data item within a DB record buffer.
   *
   * Parameters:
   *    item     - Item name
   *    itemlist - Item list
   */

  int len;

  len = 0;
  while (item != *itemlist) {
    len += item_len[(*itemlist)-1] + 1;
    itemlist++;
  }
  return(len);
}

/*--------------------------------------------------------------------------*/
int file_reclen(fid)
int fid;
{
  /* Function:
   *    To find the record length of a data base file.
   *
   * Parameters:
   *    fid - DB file ID
   */

  int len;

  len = item_offset(0,dbfile_item[fid]);
  return(len);
}

/*--------------------------------------------------------------------------*/
void db_open(flist)
int *flist;
{
  /* Function:
   *    To open a list of data base files for processing.
   *
   * Parameters:
   *    flist - DB file list
   */

  char fname[FNAME_LEN];
  int i;

  if (!db_opened) {
    for (i = 0; i < MAX_FILES; i++)
      curr_dbf[i] = FREE;
    db_opened = TRUE;
  }
  while (*flist != EOFLIST) {
    sprintf(fname,"%s.dbf",dbfile_name[*flist]);
    curr_dbf[*flist] = file_open(fname);
    i = 0;
    while (*(dbindex_item[*flist]+i)) {
      sprintf(fname,"%s.i%02d",dbfile_name[*flist],i+1);
      index_table[*flist][i++] = index_open(fname);
    }
    flist++;
  }
}

/*--------------------------------------------------------------------------*/
void db_close()
{
  /* Function:
   *    To close all the data bases.
   *
   * Parameters:
   *    Nil
   */

  int i, j;

  for (i = 0; i < MAX_FILES; i++) {
    if (curr_dbf[i] != FREE) {
      file_close(curr_dbf[i]);
      j = 0;
      while (*(dbindex_item[i]+j)) {
        index_close(index_table[i][j]);
        j++;
      }
      curr_dbf[i] = FREE;
    }
  }
  db_opened = FALSE;
}

/*--------------------------------------------------------------------------*/
int db_obtain(fid,kid,key,buffer)
int fid;
int kid;
char *key;
char *buffer;
{
  /* Function:
   *    To obtain a record from a db file for processing.
   *
   * Parameters:
   *    fid    - DB file id
   *    kid    - Key id
   *    key    - Actual key passed
   *    buffer - Record buffer
   */

  curr_recno[fid] = get_index(index_table[fid][kid-1],key);
  if (curr_recno[fid] == 0)
    return(DB_REC_NTF);
  get_record(curr_dbf[fid],curr_recno[fid],buffer);
}

/*--------------------------------------------------------------------------*/
int db_update(fid,buffer)
int fid;
char *buffer;
{
  /* Function:
   *    To update the current record from a db file.
   *
   * Parameters:
   *    fid    - DB file id
   *    buffer - Record buffer
   */

  put_record(curr_dbf[fid],curr_recno[fid],buffer);
}

/*--------------------------------------------------------------------------*/
int db_insert(fid,buffer)
int fid;
char *buffer;
{
  /* Function:
   *    To insert a record from a db file for processing.
   *
   * Parameters:
   *    fid    - DB file id
   *    buffer - Record buffer
   */

  int recno, i, j, k;
  char key[MAX_RECLEN];
  
  recno = add_record(curr_dbf[fid],buffer);
  i = 0;
  while (*(dbindex_item[fid]+i)) {
    key[0] = '\0';
    j = 0;
    while (*(*(dbindex_item[fid]+i)+j)) {
      strcat(key,
      buffer+item_offset(*(*(dbindex_item[fid]+i)+j),dbfile_item[fid]));
      j++;
    }
    k = add_index(index_table[fid][i],recno,key);
    if (k != SUCCESS) {
      delete_record(curr_dbf[fid],recno);
      return(k);
    }
    i++;
  }
  return(SUCCESS);
}

/*--------------------------------------------------------------------------*/
int db_delete(fid)
int fid;
{
  /* Function:
   *    To delete a record from a DB file.
   *
   * Parameters:
   *    fid    - DB file id
   */

  int i, j;
  char key[MAX_RECLEN];
  char *buffer;

  buffer = (char *) malloc(file_reclen(fid));
  if (buffer == NULL)                   /* Insufficient memory space        */
    return(OUT_OF_MEM);
  if (curr_recno[fid]) {
    get_record(curr_dbf[fid],curr_recno[fid],buffer);
    i = 0;
    while (*(dbindex_item[fid]+i)) {
      key[0] = '\0';
      j = 0;
      while (*(*(dbindex_item[fid]+i)+j)) {
        strcat(key,
        buffer+item_offset(*(*(dbindex_item[fid]+i)+j),dbfile_item[fid]));
        j++;
      }
      delete_index(index_table[fid][i],key);
      i++;
    }
    delete_record(curr_dbf[fid],curr_recno[fid]);
  }
  free(buffer);
  return(SUCCESS);
}

/*----------------------------- End of File --------------------------------*/
