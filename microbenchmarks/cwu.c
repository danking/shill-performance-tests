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
  int bytes;
  char * path;
  char * buf;
  struct timeval time_now;
  int time_start, time_end;
  int i;

  if (argc != 3) {
    printf("cwu accepts exactly two arguments, a byte count and a path\n");
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

  buf = malloc(bytes);
  if (buf == NULL) {
    printf("failed to malloc %d bytes\n", bytes);
    printf("  real error num %d\n", errno);
    perror("  malloc");
    exit(1);
  }

  gettimeofday(&time_now,NULL);
  time_start = time_now.tv_sec * 1000000 + time_now.tv_usec;

  /****************************************************************************/
  /* BEGIN TIMED */

  for (i=0; i<REPETITIONS; ++i) {

    fd = open(path, O_WRONLY | O_CREAT);
    if (fd == -1) {
      printf("failed to open (create) %s\n", path);
      printf("  real error num %d\n", errno);
      perror("  open");
      exit(1);
    }

    err = pwrite(fd, (void*)buf, bytes, 0);
    if (err == -1) {
      printf("failed to write %d bytes\n", bytes);
      printf("  real error num %d\n", errno);
      perror("  write");
      exit(1);
    }

    err = unlink(path);
    if (err == -1) {
      printf("failed to unlink the path %s\n", path);
      printf("  real error num %d\n", errno);
      perror("  unlink");
      exit(1);
    }

    err = close(fd);
    if (err == -1) {
      printf("failed to close the file descriptor\n");
      printf("  real error num %d\n", errno);
      perror("  close");
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
