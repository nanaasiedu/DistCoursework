% Nana Asiedu-Ampem (na1814)
-module(lossyPlComponent).
-export([start/2]).

start(Id, R) ->
  receive
    {bind_owner, Owner_pid} -> ok
  end,
  receive
    {bind_address_map, Pl_map} -> next(Id, Owner_pid, Pl_map, R)
  end.

next(Id, Owner_pid, Pl_map, R) ->
  receive
    {pl_deliver, From, M}  -> Owner_pid ! {pl_deliver, From, M};
    {pl_send, 0, M}  -> maps:get(0, Pl_map) ! {pl_deliver, Id, M};
    {pl_send, PN, M} -> Rand = rand:uniform(100),
                        if (Rand =< R) ->
                          maps:get(PN, Pl_map) ! {pl_deliver, Id, M};
                        true -> nothing
                        end
  end,
  next(Id, Owner_pid, Pl_map, R).
