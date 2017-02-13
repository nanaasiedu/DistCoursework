% Nana asiedu (na1814)
-module(processBebLossy).
-export([start/4, start_app/2]).

start(Id, System_pid, N, Reliability) ->
  Pl_pid  = spawn(lossyPlComponent, start, [Reliability]),
  Beb_pid = spawn(bebComponent, start, [N]),
  App_pid = spawn(processBebLossy, start_app, [Id, Beb_pid]),
  Beb_pid ! {bind_owner, App_pid, Pl_pid},
  Pl_pid ! {bind_owner, Beb_pid},
  System_pid ! {deliver_pl_component, Id, Pl_pid}.

start_app(Id, Beb_pid) ->
  receive
    {beb_deliver, {task1, start, N, Max_messages, Timeout}} ->
      timer:send_after(Timeout, timeup),
      {ReceivedMap, Sent} = task1(Id, Beb_pid, N, Max_messages)
  end,
  print_result(Id, ReceivedMap, Sent),
  Beb_pid ! {beb_broadcast, end_task},
  exit(normal).

task1(Id, Beb_pid, N, Max_messages) ->
  % Mapping from process Ids to the number of messages received from process
  ReceivedMap = maps:from_list([{CurrId, 0} || CurrId <- lists:seq(1, N)]),
  task1(Id, Beb_pid, N, Max_messages, ReceivedMap, 0).

task1(Id, Beb_pid, N, Max_messages, ReceivedMap, Sent) ->
  receive
    timeup               -> {ReceivedMap, Sent}

  after 0 ->
    receive
      {beb_deliver, SenderP} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                               task1(Id, Beb_pid, N, Max_messages, NewReceivedMap, Sent);

      broadcast             -> if
                                 (Sent < Max_messages) or (Max_messages == 0) ->
                                   broadcast(Id, Beb_pid),
                                   NewSent = Sent + 1,
                                   if (NewSent < Max_messages) or (Max_messages == 0) ->
                                     self() ! broadcast; true -> nothing
                                   end,
                                   task1(Id, Beb_pid, N, Max_messages, ReceivedMap, NewSent);
                                 true ->
                                   task1(Id, Beb_pid, N, Max_messages, ReceivedMap, Sent)
                               end
    after 0 ->
      self() ! broadcast,
      task1(Id, Beb_pid, N, Max_messages, ReceivedMap, Sent)
    end
  end.

broadcast(Id, Beb_pid) ->
  Beb_pid ! {beb_broadcast, Id}.

print_result(Id, ReceivedMap, Sent) ->
  Received_list = [ {Sent, Received} || {_, Received} <- maps:to_list(ReceivedMap)],
  io:format("~p: ~p~n", [Id, Received_list]).