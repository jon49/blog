---
url: /mpa-auto-scroll-focus/
date: 2022-10-23
title: MPA Auto Scroll and Focus
tags:
  - mpa
  - progressive enhancement
  - auto
  - scroll
  - focus
draft: true
---

## Problem

In an MPA after updating data in a form and submitting the data to the server,
typically the pattern to update is to reload the page, called
["Post/Redirect/Get"](https://en.wikipedia.org/wiki/Post/Redirect/Get) (PRG)
pattern. When doing this you are pushed back up to the top of the page and lose
your spot in the form you were updating. You can use the attribute `autofocus`
to overcome this problem, but you don't always end up scrolled properly and it
can be a pain, if not impossible, to track what field the user was focused on
when they submitted the form.

## [Progressive Enhancement](/progressive-enhancement/)

Using progressive enhancement we can overcome this problem. So, how could we do
this? With a little bit of simple JavaScript.

## [Complete Code](https://gist.github.com/jon49/13e2c9dfd638b78077519179e8dc210d)

```js
function getCleanUrl() {
  let url = new URL(document.location.href)
  url.hash = ""
  return url.toString()
}

window.addEventListener('beforeunload', () => {
  let active = document.activeElement?.id
  let y = window.scrollY
  let height = document.body.scrollHeight
  localStorage.pageLocation = JSON.stringify({ href: getCleanUrl(), y, height, active })
})

window.addEventListener("load", () => {
  if (document.querySelector('[autofocus]')) return
  let location = localStorage.pageLocation
  if (!location) return
  let { y, height, href, active } = JSON.parse(location)
  // If the page was refreshed then scroll back to position.
  if (y && href === getCleanUrl()) {
    window.scrollTo({ top: y + document.body.scrollHeight - height })
  }
  // If an element with an ID had focus then refocus on that element.
  document.getElementById(active)?.focus()
}
```

## Breaking the code down

### `beforeunload`

First, what we are listening to is the `beforeunload` event. This event tells
us right before a page is about to be left, in particular, we are looking for
when a page is refreshed.

So, we save the page location and some metadata in local storage on the
browser. What we would like to save is the current scrolled `y` position and
the current height of the window. We also save the last active element on the
page. And we store the current page url (cleaned). All this information will
allow us to determine what to do when the page is reloaded.

### `load`

We then have the `load` event which happens when a page is first loaded. We are
checking first if there is a `autofocus` attribute on the page, if there is we
let the server selected element be selected. If not then we go into the
determination of what should be done.

Then we check if we have the `pageLocation` data. If we do, then we make sure
that we are on the same page as we were on before, i.e., if it was a page
refresh. If it was a page refresh then we determine if the where we should be
on the page. If the height was changed then we know that there is added data on
the page and will scroll down lower than we were before. We could also add an
attribute to the submitting form to determine if we want to scroll down farther
than we were before, since sometimes the extra information might be loaded
lower than where your submitting form is.

Then if there was an active element we focus the cursor there.

## Conclusion

This is a great way to make an MPA app less janky. Depending on the browser and
page there may be a bit of a blink from this code as it scrolls to your
previous position, but that is just part of doing MPAs. In a future post we can
see how to get around this problem.

