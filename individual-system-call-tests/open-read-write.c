#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>

#define CONTAINING_DIRECTORY "./" 

int main(int argc, char** argv) {
  struct timeval start, end;
  long open_time, read_time, write_time, secs, usecs;

  gettimeofday(&start, NULL);
  int f = open(CONTAINING_DIRECTORY "test-file", O_WRONLY);
  gettimeofday(&end, NULL);
  secs  = end.tv_sec  - start.tv_sec;
  usecs = end.tv_usec - start.tv_usec;
  open_time = (secs * 1000000 + usecs);
  if (f == -1) {
    perror("open");
    return errno;
  }

  char s[11] = "hello world";
  int length = 11;
  int err = 0;

  gettimeofday(&start, NULL);
  err = write(f, &s, sizeof(char) * length);
  gettimeofday(&end, NULL);
  secs  = end.tv_sec  - start.tv_sec;
  usecs = end.tv_usec - start.tv_usec;
  write_time = (secs * 1000000 + usecs);
  if (err != length) {
    perror("write");
    return errno;
  }

  close(f);
  f = open(CONTAINING_DIRECTORY "test-file", O_RDONLY);
  if (f == -1) {
    perror("open");
    return errno;
  }

  char buf[length];

  gettimeofday(&start, NULL);
  err = read(f, &buf, sizeof(char) * length);
  gettimeofday(&end, NULL);
  secs  = end.tv_sec  - start.tv_sec;
  usecs = end.tv_usec - start.tv_usec;
  read_time = (secs * 1000000 + usecs);
  if (err != length) {
    perror("read");
    return errno;
  }

  close(f);

  printf("%ld %ld %ld\n", open_time, read_time, write_time);

  return 0;
}
