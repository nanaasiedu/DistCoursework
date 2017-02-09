
# distributed algorithms, n.dulay, 4 jan 17
# simple build and run makefile, v1

.SUFFIXES: .erl .beam

MODULES  = system1 process erlUtil
N = 5
Max_messages = 1000
Timeout = 3000

# BUILD =======================================================

ERLC	= erlc -o ebin

ebin/%.beam: %.erl
	$(ERLC) $<

all:	ebin ${MODULES:%=ebin/%.beam} 

ebin:	
	mkdir ebin

debug:
	erl -s crashdump_viewer start 

.PHONY: clean
clean:
	rm -f ebin/* erl_crash.dump

# Run1 ===================================================

SYSTEM    = system1

#L_HOST    = localhost.localdomain
L_ERL     = erl -noshell -pa ebin -setcookie pass

run1:   all
	clear; $(L_ERL) -s $(SYSTEM) start $(N) $(Max_messages) $(Timeout)

