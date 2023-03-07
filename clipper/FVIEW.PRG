@   4, 0 clear to 20,60
@   4, 0 to 20,60 double

fview('fview.prg', 5, 1, 19,59,255)
/**********
*
* 
* Function : fview.prg
* Purpose  : browse text file > 64K and > 80 cloumn
*
* Complie  : clipper fview /m /l /n /a
* By       : Denver Jen (Data-Gen System)
* Date     : September, 1992
*
* Syntax   : fview( <filename>,<top>,<left>,<bottom>,<right>,<maxline> )
*
* Note     : This function can view any ASCII file.
*            The 'TAB' character will not be expanded
*
* 
*
*/

#include "fileio.ch"
#include "inkey.ch"

static s_width       := 0
static s_height      := 0
static s_column      := 1
static s_maxline     := 255
static s_top         := 0
static s_left        := 0
static s_bof
static s_eof
static s_handle

#define FILE_HANDLE     s_handle
#define WIN_WIDTH       s_width
#define WIN_HEIGHT      s_height
#define COLUMN_MARK     s_column
#define TOP             s_top
#define LEFT            s_left
#define MAX_LINE        s_maxline

/**********
*
* function : fview()
*
*/
function fview(lfile,lt,ll,lb,lr,lmaxline)
local lptr
local lkey
local lreview := .t.

if valtype(lmaxline) = 'N'
   MAX_LINE   := lmaxline
end
WIN_WIDTH  := lr - ll
WIN_HEIGHT := lb - lt + 1
TOP        := lt
LEFT       := ll

FILE_HANDLE := fopen(lfile,FO_READ)

while .t.
      if lreview
          ___disp()
      end
      lreview := .t.
      lkey := inkey(0)
      do case
         case lkey = K_LEFT
              if COLUMN_MARK > 1
                 COLUMN_MARK--
              end
         case lkey = K_RIGHT
              if COLUMN_MARK < MAX_LINE
                 COLUMN_MARK++
              end
         case lkey = K_DOWN
              ___down()
         case lkey = K_UP
              ___up()
         case lkey = K_PGDN
              ___pgdn()
         case lkey = K_PGUP
              ___pgup()
         case lkey = K_ESC
              exit
         case lkey = K_TAB
              if COLUMN_MARK + 10 < MAX_LINE
                 COLUMN_MARK += 10
              end
         case lkey = K_SH_TAB
              if COLUMN_MARK - 10 > 1
                 COLUMN_MARK -= 10
              else
                 COLUMN_MARK := 1
              end
         case lkey = K_CTRL_PGUP
              fseek(FILE_HANDLE, 0, FS_SET)
         case lkey = K_CTRL_PGDN
              fseek(FILE_HANDLE, 0, FS_END)
              ___up()
         case lkey = K_HOME
              COLUMN_MARK := 1
      otherwise
              lreview := .f.
      endcase
end

fclose(FILE_HANDLE)

return NIL

/**********
*
* function : ___readline()
*
*/
static function ___readline()
local lstr := freadstr(FILE_HANDLE,MAX_LINE)
local lstep
local lat
local lret

lstep := len(lstr)
lat := at(chr(13),lstr)

if lstep <> MAX_LINE .and. lat = 0
   s_eof := .t.
else
   s_eof := .f.
end

if lat <> 0 
   fseek(FILE_HANDLE, lat - lstep + 1,FS_RELATIVE)
   lstr := substr(lstr,1,lat - 1)
end

lret := substr(lstr + space(MAX_LINE),COLUMN_MARK,WIN_WIDTH)

return lret

/**********
*
* function : ___disp()
*
*/
static function ___disp()
local llp
local lend
local lptr

lptr := FTELL(FILE_HANDLE)

for llp = 1 to WIN_HEIGHT
    @ TOP + llp - 1, LEFT say ___readline()
next

lend := FTELL(FILE_HANDLE)

fseek(FILE_HANDLE, lptr - lend, FS_RELATIVE)

return NIL

/**********
*
* function : ___down()
*
*/
static function ___down()
local lstart := FTELL(FILE_HANDLE)
local lend

___readline()
if s_eof
   lend := FTELL(FILE_HANDLE)   
   fseek(FILE_HANDLE, lstart - lend, FS_RELATIVE )
end

return NIL

/**********
*
* function : ___up()
*
*/
static function ___up()
local lnow := FTELL(FILE_HANDLE)
local lstr,lpos

if lnow <> 0
   if lnow <= MAX_LINE
      fseek(FILE_HANDLE, 0, FS_SET)
      lstr := freadstr(FILE_HANDLE,lnow - 2)
      lpos := rat(chr(13),lstr)
      if lpos <> 0
         s_bof := .f.
         fseek(FILE_HANDLE,lpos + 1, FS_SET)
      else
         s_bof := .t.
         fseek(FILE_HANDLE, 0, FS_SET)
      end
   else
      fseek(FILE_HANDLE, - MAX_LINE - 2, FS_RELATIVE)
      lstr := freadstr(FILE_HANDLE,MAX_LINE - 1)
      lpos := rat(chr(13),lstr)
      if lpos <> 0
         fseek(FILE_HANDLE, lpos - MAX_LINE + 2 , FS_RELATIVE)
      else
         fseek(FILE_HANDLE,  - MAX_LINE + 1, FS_RELATIVE)
      end
      s_bof := .f.   
   end
else
   s_bof := .t.         
end

return NIL

/**********
*
* function : ___pgdn()
*
*/
static function ___pgdn()
local lstep := 1

while lstep <= WIN_HEIGHT
      ___down()
      if s_eof
         exit
      end
      lstep++
end

return NIL

/**********
*
* function : ___pgup()
*
*/
static function ___pgup()
local lstep := 1

while lstep <= WIN_HEIGHT
      ___up()
      if s_bof
         exit
      end
      lstep++
end

return NIL
clipper fview /m /n /l /w /a
clipper test /m /l 
if errorlevel 1 pause
blinker fi test,fview
