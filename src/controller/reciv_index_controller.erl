-module(reciv_index_controller, [Req]).
-compile(export_all).

-record(struct, {lst=[]}).

hello('GET', []) ->
%    Post = Req:request_body(),
	Post = <<"{\"ref\": \"asd/ghj/uio/6\", \"repository\": {\"name\" : \"HyperV\"}}">>,
        Struct = mochijson:decode(Post),

	file:write_file("/home/gluka/asd",io_lib:fwrite("~p.\n",[Struct])),

	Ref = proplists:get_value("ref", Struct#struct.lst),
	Branch = lists:last(string:tokens(Ref, "/")),

	Repository = proplists:get_value("repository", Struct#struct.lst),
	Project = proplists:get_value("name", Repository#struct.lst),

	{ok, Config} = file:consult("projects.config"),

	[{Job, Server}] = [{Job, Server} || {project, ProjectConfig, Job, Server} <- Config, ProjectConfig =:= Project],
	[{Url}] = [{Url} || {url, Url} <- Config],
	[{Token}] = [{Token} || {token, Token} <- Config],
%	[{project, ProjectName, Job, Server}] = lists:filter(fun({project, ProjectConfig, _, _}) -> ProjectConfig =:= Project end, Config),


	A = [{"delay", "0sec"},
	     {"token", Token},
	     {"job", Job}, 
	     {"TARGET_SERVER", Server}, 
	     {"BRANCH_TO_BUILD", Branch}
	],

	Jenkins = geturl(Url, A),
	file:write_file("/home/gluka/asd",io_lib:fwrite("~p.\n",[Jenkins])),
	inets:start(),

	case httpc:request(get, {Jenkins, []}, [{timeout, timer:seconds(20)}], []) of
		{ok, A} -> inets:stop(), {output, Jenkins};
		_ -> inets:stop(), boss_mail:send("puzo2002@bk.ru", "puzo2002@bk.ru", "error", Jenkins), {output, "error"}
	end.

geturl(URL,QP) -> 
	URL++"?"++loop(QP,[]).

loop([{A,B}],QP) -> 
	QP++A++"="++B;
loop([{A,B}|T],QP) -> 
	loop(T,QP++A++"="++B++"&").

