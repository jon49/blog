---
title: JavaScript-Style Promises in F#
tags:
   - F#
   - Promises
   - Async
---

Working in enterprise level back end software often times I need to get
information from many different sources. When you have enough of these sources
the time it takes to get all the information can really add up. That's when F#
`async` work flow really comes in handy. Except, there is a gotcha.

Let's say we have two sources we need to fetch data from:

```fsharp
let myData () = async {
    let! a = myData1 ()
    let! b = myData2 ()
    let resultA = a
    let resultB = b
    // ... do stuff
    // return result
}
```

So, when you look at that it looks like it should fetch the two data sources at
the same time. Well, it doesn't. It does it one at a time, serially. It just
doesn't block the thread while it is doing the fetching for each asynchronous
call.

This is what you need to do to do it in parallel:

```fsharp
let myData () = async {
    let! a = Async.StartChild <| myData1 ()
    let! b = Async.StartChild <| myData2 ()
    let! resultA = a
    let! resultB = b
    // ... do stuff
    // return result
}
```

Now it is doing it at the same time! To me this feels a bit unintuitive. Enter
JavaScript-style promises. Promise objects point to data and don't execute
until you are ready to execute them as an `async` function does in F#.

```js
let myData () =
    Q
    .all([myData1(), myData2()]) // Call two promises at the same time.
    .spread((resultA, resultB) => {/* Do stuff here. */})
```

Could we do something like that in F#? We can mimic the process in F# by having
multiple functions depending on how many asynchronous processes you would like
to run at a time.

Let's say you would like to have two asynchronous functions run at once.

```fsharp
module Async =
    let Spread2 a b =
        async {
            let! a = Async.StartChild a
            let! b = Async.StartChild b
            let! result1 = a
            let! result2 = b
            return result1, result2
        }
        |> Async.RunSynchronously
```

Which would flow like so:

```fsharp
let myData () =
    Async.Spread2 (myData1 ()) (myData2 ())
    |> fun (resultA, resultB) -> // Do stuff here.
```

Pretty close to what the JavaScript promise looked like. In my opinion this
work flow is much more intuitive and cleaner. It has a nicer flow than the
`async` computation-style programming by not having to deal with the boiler
plate code. I could see having a few parallel functions all the way up to perhaps
`Async.Spread6`. It would be very rare for me to ever need to call anything with
more external calls. Usually, I'm only calling two or three web services with the
rare five or six.

A variation on the function above would be to add mapping functions to your parallel
function. I'm not sure if that would be useful in practice, but if it is I'll be
adding it to mine.

```fsharp
module Async =
    let Spread2With (a, f1) (b, f2) =
        async {
            let! a = Async.StartChild a
            let! b = Async.StartChild b
            let! result1 = a
            let! result2 = b
            return (f1 result1), (f2 result2)
        }
        |> Async.RunSynchronously
```

I also debate whether it is smart to add the `Async.RunSynchronously` at the end. If I didn't have it I could use `Spread2` to create `Spread4` etc. If I ever needed more than six it might be worth it. But for now I haven't run into that problem since I started using this pattern.

Inspiration for this post:

<http://fsharpforfunandprofit.com/posts/recipe-part2/#comment-1508742658>  
<http://stackoverflow.com/a/15829290/632495>
