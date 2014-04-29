#include <stdio.h>
#include <sys/time.h>
int main(void)
{
  struct timeval time_now;
    gettimeofday(&time_now,NULL);
    printf ("before_everything %ld usecs\n",time_now.tv_sec * 1000000 + time_now.tv_usec);

    return 0;
}

