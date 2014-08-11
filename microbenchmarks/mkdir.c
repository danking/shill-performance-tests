#include <sys/types.h> /* read */
#include <sys/uio.h>   /* read */
#include <unistd.h>    /* read */
#include <fcntl.h>     /* open */
#include <stdio.h>     /* printf, sscanf */
#include <stdlib.h>    /* exit */
#include <errno.h>     /* errno */
#include <errno.h>     /* errno */
#include <sys/time.h>  /* gettimeofday, struct timeval */

#define REPETITIONS 100

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
    fd = open(path, O_CREAT | O_EXCL);

    err = unlink(path);
    if (err == -1) {
      printf("failed to unlink the path %s\n", path);
      printf("  real error num %d\n", errno);
      perror("  unlink");
    }
  }

  /* END TIMED */
  /****************************************************************************/

  gettimeofday(&time_now,NULL);
  time_end = time_now.tv_sec * 1000000 + time_now.tv_usec;

  printf("%d\n", (time_end - time_start)/((float)REPETITIONS));

  if (fd == -1) {
    printf("failed to create (i.e. open) %s\n", path);
    printf("  real error num %d\n", errno);
    perror("  open");
  }

  err = close(fd);
  if (err == -1) {
    printf("failed to close the file descriptor\n");
    printf("  real error num %d\n", errno);
    perror("  close");
  }

  return 0;
}
