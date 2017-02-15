% Nana Asiedu-Ampem (na1814)
-module(processRbFaulty).
-export([start/4, start_app/2]).

start(Id, System_pid, N, Reliability) ->
  Pl_pid  = spawn(plComponent, start, [Id, Reliability]),
  Beb_pid = spawn(bebComponent, start, [N]),
  Rb_pid  = spawn(rbComponent, start, []),
  App_pid = spawn(processRbFaulty, start_app, [Id, Rb_pid]),
  Rb_pid     ! {bind_owner, App_pid, Beb_pid},
  Beb_pid    ! {bind_owner, Rb_pid, Pl_pid},
  Pl_pid     ! {bind_owner, Beb_pid},
  System_pid ! {deliver_pl_component, Id, Pl_pid}.

start_app(Id, Rb_pid) ->
  receive
    {rb_deliver, 0, {task1, start, N, Max_messages, Timeout}} ->
      if
        Id == 3 ->
          timer:send_after(5, terminate);
        true ->
          ok
      end,
      timer:send_after(Timeout, timeup),
      {ReceivedMap, Sent} = app:task1(Id, Rb_pid, N, Max_messages, processRbFaulty)
  end,
  process:print_result(Id, ReceivedMap, Sent),
  Rb_pid ! {rb_broadcast, end_task},
  exit(normal).

broadcast(Id, Rb_pid) ->
  Rb_pid ! {rb_broadcast, Id} .
