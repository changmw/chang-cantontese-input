/***********************************************************/
/*                                                         */
/*            IBM Internal Use Only                        */
/*                                                         */
/* Author : Chang Man Wai                                  */
/* Date   : January 10, 1988                               */
/* Revised: February 9, 1989                               */
/*          - Allow user name as search key                */
/*          - Use LOCATE instead of FIND for partial       */
/*            key match                                    */
/*          February 13, 1989                              */
/*          - incorporate SEARCH NEXT function for non-    */
/*            unique key search                            */
/*                                                         */
/* Function : Screen for viewing cabling system records    */
/*                                                         */
/* Global variables                                        */
/* ================                                        */
/* curfn : indicates which file is currently being read    */
/* maxfn : the number of data files                        */
/* lasfn : indicates the first file read in each searching */
/* recno : current record number in file.curfn             */
/* err   : indicates presence of input data error          */
/* lastfound : whether a file search is successful         */
/*                                                         */
/***********************************************************/
CONST:
  cable_profile = 'CABLE PROFILE A'
 
 
   address 'COMMAND'
   'EXECIO 1 DISKR' cable_profile
   maxfn = 0
   do until rc=2
     pull mline
     maxfn=maxfn+1
     cufile.maxfn = mline
     'EXECIO 1 DISKR' cable_profile
   end
   'FINIS' cable_profile
   if maxfn=0 then exit
 
   recno = 1
   err = 0
   call init_panel
   'EUDEXEC2'                    /* invoke interface with DMS */
   pos = 'CU_NAME'
   msg = ''
   curfn = 1
   lastfound =0
   do forever
      address 'DISPLAY'
      call format_panel
      'USE' CABLE                /* get panel CHANG PCB */
      call map_wire1
      'CASE U'                   /* upper case only */
      'CURSOR' pos               /* init cursor position */
      'DISPLAY'
      address 'COMMAND'
      msg = ''
      call unformat_panel
      select
         when rstatus = 'PF1' then  /* Search key */
            do
               call search_rec
               if found then
                  call reset_fields
            end
         when rstatus = 'PF2' then
            msg = 'Sorry! Funtion not implemented.'
         when rstatus = 'PF3' then
            call init_panel
         when rstatus = 'PF7' | rstatus = 'PF8' then
            do
               if rstatus = 'PF7' then
                  offset = -1
               else
                  offset = 1
               recno = recno + offset
               if recno < 1 then
                  do
                     recno = 1
                     msg = 'Top of file reached'
                  end
               call reset_fields
               'EXECIO 1 DISKR' cufile.curfn recno '(FINIS'
               if rc^=0 then
                  do
                      recno = recno - 1
                      msg = 'End of file reached'
                  end
               else
                  do
                     pull cu_rec
                     call reset_fields
                  end
            end
         when rstatus = 'PF12'  then   /* quit */
            leave
         otherwise
            msg = 'Please use the correct key!'
      end /* select... */
   end /* do forever... */
exit
 
MAP_WIRE1:   /* define panel parameters */
   'MAP DATA',
   '1 CU_NAME 2 U_NAME 3 P_NO    4 U_LOC   5 P_ADDR  6 B_NO',
   '7 P_TYPE  8 U_TERM 9 RACK.1 10 RACK.2 11 RACK.3 12 MSG'
RETURN
 
INIT_PANEL:
   /* empty all variables used in the screen */
   address 'COMMAND'
   cu_name = ''  /* control unit name */
   p_no    = ''  /* port number on patch panel */
   do i = 1 to 3
      rack.i  = ''  /* Rack locations */
   end
   p_type  = ''  /* port type */
   p_addr  = ''  /* port address */
   u_name  = ''  /* user name */
   u_term  = ''  /* user terminal type */
   u_loc   = ''  /* workstation number */
   b_no    = ''  /* Box number */
RETURN
 
FORMAT_PANEL:
   /* set length of variables on the screen */
   address 'COMMAND'
   cu_name = translate(left(cu_name, 3), '_', ' ')
   p_no    = translate(left(p_no, 3), '_', ' ')
   do i = 1 to 3
      rack.i = translate(left(rack.i, 8), '_', ' ')
   end
   p_addr  = translate(left(p_addr, 8), '_', ' ')
   p_type  = translate(left(p_type, 7), '_', ' ')
   u_name  = translate(left(u_name, 21), '_',' ')
   u_term  = translate(left(u_term, 6), '_', ' ')
   u_loc   = translate(left(u_loc, 4), '_', ' ')
   b_no    = translate(left(b_no, 10), '_', ' ')
RETURN
 
CHECK_PANEL:
   /* check all parameters passed back by DMS */
   address 'COMMAND'
   if p_addr = '' | length(p_addr) < 3 then
      do
         err = 1
         pos = 'P_ADDR'
         msg = 'Invalid port address'
         return
      end
   if p_type = '' | length(p_type) < 6 then
      do
         err = 1
         pos = 'P_TYPE'
         msg = 'Invalid port type'
         return
      end
   if u_loc = '' | length(u_loc) < 4 then
      do
         err = 1
         pos = 'U_LOC'
         msg = 'Invalid location or location missing'
         return
      end
   if b_no = '' | length(b_no) < 8 then
      do
         err = 1
         pos = 'B_NO'
         msg = 'box number missing or invalid'
         return
      end
   err = 0
