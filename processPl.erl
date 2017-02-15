% Nana Asiedu-Ampem (na1814)
-module(processPl).
-export([start/2, start_app/2]).

start(Id, System_pid) ->
  Pl_pid  = spawn(plComponent, start, [Id]),
  App_pid = spawn(processPl, start_app, [Id, Pl_pid]),
  Pl_pid ! {bind_owner, App_pid},
  System_pid ! {deliver_pl_component, Id, Pl_pid}.

start_app(Id, Pl_pid) ->
  receive
    {pl_deliver, 0, {task1, start, N, Max_messages, Timeout}} ->
      timer:send_after(Timeout, timeup),
      {ReceivedMap, Sent} = task1(Id, Pl_pid, N, Max_messages)
  end,
  process:print_result(Id, ReceivedMap, Sent),
  Pl_pid ! {pl_send, 0, end_task},
  exit(normal).

task1(Id, Pl_pid, N, Max_messages) ->
  % Mapping from process Ids to the number of messages received from process
  ReceivedMap = maps:from_list([{CurrId, 0} || CurrId <- lists:seq(1, N)]),
  task1(Id, Pl_pid, N, Max_messages, ReceivedMap, 0).

task1(Id, Pl_pid, N, Max_messages, ReceivedMap, Sent) ->
  receive
    timeup               -> {ReceivedMap, Sent}

  after 0 ->
    receive
      {pl_deliver, SenderP, _} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                               task1(Id, Pl_pid, N, Max_messages, NewReceivedMap, Sent);

      broadcast             -> if
                                 (Sent < Max_messages) or (Max_messages == 0) ->
                                   broadcast(Id, Pl_pid, N),
                                   NewSent = Sent + 1,
                                   task1(Id, Pl_pid, N, Max_messages, ReceivedMap, NewSent);
                                 true ->
                                   task1(Id, Pl_pid, N, Max_messages, ReceivedMap, Sent)
                               end
    after 0 ->
      if (Sent < Max_messages) or (Max_messages == 0) ->
        self() ! broadcast; true -> nothing
      end,
      task1(Id, Pl_pid, N, Max_messages, ReceivedMap, Sent)
    end
  end.

broadcast(Id, Pl_pid, N) ->
  [ Pl_pid ! {pl_send, PN, Id} || PN <- lists:seq(1, N)].
