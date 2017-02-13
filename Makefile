# Nana Asiedu-Ampem (na1814)
# distributed algorithms, n.dulay, 4 jan 17
# simple build and run makefile, v1

.SUFFIXES: .erl .beam

MODULES  = system1 process erlUtil system2 processPl plComponent erlUtil system3 bebComponent processBeb lossyPlComponent system4 processBebLossy system5 processBebFaulty
N = 5
Max_messages = 1000
Timeout = 3000
Reliability=50

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

#L_HOST   = localhost.localdomain
L_ERL     = erl -noshell -pa ebin -setcookie pass

run1:   all
	$(L_ERL) -s system1 start $(N) $(Max_messages) $(Timeout)

run2:   all
	$(L_ERL) -s system2 start $(N) $(Max_messages) $(Timeout)

run3:   all
	$(L_ERL) -s system3 start $(N) $(Max_messages) $(Timeout)

run4:   all
		$(L_ERL) -s system4 start $(N) $(Max_messages) $(Timeout) $(Reliability)

run5:   all
		$(L_ERL) -s system5 start $(N) $(Max_messages) $(Timeout) $(Reliability)
