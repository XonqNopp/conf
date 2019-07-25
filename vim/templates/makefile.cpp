OS = $(shell (uname | cut -b 1-6 ))

ifeq ($(OS),Darwin)
ECHO = echo -e
OPEN = open
CXX = /usr/bin/i686-apple-darwin8-g++-4.0.1
else
ECHO = /bin/echo -e
OPEN = acroread
CXX = g++
endif

.PHONY: all clean

#&%: #&%.o
	@${ECHO} "Building $@...\c"
	@${CXX} -o $@ $^
	@${ECHO} "..   Done!"

%.o: %.cpp
	@${ECHO} "Compiling $@...\c"
	@${CXX} -c -o $@ $<
	@${ECHO} "..   Done!"


