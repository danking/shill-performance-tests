#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mac.h>
#include <sys/queue.h> /* for shill.h */
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/module.h>
#include <sys/syscall.h>
#include <sys/wait.h>


/* definitely need */
#include "message.h"
#include "sandbox.h"

#include <fcntl.h>     /* open */
#include <err.h>
#include <stdio.h>
#include <sys/param.h>
#include <sys/cpuset.h>


int main(int argc, char ** argv) {
  int err;
  struct timeval timeval_start, timeval_end;
  int time_start, time_end;
  int i;
  cpuset_t myset;

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
  printf ("Setting affinity to CPU %d\n", i);
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

  if (argc != 2) {
    printf("r accepts exactly one argument, a path\n");
    exit(1);
  }

  gettimeofday(&timeval_start,NULL);
  /****************************************************************************/
  /* Let The Games Begin! */

  if (0 != (err = shill_init()))
    exit(err);

  /* Let The Games End! */
  /****************************************************************************/
  gettimeofday(&timeval_end,NULL);
  time_start = timeval_start.tv_sec * 1000000 + timeval_start.tv_usec;
  time_end = timeval_end.tv_sec * 1000000 + timeval_end.tv_usec;

  printf("%d\n", (time_end - time_start));

  return 0;
}