RETURN
 
SEARCH_REC:
   /* locate the search key specified */
   address 'COMMAND'
   select
     when cu_name ^= '' & p_no ^= '' then
       do
         lasfn=curfn
         do forever
           if substr(cufile.curfn, 6,3)=cu_name then
             leave
           call add_fn
           if curfn = lasfn then
             do
               msg = 'Invalid control unit name'
               pos = 'CU_NAME'
               found = 0
               lastfound=found
               return
             end
         end
         'EXECIO * DISKR' cufile.curfn '(FINIS ZONE 2 4 LOCATE /'||p_no||'/'
         if rc^=0 then
           do
             msg = 'Invalid port number'
             pos = 'P_NO'
             found = 0
             lastfound=found
             return
           end
       end
     when p_addr^='' | u_loc^='' | b_no^='' | u_name ^= '' then
       do
         lasfn = curfn
         do forever
           select
             when p_addr ^= '' then
               if lastfound then
                 'EXECIO * DISKR' cufile.curfn recno+1 '(FINIS ZONE  6 13 LOCATE /'||p_addr||'/'
               else
                 'EXECIO * DISKR' cufile.curfn '(FINIS ZONE  6 13 LOCATE /'||p_addr||'/'
             when u_loc ^= '' then
               if lastfound then
                 'EXECIO * DISKR' cufile.curfn recno+1 '(FINIS ZONE 45 48 LOCATE /'||u_loc||'/'
               else
                 'EXECIO * DISKR' cufile.curfn '(FINIS ZONE 45 48 LOCATE /'||u_loc||'/'
             when b_no ^= '' then
                if lastfound then
                  'EXECIO * DISKR' cufile.curfn recno+1 '(FINIS ZONE 57 66 LOCATE /'||b_no||'/'
                else
                  'EXECIO * DISKR' cufile.curfn '(FINIS ZONE 57 66 LOCATE /'||b_no||'/'
             otherwise
                if lastfound then
                  'EXECIO * DISKR' cufile.curfn recno+1 '(FINIS ZONE 23 43 LOCATE /'||u_name||'/'
                else
                 'EXECIO * DISKR' cufile.curfn '(FINIS ZONE 23 43 LOCATE /'||u_name||'/'
           end /* inner select.. */
           if rc=0 then
             leave
           call add_fn
           if curfn = lasfn then
             do
               msg = 'Record not found'
               found = 0
               lastfound=found
               return
             end
         end
       end
     otherwise
       do
         found = 0
         lastfound=found
         pos = 'P_ADDR'
         msg = 'No valid search key given'
         return
       end
   end
   if rc=0 then
     do
       found = 1
       lastfound=found
       pull recno
       pull cu_rec
       recno=word(recno,1)
    end
RETURN
 
UNFORMAT_PANEL:
   /* remove spaces in the parameters passed back from DMS */
   address 'COMMAND'
   cu_name = strip(translate(cu_name, ' ', '_'))
   p_no    = strip(translate(p_no,   ' ', '_'))
   rack.1  = strip(translate(rack.1, ' ', '_'))
   rack.2  = strip(translate(rack.2, ' ', '_'))
   rack.3  = strip(translate(rack.3, ' ', '_'))
   p_addr  = strip(translate(p_addr, ' ', '_'))
   p_type  = strip(translate(p_type, ' ', '_'))
   u_name  = strip(translate(u_name, ' ', '_'))
   u_term  = strip(translate(u_term, ' ', '_'))
   u_loc   = strip(translate(u_loc,  ' ', '_'))
   b_no    = strip(translate(b_no,   ' ', '_'))
RETURN
 
RESET_FIELDS:
   /* define values for each field in record of file */
   address 'COMMAND'
   cu_name = substr(cufile.curfn, 6, 3)
   p_no    = substr(cu_rec,2,3)
   p_addr  = substr(cu_rec,6,8)
   p_type  = substr(cu_rec,15,6)
   u_name  = substr(cu_rec,23,21)
   u_loc   = substr(cu_rec,45,4)
   u_term  = substr(cu_rec,50,6)
   b_no    = substr(cu_rec,57,10)
   rack.1  = substr(cu_rec,68,10)
   rack.2  = substr(cu_rec,1,1)
   rack.3  = substr(cu_rec,1,1)
RETURN
 
BUILD_REC:
    /* form the output record from fields */
    address 'COMMAND'
    cu_rec.1=' '||left(p_no,4)||' '||left(u_name,21)
    cu_rec.2=' '||left(p_no,3)||' '||left(p_addr,8)
    cu_rec.3=' '||left(p_type,7)||' '||left(u_term,6)
    cu_rec.4=' '||left(b_bo,10)||' '||left(rack.1,8)
    cu_rec.5=' '||left(rack.2,8)||' '||left(rack.3,8)
    cu_rec=cu_rec.1||cu_rec.2||cu_rec.3||cu_rec.4||cu_rec.5
RETURN
 
ADD_FN:
  lastfound=0
  found=0
  recno=1
  curfn = curfn + 1
  if curfn > maxfn then
    curfn = 1
RETURN
