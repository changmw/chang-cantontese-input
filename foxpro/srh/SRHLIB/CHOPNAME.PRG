procedure chopname
  parameters p_name,p_a,p_b,p_c
  private i,j

  set udfparms reference
  i = ffind(p_name," ")
  if i<len(p_name)+1
    a=alltrim(left(p_name, i))
  endif
  j=bfind(p_name,",")
  if j>0
    p_c=alltrim(right(p_name,len(p_name)-j))
    p_b=alltrim(substr(p_name,i,j-i))
  else
    p_b=alltrim(right(p_name,len(p_name)-i))
  endif
return

function bfind
  parameters m_string, m_exp
  private i

  i=len(m_string)
  do while substr(m_string,i,1)#m_exp .and. i>0
    i=i-1
  enddo
return i

function ffind
  parameters m_string, m_exp
  private i

  i=1
  do while substr(m_string,i,1)#m_exp .and. i<len(m_string)+1
    i=i+1
  enddo
return i
