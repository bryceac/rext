prefix ?= /usr/local
bindir = $(prefix)/bin
SYS := $(shell $(CC) -dumpmachine)
SWIFTC_FLAGS =

ifneq (, $(findstring linux, $(SYS)))
else
SWIFTC_FLAGS = --disable-sandbox
endif

build:
	swift build -c release $(SWIFTC_FLAGS)
install: build
	install ".build/release/rext" "$(bindir)"
uninstall:
	rm -rf "$(bindir)/rext"
clean:
	rm -rf .build