port module Main exposing (Msg(..), Natural, main)

{-| The above declaration shows how to:

  - declare a port module
  - expose all the tags of a custom type (Msg)
  - expose only the type (Natural)

-}

-- Shows how to create an alias for a module name (Events)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events as Events exposing (onClick)



-- CUSTOM TYPES


{-| Shows how to define a single variant custom type.
Exposing only the type and not the tags ensures that the values of the type are created only through functions that can enforce constrains.
-}
type Natural
    = Natural Int


{-| Shows how to define a function that creates a value for the above custom type
-}
fromInt : Int -> Natural
fromInt intValue =
    -- Tags of the custom types are also acting as functions that create the custom type.
    -- max function is defined in the Basics module from elm/core and is imported by default. See elm/core for a list of default imports.
    Natural (max intValue 0)


{-| Shows how to unpack custom type parameters. Works only if the type has a single variant.
-}
toInt : Natural -> Int
toInt (Natural value) =
    value


{-| Shows how to define a function in a pointfree style by composing two functions.
-}
toString : Natural -> String
toString =
    -- String.fromInt shows how to use a module that is imported by default.
    toInt >> String.fromInt


{-| Shows how to control the operations on the your custom type.
In this case the code makes sure you are not storing negative values inside the custom type
-}
addInt : Natural -> Int -> Natural
addInt natural intValue =
    let
        -- One ca unpack / destructure a custom type inside a let..in too
        (Natural value) =
            natural
    in
    fromInt (value + intValue)


{-| Shows how to create a type alias for a type that extends records. This alias will extend any other record with the field `name`.
-}
type alias Named a =
    { a | name : String }


{-| Shows how to use the above type alias.
-}
type alias NamedValue a =
    Named { value : a }


{-| Shows how to use the values from an extensible record alias fields
-}
namedToHtml : Named a -> Html msg
namedToHtml { name } =
    text name


namedNaturalToHtml : NamedValue Natural -> Html msg
namedNaturalToHtml namedValue =
    div []
        [ namedToHtml namedValue
        , text ": "
        , text (toString namedValue.value)
        ]


{-| Shows how to create a phantom type
-}
type Unit a
    = Unit Int


{-| When adding two units, the type parameter must be the same.
-}
addUnit : Unit a -> Unit a -> Unit a
addUnit (Unit first) (Unit second) =
    Unit (first + second)


{-| A type to be used with the above Unit type
-}
type Meter
    = Meter


{-| A second type to be used with the above Unit type
-}
type Gram
    = Gram


twoMeters : Unit Meter
twoMeters =
    Unit 2


threeMeters : Unit Meter
threeMeters =
    Unit 3


fewGrams : Unit Gram
fewGrams =
    Unit 21


someMeters : Unit Meter
someMeters =
    -- This works because the two units match
    addUnit twoMeters threeMeters



{- This value will throw an error if uncommented
   impossibleAdd : Unit Meter
   impossibleAdd =
       -- This doesn't work because the types don't match
       addUnit fewGrams someMeters
-}
-- MODEL


{-| Shows how to tie a name to a record type.
-}
type alias Model =
    { count : Natural
    , namedCount : NamedValue Natural
    }


{-| Shows how to ignore a parameter you are not using
This purposefully shows a function without a type signature although top level functions and values should have type signatures.
-}
init _ =
    ( { count = Natural 0
      , namedCount =
            { name = "Natural", value = Natural 0 }
      }
    , Cmd.none
    )



-- UPDATE


{-| Shows how to give a new name to a more complex type
-}
type alias Naturals =
    List Natural


{-| Shows how to define a custom type with multiple variants
-}
type Msg
    = Increment
    | Decrement
    | OnSubscription (Result String Naturals)


{-| Shows how to unpack a record parameter while still keeping the full parameter.
You can use a subset of the fields in the record if you only need certain fields.
This function type signature has been purpusefully spread over multiple lines to show that complex signatures need not be single line.
-}
update :
    Msg
    -> Model
    -> ( Model, Cmd msg )
update msg ({ count } as model) =
    case msg of
        Increment ->
            ( { model | count = addInt count 1 }, Cmd.none )

        Decrement ->
            -- Shows how to create a new scope with a let..in expression
            let
                -- values and function defined inside let..in can have type signatures although they usually don't
                newValue : Natural
                newValue =
                    addInt count -1
            in
            if newValue == count then
                -- Shows how to call a port
                ( model, reportError "There are no negative Natural numbers" )

            else
                ( { model | count = newValue }, Cmd.none )

        -- Shows how to unpack a variant by matching against the contained variants
        OnSubscription (Ok naturals) ->
            case naturals of
                -- Shows how to pattern match on a List
                [] ->
                    -- Shows how to recursively call update in order to avoid duplicating code.
                    update (OnSubscription (Err "Received an empty list")) model

                -- Shows how to pattern match on a list with a fixed number of elements
                [ first ] ->
                    ( { model | count = first }, Cmd.none )

                -- Shows how to pattern match on a list with at least two elements.
                first :: second :: _ ->
                    ( { model | count = first }, Cmd.none )

        OnSubscription (Err error) ->
            ( model, reportError error )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Increment ] [ text "+1" ]

        -- Shows how to avoid parentheses by using the backwards pipe operator
        , div [] [ text <| toString model.count ]

        -- Shows how to used a function from a module without having to expose it in the import section.
        , button [ Events.onClick Decrement ] [ text "-1" ]
        , div [] [ namedNaturalToHtml model.namedCount ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    -- Listen to the incomming port only if condition in the model is met
    if toInt model.count < 5 then
        -- Show how to use an anonymous function (lambda expression)
        fromJS
            (\value ->
                case List.map String.toInt value of
                    [] ->
                        OnSubscription (Err "Received an empty list")

                    (Just int) :: _ ->
                        let
                            output =
                                -- This shows how to prepend an element to a list
                                fromInt int :: []
                        in
                        if int >= 0 then
                            OnSubscription (Ok output)

                        else
                            -- Shows how to structure a complex function application by using the "pipe" operator
                            ("Received a negative number: " ++ String.fromInt int)
                                |> Err
                                |> OnSubscription

                    -- Shows how to catch all remaining variants. Watch out for this pattern as it can create troubles.
                    _ ->
                        OnSubscription (Err "Received a list that started with a non-integer ")
            )

    else
        Sub.none



-- WIRING


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- PORTS


{-| Shows how to define an outgoing port
-}
port reportError : String -> Cmd msg


{-| Shows how to define an incomming port.
The first parameter is a function that takes the data received from JS and produces a message that the app understands.
-}
port fromJS : (List String -> msg) -> Sub msg
