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
  Pl_map = generate_pl_map(N),
   
  Pl_map_list = maps:to_list(Pl_map),
  lists:foreach(fun({_, Pl_pid}) -> Pl_pid ! {bind_address_map, Pl_map} end, Pl_map_list),

  send_tasks(Processes, Max_messages, Timeout),
  wait_on_tasks(N).

send_tasks(Processes, Max_messages, Timeout) ->
  [ P ! {task1, start, Max_messages, Timeout} || P <- Processes ].
  
spawn_processes(N) -> 
   [ begin
       {P, _} = spawn_monitor(process, start, [Id, self()]),
       P
     end || Id <- lists:seq(1, N) ].

wait_on_tasks(0) -> halt();

wait_on_tasks(N) -> 
  receive 
    {'DOWN',_,_,_,_} -> wait_on_tasks(N-1)
  end.

generate_pl_map(N) ->
  generate_pl_map(N, maps:new()).

generate_pl_map(0, Pl_map) ->
  Pl_map.

generate_pl_map(N, Pl_map) -> 
  receive
    {deliver_pl_component, PN, Pl_pid} -> 
      New_map = maps:put(PN, Pl_pid, Pl_Map),
      generate_pl_map(N, New_map)
  end.
