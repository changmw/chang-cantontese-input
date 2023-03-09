/*
    DIRE by Chang Man Wai

    Check the disk space used by each directory in SYS:USER.
    Reverse-engineered from Yung Chun Kau's DIRX (Pascal).
    
    Mr. Yung was a CUHK graduate (major in Mathematics?) who worked
    as a programmer like me for Survey Research Hongkong.
    
    A similar utility existed for Unix/Linux called du in fileutils
    back then. But Mr. Yung didn't mention it. But then, Unix and Xenix
    programs didn't usually have source codes. "Open Source" was
    not heard of.

    Originally written for Turbo C++ for DOS 3.0

    version 1.1 : add support for filtering directory names.
    version 1.2 : bug in size calculation
    version 1.23: PATH_LENGTH increased to 512 bytes
    version 1.24: search hidden directory as well
    version 1.26: bug in detecting hidden directories!
    2008mar32-version 2.0: ported to 32-bit Visual C++ (ANSI)
    2012feb??-version 2.1: bugfix for detecting "." and ".."; count files;
                            show most recent file;
                            support both Unicode & DBCS via _t functions;
                            merge scan_files() & scan_folders into one routine to save a findfile pass
    2012aug30-version 2.2: used __int64 and printf("%i64d") when handling file sizes
	2016oct17-version 2.3: bug in calculating total when scanning a single subfolder
	2016oct18-version 2.4: add codes for counting file size by file extension; use "%llu" instead of "%i64d" in printf()
							change some system messages
	2016oct20-version 2.5: parse command-line options "/noext"; altered some system messages
						   fix bug in sorting using insertion sort with counting routine
	2016oct21-version 2.6: new function make_node()

	Resource file dire.rc: ICON_MAIN     ICON    dire.ico
	To compile resource file dire.rc: rc dire.rc
	To compile this project: cl dire.c dire.res user32.lib shlwapi.lib

References:
http://www.codeproject.com/Tips/76252/What-are-TCHAR-WCHAR-LPSTR-LPWSTR-LPCTSTR-etc
http://msdn.microsoft.com/en-us/library/s3f49ktz.aspx
http://msdn.microsoft.com/en-us/library/aa261215%28v=vs.60%29.aspx
http://stackoverflow.com/questions/31646314/get-file-extension-from-tchar-array
http://stackoverflow.com/questions/15960040/insertion-sort-on-linked-list-in-c
*/
#define _UNICODE
#define UNICODE

#define MAX_PATH_LENGTH 32767/sizeof(TCHAR)
#define UNICODE_PATH_PREFIX "\\\\?\\"
#define PROG_NAME "DIRE v2.6"
#define USAGE "Usage: DIRE [substr] [/noext] [/nofolder] [/norecent] [/nohelp]"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <malloc.h>
#include <TCHAR.h>
#include <shlwapi.h>
#include <windows.h>

void add_slash(TCHAR*);
void scan_folders(const TCHAR*, const int, const TCHAR*);
__int64 myrnd(const __int64, const __int64);
int make_node(const TCHAR*, const __int64);

DWORD GetTimeDifference(SYSTEMTIME, SYSTEMTIME);

TCHAR *cur_dir, *filter, *myname, *tree_recent_file, temp_path[MAX_PATH_LENGTH];
__int64 tree_total=0, tree_files=0;
FILETIME tree_recent = { 0, 0 };
SYSTEMTIME systime;

int skip_extn, skip_fldr, skip_rcnt, skip_help;

typedef struct EXT_NODE {
	struct EXT_NODE *next;
	__int64 total_files, total_size;
	TCHAR *file_ext;
} EXT_RECORD;
EXT_RECORD *extension_list, *node_new, *node_cur, *node_prv;

