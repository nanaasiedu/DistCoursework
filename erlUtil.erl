-module(erlUtil).
-export([atom_to_int/1]).

atom_to_int(Atom) ->
  list_to_integer(atom_to_list(Atom)).
