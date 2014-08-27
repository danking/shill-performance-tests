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

#define PERM_COUNT 15
#define CAP_COUNT 50

int main(int argc, char ** argv) {
  int err;
  int fds[];
  char * path, * dir;
  struct timeval timeval_start, timeval_end;
  int time_start, time_end;
  int i, j;
  cpuset_t myset;
  struct shill_cap cap_to_install[CAP_COUNT];
  int perms[PERM_COUNT] =
    { C_CONTENT , C_ADDLNK , C_MAKELNK , C_UNLINKFILE , C_UNLINKDIR
    , C_READ , C_WRITE , C_APPEND , C_CHMODE , C_CHOWN , C_CHFLAGS
    , C_CHTIMES , C_STAT , C_READLINK , C_ADDSYMLNK
    };


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

  if (argc != 2) {
    printf("r accepts exactly one argument, a path\n");
    exit(1);
  }

  dir = argv[1];
  for (i = 0; i < CAP_COUNT; ++i) {
    char * path = NULL;
    err = asprintf(&path, "%s/file-%d", dir, i);
    if (err == -1) {
      printf("failed to asprintf\n");
      printf("  real error num %d\n", errno);
      perror("  asprintf");
      exit(1);
    }

    fds[i] = open(path, O_CREAT);
    if (fds[i] == -1) {
      printf("failed to open %s\n", path);
      printf("  real error num %d\n", errno);
      perror("  open");
      exit(1);
    }
    free(path);

    cap_to_install[i].sc_flags = 0;
    cap_to_install[i].sc_lookup = NULL;
    cap_to_install[i].sc_createfile = NULL;
    cap_to_install[i].sc_createdir = NULL;

    for (j = 0; j < PERM_COUNT; ++j) {
      if (j & i) {
        cap_to_install[i].sc_flags |= perms[j];
      }
    }
  }

  gettimeofday(&timeval_start,NULL);
  /****************************************************************************/
  /* Let The Games Begin! */

  if (0 != (err = shill_init()))
    exit(err);

  for (i = 0; i < CAP_COUNT; ++i) {
    err = shill_grant(fds[i], &(cap_to_install[i]));
    if (0 != err) {
      printf("failed to grant cap on %s\n", path);
      printf("  real error num %d\n", errno);
      perror("  shill_grant");
      exit(1);
      exit(err);
    }
  }

  /* Let The Games End! */
  /****************************************************************************/
  gettimeofday(&timeval_end,NULL);
  time_start = timeval_start.tv_sec * 1000000 + timeval_start.tv_usec;
  time_end = timeval_end.tv_sec * 1000000 + timeval_end.tv_usec;

  printf("%d\n", (time_end - time_start));

  err = close(fd);
  if (err == -1) {
    printf("failed to close the file descriptor\n");
    printf("  real error num %d\n", errno);
    perror("  close");
    exit(1);
  }

  return 0;
}
