-module(process).
-export([start/1]).

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
  {Command, NewReceivedMap} = check_mailbox(Id, Peers, ReceivedMap),
  
  case Command of
    continue_task ->
      if 
        (Sent < Max_messages) or (Max_messages == 0) ->
          
          self() ! broadcast,
          NewSent = Sent + 1;
        true ->
          NewSent = Sent
      end,
      task1(Id, Peers, Max_messages, NewReceivedMap, NewSent);
   
    end_task ->    
      {NewReceivedMap, Sent}
  end.
  
check_mailbox(Id, Peers, ReceivedMap) ->
  receive
    timeup             -> {end_task, ReceivedMap};

    {deliver, SenderP} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                          {continue_task, NewReceivedMap};

    broadcast          -> broadcast(Id, Peers), 
                          {continue_task, ReceivedMap}
  after 0 ->
    {continue_task, ReceivedMap}
  end.

broadcast(Id, Peers) -> 
  [ P ! {deliver, Id} || P <- Peers].

print_result(Id, ReceivedMap, Sent) ->
  Received_list = [ {Sent, Received} || {_, Received} <- maps:to_list(ReceivedMap)],
  io:format("~p: ~p~n", [Id, Received_list]).
 
