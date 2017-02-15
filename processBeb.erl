% Nana Asiedu-Ampem (na1814)
-module(processBeb).
-export([start/3, start_app/2, broadcast/2]).

start(Id, System_pid, N) ->
  Pl_pid  = spawn(plComponent, start, [Id]),
  Beb_pid = spawn(bebComponent, start, [N]),
  App_pid = spawn(processBeb, start_app, [Id, Beb_pid]),
  Beb_pid ! {bind_owner, App_pid, Pl_pid},
  Pl_pid ! {bind_owner, Beb_pid},
  System_pid ! {deliver_pl_component, Id, Pl_pid}.

start_app(Id, Beb_pid) ->
  receive
    {beb_deliver, 0, {task1, start, N, Max_messages, Timeout}} ->
      timer:send_after(Timeout, timeup),
      {ReceivedMap, Sent} = app:task1(Id, Beb_pid, N, Max_messages, processBeb)
  end,
  process:print_result(Id, ReceivedMap, Sent),
  Beb_pid ! {beb_broadcast, end_task},
  exit(normal).

broadcast(Id, Beb_pid) ->
  Beb_pid ! {beb_broadcast, Id}.
