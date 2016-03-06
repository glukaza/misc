-module(save_handler).
-behaviour(cowboy_http_handler).
%% Cowboy_http_handler callbacks
-export([
	init/3,
	handle/2,
	terminate/3
]).

init({tcp, http}, Req, _Opts) ->
	{ok, Req, undefined_state}.

handle(Req, State) ->
	{Query, Req2} = cowboy_req:qs_vals(Req),
    Qurl = proplists:get_value(<<"url">>, Query),
	Number = proplists:get_value(<<"number">>, Query),
	Project = proplists:get_value(<<"project">>, Query),
	Url = re:replace(Qurl, " ", "%20", [{return,list}, global])++Number++"/api/xml",
	{ok, Config} = file:consult("projects.config"),
	[{AuthString}] = [{AuthString} || {auth, AuthString} <- Config],

	os:cmd("curl -u "++AuthString++" -s "++Url++" --data \"wrapper=changes&xpath=//changeSet//item//msg\" | grep -oP '(?<=[\\#]).([A-Z-_a-z0-9]+)(?=[\\:])' | tr [a-z] [A-Z] >> files/"++Project++".last.changes"),
	{ok, Req2} = cowboy_req:reply(200, [], Url, Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.

