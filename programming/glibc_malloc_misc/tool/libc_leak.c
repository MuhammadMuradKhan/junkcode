/* Usage:
 * gcc libc_leak.c -pthread 
 * (ulimit -v 512000 -d 512000; ./a.out)
 * 
 * Starts NTHR threads, allocates 1MB in each, waits
 * till all NTHR have allocated, then frees everything.
 * At program exit Vm* is printed from /proc/self/status
 *
 * This shouldn't use more than NTHR*(1MB + stacksize) memory.
 * With 8 threads, 512MB should be plenty, yet it is exceeded!
 *
 * There are 3 issues here:
 *  - excessive memory usage for the per thread heaps
 *  - the per thread heaps are not freed when threads are joined
 *  - malloc_stats() doesn't seem to be aware of the per thread heaps: it says that only ~7MB was allocated, yet VmSize is >400MB 
 */   
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define NTHR 8

static void print(void)
{
  char line[1024];
  FILE *f = fopen("/proc/self/status","r");
  if (!f)
	return;
  while (fgets(line, sizeof(line),f)) {
     if (!strncmp(line, "Vm", 2))
	fputs(line, stdout);
  }
   
  fclose(f);
}

static pthread_barrier_t barrier;
static void *thread(void *arg)
{
  char *x = malloc(1*1024*1024);
  if (!x) {
       perror("malloc failed");
       malloc_stats();
       pthread_barrier_wait(&barrier);
       return NULL;
  }
  pthread_barrier_wait(&barrier);
  *x = 5; 
  free(x);  
  return NULL;
}

int main(void)
{
   unsigned i;
   pthread_t t[NTHR];
   if (pthread_barrier_init(&barrier, NULL, NTHR)) {
      printf("pthread_barrier_init failed\n");
      abort();
   }
 
   for (i=0;i<NTHR;i++) {
	   if (pthread_create(&t[i], NULL, thread, NULL)) {
      		printf("pthread_create failed!\n");
		abort();
	   }
   }
   for (i=0;i<NTHR;i++) {
	pthread_join(t[i], NULL);
   }
   pthread_barrier_destroy(&barrier);
   puts("/proc/self/status at exit\n");
   print();

  return 0;
}
