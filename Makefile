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
install: build
ifneq (, $(findstring darwin, $(SYS)))
	test ! -d $(bindir) && mkdir -p $(bindir)

	install ".build/release/rext" "$(bindir)/rext"
else
	install -D ".build/release/rext" "$(bindir)/rext"
endif
uninstall:
	rm -rf "$(bindir)/rext"
clean:
	rm -rf .build
.PHONY: build install uninstall clean