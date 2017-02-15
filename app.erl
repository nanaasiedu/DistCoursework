% Nana Asiedu-Ampem (na1814)
-module(app).
-export([task1/5]).

task1(Id, Proxy, N, Max_messages, ProcessModule) ->
  % Mapping from process Ids to the number of messages received from process
  ReceivedMap = maps:from_list([{CurrId, 0} || CurrId <- lists:seq(1, N)]),
  task1(Id, Proxy, N, Max_messages, ReceivedMap, 0, ProcessModule).

task1(Id, Proxy, N, Max_messages, ReceivedMap, Sent, ProcessModule) ->
  receive
    timeup               -> {ReceivedMap, Sent};
    terminate            -> exit(faulty)

  after 0 ->
    task1_receive(Id, Proxy, N, Max_messages, ReceivedMap, Sent, ProcessModule)
  end.

task1_receive(Id, Proxy, N, Max_messages, ReceivedMap, Sent, processPl) ->
  receive
    {pl_deliver, SenderP, _} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                                task1(Id, Proxy, N, Max_messages, NewReceivedMap, Sent, processPl)
  after 0 ->
    attempt_broadcast(Id, Proxy, N, Max_messages, ReceivedMap, Sent, processPl)
  end;

task1_receive(Id, Proxy, N, Max_messages, ReceivedMap, Sent, processBeb) ->
  receive
    {beb_deliver, SenderP, _} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                                task1(Id, Proxy, N, Max_messages, NewReceivedMap, Sent, processBeb)
  after 0 ->
    attempt_broadcast(Id, Proxy, N, Max_messages, ReceivedMap, Sent, processBeb)
  end;

task1_receive(Id, Proxy, N, Max_messages, ReceivedMap, Sent, processRbFaulty) ->
  receive
    {rb_deliver, SenderP, _} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                                task1(Id, Proxy, N, Max_messages, NewReceivedMap, Sent, processRbFaulty)
  after 0 ->
    attempt_broadcast(Id, Proxy, N, Max_messages, ReceivedMap, Sent, processRbFaulty)
  end.

attempt_broadcast(Id, Proxy, N, Max_messages, ReceivedMap, Sent, ProcessModule) ->
  if
    (Sent < Max_messages) or (Max_messages == 0) ->
      % Sent is used as a sequence number to make messages unique
      if ProcessModule == processPl ->
        ProcessModule:broadcast(Id, Proxy, N);
      true ->
        ProcessModule:broadcast(Id, Proxy, Sent)
      end,
      task1(Id, Proxy, N, Max_messages, ReceivedMap, Sent+1, ProcessModule);
    true ->
      task1(Id, Proxy, N, Max_messages, ReceivedMap, Sent, ProcessModule)
  end.
