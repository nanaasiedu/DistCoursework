% Nana Asiedu-Ampem (na1814)
-module(processBebLossy).
-export([start/4]).

start(Id, System_pid, N, Reliability) ->
  Pl_pid  = spawn(lossyPlComponent, start, [Id, Reliability]),
  Beb_pid = spawn(bebComponent, start, [N]),
  App_pid = spawn(processBeb, start_app, [Id, Beb_pid]),
  Beb_pid ! {bind_owner, App_pid, Pl_pid},
  Pl_pid ! {bind_owner, Beb_pid},
  System_pid ! {deliver_pl_component, Id, Pl_pid}.
