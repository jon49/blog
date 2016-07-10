---
date: 2016-07-10
title: Swagger is too Restrictive
tags:
  - swagger
  - REST
  - API
---

Swagger has a definite idea of what makes a good URL. But if you want to do
anything outside of that good luck. I think, that even though it seems like a
good idea to push people towards a standard it doesn't allow the user to really
create RESTful APIs which suit their own needs.

Let's say that you have a reports resource. Sometimes you would like to get the
JSON data of the report. Sometimes you would like a partial static HTML page of
the report. Well, with RESTful APIs you could have something like:

```
GET /api/reports/{id}
```

This will get the data which you wanted. Now, what about the report? You could:

`GET reports/{id}`

But that seems like it would get you a full page, not a partial page. What if
you did this instead?

```
GET /api/reports/{id}
Content-Type text/html
```

The mapping of resources should be use all the available HTTP standards.
Swagger doesn't allow for this. This is unfortunate.  The routes could have
been mapped something like this instead:

```yaml
paths:
  - url: /api/reports/{id}
    headers:
      - Content-Type: text/html
        response: ...
```

It appears that the standard might become more flexible in the future.  [See
the issue on Github](https://github.com/OAI/OpenAPI-Specification/issues/146).
