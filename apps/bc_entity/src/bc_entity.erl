
-module(bc_entity).

%% API exports
-export([create/6, 
		 create/7, 
		 uuid/1, 
		 player_id/1, 
		 team/1, 
		 entity_type/1, 
		 health/1, 
		 ai_fsm/1,
		 vertices/1,
		 damage/2,
		 to_tuple/1,
		 from_tuple/1]).

%%
%% @doc base entity type for saving and transfering entities.
%%
-type entity() :: #{uuid => uuid:uuid(), 
					player_id => integer(), 
					team => integer(), 
					entity_type => integer(), 
					health => integer(), 
					ai_fsm => pid() | undefined,
					vertices => [bc_vertex:vertex()]}.

%% type exports
-export_type([entity/0]).

%%====================================================================
%% API functions
%%====================================================================

-spec create(Uuid :: uuid:uuid(), 
			 PlayerId :: integer(), 
			 Team :: integer(), 
			 EntityType :: integer(), 
			 Health :: integer(),
			 Vertices :: [bc_vertex:vertex()]) -> entity().
create(Uuid, PlayerId, Team, EntityType, Health, Vertices) ->
	create(Uuid, PlayerId, Team, EntityType, Health, Vertices, undefined).

-spec create(Uuid :: uuid:uuid(), 
			 PlayerId :: integer(), 
			 Team :: integer(), 
			 EntityType :: integer(), 
			 Health :: integer(),
			 Vertices :: [bc_vertex:vertex()],
			 AIFsm :: pid()) -> entity().
create(Uuid, PlayerId, Team, EntityType, Health, Vertices, AIFsm) ->
	#{uuid => Uuid,
	  player_id => PlayerId,
	  team => Team,
	  entity_type => EntityType,
	  health => Health,
	  vertices => Vertices,
	  ai_fsm => AIFsm}.

-spec uuid(BcEntity :: entity()) -> uuid:uuid().
uuid(BcEntity) ->
	maps:get(uuid, BcEntity).

-spec player_id(BcEntity :: entity()) -> integer().
player_id(BcEntity)->
	maps:get(player_id, BcEntity).

-spec team(BcEntity :: entity()) -> integer().
team(BcEntity) ->
	maps:get(team, BcEntity).

-spec entity_type(BcEntity :: entity()) -> integer().
entity_type(BcEntity) ->
	maps:get(entity_type, BcEntity).

-spec health(BcEntity :: entity()) -> integer().
health(BcEntity) ->
	maps:get(health, BcEntity).

-spec ai_fsm(BcEntity :: entity()) -> pid() | undefined.
ai_fsm(BcEntity) ->
	maps:get(ai_fsm, BcEntity).
	
-spec vertices(BcEntity :: entity()) -> [bc_vertex:vertex()].
vertices(BcEntity) ->
	maps:get(vertices, BcEntity).

-spec damage(BcEntity :: entity(), Damage :: integer()) -> entity().
damage(BcEntity, Damage) ->
	Health = maps:get(BcEntity, health),
	maps:update(health, Health - Damage, BcEntity).

-spec to_tuple(BcEntity :: entity()) -> tuple().
to_tuple(BcEntity) ->
	{uuid(BcEntity), 
	 player_id(BcEntity), 
	 team(BcEntity), 
	 entity_type(BcEntity), 
	 health(BcEntity), 
	 ai_fsm(BcEntity)}.

-spec from_tuple(tuple()) -> entity().
from_tuple(
	{Uuid, 
	 PlayerId, 
	 Team, 
	 EntityType, 
	 Health, 
	 AiFsm}) ->
	create(Uuid, PlayerId, Team, EntityType, Health, AiFsm).
