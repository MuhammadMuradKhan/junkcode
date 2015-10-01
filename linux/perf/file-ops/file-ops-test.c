/*
 * Copyright (C) 2005, Ingo Molnar
 *
 * file-ops-test.c: check file open/close scalability on SMP systems
 *
 * Compile with: gcc -Wall -O2 -o file-ops-test file-ops-test.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

char filename[100];

#define NR_ITERATIONS 1000000

/*
 * This is the workload we run on each CPU:
 */
static void test_files(void)
{
	int i;

	for (i = 0; i < NR_ITERATIONS; i++)
		close(open(filename, O_RDWR));
}

#define rdtod()						\
({							\
	struct timeval tv;				\
							\
	gettimeofday(&tv, NULL);			\
	tv.tv_sec * 1000000ULL + tv.tv_usec;		\
})

int main(int argc, char **argv)
{
	unsigned long cpus, tasks;
	unsigned long long T0, T1;
	int i, me, parent;

	cpus = system("exit `grep processor /proc/cpuinfo  | wc -l`");
	cpus = WEXITSTATUS(cpus);

	if (argc > 2) {
usage:
		fprintf(stderr,
			"usage: tsc-sync-test <threads>\n");
		exit(-1);
	}
	if (argc == 2) {
		tasks = atol(argv[1]);
		if (!tasks)
			goto usage;
	} else
		tasks = cpus;

	printf("%ld CPUs, running %ld parallel test-tasks.\n", cpus, tasks);

	parent = getpid();
	T0 = rdtod();

	for (i = 1; i < tasks; i++)
		if (!fork())
			break;
	me = getpid();
	sprintf(filename, "./silly-%d", me);

	close(open(filename, O_RDWR|O_CREAT|O_TRUNC));

	test_files();

	unlink(filename);

	if (me == parent) {
		for (i = 1; i < tasks; i++)
			wait(NULL);

		T1 = rdtod();
		printf("time: %Ld usecs\n", T1-T0);
		printf("%.2f usecs/op\n", (double)(T1-T0)/NR_ITERATIONS/tasks);
	}

	return 0;
}
