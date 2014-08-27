#include <sys/types.h> /* read */
#include <sys/uio.h>   /* read */
#include <unistd.h>    /* read */
#include <fcntl.h>     /* open */
#include <stdio.h>     /* printf, sscanf */
#include <stdlib.h>    /* exit */
#include <errno.h>     /* errno */
#include <errno.h>     /* errno */
#include <sys/time.h>  /* gettimeofday, struct timeval */

#include <err.h>
#include <sys/param.h>
#include <sys/cpuset.h>

int main(int argc, char *argv[]) {
  int err, err2;
  int fd;
  int bytes;
  int iters;
  char * path;
  char * buf;
  struct timespec time_start_spec, time_end_spec;
  long time_start, time_end;
  int i;

  if (argc != 4) {
    printf("orc accepts exactly three arguments, a byte count, a path, and an iteration count\n");
    exit(1);
  }

  err = sscanf(argv[1], "%d", &bytes);
  if (err != 1) {
    printf("failed to read number of bytes, given %s\n", argv[1]);
    printf("  real error num %d\n", errno);
    perror("  sscanf");
    exit(1);
  }

  path = argv[2];

  err = sscanf(argv[3], "%d", &iters);
  if (err != 1) {
    printf("failed to read number of iterations, given %s\n", argv[3]);
    printf("  real error num %d\n", errno);
    perror("  sscanf");
    exit(1);
  }

  buf = malloc(bytes);
  if (buf == NULL) {
    printf("failed to malloc %d bytes\n", bytes);
    printf("  real error num %d\n", errno);
    perror("  malloc");
    exit(1);
  }

  /****************************************************************************/
  /* And There Was One CPU */

  /* Get CPU mask for the current thread */
  if (cpuset_getaffinity( CPU_LEVEL_WHICH
                        , CPU_WHICH_TID
                        , -1
                        , sizeof(myset)
                        , &myset
                        )
      == -1) {
    printf("getaffinity failed");
    exit(1);
  }

  /* Find first available CPU - don't assume CPU0 is always available */
  for (i = 0; i < CPU_SETSIZE; i++) {
    if (CPU_ISSET(i, &myset)) {
      break;
    }
  }

  if (i == CPU_SETSIZE) {
    printf("Not allowed to run on any CPUs?  How did I print this, then?");
    exit(1);
  }

  /* Set new CPU mask */
  CPU_ZERO(&myset);
  CPU_SET(i, &myset);

  if (cpuset_setaffinity( CPU_LEVEL_WHICH
                        , CPU_WHICH_TID
                        , -1
                        , sizeof(myset)
                        , &myset
                        )
      == -1) {
    warn("setaffinity failed");
  }

  /* And There Was One CPU */
  /****************************************************************************/

  for (i = 1; i < iters; ++i) {
    clock_gettime(CLOCK_MONOTONIC_PRECISE, &time_start_spec);

    fd = open(path, O_RDONLY);
    err = pread(fd, (void*)buf, bytes, 0);
    err2 = close(fd);

    clock_gettime(CLOCK_MONOTONIC_PRECISE, &time_end_spec);
    time_start = time_start_spec.tv_sec * 1000000000 + time_start_spec.tv_nsec;
    time_end = time_end_spec.tv_sec * 1000000000 + time_end_spec.tv_nsec;
    printf("%ld\n", time_end - time_start);
    if (i % (iters / 100) == 0)
      fprintf(stderr, ".");

    if (fd == -1) {
      printf("failed to open %s\n", path);
      printf("  real error num %d\n", errno);
      perror("  open");
      exit(1);
    }

    if (err == -1) {
      printf("failed to read %d bytes\n", bytes);
      printf("  real error num %d\n", errno);
      perror("  read");
      exit(1);
    }

    if (err2 == -1) {
      printf("failed to close the file descriptor\n");
      printf("  real error num %d\n", errno);
      perror("  close");
      exit(1);
    }
  }

  /* END TIMED */
  /****************************************************************************/

  return 0;
}
