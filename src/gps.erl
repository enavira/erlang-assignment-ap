-module(gps).
-export([start/2, init/3]).


start(CityA, CityB) ->
    spawn_link(gps, init, [CityA, CityB, element(2,now())]).

init(CityA, CityB, Time) ->
    random:seed(now()),
    CityList = [{goteborg, 57.71, 11.96}, {newyork, 40.71, -74.00},{rome, 41.89, 12.49}, {madrid, 40.41, -3.69},
		{barcelona, 41.393, 2.172}, {berlin,52.523, 13.413}, {paris, 48.862, 2.355}, {amsterdam, 52.376, 4.898},
	       {london, 51.505, -0.113}],
    {value, {_,LatA,LonA}} = lists:keysearch(CityA, 1, CityList),
    {value, {_,LatB,LonB}} = lists:keysearch(CityB, 1, CityList),
    Speed = random:uniform(200) + 800,
    io:format("~w \n", [Speed]),
    loop(LatA, LonA, LatB, LonB, Time, Speed).

loop(LatA, LonA, LatB, LonB, Time, Speed) ->
    A = math:pow(math:sin((to_rad(LatB - LatA)) / 2), 2) + 
    math:cos(to_rad(LatA)) * math:cos(to_rad(LatB)) * math:pow(math:sin((to_rad(LonB - LonA)) / 2), 2),
    C = 2 * math:atan2(math:sqrt(A), math:sqrt(1-A)),
    TotalDistance = 6371 * C,
     receive 
     	{position, Pid} ->
	     NewTime = element(2,now()) - Time,	     
	     Distance = (NewTime * Speed) / 3600,
	     K = Distance / TotalDistance,
	     if 
		 Distance >= TotalDistance ->
		     Pid ! stop;
		 true ->
		     NewLat = K * (LatB - LatA) + LatA,
		     NewLon = K * (LonB - LonA) + LonA,
		     Pid ! {reply, NewLat, NewLon},
		     loop(LatA, LonA, LatB, LonB, Time, Speed)
	     end
     end.
	
to_rad(Degree) ->
    (Degree*math:pi()) / 180.
