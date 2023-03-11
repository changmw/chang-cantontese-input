*
* For window shrinking
* Procedure Shrink
* written by Adam Chan
*
  parameter win_name, st, sl, sb, sr
  private st,sl,sb,sr,factor,i
  factor=(sr-sl)/(sb-st)
  show window (win_name)
  for i=1 to ((sr-sl)/2)
     zoom window (win_name) norm from st+i/factor,sl+i to sb-i/factor,sr-i
  endfor
  hide window (win_name)
return
