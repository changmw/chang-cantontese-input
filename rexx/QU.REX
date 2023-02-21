/*  CLASSIFICATION:    IBM Internal Use Only         */
/* This EXEC will check the status of a given userid */
/* or a nickname. If will SMSG the current id's RSCS */
/* to query the status of the given id               */
/*  OWNER: Chang Man Wai                             */
 
PARSE ARG in_userid AT in_usernode
   IF in_userid = '' & in_usernode = '' THEN
      CALL qq_help
   ELSE
      CALL q_userid in_userid in_usernode
EXIT
 
Q_USERID: PROCEDURE
ARG userid usernode
   'IDENTIFY (FIFO'
   PULL myid AT mynode via rscs_name . . .
   IF usernode ^= '' & userid ^= '' THEN  /* querying remote userid */
      DO
         victim_id = userid
         victim_node = usernode
      END
   IF usernode = '' THEN           /* the input is nickname or local userid */
      DO
         'NAMEFIND :NICK' userid ':NODE :USERID (FIFO'
         IF RC = 0 THEN
            DO
               PULL victim_node
               PULL victim_id
            END
         ELSE
            DO
               victim_id = userid
               victim_node = mynode
            END
      END
   IF victim_node ^= mynode THEN
      'SMSG ' rscs_name ' CMD ' victim_node ' CPQ USER ' victim_id
   ELSE
      'Q' victim_id
RETURN
 
QQ_HELP: PROCEDURE
   SAY 'COMMAND SYNTAX:  QQ <nickname>|[<userid> [AT <nodeid>]]'
RETURN
