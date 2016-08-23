
-module(bc_gen_ai).
-behaviour(gen_fsm).

-export([init/1, 
		 state_name/2, 
		 state_name/3, 
		 handle_event/3, 
		 handle_sync_event/4, 
		 handle_info/3, 
		 terminate/3, 
		 code_change/4]).

-export([start_link/3]).

%% internal state
-record(state, {entity,
				entity_config,
				entities,
				map,
				timer}).

%% ====================================================================
%% API functions
%% ====================================================================

-spec start_link(BcEntity :: bc_entity:entity(), 
				 BcEntities :: bc_entities:entities(), 
				 BcMap :: bc_map:map_graph()) -> gen:start_ret().
start_link(BcEntity, BcEntities, BcMap) ->
	gen_fsm:start_link(?MODULE, [BcEntity, BcEntities, BcMap], []).

%% ====================================================================
%% Behavioural functions
%% ====================================================================

init([BcEntity, BcEntities, BcMap]) ->
	EntityType = bc_entity:entity_type(BcEntity),
	{ok, BcEntityConfig} = bc_entities:entity_config(EntityType, BcEntities),
	TimerRef = gen_fsm:send_event_after(50, action),
	{ok, sensing, #state{entity = BcEntity,
						 entity_config = BcEntityConfig 
					   	 entities = BcEntities, 
					   	 map = BcMap,
						 timer = TimerRef}}.

sensing(action, State) ->
	move(down, State).

moving({timeout, Ref, action_complete}, State) ->
	%% TODO move and publish event
	{next_state, sensing, State}

handle_event(Event, StateName, StateData) ->
    {next_state, StateName, StateData}.

handle_sync_event(Event, From, StateName, StateData) ->
    Reply = ok,
    {reply, Reply, StateName, StateData}.

handle_info(Info, StateName, StateData) ->
    {next_state, StateName, StateData}.

terminate(Reason, StateName, StatData) ->
    ok.

code_change(OldVsn, StateName, StateData, Extra) ->
    {ok, StateName, StateData}.

%% ====================================================================
%% Internal functions
%% ====================================================================

move(Direction, State) ->
	%% TODO perform move
	MoveSpeed = bc_entity_config:move_speed(BcEntityConfig),
	MoveDelay = 1000 * MoveSpeed,
	TimerRef = gen_fsm:send_event_after(MoveDelay, action),
	{next_state, moving, State#state{timer = TimerRef}}.