int _tmain(int argc, const TCHAR *argv[])
{
	int i;
	TCHAR *filter_exp, *xx;

#ifdef hahaha
	// Get the local system time.
	SYSTEMTIME LocalTime = { 0 };
	GetSystemTime(&LocalTime);

	// Get the timezone info.
	TIME_ZONE_INFORMATION TimeZoneInfo;
	GetTimeZoneInformation(&TimeZoneInfo);

	// Convert local time to UTC.
	SYSTEMTIME GmtTime = { 0 };
	TzSpecificLocalTimeToSystemTime(&TimeZoneInfo,
		&LocalTime,
		&GmtTime);
#endif

  if (GetModuleFileName(0, temp_path, MAX_PATH_LENGTH) == 0) exit(1);

  myname=(TCHAR *)calloc(_tcslen(temp_path)+1, sizeof(TCHAR));
  _tcscpy(myname, temp_path);

  printf("\n%s",  PROG_NAME);

  // parse command-line options

  filter_exp = NULL;
  
  skip_extn = 0;
  skip_fldr = 0;
  skip_rcnt = 0;
  skip_help = 0;
  
  for (i = 1; i < argc; i++) {
	  xx = (TCHAR *)calloc(_tcslen(argv[i])+1, sizeof(TCHAR));
	  _tcscpy(xx, argv[i]);
	  _tcslwr(xx);
	  // _tprintf(_T("\n-- %s %d"), xx, i);
	  if (_tcscmp(xx, _T("/nohelp")) == 0)
		  skip_help = 1;
	  else if (_tcscmp(xx, _T("/norecent")) == 0)
		  skip_rcnt = 1;
	  else if (_tcscmp(xx, _T("/nofolder")) == 0)
		  skip_fldr = 1;
	  else if (_tcscmp(xx, _T("/noext"))==0)
		  skip_extn = 1;
	  else {
		  free(filter_exp);
		  filter_exp = (TCHAR *)calloc(_tcslen(argv[i])+1, sizeof(TCHAR));
		  _tcscpy(filter_exp, argv[i]);
	  }
	  free(xx);
  }

  _tgetcwd(temp_path, MAX_PATH_LENGTH); 
  cur_dir=(TCHAR *)calloc(_tcslen(temp_path)+1, sizeof(TCHAR));
  _tcscpy(cur_dir, temp_path);

  tree_recent_file=(TCHAR *)calloc(1,sizeof(TCHAR));

  extension_list = NULL;
  
  _tprintf(_T("\nScanning: %s"), cur_dir); 

  if (filter_exp != NULL) _tprintf(_T("\nFilename: *%s*"), filter_exp);

  if (!skip_fldr) printf("\n\n%s%52s%11s %7s", "Folder", "MBytes", "KBytes", "Count");

  /* show folders statistics within cur_dir */
  scan_folders(cur_dir, 0, filter_exp);

  if (!skip_fldr) _tprintf(_T("\n\n%-52s%6llu %10llu %7llu"), _T("total"), myrnd(tree_total,1024*1024), myrnd(tree_total,1024), tree_files);

  free(cur_dir);

  if (!skip_extn) {
	  printf("\n%-30s %10s %11s", "\nFile Extension/Type", "KBytes", "Count");
	  node_cur = extension_list;
	  tree_files = 0;
	  tree_total = 0;
	  while (node_cur != NULL) {
		_tprintf(_T("\n%-30s %10llu %10llu"), node_cur->file_ext, myrnd(node_cur->total_size, 1024), node_cur->total_files);
		tree_files += node_cur->total_files;
		tree_total += node_cur->total_size;
		node_prv = node_cur;
		node_cur = node_cur->next;
		free(node_prv->file_ext);
		free(node_prv);
	  }
	  _tprintf(_T("\n\n%-30s %10llu %10llu"), _T("total"), myrnd(tree_total, 1024), tree_files);
  }

  if (!skip_rcnt) {
	  FileTimeToSystemTime(&tree_recent, &systime);
	  _tprintf(_T("\n\nMost recent file:"));
	  _tprintf(_T("\nname: %s"), tree_recent_file);
	  _tprintf(_T("\ndate: %0d/%0d/%0d %02d:%02d:%02d"), systime.wDay, systime.wMonth, systime.wYear, systime.wHour, systime.wMinute, systime.wSecond);
  }

  if (!skip_help) printf("\n\n%s\n", USAGE);
  // Beep( 750, 300 );
 
}

void add_slash(TCHAR *s)
{
  if (s[_tcslen(s)-1] != _T('\\'))  {
    _tcscat(s, _T("\\"));
  }
}

