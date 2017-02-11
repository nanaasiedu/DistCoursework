% Nana asiedu (na1814)
-module(process).
-export([start/1]).

start(Id, System_pid) ->
  Pl_pid  = spawn(pl_component, start, []),
  App_pid = spawn(process, next, [Id, Pl_pid]),
  Pl_pid ! {bind_owner ! App_pid},
  System_pid ! {deliver_pl_component, Id, Pl_pid}.

next(Id, Pl_pid) ->  
  receive
    {task1, start, N, Max_messages, Timeout} -> 
      timer:send_after(Timeout, timeup),
      {ReceivedMap, Sent} = task1(Id, Pl_pid, N, Max_messages)  
  end,
  print_result(Id, ReceivedMap, Sent),
  exit(normal).

task1(Id, PL_pid, N, Max_messages) ->
  % Mapping from process Ids to the number of messages received from process
  ReceivedMap = maps:from_list([{CurrId, 0} || CurrId <- lists:seq(1, N)]),
  task1(Id, Pl_pid, N, Max_messages, ReceivedMap, 0).

task1(Id, Pl_pid, N, Max_messages, ReceivedMap, Sent) ->
  receive
    timeup                -> {ReceivedMap, Sent}

  after 0 ->
    receive 
      {deliver, SenderP} -> NewReceivedMap = maps:update(SenderP, maps:get(SenderP, ReceivedMap) + 1, ReceivedMap),
                            task1(Id, Pl_pid, N, Max_messages, NewReceivedMap, Sent);

      broadcast          -> if 
                              (Sent < Max_messages) or (Max_messages == 0) ->
                                broadcast(Id, Pl_pid, N),
                                NewSent = Sent + 1,
                                if (NewSent < Max_messages) or (Max_messages == 0) ->
                                  self() ! broadcast; true -> nothing  
                                end,
                                task1(Id, Pl_pid, N, Max_messages, ReceivedMap, NewSent);
                              true ->
                                task1(Id, Pl_pid, N, Max_messages, ReceivedMap, Sent)
                           end 
    after 0 ->
      self() ! broadcast,
      task1(Id, Pl_pid, N, Max_messages, ReceivedMap, Sent)
    end
  end.

broadcast(Id, Pl_pid) -> 
  [ Pl_pid ! {pl_send, Id, whatsup} || PN <- lists:seq(1, N)].

print_result(Id, ReceivedMap, Sent) ->
  Received_list = [ {Sent, Received} || {_, Received} <- maps:to_list(ReceivedMap)],
  io:format("~p: ~p~n", [Id, Received_list]).
 