module Entity exposing (Msg(..), Model)

import Element exposing (..)
import Collage exposing (..)
import Effects exposing (Effects)

-- Local imports

import EntityEvent exposing (Vertex, Entity, EntityEvent)

-- Actions

type Effect =
    Holder1 | Holder2

type Msg =
    EntityEv EntityEvent |
    NoOp

-- Model

type Orientation =
    Up |
    Right |
    Down |
    Left

type EntityState =
    Standing |
    Moving |
    Attacking

type alias Model = {
    entity : Entity,
    vertexMatrix : Dict Int List Int,
    position : (Float, Float),
    orientation : Orientation,
    entityState : EntityState
}

init : TmxMap -> Entity -> Effects Model Effect
init tmxMap entity =
    let
        matrix = vertexMatrix entity.vertices
    in
        Effects.return {
            entity = entity,
            vertexMatrix = matrix,
            position = entityPosition tmxMap matrix,
            orientation = Down,
            ntityState = Standing
        }

-- Update

vertexMatrix : List Vertex -> Dict Int List Int
vertexMatrix vertices =
    List.foldl (
            \vertex -> vertexMatrix ->
                let
                    row = vertex.row

                    cols = Dict.get row vertexMatrix
                            |> Maybe.withDefault []

                    updatedCols = vertex.col :: cols
                in
                    Dict.insert row updatedCols
        )  Dict.empty vertices

{--

update : Msg -> Model -> Effects Model Effect
update msg model =
    case msg of

        EntityEvent entityEvent ->

onEntityEvent : EntityEvent -> Model -> Effects Model Effect
onEntityEvent entityEvent model =
    case entityEvent of

        EntitySpawnedEvent entitySpawnedEvent ->
            Effects.return {model | }

--}

entityRowCount : Dict -> Int
entityRowCount vertexMatrix =
    let
        rows = Dict.keys vertexMatrix
    in
        List.length rows

entityHeight : TmxMap -> Dict -> Int
entityHeight tmxMap vertexMatrix =
    let
        entityRows = entityRowCount vertexMatrix
    in
        entityRows * tmxMap.tileHeight

entityColCount : Dict -> Int
entityColCount vertexMatrix =
    let
        row = Dict.keys vertexMatrix
                |> List.take 1
    in
        Dict.get row vertexMatrix
            |> Maybe.withDefault 0

entityWidth : TmxMap -> Dict -> Int
entityWidth tmxMap vertexMatrix =
    let
        entityCol = entityColCount vertexMatrix
    in
        entityCol * tmxMap.tileWidth

entityPosition : TmxMap -> Dict -> (Float, Float)
entityPosition tmxMap vertexMatrix =
    let
        minRow = Dict.keys vertexMatrix
                    |> List.minimum
                    |> Maybe.withDefault -1

        minCol = Dict.get minRow vertexMatrix
                    |> Maybe.withDefault [-1]
                    |> List.minimum

        height = entityHeight tmxMap vertexMatrix

        heightOffset = height / 2

        width = entityWidth tmxMap vertexMatrix

        widthOffset = entityWidth / 2

        y = ((minRow * tmxMap.tileHeight) / 2)

        offsetY = y + heightOffset

        x = ((minCol * tmxMap.tileWidth) / 2)

        offsetX = x + widthOffset
    in
        (toFloat offsetX, toFloat offsetY)

-- View

{--

view : Model -> TmxMap -> Collage.Form
view model tmxMap =
    let
        entityType = model.entity.entityType

        maxHealth = model.entity.maxHealth

        healthPct = model.entity.health / maxHealth

        entityWidth = entityWidth tmxMap.tileWidth model.vertexMatrix
    in
       case entityType of

           "base" ->

--}