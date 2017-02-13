% Nana Asiedu-Ampem (na1814)
-module(lossyPlComponent).
-export([start/1]).

start(R) ->
  receive
    {bind_owner, Owner_pid} -> ok
  end,
  receive
    {bind_address_map, Pl_map} -> next(Owner_pid, Pl_map, R)
  end.

next(Owner_pid, Pl_map, R) ->
  receive
    {pl_deliver, M}  -> Owner_pid ! {pl_deliver, M};
    {pl_send, 0, M}  -> maps:get(0, Pl_map) ! {pl_deliver, M};
    {pl_send, PN, M} -> Rand = rand:uniform(100),
                        if (Rand =< R) ->
                          maps:get(PN, Pl_map) ! {pl_deliver, M};
                        true -> nothing
                        end
  end,
  next(Owner_pid, Pl_map, R).
