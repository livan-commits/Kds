/* SPDX-License-Identifier: GPL-3.0-or-later */
#include "kds_storage.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include <direct.h>
#define KDS_MKDIR(p) _mkdir(p)
#define KDS_SEP '\\'
#else
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#define KDS_MKDIR(p) mkdir((p), 0700)
#define KDS_SEP '/'
#endif
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
static char root[PATH_MAX];
static int ready;
static int make_dir(const char *p) { int r=KDS_MKDIR(p); (void)r; 
#ifdef _WIN32
 return 0;
#else
 return (r==0 || access(p,F_OK)==0) ? 0 : -1;
#endif
}
int kds_storage_init(void) {
 const char *base=NULL; char parent[PATH_MAX];
#ifdef _WIN32
 base=getenv("APPDATA"); if(!base || !*base) base=getenv("USERPROFILE");
#else
 base=getenv("XDG_DATA_HOME"); if(!base || !*base) { const char *h=getenv("HOME"); if(h && *h) { snprintf(parent,sizeof parent,"%s/.local/share",h); base=parent; } }
#endif
 if(!base || !*base) return -1;
 if(snprintf(parent,sizeof parent,"%s%cKds",base,KDS_SEP)>=(int)sizeof parent) return -1;
 if(make_dir(parent)!=0) return -1;
 if(snprintf(root,sizeof root,"%s%cSD",parent,KDS_SEP)>=(int)sizeof root) return -1;
 if(make_dir(root)!=0) return -1;
 ready=1; return 0;
}
const char *kds_storage_root(void) { return ready ? root : NULL; }
int kds_storage_path(const char *relative,char *out,size_t cap) {
 if(!ready || !relative || !*relative || !out || !cap) return -1;
 if(relative[0]=='/' || relative[0]=='\\' || (strlen(relative)>1 && relative[1]==':')) return -1;
 const char *p=relative;
 while(*p) { while(*p=='/' || *p=='\\') p++; const char *s=p; while(*p && *p!='/' && *p!='\\') p++; size_t n=(size_t)(p-s); if(n==2 && s[0]=='.' && s[1]=='.') return -1; }
 int n=snprintf(out,cap,"%s%c%s",root,KDS_SEP,relative); if(n<0 || (size_t)n>=cap) return -1;
 for(char *q=out;*q;q++) if(*q=='/' || *q=='\\') *q=KDS_SEP;
 return 0;
}
FILE *kds_storage_open(const char *relative,const char *mode) {
 char path[PATH_MAX]; if(!mode || kds_storage_path(relative,path,sizeof path)!=0) return NULL;
 return fopen(path,mode);
}
