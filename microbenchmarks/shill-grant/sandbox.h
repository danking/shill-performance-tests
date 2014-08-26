#ifndef SANDBOX_H
#define SANDBOX_H

#include <fcntl.h>
#include <stdio.h>
#include <stddef.h>
#include <unistd.h>
#include "sandbox.h"
#include "cflags.h"

struct shill_cap {
  uint32_t sc_flags;
  struct shill_cap *sc_lookup;
  struct shill_cap *sc_createfile;
  struct shill_cap *sc_createdir;
};

int shill_grant(int fd, struct shill_cap *cap);
int shill_init(void);
int shill_enter(void);
int shill_debug(void);
int shill_sandbox(int execfd, int stdin, int stdout, int stderr,
		  int capfds[], struct shill_cap *caps[], int lim,
                  rlim_t timeout, int debug, char *const argv[],
                  uint64_t *netcaps, int netcapcount);

#endif /* SANDBOX_H */
