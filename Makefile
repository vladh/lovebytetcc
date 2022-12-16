.POSIX:
.SUFFIXES:

LIBS=-lc -lSDL2 -lEGL
VARS=LD_LIBRARY_PATH=/usr/lib:${LD_LIBRARY_PATH} \
	HAREPATH=vendor/hare-sdl2:${HAREPATH}

04:
	$(VARS) hare build $(LIBS) -o bin/04 04.ha

.PHONY: 04
