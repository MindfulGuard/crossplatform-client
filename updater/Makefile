GO := go

BINARY_NAME := updater

SRC := $(wildcard *.go)

ifeq ($(OS),Windows_NT)
    BINARY_NAME := $(BINARY_NAME).exe
    LD_FLAGS := -H windowsgui
else
    BINARY_NAME := $(BINARY_NAME).sh
    LD_FLAGS := -s -w
endif

all: linux windows

linux: $(SRC)
	$(GO) build -ldflags="$(LD_FLAGS)" -o $(BINARY_NAME)

windows: $(SRC)
	$(GO) build -ldflags="$(LD_FLAGS)" -o $(BINARY_NAME)

clean:
	rm -f $(BINARY_NAME)