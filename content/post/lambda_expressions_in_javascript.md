---
date: 2016-06-13
title: On-the-Fly Lambda Expressions in JavaScript
tags:
    - JavaScript
    - History
---

Before many of the JavaScript compilers became real popular and if you wanted to write in straight JavaScript you could create functions on the fly. This was really nice for doing lambda functions.

Here's a couple libraries that did this.

https://github.com/fschaefer/Lambda.js
https://github.com/dfellis/lambda-js

Here's how it basically worked:

    var f = function(func){
       var funcArray = func.split('->')
       return   (funcArray.length === 1)
                ? new Function('x', 'return (' + funcArray[0].trim() + ')')
                : new Function(funcArray[0].trim(), 'return (' + funcArray[1].trim() + ')')
    }

Pretty simple, but definitely not best practice now days.
