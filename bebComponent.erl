% Nana asiedu (na1814)
-module(bebComponent).
-export([start/1]).

start(N) ->
  receive
    {bind_owner, Owner_pid, Pl_pid} -> next(Owner_pid, Pl_pid, N)
  end.

next(Owner_pid, Pl_pid, N) ->
  receive
    {beb_broadcast, M} -> [ Pl_pid ! {pl_send, Dest, M} || Dest <- lists:seq(0,N)];
    {pl_deliver, M}    -> Owner_pid ! {beb_deliver, M}
  end,
  next(Owner_pid, Pl_pid, N).