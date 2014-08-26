HEADERS=sandbox.h

LIBS=-L../../../shill/rt/ -l shillrt

CFLAGS+=-I../../../shill/include -I../../../shill/kmod -Wall -Werror

default:
	cc -O0 $(LIBS) $(CFLAGS) shill-grant.c $(HEADERS) -o shill-grant
	cc -O0 $(LIBS) $(CFLAGS) shill-no-grant.c $(HEADERS) -o shill-no-grant
