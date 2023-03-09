#
# MAKEFILE for Retail Audit Btrieve File Handling functions
#
MODEL   = s
INCLUDE = g:\dp\tcpp3\include;g:\dp\netcall\include
LIB     = g:\dp\tcpp3\lib;g:\dp\netcall\turc
TCLIB   = g:\dp\tcpp3\lib
#
.c.obj:
  tcc -m$(MODEL) -c -k -I$(INCLUDE) $**
#
# Note that Cx.LIB must be at the end
#
getq.exe        : $(TCLIB)\c0$(MODEL).obj getq.obj
  tlink /3 /x /L$(LIB) @getq.lnk
#
getq.obj        : getq.c
