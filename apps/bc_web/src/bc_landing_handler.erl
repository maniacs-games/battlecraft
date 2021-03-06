
-module(bc_landing_handler).

-export([init/3, handle/2, terminate/3]).

init(_Type, Req, _Opts) ->
	Version =
		case application:get_key(bc, vsn) of
			{ok, Vsn} -> Vsn;
			undefined -> "0.1.0"
		end,
	ViewFile = bc_web_files:view_file("index.html"),
	erlydtl:compile(ViewFile, landing_view, 
					[{vars, [{title, "BattleCraft Online"}, 
							 {description, "An online real time strategy simulation game."},
							 {version, Version}]}]),
	{ok, Req, no_state}.

handle(Req, _State) ->
	case landing_view:render([]) of
		{ok, View} ->
			{ok, cowboy_req:reply(200, [], View, Req), no_state};
		{error, Reason} ->
			{shutdown, cowboy_req:reply(500, [], <<Reason>>, Req), no_state}
	end.

terminate(_Reason, _Req, _State) ->
	ok.