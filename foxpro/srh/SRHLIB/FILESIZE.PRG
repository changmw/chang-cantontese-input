FUNCTION filesize      && Return the size of a file
PARAMETERS fn
fh=fopen(fn)
IF fh <> -1
  m.fsize=fseek(fh,0,2)
ELSE
  m.fsize= -1
ENDIF
=fclose(fh)
RETURN m.fsize
