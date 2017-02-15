% Nana Asiedu-Ampem (na1814)
-module(bebComponent).
-export([start/1]).

start(N) ->
  receive
    {bind_owner, Owner_pid, Pl_pid} -> next(Owner_pid, Pl_pid, N)
  end.

next(Owner_pid, Pl_pid, N) ->
  receive
    % Process number 0 is used for the system. For the purpose of my solution
    % I have made it so end_task sends only to the system process (special message)
    {beb_broadcast, end_task} -> Pl_pid    ! {pl_send, 0, end_task};
    {beb_broadcast, M}        -> [ Pl_pid  ! {pl_send, Dest, M} || Dest <- lists:seq(1,N)];
    {pl_deliver, From, M}     -> Owner_pid ! {beb_deliver, From, M}
  end,
  next(Owner_pid, Pl_pid, N).
