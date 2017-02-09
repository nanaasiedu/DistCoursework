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
  send_tasks(Processes, Max_messages, Timeout).

send_tasks(Processes, Max_messages, Timeout) ->
  [ P ! {task1, start, Max_messages, Timeout} || P <- Processes ].
  

spawn_processes(N) -> 
   [ spawn(process, start, [Id]) || Id <- lists:seq(1, N) ].
