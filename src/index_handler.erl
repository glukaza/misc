-module(index_handler).
-behaviour(cowboy_http_handler).

-record(struct, {lst=[]}).

%% Cowboy_http_handler callbacks
-compile(export_all).

init({tcp, http}, Req, _Opts) ->
	{ok, Req, undefined_state}.

handle(Req, []) ->
    {[], Req2} = cowboy_req:method(Req),
    {ok, Body, []} = cowboy_req:body(Req2),
    Struct = mochijson:decode(Body),

    file:write_file("files/input",io_lib:fwrite("~p.\n",[Struct])),

    Ref = proplists:get_value("ref", Struct#struct.lst),
    Branch = lists:last(string:tokens(Ref, "/")),

    Repository = proplists:get_value("repository", Struct#struct.lst),
    Project = proplists:get_value("name", Repository#struct.lst),
    After = proplists:get_value("after", Struct#struct.lst),
    ProjectID = proplists:get_value("project_id", Struct#struct.lst),
    UserEmail = proplists:get_value("user_email", Struct#struct.lst),

	{ok, Config} = file:consult("projects.config"),
	[{GitlabUrl, GitLabToken}] = [{GitlabUrl, GitLabToken} || {gitlab, GitlabUrl, GitLabToken} <- Config],
	[{Job, Server, RemoveJob}] = [{Job, Server, RemoveJob} || {project, ProjectConfig, Job, Server, RemoveJob} <- Config, ProjectConfig =:= Project],
	[{Url}] = [{Url} || {url, Url} <- Config],
	[{Token}] = [{Token} || {token, Token} <- Config],

    inets:start(),
    ssl:start(),
	case httpc:request(get, {GitlabUrl++"/api/v3/users?search="++UserEmail, [{"PRIVATE-TOKEN", GitLabToken}]}, [{ssl,[{verify,0}]}], []) of
		{ok, {_, _, User}} -> {array, [UserInfo]} = mochijson:decode(User);
		_ -> UserInfo = null
	end,

    Skype = proplists:get_value("skype", UserInfo#struct.lst),

	case After of
	    "0000000000000000000000000000000000000000" -> RealJob = RemoveJob;
	    _ -> RealJob = Job
	end,

	A = [{"delay", "0sec"},
	     {"token", Token},
	     {"job", RealJob},
	     {"SKYPE", Skype},
	     {"TARGET_SERVER", Server},
	     {"BRANCH_TO_BUILD", Branch},
	     {"HEAD_COMMIT", After},
	     {"PROJECT_ID", ProjectID}
	],

	Jenkins = geturl(Url, A),
	file:write_file("files/user",io_lib:fwrite("~p.\n",[Jenkins])),
	inets:start(),

	case httpc:request(get, {Jenkins, []}, [{timeout, timer:seconds(20)}], []) of
		{ok, A} -> inets:stop(), {output, Jenkins};
		_ -> inets:stop(),{output, "error"}
	end.

geturl(URL,QP) ->
	URL++"?"++loop(QP,[]).

loop([{A,B}],QP) ->
	QP++A++"="++B;
loop([{A,B}|T],QP) ->
	loop(T,QP++A++"="++B++"&").

terminate(_Reason, _Req, _State) ->
	ok.