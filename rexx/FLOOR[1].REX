/**/
hp='1DE8'x
ehp='1D60'x
/* IBM Internal Use Only */
/* Function : Sort & Merge the cabling system records by floor */
/* Author   : Chang, Man Wai CHANGMW(HKGVMAPG) */
 
cable_profile = 'CABLE PROFILE A'
outf_header='CABTEMP SCRIPT A'
 
STATE cable_profile
if rc^=0 then exit
 
do floor=27 to 32
  outf.floor=floor||'F SCRIPT A'
  'COPY' outf_header outf.floor '(REPLACE'
end
 
/* get list of file names that hold the cabling system records */
SAY hp'Reading'ehp cable_profile
'EXECIO 1 DISKR' cable_profile
fn = 0
maxfn = 0
do until rc=2
  pull mline
  maxfn=maxfn+1
  cufile.maxfn = mline
  'EXECIO 1 DISKR' cable_profile
end
'FINIS' cable_profile
if maxfn=0 then
  exit
 
/* sort & merge record by floor   */
DO fn=1 to maxfn
  CLRSCRN
  SAY 'Reading' hp cufile.fn ehp
  'EXECIO 1 DISKR' cufile.fn
  DO UNTIL rc=2
    PULL aline
    SELECT
      WHEN substr(aline,45,2) = 27 THEN
        'EXECIO 1 DISKW' outf.27 '(STRING' aline
      WHEN substr(aline,45,2) = 28 THEN
        'EXECIO 1 DISKW' outf.28 '(STRING' aline
      WHEN substr(aline,45,2) = 29 THEN
        'EXECIO 1 DISKW' outf.29 '(STRING' aline
      WHEN substr(aline,45,2) = 30 THEN
        'EXECIO 1 DISKW' outf.30 '(STRING' aline
      WHEN substr(aline,45,2) = 31 THEN
        'EXECIO 1 DISKW' outf.31 '(STRING' aline
      WHEN substr(aline,45,2) = 32 THEN
        'EXECIO 1 DISKW' outf.32 '(STRING' aline
      OTHERWISE
        NOP
    END
    'EXECIO 1 DISKR' cufile.fn
  END
  'FINIS' cufile.fn
END
CLRSCRN
SAY 'Done...'
SAY 'Output Files:'
do floor=27 to 32
  SAY hp outf.floor ehp
end
