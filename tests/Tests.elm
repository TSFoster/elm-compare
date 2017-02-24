module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (Fuzzer, list, int, string, tuple)
import Compare exposing (..)


record : Fuzzer Record
record =
    Fuzz.map3 Record int int string


type alias Record =
    { hello : Int
    , world : Int
    , bang : String
    }


record1 : Record
record1 =
    { hello = 1
    , world = 2
    , bang = "!"
    }


record2 : Record
record2 =
    { hello = 1
    , world = 3
    , bang = "!"
    }


all : Test
all =
    describe "Compare"
        [ describe "Basics"
            [ test "Can compare records with Compare.by" <|
                \() ->
                    (by .hello descending) record1 record2
                        |> Expect.equal EQ
            , test "Can chain comparisons with Compare.thenBy" <|
                \() ->
                    (by .hello thenBy .world ascending) record1 record2
                        |> Expect.equal LT
            , test "Can chain comparisons with multiple Compare.thenBy" <|
                \() ->
                    (by .hello thenBy .world thenBy .bang ascending) record1 record2
                        |> Expect.equal LT
            ]
        , describe "Ascending and descending"
            [ fuzz (list record) "Lists sorted with Compare.ascending are the reverse of lists sorted with Compare.descending" <|
                \records ->
                    let
                        sort =
                            by .hello thenBy .world thenBy .bang
                    in
                        List.sortWith (sort ascending) records
                            |> List.reverse
                            |> Expect.equal (List.sortWith (sort descending) records)
            ]
        , describe "Reverse"
            [ fuzz (tuple ( record, record )) "thenByReverse sorts in opposite order to thenBy" <|
                \( a, b ) ->
                    (Compare.with (always <| always EQ) thenBy .hello ascending) a b
                        |> Expect.equal
                            ((Compare.with (always <| always EQ) thenByReverse .hello descending) a b)
            ]
        ]
