BINS := $(wildcard cmd/*)
OUT := $(BINS:cmd/%=bin/%)

ARCH := $(shell echo $CRAFT_ARCH_BUILD_FOR)
# ifeq ($(ARCH),)
	# ARCH := "amd64"
# endif

all: $(OUT)

bin/%: cmd/%/main.go
	GOARCH=$(ARCH) CGO_ENABLED=0 go build -o $@ ./$<

clean:
	rm -rf bin/*

