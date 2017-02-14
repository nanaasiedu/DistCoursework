% Nana Asiedu-Ampem (na1814)
-module(plComponent).
-export([start/1]).

start(Id) ->
  receive
    {bind_owner, Owner_pid} -> ok
  end,
  receive
    {bind_address_map, Pl_map} -> next(Id, Owner_pid, Pl_map)
  end.

next(Id, Owner_pid, Pl_map) ->
  receive
    {pl_deliver, From, M}  -> Owner_pid            ! {pl_deliver, From, M};
    {pl_send, PN, M}       -> maps:get(PN, Pl_map) ! {pl_deliver, Id, M}
  end,
  next(Id, Owner_pid, Pl_map).
