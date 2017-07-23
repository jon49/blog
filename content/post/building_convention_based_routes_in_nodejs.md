---
date: 2016-06-07
title: Building a Convention Based Routes in Node.js
tags:
   - node.js
   - convention over configuration
---

> [Convention over
> configuration](https://en.wikipedia.org/wiki/Convention_over_configuration)
> (also known as coding by convention) is a software design paradigm which
> seeks to decrease the number of decisions that developers need to make,
> gaining simplicity, and not necessarily losing flexibility.

It seems in programming, if we haven't learned the basic practices of others,
we'll end of repeating those practices; discovering them on our own. This isn't
necessarily a bad thing. It can be a good way to learn. But at the same time,
we can learn faster just by learning from others first. I also like to think
about how a pattern or architecture could come about.

Take for example the library [intercooler.js](http://intercoolerjs.org/). You
can see where that library originated from. In HTML you can call a function
directly by adding an event to it. E.g.,

```js
<div onclick="clicked(this, 'my string I am passing')">Click Me!</div>
```

So, intercooler.js took it the next step. They made it so you can create a
declarative HTML syntax. Similar to the code above, but an abstraction of that.
Now, I can see where [angular.js](https://angularjs.org/) came from (note, I've
never actually used angular.js). It just takes another abstraction layer up.

Well, for convention of configuration. I came up with something for node.js,
but, after coming up with the idea I noticed that other people had come up with
similar ideas. In the end I liked mine more than theirs. But, many times we
think we are being original, but many of the ideas have probably existed for
the past thirty plus years.

I went to a class at work where they were showing ASP.NET WebAPI. It is also
convention based and pretty much did the same thing I came up with, but more
powerful. I can understand why people don't like convention over configuration
since you need to learn the conventions before you can understand the code,
since there is a certain amount of "magic". But once you get past the magic it
becomes nice since you don't need to write the same code over and over again.

So, after that long introduction, here's how I did convention based node.js.

The file structure is like so:

```
root
  â”• controllers
    â” people
    â”‚ â” get-{id}.js
    â”‚ â”• get-{id}-animals.js
    â”• animals
      â” get-{id}.js
      â”• delete-{id}.js
```

These directories/files would correspond to the routes:

```
/api/people/{id} â†’ Method: GET
/api/people/{id} â†’ Method: GET
/api/animals/{id} â†’ Method: GET
/api/animals/{id} â†’ Method: DELETE
```

As you can see you could set up whatever combination you would like. I like
this method of convention also, since it keeps things simple. All your routes
are in your controller and easy to scan. So, when I need to edit a file I can
quickly find which one I'm looking for. Some of the other libraries nest the
routes in directories, which becomes very tedious.

I use [swagger](http://swagger.io/) to map the route definitions to the route
methods. This way, I must have documentation in order to have a route. No
documentation, no route. But it also leaves me the flexibility to create routes
outside of this documentation if I really need to. But it just means it won't
be set up in the normal way.

So, in swagger (using YAML), the code would look like so:

```yaml
paths:

    /api/people/{id}:
      get:
        _call:
          - [params, id]

    /api/animals/{id}:
      delete:
        _call:
          - [params, id]
```

So, you can see how you can pass pretty much anything into your route method.
Each array element is passed into the method in the order given. The call takes
the parameters from the `request` object that `express.js` passes in. For more
complex items you can even pass in an object from different parts of the
`request` object like so:

```yaml
_call:
  - userId: [params, id]
    userName: [user, username]
    guid: [user, guid]
```

Where `user` comes from some middleware which validates the user authentication
information.

This way of doing things also comes in handy since it means I can automate
integration tests. I can test each route in the `swagger` file and make sure
that it is validated against the json-schema associated with that route.

So, let's look at the glue for all of this. I didn't create an npm library for
this. I was thinking I would eventually, but since I just use WebAPI now, I
don't want to support it. But, luckily the code is simple enough that that
isn't a problem!

```ts
import path = require('path')

module SwaggerRoutes {
    export interface Options {
        swagger: any
        baseRoute: any
        response: any
        baseDirectory: string
    }
    export interface CreateRoutes {
        (options: Options): void
    }
}

const
fail = reason => {throw new Error(reason)},
type = o => Object.prototype.toString.call(o),
isFunction = o => type(o) === '[object Function]',
isArray = o => type(o) === '[object Array]',
isObject = o => type(o) === '[object Object]',
getPropValue = (path, obj) =>
    path.reduce((acc, prop) => acc === void 0 ? void 0 : acc[prop], obj),
args = (o, xs) =>
    xs.map(x => (
        isArray(x)
            ? getPropValue(x, o)
        : isObject(x)
            ? (Object
                .keys(x)
                .reduce((acc, name) =>
                    (acc[name] = getPropValue(x[name], o), acc), {}))
        : void 0
    ))

const routePath = (route: string) => {
    const
    components = route.slice(1).split('/'),
    dir = components[0],
    baseFileName = components.slice(1).join('-')
    return [dir, baseFileName]
}

const expressCallback = (response, routeProperties, method, controller) =>
    (request, client, error) => {

        const send = <any> response.bind(response, client)
        controller.apply(controller, args(request, routeProperties[method]._call))
        .then(send)
        .catch(error)

    }

const createRoutes: SwaggerRoutes.CreateRoutes = (o: SwaggerRoutes.Options) => {
    const paths = o.swagger.paths
    Object.keys(paths)
    .filter(x => x.charAt(0) === '/')
    .forEach(routeName => {

        const
        routeProperties = paths[routeName],
        basePath = routePath(routeName)

        Object.keys(routeProperties)
        .forEach(method => {
            if (routeProperties[method]._call) {
                const
                requirePath = path.resolve(
                    __dirname,
                    path.join(
                        o.baseDirectory,
                        basePath[0],
                        (basePath[1] ? `${method}-${basePath[1]}` : method))),
                handler = require(requirePath),
                controller =
                    isFunction(handler)
                        ? handler
                    : isFunction(handler.default)
                        ? handler.default
                    : fail('Could not retrieve `handler` function.')

                const
                routePath = routeName.replace(/{(\w+)}/g, ':$1'),
                altPath =
                    (routeProperties[method].parameters || [])
                    .reduce((acc, x) =>
                        x.required ? acc : acc.replace(RegExp(`/:${x.name}`), ''), routePath),
                routePaths = altPath !== routePath ? [altPath, routePath] : [routePath]

                routePaths.forEach(x => {
                    o.baseRoute(x)
                    [method](expressCallback(o.response, routeProperties, method, controller))
                })

            }
        })

    })
}

export = createRoutes
```

Here's how you would call that code to set up your routes:

```ts
import swaggerRoutes = require('./swagger-routes')
const yaml = require('js-yaml')

swaggerRoutes({
    swagger: yaml.load(readFileSync('./api/api.yml', 'utf-8')),
    baseRoute: authenticatedRoute,
    response: (client: express.Response, result) =>
        client.send(omit(['httpStatusCode'], withMessageAs(result))),
    baseDirectory: '../controllers'
})
```
