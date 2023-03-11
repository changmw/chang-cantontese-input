  *
  * Procedure Explode
  *
  * Written by: Adam Chan
  *
  parameters win_name, dt, dl, db, dr
  private st, sl, sr, sb, i
  sl=(dr-dl)/2+dl
  st=(db-dt)/2+dt
  sr=sl
  sb=st
  factor=(dr-sr)/(db-sb)
  show window (win_name)
  for i=0 to (dr-sr)
     zoom window (win_name) norm from st-i/factor,sl-i to sb+i/factor,sr+i
  endfor
  zoom window (win_name) norm from dt,dl to db,dr
  activate window (win_name)
return
