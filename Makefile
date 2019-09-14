.PHONY: all clean

SRCs := $(shell hx-srcs.sh)
GENs := $(shell hx-files.sh $(SRCs))
LLs := $(filter %.ll,$(GENs))

all: .hx-run
	@make -f Makefile.build all

.hx-run: $(SRCs)
	@echo HX
	@hx
	@date >$@

enigma.ll: hx-run

%.list: %.hex
	@make -f Makefile.build $@

clean:
	@echo RM
	@rm -f .hx-run $(GENs)
	@make -f Makefile.build clean
