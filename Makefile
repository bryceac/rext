prefix ?= /usr/local
bindir = $(prefix)/bin
SYS := $(shell $(CC) -dumpmachine)
SWIFT_FLAGS =

ifneq (, $(findstring linux, $(SYS)))
SWIFT_FLAGS = -c release
else
SWIFT_FLAGS = -c release --disable-sandbox
endif

build:
	swift build $(SWIFT_FLAGS)
install:
	install ".build/release/rext" "$(bindir)"
uninstall:
	rm -rf "$(bindir)/rext"
clean:
	swift build --clean