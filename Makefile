TARGET := xen.pdf
LATEX  := pdflatex -halt-on-error -interaction nonstopmode
VIEW   := evince

MAKEFLAGS += -rR --no-print-directory

V ?= 1

ifeq ($(V),1)
  define cmd-print
    @echo '$1'
  endef
endif

ifneq ($(V),0)
  Q := @
endif


default: all

all: $(TARGET)

view : $(TARGET)
	$(call cmd-print,  VIEW    $<)
	$(Q)$(VIEW) $<


start-daemon: $(TARGET)
	$(call cmd-print,  SDAEMON $<)
	$(Q)$(VIEW) $< & echo $$! > .daemon
	$(Q)while [ -e .daemon ]; do $(MAKE) all | tail -n +2; sleep 1; done &

stop-daemon:
	$(call cmd-print,  KDAEMON)
	$(Q)kill `cat .daemon`
	$(Q)rm .daemon
	$(Q)$(MAKE) clean


$(TARGET): $(shell find . -name "[!.]*.tex")
	$(call cmd-print,  LATEX   $@)
	$(Q)$(LATEX) main.tex | grep -A 50 -e '!' && false || true
	$(Q)$(LATEX) main.tex | grep -A 50 -e '!' || true
	$(Q)cp main.pdf $@

clean:
	$(call cmd-print,  CLEAN)
	$(Q)rm $(TARGET) main.pdf 2>/dev/null || true
	$(Q)rm *.aux *.log *.out 2>/dev/null || true
	$(Q)find . -name "*~" -exec rm {} \; || true
