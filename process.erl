% Nana Asiedu-Ampem (na1814)
-module(process).
-export([start/1, print_result/3]).

start(Id) ->
  receive
    {bindProcesses, Processes} ->  next(Id, Processes)
  end.

next(Id, Peers) ->
  receive
    {task1, start, Max_messages, Timeout} ->
      timer:send_after(Timeout, timeup),
      {ReceivedMap, Sent} = task1(Id, Peers, Max_messages)
  end,
  print_result(Id, ReceivedMap, Sent),
  exit(normal).

task1(Id, Peers, Max_messages) ->
  % Mapping from process Ids to the number of messages received from process
  ReceivedMap = maps:from_list([{CurrId, 0} || CurrId <- lists:seq(1, length(Peers))]),
  task1(Id, Peers, Max_messages, ReceivedMap, 0).

task1(Id, Peers, Max_messages, ReceivedMap, Sent) ->
  receive
    timeup                -> {ReceivedMap, Sent}

  after 0 ->
    receive
      {deliver, SenderP} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                            task1(Id, Peers, Max_messages, NewReceivedMap, Sent)

    after 0 ->
      if
        (Sent < Max_messages) or (Max_messages == 0) ->
          broadcast(Id, Peers),
          task1(Id, Peers, Max_messages, ReceivedMap, Sent+1);
        true ->
          task1(Id, Peers, Max_messages, ReceivedMap, Sent)
      end
    end
  end.

broadcast(Id, Peers) ->
  [ P ! {deliver, Id} || P <- Peers].

print_result(Id, ReceivedMap, Sent) ->
  Received_list = [ {Sent, Received} || {_, Received} <- maps:to_list(ReceivedMap)],
  io:format("~p: ~w~n", [Id, Received_list]).
