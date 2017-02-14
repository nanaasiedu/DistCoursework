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
      {ReceivedMap, Sent} = task1(Id, Rb_pid, N, Max_messages)
  end,
  process:print_result(Id, ReceivedMap, Sent),
  Rb_pid ! {rb_broadcast, end_task},
  exit(normal).

  task1(Id, Rb_pid, N, Max_messages) ->
    % Mapping from process Ids to the number of messages received from process
    ReceivedMap = maps:from_list([{CurrId, 0} || CurrId <- lists:seq(1, N)]),
    task1(Id, Rb_pid, N, Max_messages, ReceivedMap, 0).

  task1(Id, Rb_pid, N, Max_messages, ReceivedMap, Sent) ->
    receive
      timeup                   -> {ReceivedMap, Sent};
      terminate                -> exit(normal)

    after 0 ->
      receive
        {rb_deliver, SenderP, _} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                                    task1(Id, Rb_pid, N, Max_messages, NewReceivedMap, Sent);

        broadcast             -> if
                                   (Sent < Max_messages) or (Max_messages == 0) ->
                                     broadcast(Id, Rb_pid),
                                     NewSent = Sent + 1,
                                     if (NewSent < Max_messages) or (Max_messages == 0) ->
                                       self() ! broadcast; true -> nothing
                                     end,
                                     task1(Id, Rb_pid, N, Max_messages, ReceivedMap, NewSent);
                                   true ->
                                     task1(Id, Rb_pid, N, Max_messages, ReceivedMap, Sent)
                                 end
      after 0 ->
        self() ! broadcast,
        task1(Id, Rb_pid, N, Max_messages, ReceivedMap, Sent)
      end
    end.

  broadcast(Id, Rb_pid) ->
    Rb_pid ! {rb_broadcast, Id} .
