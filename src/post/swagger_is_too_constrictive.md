---
title: Swagger is too Restrictive
tags:
  - swagger
---

Swagger has a definite idea of what makes a good URL. But if you want to do anything outside of that good luck. I think, that even though it seems like a good idea to push people towards a standard it doesn't allow the user to really create RESTful APIs which suit their own needs.

Let's say that you have a reports resource. Sometimes you would like to get the JSON data of the report. Sometimes you would like a partial static HTML page of the report. Well, with RESTful APIs you could have something like:

```
GET /api/reports/{id}
```

This will get the data which you wanted. Now, what about the report? You could:

`GET reports/{id}`

But that seems like it would get you a full page, not a partial page. What if you did this instead?

```
GET /api/reports/{id}
Content-Type text/html
```

The mapping of resources should be use all the available HTTP standards. Swagger doesn't allow for this. This is unfortunate. It's too bad Swagger has gained so much popularity when a more flexible standard could have been created. The routes could have been mapped something like this instead:

```yaml
paths:
  - url: /api/reports/{id}
    headers:
      - Content-Type: text/html
    response: ...
```

You get the point. This would allow for a much more flexible API that can change with the changing standards of the web. Since the curators have chosen to be staunch in their position that URLs can only return a single type regardless of what is in the headers will make Swagger become obsolete in the long run. Which is unfortunate, because a lot of work has gone into making this standard. Maybe they will eventually catch up to the changing standards of today, but I'll be doing my own thing before that ever happens it appears.
