prefix ?= /usr/local
bindir = $(prefix)/bin
SYS := $(shell uname)

build:
	ifeq ($(SYS), Linux)
		swift build -c release
	else
		swift build -c release --disable-sandbox
	endif
install: build
	install ".build/release/rext" "$(bindir)"
uninstall:
	rm -rf "$(bindir)/rext"
clean:
	rm -rf .build