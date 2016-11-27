---
title: Validation in F#
tags:
  - F#
  - validation
  - .net
  - webapi
---

[The full code for this article is up on GitHub.](https://gist.github.com/jon49/c2835a9c85b43036323547dc3706ebd2)

I like to the keep things as simple as possible and, ideally, reusable. At my
previous employment I came up with a method of validation, but I was never
entirely happy with the results. Some of the code repeated itself, and it was
difficult to extend to arrays and array comparison. So, I went back to the
drawing board building on top of the ideas that I created with the first
validation library I created.

Here's how the original API looked:

```fsharp
validate "Name" a.Name [nonEmptyString]
```

So, you needed to add the name of your property, the property, and a list of
validators you would like to validate. The list of validators would return a
`Choice<string, 'a>`.

The new validation has a pretty straight forward API that is used throughout.
You can validate against an `Object`, `Array`, `Primitive`, or `Raw` value.

The `Object` validation validates against each property in a `Record`. If one
fails then it will continue to validate the other properties also. But if
there are multiple validators on a single property the first failure will
return but not the others. `Object` has the following signature:

```fsharp
| Object of
    value : Expr<'a> *
    required : bool *
    proof : ('a -> (string list option) list)
```

Where `value` is the quotation value of the property you are testing.
`required` tests if the property is `null` or not if you mark it as true,
otherwise it doesn't care if it is `null` or not. `proof` is the list of
provided validators. A single validator has the signature
`a -> string option`. If the property is valid the validator returns `None`
otherwise it returns `Some` with a message describing why it didn't pass
validation.

I like this way of validating since it keeps things simple. The validators are
reusable functions which return a simple `string option`. The validators are
composable functions that can be put in a list. The discriminated union
validation object is also composable.

Some things that I don't like about validating this way. There is no compile
time check to determine if you validated each field in an object. For that
matter there is no runtime test for that either. It would be nice to have a
least a runtime way to tell if all properties were tested, or, even better, a
compile time way. But this works for now.

Here's an example of using all the validators in with an object.

```fsharp
type Person =
    {
    Name : Name
    BirthDate : DateTime
    Favorites : string[]
    FavoriteNumbers : int[]
    }
    static member Proof a =
                [
                prove <| Primitive (<@ a.BirthDate @>, true, [])
                prove <| Object (<@ a.Name @>, true, Name.Proof)
                prove <|
                    Array (
                        <@ a.Favorites @>,
                        true,
                        [arrayMinLength 1],
                        (fun favorite -> Primitive (<@ favorite @>, true, [stringMax 5]) ))
                prove <|
                    Array (
                        <@ a.FavoriteNumbers @>,
                        true,
                        [arrayMinLength 1],
                        fun favorite -> Primitive (<@ favorite @>, true, [greaterThan 2])
                    )
                prove <|
                    Raw (
                        (a.Favorites, a.FavoriteNumbers),
                        "Person.Favorites, Person.FavoriteNumbers",
                        [
                        fun (a, b) ->
                            match a, b with
                            | null, null | null, _ | _, null -> Some "Arrays must not be null."
                            | _ -> None
                        fun (a, b) ->
                            if a.Length = b.Length then
                                None
                            else
                                Some <| sprintf "Arrays must have same length but Person.Favorites has %i and Person.FavoriteNumbers has %i" a.Length b.Length
                        ]
                    )
                ]
    static member Validate a =
        prove <| Object (<@ a @>, true, Person.Proof)

let jon = {
    Name = { First = "Jon"; Last = "Nyman1" }
    BirthDate = new DateTime(1947, 9, 9)
    Favorites = [| "Reading"; "Red";  "Writing" |]
    FavoriteNumbers = [| 1 |]
    }

jon
|> validate Person.Validate
// |> ....

// OR
jon
|> validate (fun a -> prove <| Object (<@ a @>, true, Person.Proof))

```
where `prove` is

```fsharp
let rec prove validation =
    match validation with
    | Primitive (v, required, fs) ->
        match required, getValue v with
        | true, None -> Some [sprintf "The value `%s` is required but was found to be `null`." v.Type.Name]
        | false, None -> None
        | _, Some value ->
            fs
            |> List.fold (fun acc f ->
                match acc with
                | None -> f value
                | Some _ -> acc
                ) None
            |> Option.map (fun x -> [printParameterWith " - " v + x] )
    | Object (v, required, f) ->
        match required, getValue v with
        | true, None -> Some [sprintf "The object `%s` is required but was found to be `null`." (getOrElse "Unknown Parameter" <| getParameterName v)]
        | false, None -> None
        | _, Some x ->
            f x
            |> List.fold (
                fun acc option ->
                match option, acc with
                | Some newError, Some error -> Some (List.append error newError)
                | Some newError, None -> Some newError
                | None, Some error -> Some error
                | None, None -> None
                ) None
    | Array (vs, required, proof, proveItems) -> 
        match required, getValue vs with
        | true, None -> Some [sprintf "%s: %s" (getOrElse "Unknown Parameter" <| getParameterName vs) "This array is required."]
        | false, None -> None
        | _, Some xs ->
            let validSelf =
                proof
                |> List.fold (fun acc f ->
                    match acc with
                    | None -> f xs
                    | Some _ -> acc
                ) None
            match validSelf, obj.Equals(vs, null) with
            | Some error, _ -> 
                Some [(printParameterWith ": " vs) + error]
            | _, true ->
                None
            | None, false ->
                xs
                |> Array.fold (fun (i, acc) x ->
                    let i = i + 1
                    match (prove (proveItems x) ), acc with
                    | Some newError, Some error -> 
                        (i, Some <| List.append error [prettyIndex i newError])
                    | Some newError, None -> (i, Some [prettyIndex i newError])
                    | None, Some error -> (i, Some error)
                    | None, None -> (i, None)
                ) (-1, None)
                |> snd
                |> Option.map (fun xs -> (printParameterWith ":" vs)::xs)
    | Raw (a, msg, fs) ->
        fs
        |> List.fold (fun acc f ->
            match acc with
            | None -> f a
            | Some _ -> acc
            ) None
        |> Option.map (fun x -> [msg+" - "+x] )
```

And `validate` is:

```fsharp
let validate f a =
    match f a with
    | Some xs -> Choice1Of2 <| String.concat "\n" xs
    | None -> Choice2Of2 a
```

And `Validate` is:

```fsharp
type Validate<'a> =
    | Object of
        value : Expr<'a> *
        required : bool *
        proof : ('a -> (string list option) list)
    | Array of
        value : Expr<'a[]> *
        required : bool *
        proof : ('a[] -> string Option) list *
        proveItems : ('a -> Validate<'a>)
    | Primitive of
        value : Expr<'a> *
        required : bool *
        proof : ('a -> string Option) list
    | Raw of
        value : 'a *
        message : string *
        proof : ('a -> string Option) list
```

Other F# validation libraries (that I know of).

http://fsharpforfunandprofit.com/posts/recipe-part2/
