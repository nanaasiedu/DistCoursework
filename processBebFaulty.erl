% Nana Asiedu-Ampem (na1814)
-module(processBebFaulty).
-export([start/4, start_app/2]).

start(Id, System_pid, N, Reliability) ->
  Pl_pid  = spawn(plComponent, start, [Id, Reliability]),
  Beb_pid = spawn(bebComponent, start, [N]),
  App_pid = spawn(processBebFaulty, start_app, [Id, Beb_pid]),
  Beb_pid ! {bind_owner, App_pid, Pl_pid},
  Pl_pid ! {bind_owner, Beb_pid},
  System_pid ! {deliver_pl_component, Id, Pl_pid}.

start_app(Id, Beb_pid) ->
  receive
    {beb_deliver, 0, {task1, start, N, Max_messages, Timeout}} ->
      if
        Id == 3 ->
          timer:send_after(5, terminate);
        true ->
          ok
      end,
      timer:send_after(Timeout, timeup),
      {ReceivedMap, Sent} = processBeb:task1(Id, Beb_pid, N, Max_messages)
  end,
  process:print_result(Id, ReceivedMap, Sent),
  Beb_pid ! {beb_broadcast, end_task},
  exit(normal).
