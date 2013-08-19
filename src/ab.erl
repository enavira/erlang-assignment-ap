-module(ab).
-export([start/2, loop/3]).
-define(NODE, 'foo@dhcp-164-140').

start(CityA, CityB) ->
    GPSPid = gps:start(CityA, CityB),
    Pid = spawn_link(ab, loop, [GPSPid, [], element(2, now())]),

    sensor:start(Pid),
    sensor:start(Pid),
    sensor:start(Pid),
    sensor:start(Pid),
    Pid.

loop(GPSPid, Data, LastSentTime) ->		
    receive
	{sensor, X} -> 
	    T = passed_time(LastSentTime),
	    if 
		T < 50 ->
		    loop(GPSPid, [X|Data], LastSentTime);
		true ->
		    Result = calc_average(Data),
		    GPSPid ! {position, self()},
		    receive 
			{reply, Lat, Lon} ->
			    %% dc ! {result, {Lat, Lon, round(Result)}},
			    {dc, ?NODE} ! {result, {Lat, Lon, round(Result)}},
			    loop(GPSPid, [], element(2, now()));
			stop ->
			    stop
			    %% flush(self())
		    end
	    end
    end.

calc_average(Data) ->
    calc_average(Data, 0, 0).

calc_average([H|T], Length, Sum) ->
    calc_average(T, Length + 1, Sum + H);
calc_average([], Length, Sum) ->
    Sum / Length.

passed_time(Time) ->
    element(2, now()) - Time.
