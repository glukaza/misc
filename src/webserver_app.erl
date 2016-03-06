-module(webserver_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", index_handler, []},
			{"/load", load_handler, []},
			{"/save", save_handler, []},
			{'_', notfound_handler, []}
		]}
	]),
	Port = 8008,
	{ok, _} = cowboy:start_http(http_listener, 100,
		[{port, Port}],
		[{env, [{dispatch, Dispatch}]}]
	),
	webserver_sup:start_link().

stop(_State) ->
    ok.
