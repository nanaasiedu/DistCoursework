% Nana Asiedu-Ampem (na1814)
-module(system2345).

-export([start/0, start/1]).

start() ->
  % Default values
  start(['5', '1000', '3000', processPl, '100']).

start(CmdArgs) ->
  Args = CmdArgs ++ ['100'],
  N            = erlUtil:atom_to_int(hd(Args)),
  Max_messages = erlUtil:atom_to_int(lists:nth(2, Args)),
  Timeout      = erlUtil:atom_to_int(lists:nth(3, Args)),
  ProcessModule= lists:nth(4, Args),
  Reliability  = erlUtil:atom_to_int(lists:nth(5, Args)),

  spawn_processes(N, ProcessModule, Reliability),
  Pl_map = generate_pl_map(N),

  Pl_map_list = maps:to_list(Pl_map),
  [ Pl_pid ! {bind_address_map, Pl_map} || {_, Pl_pid} <- Pl_map_list, Pl_pid /= self() ],

  send_tasks(Pl_map_list, N, Max_messages, Timeout),

  SystemShutDownTimeOut = Timeout + 10000,
  timer:send_after(SystemShutDownTimeOut, timeup),
  wait_on_tasks(N).

send_tasks(Pl_map_list, N, Max_messages, Timeout) ->
  TaskRequest = {task1, start, N, Max_messages, Timeout},
  [ Pl_pid ! {pl_deliver, 0, TaskRequest} || {_, Pl_pid} <- Pl_map_list, Pl_pid /= self() ].

spawn_processes(N, ProcessModule, Reliability) ->
  Args =
  case ProcessModule of
    processPl       -> [self()];
    processBeb      -> [self(), N];
    processBebLossy -> [self(), N, Reliability];
    processBebFaulty-> [self(), N, Reliability];
    processRbFaulty -> [self(), N, Reliability];
    _               -> []
  end,
  [ spawn(ProcessModule, start, [Id] ++ Args) || Id <- lists:seq(1, N) ].

wait_on_tasks(0) -> halt();

wait_on_tasks(N) ->
  receive
    {pl_deliver, _, end_task} -> wait_on_tasks(N-1);
    timeup -> io:format("System timeout: ~p process have not exited sucessfully", [N]),
              halt()
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
