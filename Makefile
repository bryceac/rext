prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox
install: build
	install ".build/release/rext" "$(bindir)"
uninstall:
	rm -rf "$(bindir)/rext"
clean:
	rm -rf .build