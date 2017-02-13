% Nana Asiedu-Ampem (na1814)
-module(system5).

-export([start/0, start/1]).

start() ->
  % Default values
  start(['5', '1000', '3000', '50']).

start(Args) ->
  N            = erlUtil:atom_to_int(hd(Args)),
  Max_messages = erlUtil:atom_to_int(lists:nth(2, Args)),
  Timeout      = erlUtil:atom_to_int(lists:nth(3, Args)),
  Reliability  = erlUtil:atom_to_int(lists:nth(4, Args)),

  spawn_processes(N, Reliability),
  Pl_map = generate_pl_map(N),

  Pl_map_list = maps:to_list(Pl_map),
  [ Pl_pid ! {bind_address_map, Pl_map} || {_, Pl_pid} <- Pl_map_list, Pl_pid /= self() ],

  send_tasks(Pl_map_list, N, Max_messages, Timeout),
  wait_on_tasks(N).

send_tasks(Pl_map_list, N, Max_messages, Timeout) ->
  TaskRequest = {task1, start, N, Max_messages, Timeout},
  [ Pl_pid ! {pl_deliver, TaskRequest} || {_, Pl_pid} <- Pl_map_list, Pl_pid /= self() ].

spawn_processes(N, Reliability) ->
   [ spawn(processBebFaulty, start, [Id, self(), N, Reliability]) || Id <- lists:seq(1, N) ].

wait_on_tasks(0) -> halt();

wait_on_tasks(N) -> 
  receive
    {pl_deliver, end_task} -> wait_on_tasks(N-1)
  end.

generate_pl_map(N) ->
  generate_pl_map(N, maps:new()).

generate_pl_map(0, Pl_map) ->
  maps:put(0, self(), Pl_map);

generate_pl_map(N, Pl_map) ->
  receive
    {deliver_pl_component, PN, Pl_pid} ->
      New_map = maps:put(PN, Pl_pid, Pl_map),
      generate_pl_map(N-1, New_map)
  end.
