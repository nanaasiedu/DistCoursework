% Nana Asiedu-Ampem (na1814)
-module(processPl).
-export([start/2, start_app/3, broadcast/3]).

start(Id, System_pid) ->
  Pl_pid  = spawn(plComponent, start, [Id]),
  App_pid = spawn(processPl, start_app, [Id, Pl_pid, processPl]),
  Pl_pid     ! {bind_owner, App_pid},
  System_pid ! {deliver_pl_component, Id, Pl_pid}.

start_app(Id, Pl_pid, ProcessModule) ->
  receive
    {pl_deliver, 0, {task1, start, N, Max_messages, Timeout}} ->
      timer:send_after(Timeout, timeup),
      {ReceivedMap, Sent} = app:task1(Id, Pl_pid, N, Max_messages, ProcessModule)
  end,
  process:print_result(Id, ReceivedMap, Sent),
  Pl_pid ! {pl_send, 0, end_task},
  exit(normal).

broadcast(Id, Pl_pid, N) ->
  [ Pl_pid ! {pl_send, PN, Id} || PN <- lists:seq(1, N)].
