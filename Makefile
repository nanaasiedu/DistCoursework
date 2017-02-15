# Nana Asiedu-Ampem (na1814)
# distributed algorithms, n.dulay, 4 jan 17
# simple build and run makefile, v1

.SUFFIXES: .erl .beam

MODULES  = system1 process erlUtil system23456 processPl plComponent erlUtil bebComponent processBeb lossyPlComponent processBebLossy processBebFaulty processRbFaulty rbComponent
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
	$(L_ERL) -s system23456 start $(N) $(Max_messages) $(Timeout) processPl

run3:   all
	$(L_ERL) -s system23456 start $(N) $(Max_messages) $(Timeout) processBeb

run4:   all
		$(L_ERL) -s system23456 start $(N) $(Max_messages) $(Timeout) processBebLossy $(Reliability)

run5:   all
		$(L_ERL) -s system23456 start $(N) $(Max_messages) $(Timeout) processBebFaulty $(Reliability)

run6:   all
		$(L_ERL) -s system23456 start $(N) $(Max_messages) $(Timeout) processRbFaulty $(Reliability)
