FUNCTION touch        && Update the DOS date/time stamp
PARAMETERS fn         && Name of File to update
fh=fopen(fn,12)

IF fh <> -1
  os=fseek(fh,0,2)     && Go to eof, get number bytes in the file
  =fwrite(fh,'  ',1)   && Add a character to Make DOS update the file
  =fchsize(fh,os)      && Return file to original size
  m.error = 0
ELSE
  m.error=ferror()     && if file not opened save error number
ENDIF
  =fclose(fh)
RETURN m.error         && return error number or 0
