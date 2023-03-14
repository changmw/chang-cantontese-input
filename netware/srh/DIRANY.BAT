@Echo Off
rem
rem Described by PC Magazine
rem
If '%2' == '' GoTo Syntax
For %%v In (1 2 3 4 5 6 7 8) Do If %2==%%v GoTo Ok
GoTo Sntax
:Ok
Set Temp=%1*.*
Rem If name has 8 letters, we're done
If %2==8 GoTo DoIt
Set Temp=%Temp% ?%1*.*
If %2==7 GoTo DoIt
Set Temp=%Temp% ??%1*.*
If %2==6 GoTo DoIt
Set Temp=%Temp% ???%1*.*
If %2==5 GoTo DoIt
Set Temp=%Temp% ????%1*.*
If %2==4 GoTo DoIt
Set Temp=%Temp% ?????%1*.* *.%1*
If %2==3 GoTo DoIt
Set Temp=%Temp% ??????%1*.* *.?%1*
If %2==2 GoTo DoIt
Set Temp=%Temp% ???????%1*.* *.??%1
:DoIt
For %%f In (%Temp%) Do Echo %%f
Set Temp=
GoTo End
:Syntax
Echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
Echo ³DirAny lists files whose names contain a certain string.    ³
Echo ³        Syntax: "DirAny string n"                           ³
Echo ³        where "string" is a string of 1 to 8 characters     ³
Echo ³        (no wildcards) and "n" is the length of that string.³
Echo ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
Echo ³Example on how to use this Batch File                       ³
Echo ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
Echo ³[ C:\ ] dirany srh 3                                        ³
Echo ³SRH_FILES.DAT                                               ³
Echo ³DP_SRH.PRG                                                  ³
Echo ³SEC_SRH.MNU                                                 ³
Echo ³[ C:\ ]                                                     ³
Echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
:End
