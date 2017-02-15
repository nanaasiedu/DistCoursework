== NANA ASIEDU-AMPEM'S DISTRIBUTED ALGORITHMS COURSEWORK ==

A Makefile has been included to make it easier to run the systems.
On the command line run "make runN" where N is the number of the system you
want to operate. Default values will be used when running the make file with
no variable assignments.

== Default values ==
N (Number of processes) = 3,
Max_messages            = 10,
Timeout                 = 3000,
Reliability             = 50, (Only relevant for system4 onwards)

On the commad line, variable assignments can be made to test various configurations.
Using "make runN N=3 Timeout=10" you can change the values of N and Timeout.

== Extra notes ==
In the absence of bugs, all runs of any system should eventually halt.
Note system5 and system6 will take longer to halt because of the fact process 3
dies. The system will eventually time out when waiting for confirmation of processes'
ending their tasks (hence all systems will eventually halt)

== Examples ==

make run1 : system1 with default parameters
make run2 N=100 Max_messages=0 : system2
make run4 Reliability=20 : system4 with low reliability
make run5 : system 5
