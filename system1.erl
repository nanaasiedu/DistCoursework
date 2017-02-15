% Nana Asiedu-Ampem (na1814)
-module(system1).

-export([start/0, start/1]).

start() ->
  % Default values
  start(['5', '1000', '3000']).

start(Args) ->
  N            = erlUtil:atom_to_int(hd(Args)),
  Max_messages = erlUtil:atom_to_int(lists:nth(2, Args)),
  Timeout      = erlUtil:atom_to_int(lists:nth(3, Args)),

  Processes = spawn_processes(N),
  [ P ! {bindProcesses, Processes} || P <- Processes ],
  send_tasks(Processes, Max_messages, Timeout),
  wait_on_tasks(N).

send_tasks(Processes, Max_messages, Timeout) ->
  [ P ! {task1, start, Max_messages, Timeout} || P <- Processes ].

spawn_processes(N) ->
   [ begin
       {P, _} = spawn_monitor(process, start, [Id]),
       P
     end || Id <- lists:seq(1, N) ].

wait_on_tasks(0) -> halt();

wait_on_tasks(N) ->
  receive
    {'DOWN',_,_,_,_} -> wait_on_tasks(N-1)
  end.
