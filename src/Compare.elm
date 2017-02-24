module Compare
    exposing
        ( by
        , with
        , thenBy
        , thenWith
        , thenByReverse
        , thenWithReverse
        , ascending
        , descending
        )

{-| DSL for creating compare functions

This small module provides a concise DSL for creating comparison functions.

# Comparisons by value

Oftentimes, you will be able to convert a value to another, comparable, value. `by` takes a function which converts a value to a comparable value. For example, to get a list of bank account holders, ordered by wealth:

    >>> List.sortWith (Compare.by (.transactions >> List.sum) descending)
    ...     [ { holder = "James Joyce", transactions = [100.00, -25.00, -2.99, 30.00] }
    ...     , { holder = "Bill Bryson", transactions = [999.02, -233.00, -400.00, -300.00] }
    ...     ]
    ...         |> List.map .holder
    [ "James Joyce", "Bill Bryson" ]

@docs by

# If comparing by the first value does not create a definitive order, comparisons can be chained with `thenBy` and `thenByReverse`. A typical example would be sorting an address book by last name then first name:

    >>> List.sortWith (Compare.by .lastName thenBy .firstName thenByReverse .age ascending)
    ...     [ { firstName = "Andy", lastName = "Baldwin", age = 90 }
    ...     , { firstName = "Bert", lastName = "Anderson", age = 23 }
    ...     , { firstName = "Alec", lastName = "Anderson", age = 8 }
    ...     , { firstName = "Alec", lastName = "Anderson", age = 100 }
    ...     ]
    [ { firstName = "Alec", lastName = "Anderson", age = 100 }
    , { firstName = "Alec", lastName = "Anderson", age = 8 }
    , { firstName = "Bert", lastName = "Anderson", age = 23 }
    , { firstName = "Andy", lastName = "Baldwin", age = 90 }
    ]

@docs thenBy, thenByReverse

Comparison declarations always end with either `ascending` or `descending`. These functions return the final comparison function of type `a -> a -> Basics.Order`.

@docs ascending, descending


# Comparisons with arbitrary compare functions

If converting values to comparable types alone is not enough, arbitrary comparison functions can be introducted by swapping out `by` for `with`.

    >>> Compare.with
    ...     (\player opponent ->
    ...         if List.member (opponent.name) player.alwaysBeats then
    ...             GT
    ...         else if List.member (player.name) opponent.alwaysBeats then
    ...             LT
    ...         else
    ...             EQ
    ...     )
    ...     thenBy .strength ascending
    ...     { name = "Ogre"
    ...     , strength = 100
    ...     , alwaysBeats = [ "Yeti", "Dragon" ]
    ...     }
    ...     { name = "Cyborg"
    ...     , strength = 20
    ...     , alwaysBeats = [ "Ogre", "Kappa" ]
    ...     }
    LT


@docs with, thenWith, thenWithReverse

-}


{-|
-}
by : (a -> comparable) -> ((a -> a -> Order) -> b) -> b
by fn =
    with (comp fn)


{-|
-}
with : (a -> a -> Order) -> ((a -> a -> Order) -> b) -> b
with fn next =
    next fn


{-|
-}
thenBy : (a -> a -> Order) -> (a -> comparable) -> ((a -> a -> Order) -> b) -> b
thenBy ord fn =
    thenWith ord (comp fn)


{-|
-}
thenWith : (a -> a -> Order) -> (a -> a -> Order) -> ((a -> a -> Order) -> b) -> b
thenWith ord fn next =
    next <|
        \x y ->
            case ord x y of
                EQ ->
                    fn x y

                order ->
                    order


{-|
-}
thenByReverse : (a -> a -> Order) -> (a -> comparable) -> ((a -> a -> Order) -> b) -> b
thenByReverse ord fn =
    thenWithReverse ord (comp fn)


{-|
-}
thenWithReverse : (a -> a -> Order) -> (a -> a -> Order) -> ((a -> a -> Order) -> b) -> b
thenWithReverse ord fn next =
    next <|
        \x y ->
            case ord x y of
                EQ ->
                    fn y x

                order ->
                    order


{-|
-}
ascending : (a -> a -> Order) -> a -> a -> Order
ascending fn a b =
    fn a b


{-|
-}
descending : (a -> a -> Order) -> a -> a -> Order
descending fn a b =
    fn b a


comp : (a -> comparable) -> a -> a -> Order
comp fn x y =
    compare (fn x) (fn y)
