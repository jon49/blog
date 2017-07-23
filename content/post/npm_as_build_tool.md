---
date: 2016-06-21
title: Using NPM as a Build Tool
tags:
   - npm
   - build tool
   - javascript
   - yaml
---

I really like simplicity. The tools I use, I like them to make my life easy,
not hard. They need to work out of the box. No huge configuration settings,
just make it easy so I can get to work.

Well, along come `grunt`, `gulp`, and now even more tools since I first started
writing this that I won't mention. Two build tools for JavaScript. Wonderful,
we need tools to help us build our files. Wait a minute. We already have a
build tool, it's called NPM. By the time I started learning JavaScript,
`gulp.js` was the cool thing. I think `gulpl.js` is a really nice tool. But, if
you are building simple apps or even complex apps you can get away with just
the command line and keep things simple and concise.

So, if you really want to learn how to use NPM as your build tool there's a
well written tutorial called [How to Use npm as a Build
Tool](http://blog.keithcirkel.co.uk/how-to-use-npm-as-a-build-tool/) which you
can read.

So, some gripes people have about using NPM as a command tool are that you
can't comment your scripts and that you can't write variables. Well, enter
YAML. I haven't done variables in YAML but you can write them. You can also
comment in YAML. You can even [write variables in your command
line](http://unix.stackexchange.com/a/56449/89551). So, I write my scripts in
YAML and merge that into my `package.json` file.

Here's my scripts in YAML.

```yaml
# scripts run with npm. to build to package.json
# in command line in directory `.../mobiledlr/dist`
# `node ./tasks/buildPackage`
scripts:

  # bring together api.yml file with d.ts definitions
  # print to public
  api: |
    cpx "../ts/api/**" api
    && node ./tasks/api-generator.js
  browserify: browserify
  deploy: node ./tasks/deploy.js

  # dsr app
  dsr: |
    browserify ./views/dealer_service_report/dsr.js
    | uglifyjs -m -c
    | tee ./public/js/dsr.min.js
    | ngzip
    > ./public/js/dsr.min.js.gz
  r: ramda
  start: node ./app.js --use_strict

  # Copy convert stylus files in directory to css
  # files in public directory.
  stylus: stylus -w -c ../static/stylus -o public/css
  test: node ./tasks/tests.js
  typescript: |
    tsc
    --isolatedModules
    -m commonjs
    -t es5
    --removeComments
    --sourceMap
    --outDir ./
    --rootDir ../ts

  watch: nodemon ./app.js --use_strict

  # this has been deprecated in preference for browserify
  webpack: |
    ./node_modules/.bin/webpack -w --cache --config ./config/webpack.config.js

  # e.g., npm run watchify ./dsr.js -o ./public/dsr.js
  watchify: watchify
```

And here is the code I use to merge it with my `package.json` file:

```typescript
import r = require('ramda')
import yaml = require('js-yaml')
import {readFile, writeFile} from 'fs'

var npmPackage = require('../package.json')

readFile('../scripts.yml', 'utf-8', (err, file) => {
    if (err) {
        console.log('Error reading scripts.yml', err)
        return process.exit(1)
    }

    const
    scripts = yaml.load(file),
    combined = r.merge(npmPackage, scripts)

    writeFile('./package.json', JSON.stringify(combined, null, '  ').replace(/\\n/g, ' '), err => {
        if (err) {
            console.error('There was an error writing to package.json!', err)
            return process.exit(1)
        }
        process.exit(0)
    })
})
```

I put the scripts script in a directory called `tasks` and just use the command
line `node ./tasks/scriptsPackage` anytime I change my `scripts.yml` file. I
suppose I could make it a CLI compatible command. But I haven't needed to. But
I'm sure I would eventually want to. Once I do that I could add it to my
`scripts.yml` file! Only the first time I call it would I need to call it
directly, so it would be something like this: `node
./.node_modules/.bin/scripts ../ts/scripts.yml`.
