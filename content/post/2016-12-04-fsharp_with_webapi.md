---
url: /fsharp-with-webapi/
date: 2016-12-04
title: F# with Web API and Railway-Oriented Programming
tags:
  - F#
  - railway-oriented programming
  - .net
  - webapi
---

I presented at the [2016 Desert Code
Camp](http://oct2016.desertcodecamp.com/session/1224). The topic was *WebAPI
with F#*. I also did a video series to go along with the talk. The talk and
video series basically goes over how to use F# in a functional manner by
building out all the pieces from scratch.

Here's the series, hope you enjoy it!

[F# WebAPI From Start to
Finish](https://www.youtube.com/playlist?list=PLBrr7-AbuzAfeA4vVhHEDsaAPBep2SUVI).

Some set up steps and notes that are important to the success of the project:

Rather than using a custom Railway-Oriented code like in the videos you can use
[Chessie](https://fsprojects.github.io/Chessie/railway.html).

[I've updated my validation library.](http://jnyman.com/2016/11/27/validation_in_fsharp/)

## Setting Up Your Project

- [Install Visual F# Power Tools](https://visualstudiogallery.msdn.microsoft.com/136b942e-9f2c-4c0b-8bac-86d774189cff)
- Create new C# WebAPI
- Create new F# Library
- Add reference to F# Library from C# project.
- Make sure works
- Add reference to System.Net.Http
- Add reference to System.Web.Http &rarr; Need to install Nuget package
  Microsoft.AspNet.WebApi.Core
- [Add configuration](http://blog.ploeh.dk/2015/03/19/posting-json-to-an-f-web-api/)
  &rarr;
  `GlobalConfiguration.Configuration.Formatters.JsonFormatter.SerializerSettings.ContractResolver = new Newtonsoft.Json.Serialization.CamelCasePropertyNamesContractResolver();`
- [Add FSharp Converters](https://github.com/eulerfx/JsonNet.FSharp)
- Configuration
    - [JsonProvider](http://fsharp.github.io/FSharp.Data/library/JsonProvider.html)
      &rarr; Use FSharp.Data from Nuget
- Connecting to a database using
  [FSharp.Data.SqlClient](http://fsprojects.github.io/FSharp.Data.SqlClient/)

## Resources for Railway-Oriented Programming

- [https://fsharpforfunandprofit.com/rop/](https://fsharpforfunandprofit.com/rop/)
- [https://fsharpforfunandprofit.com/posts/recipe-part2/](https://fsharpforfunandprofit.com/posts/recipe-part2/)
