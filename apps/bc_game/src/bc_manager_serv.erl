
-module(bc_manager_serv).
-behavior(gen_server).

%% api functions
-export([start_link/0,
		 create_game/1,
		 get_game/1,
		 get_player/2,
		 get_all_players/1,
		 add_player/3,
		 remove_player/2,
		 remove_game/1
		]).

%% gen_server callbacks
-export(init/1,
		handle_call/3,
		handle_cast/2).

%% state rec
-record(state, {
				game_sup,
				games
				}).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

create_game(Privacy) ->
	gen_server:call(?MODULE, {create_game, Privacy}).

get_game(GameId) ->
	gen_server:call(?MODULE, {get_game, GameId}).

remove_game(GameId) ->
	gen_server:cast(?MODULE, {remove_game, GameId}).

%%====================================================================
%% Gen_server callbacks
%%====================================================================

init(BcGameSup) ->
	{ok, #state{game_sup = BcGameSup, games = dict:new()}}.
	
handle_call({create_game, Privacy}, _From, 
		S = #state{game_sup = BcGameSup, games = GameDict}}) ->
	case new_game(Privacy) of
		{ok, GameId} ->
			{ok, BcGameServ} = supervisor:start_child(BcGameSup, #{
			   id => GameId,
			   start => {bc_game_serv, start_link, [BcGameSup]},
			   modules => [bc_game_serv]
			}),
			{reply {ok, GameId, BcGameServ}, S#state{games = dict:store(GameId, BcGameServ, GameDict)}};
		{error, Reason} ->
			{reply, {error, Reason}, S}
	end;

handle_call({get_game, GameId}, _From, State) ->
	GameDict = State#state.games,
	case dict:find(GameId, GameDict) of
		{ok, BcGameServ} ->
			{reply, {ok, BcGameServ}, State};
		error ->
			{reply, {error, not_found}, State}
	end.

handle_cast({remove_game, GameId}, _From, State) ->
	GameDict = State#state.games,
	{noreply, State#state{games = dict:erase(GameId, GameDict)}}.

%%====================================================================
%% Internal functions
%%====================================================================

new_game(Privacy) ->
	Now = now(),
	GameId = bc_model:gen_id(game),
	Game = game#{id = GameId,
				 state = ?CREATED,
				 winner_id = 0,
				 is_private = Privacy,
				 created = Now,
				 modified = Now},
	case mnesia:sync_transaction(fun() -> mnesia:write(Game) end) of
		{atomic, Result} ->
			{ok, GameId};
		{aborted, Reason} ->
			{error, Reason}
	end.

