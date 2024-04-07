GO := go

BINARY_NAME := updater

SRC := $(wildcard *.go)

ifeq ($(OS),Windows_NT)
    BINARY_NAME := $(BINARY_NAME).exe
else
    BINARY_NAME := $(BINARY_NAME).sh
endif

all: linux windows

linux: $(SRC)
	$(GO) build -o $(BINARY_NAME)

windows: $(SRC)
	$(GO) build -o $(BINARY_NAME)

clean:
	rm -f $(BINARY_NAME)