#include <sys/types.h> /* read */
#include <sys/uio.h>   /* read */
#include <unistd.h>    /* read */
#include <fcntl.h>     /* open */
#include <stdio.h>     /* printf, sscanf */
#include <stdlib.h>    /* exit */
#include <errno.h>     /* errno */
#include <errno.h>     /* errno */
#include <sys/time.h>  /* gettimeofday, struct timeval */

#define REPETITIONS 10000

int main(int argc, char *argv[]) {
  int err;
  int fd;
  char * path;
  char * buf;
  struct timeval time_now;
  int time_start, time_end;
  int i;

  if (argc != 2) {
    printf("mkdir accepts exactly one argument, a path\n");
    exit(1);
  }

  path = argv[1];

  gettimeofday(&time_now,NULL);
  time_start = time_now.tv_sec * 1000000 + time_now.tv_usec;

  /****************************************************************************/
  /* BEGIN TIMED */

  for (i=0; i<REPETITIONS; ++i) {
    err = mkdir(path, 0777);
    if (err == -1) {
      printf("failed to create the directory %s\n", path);
      printf("  real error num %d\n", errno);
      perror("  mkdir");
      exit(1);
    }

    err = rmdir(path);
    if (err == -1) {
      printf("failed to rmdir the path %s\n", path);
      printf("  real error num %d\n", errno);
      perror("  rmdir");
      exit(1);
    }
  }

  /* END TIMED */
  /****************************************************************************/

  gettimeofday(&time_now,NULL);
  time_end = time_now.tv_sec * 1000000 + time_now.tv_usec;

  printf("%f\n", (time_end - time_start)/((float)REPETITIONS));

  return 0;
}