// tree-walk directory tree of filesystem
void scan_folders(const TCHAR* in_path, const int level, const TCHAR *filter)
{
  WIN32_FIND_DATA c_ffblk;
  HANDLE hFind;
  static __int64 subtree_size=0, subtree_files=0;
  __int64 cur_size=0, cur_files=0;
  __int64 ffsize=0;
  TCHAR *tt, *pathname, *ffext;

  _tcscpy(temp_path, in_path);
  add_slash(temp_path);
  if (filter == NULL) {
    _tcscat(temp_path, _T("*"));
  } else {
	_tcscat(temp_path, _T("*"));
	_tcscat(temp_path, filter);
    _tcscat(temp_path, _T("*"));
  }
  pathname=(TCHAR *)calloc(_tcslen(temp_path)+1, sizeof(TCHAR));
  _tcscpy(pathname, temp_path);

  hFind=FindFirstFile(pathname, &c_ffblk);
  while (hFind != INVALID_HANDLE_VALUE && !kbhit())
  {
    if (c_ffblk.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
      while (TRUE) {
        // folders
        /* ignore "." */
        if (!_tcscmp(c_ffblk.cFileName, _T("."))) break;
        /* ignore ".." */
        if (!_tcscmp(c_ffblk.cFileName, _T(".."))) break;

        /* ready next level of pathname */
        _tcscpy(temp_path, in_path);
        add_slash(temp_path);
        _tcscat(temp_path, c_ffblk.cFileName);

		tt=(TCHAR *)calloc(_tcslen(temp_path)+1, sizeof(TCHAR));
        _tcscpy(tt, temp_path);
        scan_folders(tt, level+1, NULL);
        free(tt);

		/* complete depth-first search for a subfolder in startting folder, show total sub-tree size */
        if (level == 0)
        {
          if (!skip_fldr) _tprintf(_T("\n%-51s %6llu %10llu %7llu"), c_ffblk.cFileName, myrnd(subtree_size,1024*1024), myrnd(subtree_size,1024), subtree_files);
          tree_total += subtree_size;
          tree_files += subtree_files;
          subtree_size=0;
          subtree_files=0;
        }
        break;
      }
    } else {
       // files
       ffsize=(__int64)c_ffblk.nFileSizeLow+((__int64)c_ffblk.nFileSizeHigh * ((__int64)MAXDWORD+1));
       // printf("\n** %llud %d", ffsize, sizeof(__int64));

	   if (level == 0) {
          // starting folder
          cur_size += ffsize;
          cur_files++;
       } else {
          subtree_size += ffsize;
          subtree_files++;
       }

	   // get file extension
	   ffext = (TCHAR *)calloc(_tcslen(c_ffblk.cFileName) + 1, sizeof(TCHAR));
	   _tcscpy(ffext, PathFindExtension(c_ffblk.cFileName));
	   _tcslwr(ffext);

	   // insertion sort combined with statistics update
	   if (extension_list == NULL) {
		   make_node(ffext, ffsize);
		   extension_list = node_new;
	   }
	   else if (_tcscmp(ffext, extension_list->file_ext) < 0) {
		   make_node(ffext, ffsize);
		   node_new->next = extension_list;
		   extension_list = node_new;
	   }
	   else {
		   node_cur = extension_list;
		   while (node_cur != NULL) {
			   if (_tcscmp(node_cur->file_ext, ffext) == 0) {
				   node_cur->total_files++;
				   node_cur->total_size += ffsize;
				   break;
			   }
			   if (node_cur->next == NULL || _tcscmp(node_cur->next->file_ext, ffext) > 0) {
				   make_node(ffext, ffsize);
				   node_new->next = node_cur->next;
				   node_cur->next = node_new;
				   break;
			   }
			   node_cur = node_cur->next;
		   }
	   }
	   free(ffext);

	   /* find recent file */
	   _tcscpy(temp_path, in_path);
      add_slash(temp_path);
      _tcscat(temp_path, c_ffblk.cFileName);
      if (_tcscmp(myname, temp_path) != 0) {
        if (CompareFileTime(&c_ffblk.ftLastWriteTime, &tree_recent) > 0)
        {
            tree_recent=c_ffblk.ftLastWriteTime;
			// re-allocate memory
            free(tree_recent_file);
            tree_recent_file=(TCHAR *)calloc(_tcslen(c_ffblk.cFileName)+1, sizeof(TCHAR));
            _tcscpy(tree_recent_file, c_ffblk.cFileName);
        }
      }
    }
    if (FindNextFile(hFind, &c_ffblk) == 0) break;
  }
  FindClose(hFind);
  free(pathname);

  // starting folder stats. last row
  if (level == 0) {
    if (!skip_fldr) _tprintf(_T("\n%-51s %6llu %10llu %7llu"), _T("."), myrnd(cur_size,1024*1024), myrnd(cur_size,1024), cur_files); 
	tree_total += cur_size;
	tree_files += cur_files;
  }
}

int make_node(const TCHAR *ffext, const __int64 ffsize)
{
	node_new = malloc(sizeof(EXT_RECORD));
	node_new->file_ext = (TCHAR *)calloc(_tcslen(ffext) + 1, sizeof(TCHAR));
	if (node_new == NULL) return 1;
	_tcscpy(node_new->file_ext, ffext);
	node_new->total_size = ffsize;
	node_new->total_files = 1;
	node_new->next = NULL;
	return 0;
}

// rounding a number, minimum value 1 if non-zero
__int64 myrnd(const __int64 x, const __int64 unit)
{
  if (x > 0 && x/unit < 1) return 1;
  return (__int64)x/unit;
}

// compute time differnces
DWORD GetTimeDifference( SYSTEMTIME st1, SYSTEMTIME st2 )
{
/*
  http://www.experts-exchange.com/Programming/Languages/CPP/Q_21498789.html
*/
    FILETIME        ft1, ft2;
    LARGE_INTEGER   li1, li2, liDiff;
    DWORD dwDiff;

    SystemTimeToFileTime( &st1, &ft1 );
    SystemTimeToFileTime( &st2, &ft2 );

    li1.LowPart = ft1.dwLowDateTime;
    li1.HighPart = ft1.dwHighDateTime;
    li2.LowPart = ft2.dwLowDateTime;
    li2.HighPart = ft2.dwHighDateTime;

    if ( CompareFileTime(&ft1, &ft2) < 0 ) {
        liDiff.LowPart  = li2.LowPart  - li1.LowPart;
        liDiff.HighPart = li2.HighPart - li1.HighPart;
    }
    else {
        liDiff.LowPart  = li1.LowPart  - li2.LowPart;
        liDiff.HighPart = li1.HighPart - li2.HighPart;
    }

    dwDiff = ((__int64)liDiff.HighPart << 32) + liDiff.LowPart;
    // Convert from n x 100ns intervals into seconds
    dwDiff /= ((__int64)10*1000*1000);

    return dwDiff;
}
// end of file
