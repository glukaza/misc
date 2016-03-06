-module(load_handler).
-behaviour(cowboy_http_handler).
%% Cowboy_http_handler callbacks
-export([
	init/3,
	handle/2,
	terminate/3
]).

init({tcp, http}, Req, _Opts) ->
	{ok, Req, undefined_state}.

readlines(FileName) ->
	{ok, Data} = file:read_file(FileName),
	binary:split(Data, [<<"\n">>], [global]).

handle(Req, State) ->
	{Query, Req2} = cowboy_req:qs_val(<<"project">>, Req),
	Project = binary_to_list(Query),
	File = readlines("files/"++Project++".last.changes"),
	os:cmd("rm files/"++Project++".last.changes"),
	{ok, Req2} = cowboy_req:reply(200, [], File, Req),
        {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.

