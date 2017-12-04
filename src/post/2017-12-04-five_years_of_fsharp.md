---
title: Over 5 Years of F#
tags:
  - F#
  - F# Advent Calendar
---

Originally when I was planning on doing a post for the [F# Advent
Calendar](https://sergeytihon.com/2017/10/22/f-advent-calendar-in-english-2017/)
I was thinking I would do one on a [tool I'm building for C# in
F#](https://github.com/jon49/SQLToDapper) that mimicks some of the functionality
of the fantastic library
[`FSharp.Data.SqlClient`](http://fsprojects.github.io/FSharp.Data.SqlClient/).
But then I was thinking, "I've been messing around with F# for a while and have
done some production work with it; why not share some of the experiences that I
have had with F#?"

### Getting started with programming and F\#

I originally started my professional career as an electrical engineer. But then
I got a job where I was bored and started automating some of the work I was
doing with Excel.

After leaving that company I started up my own gig writing add-ons for Excel. I
believe the first thing that drew my attention to F# was a library called [Excel
DNA](https://excel-dna.net/). So, I started to learn F# after having picked up
VB.NET and C#.

I wrote a [little script in
F#](https://gist.github.com/jon49/0940bcba98c4dce8da7a89cc66dd52a4) to find the
earliest dated file in my old repos. Unfortunately, I had moved and copied the
files since that time, so the original creation date was not the same. The
earliest last modified date comes out to be August 27, 2013 for my Excel Time
Card application. But looking at the [actual release of that product puts it
back to May 16, 2012](http://jnyman.com/2012/05/16/excel_time_card_completed/).
So, it looks like I've been using F# for at least five and a half years.

### Getting a full time job

Apparently I had started getting into Excel too late. When I needed to get a
full time job there weren't as many Excel jobs out there for building add-ons.
Many of the people that freelanced Excel were starting to look elsewhere for
work.  So, I started learning JavaScript and did a programming boot camp to
learn web development.

### Developing with F\#

My first full time job out of the gate was with Node.js. I took the job because
they promised I could do F# also :-). It was a .NET company but the team I
joined was small and off to itself. After programming in Node.js for a while I
realized I was making similar abstractions as ASP.NET's WebAPI. So, after my
team lead left the company, I switched it over to F# (with a C# project wrapping
the F# code, just in case the F# didn't work out).

I learned how to do ["railway-oriented
programming"](http://fsharpforfunandprofit.com/posts/recipe-part2/) from Scott
Wlaschin's great blog posts. It was great.

### Moving on

I helped hire a junior developer, but, unfortunately, I was only there for a few
more weeks before I was hired by another company. As much as I enjoyed working at
that first company, the opportunity to work 100% remote was too great to pass up.

A few months later, I asked the junior dev how it was going with the F# code. He said that he loved
it and it was so much nicer to work with and to read than C#. Unfortunately, since
he was only one of a couple that used F# at the company and the only one that
was doing full-on F# development, it made it more difficult to fix problems since
he couldn't really ask for help. Then the company started moving toward
continuous integration, and for some reason the F# code was not working in the test
environment. On top of that, I had used `FSharp.Data.SqlClient` but did not have
a local SQL Server application running, so as the application continued to grow
the application became slower and slower. Ultimately, the application was moved to C#.

### F# at the remote company

The next company I started working at also said I could do work with F#
but only for a limited amount of projects. So, I would explicitly ask if
it was OK to write a project in F#. It was a very small company of about 10
people, so I knew that leaving legacy F# code could potentially be a problem
since there aren't a whole lot of F# programmers in my neck of the woods.

I spent most of my time writing T-SQL. But any temporary tools I needed to
create during the migration process (Access to SQL Server) I would do in F#. F#
is a fantastic tool for this purpose. I also wrote testing code with F#.

Unfortunately, the industry was moving in a new direction, and the product I was
working on wasn't as important as it had been for the company and was no longer
given priority. I was let go.  Much of my temporary code has now turned into
permanent code.

### Evangelizing F\#

[Desert Code Camp 2017](http://desertcodecamp.com/conference/notfound) is
the [second year](http://jnyman.com/2017/10/15/desert_code_camp_2017/) that I've
presented at that conference. The first year I presented on my [experiences
doing F# with WebAPI](http://jnyman.com/2016/12/04/fsharp_with_webapi/). The
second year I took a step back and did just an [introduction on F# and some
practical scripting with
F#](http://jnyman.com/2017/10/15/desert_code_camp_2017/) that you can use in
your work even if you can't do F# all the time.

### Life lessons learned with F\#

Here are some lessons that I've learned from the last five years that I've
programmed with F#.

1. F# is fun.
2. C# is an amazing language with amazing tooling. [That's why it is much more
   difficult to get people to use F# instead of
   C#,](http://ericsink.com/entries/fsharp_chasm.html) [unlike other languages
   like Objective-C and
   Java.](https://thomasbandt.com/the-problem-with-fsharp-evangelism)
3. F# is an amazing language and the tooling is getting much better with VS
   2017.
3. Even if you can't use F# as your main language [there are still things you
   can do to use F# in your daily
   work](https://fsharpforfunandprofit.com/posts/low-risk-ways-to-use-fsharp-at-work/),
   like creating scripts for automating repetitive tasks.
4. I need to be careful when and how I introduce F# to the team. Although I'm
   really stoked about F# and think it is a great language to use, if the whole
   team isn't on board, it is a better idea to introduce it slowly in a way that
   won't negatively impact the team.
5. Maybe your team will never embrace it. But learning a different paradigm can
   help you become a better programmer and bring good insights back to C# or
   whatever other language you are using. This is what the industry is seeing as
   they introduce more and more functional concepts back into the
   object-oriented world.
6. There are some [places where F# really
   shines](https://fsharpforfunandprofit.com/posts/why-use-fsharp-intro/). If my
   development team ever hits some of those hurdles I can always point out some
   of the great benefits of F# for those circumstances. You need to [work with
   units](https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/units-of-measure)
   that are statically typed - F#! You need the [business logic to not allow
   illegal
   states](https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/)
   \- F#! You need [concise syntax and an expressive
   language](http://fpbridge.co.uk/why-fsharp.html#design) - F#!  You need
   [on-the-fly type
   checking](https://docs.microsoft.com/en-us/dotnet/fsharp/tutorials/type-providers/)
   for external data - F#! [You see my
   point](http://fpbridge.co.uk/why-fsharp.html) :-)


