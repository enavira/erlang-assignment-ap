-module(dc).
-export([start/0, loop/1]).
-define(PATH, "/Library/WebServer/Documents/erlangmap/file.txt").
start() ->
    register(dc,spawn_link(dc, loop, [[]])).


loop(List) ->
    receive
	{result, {Lat, Lon, Sensor}} ->
	    Time = add_time({Lat, Lon, Sensor}),
	    Color = add_color(Time),
	    Add = add_list(Color, List),
	    Check = check(Add),
	    io:format("List:~w \n \n", [Check]),
	    {ok, IoDevice} = file:open(?PATH, write),
	    write(Check, IoDevice),
	    file:close(IoDevice),
	    loop(Check);
	stop -> stop
    end.


add_time({A, B, C}) ->
    {element(2, now()), A, B, C}.

add_color({A, B, C, D}) ->
    if
	D < 1000 ->
	    {1, A, B, C};
	(D >= 1000) and (D < 5000) ->
	    {2, A, B, C};
	(D >= 5000) and (D < 10000)->
	    {3, A, B, C};
	(D >= 10000) and (D < 15000) ->
	    {4, A, B, C};
	(D >= 15000) and (D =< 20000) ->
	    {5, A, B, C}
    end.

add_list(Color, []) ->
    [Color];
add_list(Color, [H|T]) ->
    LatA = element(3, H),
    LonA = element(4, H),
    LatB = element(3, Color),
    LonB = element(4, Color),
    A = math:pow(math:sin((to_rad(LatB - LatA)) / 2), 2) + 
    math:cos(to_rad(LatA)) * math:cos(to_rad(LatB)) * math:pow(math:sin((to_rad(LonB - LonA)) / 2), 2),
    C = 2 * math:atan2(math:sqrt(A), math:sqrt(1-A)),    
    Distance = 6371 * C,
    io:format("~w \n", [Distance]),
    if 
	Distance >= 10 ->
	    [H|add_list(Color, T)];
	true ->
	    add_list(Color,T)
    end.


to_rad(Degree) ->
    (Degree*math:pi()) / 180.

check([]) ->
    [];
check([H|T]) ->
    Time = element(2, now()) - element(2, H),
    if
	Time > 86400 ->
	    check(T);
	true ->
	    [H|check(T)]
    end.
write([], _IoDevice) -> 
    ok;
write([H|T], IoDevice) ->
    io:write(IoDevice, element(1, H)),
    io:write(IoDevice, a),
    io:write(IoDevice, element(3, H)),
    io:write(IoDevice, a),
    io:write(IoDevice, element(4, H)),
    io:write(IoDevice, a),
    write(T, IoDevice).
