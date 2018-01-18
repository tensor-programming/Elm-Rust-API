module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Json.Encode as Encode


type alias Book =
    { title : String
    , author : String
    , published : Bool
    }


type alias Model =
    { books : List Book }


init =
    ( Model [], Cmd.none )


type Msg
    = GetBooks (Result Http.Error (List Book))
    | RequestBooks


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetBooks (Ok json) ->
            ( { model | books = json }, Cmd.none )

        GetBooks (Err e) ->
            ( Debug.log (toString e) model, Cmd.none )

        RequestBooks ->
            ( model, getBooks )


getBooks : Cmd Msg
getBooks =
    let
        url =
            "http://localhost:8000/api/v1/books"

        req =
            Http.get url decodeBooks
    in
        Http.send GetBooks req


decodeBooks : Json.Decoder (List Book)
decodeBooks =
    Json.at [ "result" ] (Json.list bookDecoder)


bookDecoder : Json.Decoder Book
bookDecoder =
    Json.map3
        Book
        (Json.at [ "title" ] Json.string)
        (Json.at [ "author" ] Json.string)
        (Json.at [ "published" ] Json.bool)


view : Model -> Html Msg
view model =
    div []
        [ div [] <| List.map bookView model.books
        , button [ onClick RequestBooks ] [ text "Get Books!" ]
        ]


bookView : Book -> Html Msg
bookView book =
    ul []
        [ li [] [ text book.title ]
        , li [] [ text book.author ]
        , li [] [ book.published |> toString |> text ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }