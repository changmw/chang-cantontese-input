* Program.: NUMWORDS.PRG
* Author..: Stephen Kurasch, based on Nmbrword.PRG by Tom Rettig
*           Ported to FoxPro by Chang Man Wai
* Date....: June 10, 1985
* Notice..: Copyright 1985, Ashton-Tate
* Notes...: Converts numeric amounts to words
* Usage...: NUMWORDS(<amount>, <string 1>, <string 2>)

PARAMETERS mamt, word1, word2
private ones, camt, teen, tens, cnum, string, length, counter
declare ones[9], teen[10], tens[8]

* Initialize memory variables
camt = ""

ones[1] = "ONE  "
ones[2] = "TWO  "
ones[3] = "THREE"
ones[4] = "FOUR "
ones[5] = "FIVE "
ones[6] = "SIX  "
ones[7] = "SEVEN"
ones[8] = "EIGHT"
ones[9] = "NINE "

teen[1] = "TEN      "
teen[2] = "ELEVEN   "
teen[3] = "TWELVE   "
teen[4] = "THIRTEEN "
teen[5] = "FOURTEEN "
teen[6] = "FIFTEEN  "
teen[7] = "SIXTEEN  "
teen[8] = "SEVENTEEN"
teen[9] = "EIGHTEEN "
teen[10]= "NINETEEN "

tens[1] = "TWENTY "
tens[2] = "THIRTY "
tens[3] = "FORTY  "
tens[4] = "FIFTY  "
tens[5] = "SIXTY  "
tens[6] = "SEVENTY"
tens[7] = "EIGHTY "
tens[8] = "NINETY "

* Store whole dollar amount to a string, at most hundreds of thousands
cnum=LEFT(STR(mamt,9,2),6)

* check hundreds of thousands
IF LEFT(cnum,1)>" "
   camt=RTRIM(ones[VAL(LEFT(cnum,1)]))+" HUNDRED "
ENDIF

* check tens of thousands and thousands
DO CASE
   CASE SUBSTR(cnum,2,1)>"1"
      camt=camt+RTRIM(SUBSTR(tens,VAL(SUBSTR(cnum,2,1))-12,7))
      IF SUBSTR(cnum,3,1)>"0"
         camt=camt+"-"+RTRIM(SUBSTR(ones,VAL(SUBSTR(cnum,3,1))+1,5))
      ENDIF
      camt=camt+" THOUSAND " 

   CASE SUBSTR(cnum,2,1)="1"
      camt=camt+RTRIM(teen[VAL(SUBSTR(cnum,3,1))])+" THOUSAND "

   CASE SUBSTR(cnum,2,2)="00"
      camt=camt+"THOUSAND "

   CASE SUBSTR(cnum,3,1)>" "
      camt=camt+RTRIM(ones[VAL(SUBSTR(cnum,3,1))])+" THOUSAND "
ENDCASE

* check hundreds
IF SUBSTR(cnum,4,1)>"0"
   camt=camt+RTRIM(ones[VAL(SUBSTR(cnum,4,1))])+" HUNDRED "
ENDIF

* check tens and ones
DO CASE
   CASE SUBSTR(cnum,5,1)>"1"
      camt=camt+RTRIM(tens[VAL(SUBSTR(cnum,5,1))-12])
      IF RIGHT(cnum,1)>"0"
         camt=camt+"-"+RTRIM(ones[VAL(RIGHT(cnum,1))])
      ENDIF

   CASE SUBSTR(cnum,5,1)="1"
      camt=camt+RTRIM(teen[VAL(RIGHT(cnum,1))+1])

   CASE RIGHT(cnum,2)=" 0"
      camt="ZERO"

   OTHERWISE
      camt=camt+RTRIM(ones[VAL(RIGHT(cnum,1))+1])
ENDCASE

* Convert decimal places to a string containing cents amount
cents=RIGHT(STR(mamt,9,2),2)
camt=RTRIM(camt)+" AND "+cents+"/100 DOLLARS"

string = SPACE(62)
length = LEN(camt)

* if length is greater than 75, the words will have to be 
*    broken up so that it will fit on the check
IF length > 75
   counter = 74

   DO WHILE .NOT. SUBSTR(camt,counter,1) $ " -"
      counter = counter - 1
   ENDDO

   * divide the word into two parts and display
   word1 = LEFT(camt,counter)+LEFT(string,75-counter)
   word2 = RIGHT(camt,length-counter)
ELSE
   * else word is less than or equal to 75 characters
   word1 = camt + LEFT(string,75-length)
ENDIF

RETURN
* Eof: Numwords.prg
