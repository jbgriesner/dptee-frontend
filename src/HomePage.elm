module HomePage exposing (main)

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task


type alias Model =
    { leftPane : String
    , rightPane : String
    , fileContent : Maybe String
    , serverAddr : String
    }


type Msg
    = UploadFileClicked
    | InputServerAddr String
    | FileSelected File
    | FileRead String
    | SendToServer
    | GetDataFromServer (Result Http.Error String)
    | NoOp


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "" "" Nothing "", Cmd.none )


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputServerAddr str ->
            ( { model | serverAddr = str }
            , Cmd.none
            )

        FileSelected file ->
            ( model, Task.perform FileRead (File.toString file) )

        FileRead content ->
            ( { model | fileContent = Just content, leftPane = content }
            , Cmd.none
            )

        GetDataFromServer result ->
            let
                rez =
                    case result of
                        Ok t ->
                            t

                        Err _ ->
                            "Error"
            in
            ( { model | rightPane = rez }
            , Cmd.none
            )

        UploadFileClicked ->
            ( model, Select.file [] FileSelected )

        SendToServer ->
            ( model, sendFileToServer model )

        NoOp ->
            ( model
            , Cmd.none
            )


sendFileToServer : Model -> Cmd Msg
sendFileToServer model =
    Http.request
        { method = "POST"
        , headers = []
        , url = model.serverAddr
        , body = stringBody "data" model.leftPane
        , expect = Http.expectString GetDataFromServer
        , timeout = Nothing
        , tracker = Nothing
        }


view : Model -> Html Msg
view model =
    div [ class "jumbotron" ]
        [ nav model
        , mainContent model
        , footer
        ]


footer : Html Msg
footer =
    Html.footer [ class "container", style "align-items" "center" ]
        [ small [] [ "Copyright " ++ String.fromChar copyright ++ " 2023 J.B. Griesner" |> text ]
        ]


copyright : Char
copyright =
    Char.fromCode 169


mainContent : Model -> Html Msg
mainContent model =
    div
        [ style "display" "flex"
        , style "justify-content" "space-evenly"
        , class "container"
        ]
        [ div [ class "row" ]
            [ div [ class "col" ] [ text "Raw dataset:" ]
            , div [ class "col" ] [ textArea1 model ]
            , button [ class "btn btn-info ml-2", onClick UploadFileClicked ] [ text "Upload File" ]
            ]
        , div [ class "row" ]
            [ div [ class "col" ] [ text "Differentially private Dataset:" ]
            , div [ class "col" ] [ textArea2 model ]
            , button [ class "btn btn-info ml-3", onClick SendToServer ] [ text "Send to SGX Server" ]
            ]
        ]


textArea1 : Model -> Html Msg
textArea1 model =
    textarea
        [ rows 15, cols 60, style "margin" "5px auto", style "padding" "5px", readonly True ]
        [ text model.leftPane ]


textArea2 : Model -> Html Msg
textArea2 model =
    textarea
        [ rows 15, cols 60, style "margin" "5px auto", style "padding" "5px", readonly True ]
        [ text model.rightPane ]


nav : Model -> Html Msg
nav model =
    Html.header [ class "navbar jumbotron" ]
        [ div [ class "container" ]
            [ h2 [] [ text "Differentially Private TEE: Data Loader" ]
            , p [ class "lead" ] [ text "POC for BSA Helsing Interview" ]
            , input [ placeholder "Enter SGX Server Address", value model.serverAddr, onInput InputServerAddr ] []
            ]
        ]
