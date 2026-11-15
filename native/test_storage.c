#include "kds_storage.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
int main(void) {
 char path[4096], buf[64]={0};
 assert(kds_storage_init()==0);
 assert(kds_storage_root()!=NULL);
 assert(kds_storage_path("apps/test.txt",path,sizeof path)==0);
 assert(kds_storage_path("../escape",path,sizeof path)!=0);
 assert(kds_storage_path("/absolute",path,sizeof path)!=0);
 FILE *f=kds_storage_open("kds-storage-test.txt","wb"); assert(f); fputs("persistent",f); fclose(f);
 f=kds_storage_open("kds-storage-test.txt","rb"); assert(f); assert(fgets(buf,sizeof buf,f)); fclose(f);
 assert(strcmp(buf,"persistent")==0);
 puts("Kds persistent storage tests: OK"); return 0;
}
