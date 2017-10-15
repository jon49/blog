---
title: Authentication and Authorization in ASP.NET Core
tags:
  - asp.net core
  - authentication
  - authorization
---

One thing that really got me frustrated in WebAPI 2.0 was creating custom
authentication. Eventually I found a [blog post by Rick
Strahl](https://weblog.west-wind.com/posts/2013/Apr/18/A-WebAPI-Basic-Authentication-Authorization-Filter)
that showed how to roll your own authentication/authorization. I wanted to
implement a login ([Basic
Authentication](https://en.wikipedia.org/wiki/Basic_access_authentication))
with username/password that would return a token for later ([Bearer
Authorization](https://en.wikipedia.org/wiki/OAuth)) use. It was quite simple
but really frustrating because there wasn't a whole lot of documentation on
the subject.

Now I want to do something similar for ASP.NET Core. But there wasn't any
documentation on that either. For ASP.NET Core I wanted to implement an OAuth
2.0 with a custom provider. But there isn't any documentation on the subject.
I've struggling to find a solution to it I ran across a couple of [Stack
Overflow](http://stackoverflow.com/).

The first one that I found really easy to follow is here
<http://stackoverflow.com/questions/37396709/simple-token-based-authentication-authorization-in-asp-net-core-for-mongodb-data/37415902#37415902>.
The second one is here
<http://stackoverflow.com/questions/31687955/authorizing-a-user-depending-on-the-action-name/31688792#31688792>.

Both of them together give a good overview of how one can create custom
authentication/authorization. One thing to note is that a `Claim` can have the
first parameter be a simple `string`.

