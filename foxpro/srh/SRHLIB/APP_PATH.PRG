*
* Locations of SRHIS information systems data
*
*
* First created by Chang Man Wai
* used by every SRHIS components
*
public PS_PATH, PR_PATH, ML_PATH, JB_PATH, PU_PATH, TS_PATH
public DA_PATH
private ROOT

ROOT=getenv("SRHIS")
if empty(ROOT)
  ROOT="F:\SRHIS\"    && default root for SRH information systems
endif
if right(ROOT,1)#"\"
  ROOT=ROOT+"\"
endif

* all paths must end with '\'
* containing DBF, FRX and LBX
PS_PATH=ROOT+"PERSON\DATA\"     && personnel system
PR_PATH=ROOT+"PAYROLL\DATA\"    && payroll system
ML_PATH=ROOT+'MAILLIST\DATA\'   && mailing list system
JB_PATH=ROOT+'JOBSHEET\DATA\'   && ad hoc job control sheet system
PU_PATH=ROOT+'PUBLIC\DATA\'     && shared databases
TS_PATH=ROOT+'TIMESHET\DATA\'   && time sheet system
DA_PATH=ROOT+'PUBLIC\DATA\'     && database Administration

return
