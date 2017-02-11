% Nana asiedu (na1814)
-module(pl_component).
-export([start/1]).

start() ->
  receive
    {bind_owner, Owner_pid} -> ok
  end,
  receive
    {bind_address_map, Pl_map} -> next(Owner_pid, Pl_map).  
  end.

next(Owner_pid, Pl_map) ->
  receive
    {pl_deliver, M}  -> Owner ! {pl_deliver, M};
    {pl_send, PN, M} -> maps:get(PN, Pl_map)
  end,
  next(Pl_map).

