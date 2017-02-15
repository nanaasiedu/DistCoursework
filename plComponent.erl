% Nana Asiedu-Ampem (na1814)
-module(plComponent).
-export([start/1, start/2]).

start(Id) ->
  start(Id, 100).

% Initial set up binding owner process and address map
% R : Reliability of p2p link
start(Id, R) ->
  receive
    {bind_owner, Owner_pid} -> ok
  end,
  receive
    {bind_address_map, Pl_map} -> next_send(Id, Owner_pid, Pl_map, R)
  end.

% next_send prioritise receiving pl_send messages over pl_deliver. If no such
% can be found, we call next_deliver to prioritise pl_deliver.
% It should be noted that no blocking on either message takes place as after 0
% prevents blocking.
% The reason for this is to give both pl_send and pl_deliver a fair chance of
% being read (e.g. flooding the message queue with send commands will not starve
% the delivery of messages)
next_send(Id, Owner_pid, Pl_map, 100) ->
  receive
    {pl_send, PN, M}       -> maps:get(PN, Pl_map) ! {pl_deliver, Id, M}
  after 0 -> ok
  end,
  next_deliver(Id, Owner_pid, Pl_map, 100);

next_send(Id, Owner_pid, Pl_map, R) ->
  receive
    % Process number 0 is used for the system. For the purpose of my solution
    % I have given messages to the system process full reliability (I do not believe doing so will hinder the solution or spec)
    {pl_send, 0, M}  -> maps:get(0, Pl_map) ! {pl_deliver, Id, M};
    {pl_send, PN, M} -> Rand = rand:uniform(100),
                        if (Rand =< R) ->
                          maps:get(PN, Pl_map) ! {pl_deliver, Id, M};
                        true -> failed_to_send
                        end
  after 0 -> ok
  end,
  next_deliver(Id, Owner_pid, Pl_map, R).

next_deliver(Id, Owner_pid, Pl_map, R) ->
  receive
    {pl_deliver, From, M}  -> Owner_pid ! {pl_deliver, From, M}
  after 0 -> ok
  end,
  next_send(Id, Owner_pid, Pl_map, R).
