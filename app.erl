% Nana Asiedu-Ampem (na1814)
-module(app).
-export([task1/5]).

task1(Id, Proxy, N, Max_messages, ProcessModule) ->
  % Mapping from process Ids to the number of messages received from process
  ReceivedMap = maps:from_list([{CurrId, 0} || CurrId <- lists:seq(1, N)]),
  task1(Id, Proxy, N, Max_messages, ReceivedMap, 0, true, ProcessModule).

task1(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, ProcessModule) ->
  receive
    timeup               -> {ReceivedMap, Sent};
    terminate            -> exit(faulty)

  after 0 ->
    task1_receive(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, ProcessModule)
  end.

task1_receive(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, processPl) ->
  receive
    {pl_deliver, SenderP, _} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                                task1(Id, Proxy, N, Max_messages, NewReceivedMap, Sent, true, processPl)
  after 0 ->
    attempt_broadcast(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, processPl)
  end;

task1_receive(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, processBeb) ->
  receive
    {beb_deliver, SenderP, _} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                                task1(Id, Proxy, N, Max_messages, NewReceivedMap, Sent, true, processBeb)
  after 0 ->
    attempt_broadcast(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, processBeb)
  end;

task1_receive(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, processRbFaulty) ->
  receive
    {rb_deliver, SenderP, _} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                                  task1(Id, Proxy, N, Max_messages, NewReceivedMap, Sent, true, processBeb)
  after 0 ->
    attempt_broadcast(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, processRbFaulty)
  end.

attempt_broadcast(Id, Proxy, N, Max_messages, ReceivedMap, Sent, Allow_broadcast, ProcessModule) ->
  if
    Allow_broadcast and ((Sent < Max_messages) or (Max_messages == 0)) ->

      if ProcessModule == processPl ->
        ProcessModule:broadcast(Id, Proxy, N);
      true ->
        ProcessModule:broadcast(Id, Proxy)
      end,

      NewSent = Sent + 1,
      task1(Id, Proxy, N, Max_messages, ReceivedMap, NewSent, false, ProcessModule);
    true ->
      task1(Id, Proxy, N, Max_messages, ReceivedMap, Sent, false, ProcessModule)
  end.
