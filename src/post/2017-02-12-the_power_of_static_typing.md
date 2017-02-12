---
title: The Power of Static Typing
tags:
  - Static Typing
  - F#
---

From what I understand [static typing makes programmers more productive and
gives implicit documentation to the code
base](http://www.cs.cmu.edu/~NatProg/papers/CHI2016-SIG-ProgLang-Usability.pdf)
- although explicit documentation is also very helpful.  It also seems to make
the tools we use much more powerful.

One of the problems of static typing is that your code becomes more verbose.
With programming languages like F# the compiler will implicitly type as much
of your program as possible. Where it fails, you need to type it yourself.

Not only that but many times static languages will provide tools to do the
typing for you. F# has [Type
Providers](https://docs.microsoft.com/en-us/dotnet/articles/fsharp/tutorials/type-providers/)
which will dynamically create types for your program on the fly, lessening the
burdens of a statically typed system. One of my favorite libraries that does
this is [`FSharp.Data.SqlClient` - *Not your grandfather's
ORM*](http://fsprojects.github.io/FSharp.Data.SqlClient/) which will
statically type your calls to SQL Server letting you even type raw SQL in your
code. Another useful one is the [JSON Type
Provider](http://fsharp.github.io/FSharp.Data/library/JsonProvider.html).

With F#, [WebSharper](http://websharper.com/), and [SQL Server Data
Tools](https://msdn.microsoft.com/en-us/library/hh272686(v=vs.103).aspx)(SSDT)
you can have static typing from your database all the way down to your client
web app. You can literally keep everything in sync with each other from across
your entire infrastructure. This seems really huge to me. Programming in any
other way seems like programming in the past, by decades. Unfortunately, it
seems like it takes ages for the programming community and business industry
to get on board. It is understandable and mind boggling at the same time.

So, SSDT, can give you static typing across databases, it seems to work best
when they live on the same server when you track the databases in the same
SSDT solution. But you can also have this static typing across different
servers in different SSDT solutions by referencing the `dacpac` of the
different databases you are connecting to. It also makes testing much simpler
with the help of [`tSQLt`](http://tsqlt.org/) testing framework.

I've never used [WebSharper](http://websharper.com/) before but it looks like
it is a wonderful way to write your back end and front end code. I'm not sure
if other .NET frameworks can give you the same static typing that WebSharper
can, but [WebSharper can generate your end points for you in distributed
applications, letting them be private or public end
points](http://websharper.com/blog-entry/5204/distributed-web-applications-in-f-with-websharper).

So, with all this incredible technology that can make us so much more
productive why do we not embrace this technology and stop doing the computer's
work for it? I'm sure there are many reasons, including psychology and
business maintainability. Which I won't enumerate some here, which I
think could possibly be reasons. Let's start embracing this technology and
start slowly introducing them where we can in are work places. It might take
another ten or twenty years to be able to really start letting the computer do
its work rather than us doing its work, but the time to start planting the
seeds is now.

