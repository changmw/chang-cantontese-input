@Echo Off
rem
rem Netware command: Userlist
rem
UserList RA/%1 %2 %3 /O
PAUSE > NUL
UserList SRH486A/%1 %2 %3 /O
PAUSE > NUL
UserList SRH486DP/%1 %2 %3 /O
PAUSE > NUL
UserList SRH386A/%1 %2 %3 /O
Pause > NUL
