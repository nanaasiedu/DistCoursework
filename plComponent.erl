% Nana Asiedu-Ampem (na1814)
-module(plComponent).
-export([start/1, start/2]).

start(Id) ->
  start(Id, 100).

start(Id, R) ->
  receive
    {bind_owner, Owner_pid} -> ok
  end,
  receive
    {bind_address_map, Pl_map} -> next_send(Id, Owner_pid, Pl_map, R)
  end.

next_send(Id, Owner_pid, Pl_map, 100) ->
  receive
    {pl_send, PN, M}       -> maps:get(PN, Pl_map) ! {pl_deliver, Id, M}
  after 0 -> ok
  end,
  next_deliver(Id, Owner_pid, Pl_map, 100);

next_send(Id, Owner_pid, Pl_map, R) ->
  receive
    {pl_send, 0, M}  -> maps:get(0, Pl_map) ! {pl_deliver, Id, M};
    {pl_send, PN, M} -> Rand = rand:uniform(100),
                        if (Rand =< R) ->
                          maps:get(PN, Pl_map) ! {pl_deliver, Id, M};
                        true -> nothing
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
