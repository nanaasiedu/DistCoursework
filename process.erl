-module(process).
-export([start/1]).

start(Id) ->
  receive
    {bindProcesses, Processes} ->  next(Id, Processes)
  end.

next(Id, Peers) ->  
  receive
    {task1, start, Max_messages, Timeout} -> timer:send_after(Timeout, timeup), {ReceivedMap, Sent} = task1(Id, Peers, Max_messages, Timeout)  
  end,
  io:format("~p : Sent ~p Received 1st: ~p ~n", [Id, Sent, maps:get(1,ReceivedMap)]),
  next(Id, Peers).

task1(Id, Peers, Max_messages, Timeout) ->
  % Mapping from process Ids to the number of messages received from process
  ReceivedMap = maps:from_list([{CurrId, 0} || CurrId <- lists:seq(1, length(Peers))]),
  task1(Id, Peers, Max_messages, Timeout, ReceivedMap, 0).

task1(Id, Peers, Max_messages, Timeout, ReceivedMap, Sent) ->
  receive
    timeup -> Continue = false;
    {deliver, SenderP} -> ReceivedMap = maps:put(SenderP, maps:get(SenderP, ReceivedMap) + 1),
                          Continue = true
  after 0 ->
    Continue = true
  end, 
  
  io:format(" SENT: ~p CONTINUE: ~p MAX: ~p   TIMEVAL: ~p~n", [Sent, Continue, Max_messages, Timeout]),
  if 
    Continue -> 
      if 
        (Sent < Max_messages) or (Max_messages == 0) ->
          io:format("BROADCASTING"), 
          broadcast(Id, Peers),
          Result = task1(Id, Peers, Max_messages, Timeout, ReceivedMap, Sent + 1);
        true -> 
          Result = task1(Id, Peers, Max_messages, Timeout, ReceivedMap, Sent)
      end;
    true ->
      Result = {ReceivedMap, Sent}
  end,
  
  Result.
  

broadcast(Id, Peers) -> 
  [ P ! {deliver, Id} || P <- Peers].
 
