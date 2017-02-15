% Nana Asiedu-Ampem (na1814)
-module(rbComponent).
-export([start/0]).

start() ->
  receive
    {bind_owner, Owner_pid, Beb_pid} -> next(Owner_pid, Beb_pid, [])
  end.

next(Owner_pid, Beb_pid, Delivered) ->
  receive
    % Process number 0 is used for the system. For the purpose of my solution
    % I have made it so end_task sends only to the system process (special message)
    {rb_broadcast, end_task} -> Beb_pid ! {beb_broadcast, end_task},
                                next(Owner_pid, Beb_pid, Delivered);
    {rb_broadcast, M}        -> Beb_pid ! {beb_broadcast, {data, self(), M}},
                                next(Owner_pid, Beb_pid, Delivered);
    {beb_deliver, From, {data, Rb_From, M}} ->
      case lists:member(M, Delivered) of
        true -> next(Owner_pid, Beb_pid, Delivered);
        false-> 
          Owner_pid ! {rb_deliver, From, M},
          Beb_pid   ! {beb_broadcast, {data, Rb_From, M}},
          next(Owner_pid, Beb_pid, Delivered ++ [M])
      end;
    {beb_deliver, 0, M} ->
      Owner_pid ! {rb_deliver, 0, M},
      next(Owner_pid, Beb_pid, Delivered)
  end.
