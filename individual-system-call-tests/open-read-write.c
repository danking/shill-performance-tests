#include <errno.h>
#include <stdio.h>
#include <sys/time.h>
#include <unistd.h>

#define CONTAINING_DIRECTORY "/usr/home/danking/tests/individual-system-call-tests/"

int main(int argc, char** argv) {
  struct timeval start, end;
  long fopen_time, fread_time, fwrite_time, secs, usecs;

  gettimeofday(&start, NULL);
  FILE * f = fopen(CONTAINING_DIRECTORY "test-file", "w");
  gettimeofday(&end, NULL);
  secs  = end.tv_sec  - start.tv_sec;
  usecs = end.tv_usec - start.tv_usec;
  fopen_time = (secs * 1000000 + usecs);
  if (f == NULL) {
    perror("fopen");
    return errno;
  }

  char s[11] = "hello world";
  int length = 11;
  int err = 0;

  gettimeofday(&start, NULL);
  err = fwrite(&s, sizeof(char), length, f);
  gettimeofday(&end, NULL);
  secs  = end.tv_sec  - start.tv_sec;
  usecs = end.tv_usec - start.tv_usec;
  fwrite_time = (secs * 1000000 + usecs);
  if (err != length) {
    perror("fwrite");
    return errno;
  }

  fclose(f);
  f = fopen(CONTAINING_DIRECTORY "test-file", "r");

  char buf[length];

  gettimeofday(&start, NULL);
  err = fread(&buf, sizeof(char), length, f);
  gettimeofday(&end, NULL);
  secs  = end.tv_sec  - start.tv_sec;
  usecs = end.tv_usec - start.tv_usec;
  fread_time = (secs * 1000000 + usecs);
  if (err != length) {
    perror("fread");
    return errno;
  }

  fclose(f);

  printf("fopen: %ld\n", fopen_time);
  printf("fread: %ld\n", fread_time);
  printf("fwrite: %ld\n", fwrite_time);

  return 0;
}
