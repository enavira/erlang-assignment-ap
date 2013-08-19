-module(sensor).
-export([start/1, init/1, stop/1]).

start(Pid) ->
    spawn_link(sensor, init, [Pid]).

init(Pid) ->
    {A1,A2,A3} = now(),
    random:seed(A1,A2,A3),
    Pid ! {sensor, random:uniform(20001) - 1},
    loop(Pid).


loop(Pid) ->
    receive
	stop -> ok
	after 2000 ->	
	    Pid ! {sensor, random:uniform(20001) - 1},
	    loop(Pid)
    end.

stop(Pid) ->
    Pid ! stop.
