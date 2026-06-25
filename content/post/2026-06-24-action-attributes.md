---
title: "_action: Declarative Event Handlers in an Attribute"
url: /action-attributes/
date: 2026-06-24
description: Introducing _action, a tiny event-delegation layer, and comparing it with HTML Traits and web components.
tags:
    - progressive-enhancement
    - web-components
    - html
    - javascript
---

## Introduction

In [HTML Traits](/html-traits/) I went looking for a cleaner way to attach
behavior to an element than wrapping it in a custom element. Traits got me most
of the way there: composition over inheritance, multiple behaviors per element,
no wrapper soup. But once I started building real pages I noticed that the
*majority* of the behavior I wanted wasn't really a "component" at all. It was
just: *when this changes, submit the form*. Or: *when this form submits, reset
it*. Reaching for a class with a constructor and a lifecycle to express "call
this function on change" felt like too much ceremony.

So I wrote something even smaller. It lives in
[`_action.ts`](https://github.com/jon49/jon49-web/blob/master/lib/_action.ts)
and the whole thing is about 60 lines. Instead of defining a behavior and
registering it, you name a function and bind it to an event with an attribute:

```html
<form _change=submit method=post action="?handler=editTeam">
    ...
</form>
```

When anything inside that form fires a `change` event, the function named
`submit` runs. That's it. No custom element, no trait definition, no wrapper.

## How it works

There is a single set of delegated listeners on the document:

```js
for (let event of ["click", "change", "submit"]) {
  doc.addEventListener(event, e => {
    let target = e.target
    let action = findAttr(target, event)
    if (!action) return
    handleCall(e, target, action)
  })
}
```

That `["click", "change", "submit"]` list isn't special — it's just the set
this app happens to use. The mechanism works for **any bubbling event**, so if
you want `input`, `keydown`, `focusout`, or a custom event of your own, you add
its name to the list and you immediately get a matching `_input` / `_keydown` /
`_focusout` attribute to bind against. Nothing else changes.

For each event type it walks up from the target with `closest(`[_${event}]`)`
to find the nearest `_click` / `_change` / `_submit` attribute, with a fallback
to the element's owning `form`. The attribute's value is a space-separated list
of function names that live on `window.app`, and each one is called with a small
context object:

```js
fn.call(null, { app: w.app, ev: e, target, el: target, form })
```

Because the listener is delegated at the document, it works for elements that
were swapped in later (this app morphs HTML in from the server), and because the
value can hold several names you get composition for free:

```html
<input name=newPlayerName required _submit="reset clearAutoFocus">
```

Registering a handler is just hanging a function off `window.app`:

```js
Object.assign(window.app, {
  reset: ({ form }) => form?.reset(),
  clearAutoFocus: ({ target }) => target.removeAttribute("autofocus"),
})
```

There is also a `_load` attribute, handled separately, for the "run this once
when the element appears" case. It fires on page load and again on `hz:completed`
(after server HTML is morphed in), then removes itself so it only runs once per
element:

> The `hz:completed` event comes from
> [htmz-be](https://github.com/jon49/htmz-be), a small library I wrote for
> morphing server HTML into the page. It was inspired by
> [htmz](https://github.com/Kalabasa/htmz) and
> [Datastar](https://github.com/starfederation/datastar). It dispatches
> `hz:completed` after a swap, which is the hook `_action` uses to re-run
> `_load` handlers on freshly inserted elements.

```js
function handleLoad() {
  for (let el of doc.querySelectorAll("[_load]")) {
    let action = el.getAttribute("_load")
    handleCall(new Event("load"), el, action)
    el.removeAttribute("_load")
  }
}
```

## Most of the time it's this simple

In the soccer app the overwhelming majority of interactivity is a one-liner
attribute. Auto-submit a settings form as you edit it:

```html
<form _change=submit method=post action="?handler=editTeam&teamId=${team.id}">
```

Reset the "add player" form after it submits, and drop the autofocus once
you've used it:

```html
<form _submit=reset method=post action="?handler=addPlayer">
    <input name=newPlayerName required autofocus _submit=clearAutoFocus>
</form>
```

None of these needed a component, a lifecycle, or a definition. The function is
named, the attribute points at it, done.

## When it gets more involved: the game timer

The interesting case is the live game timer. A `<span>` that ticks up every
second, can flash, can be paused (static), and ticks for several elements at
once on the page. Here `_action` is just the *entry point* — the `_load`
attribute instantiates a real class:

```html
<span _load="gameTimer" data-total="${total}" data-static>00:00</span>
```

```js
window.app.gameTimer = ({ el }) => {
  if (el._) return   // guard against double-init
  el._ = true
  new GameTimer(el)
}
```

The `GameTimer` class then does everything a stateful component does — but
notice it has to *assemble its own lifecycle* out of parts:

```js
class GameTimer {
  constructor(el) {
    this.el = el
    this.interval = +(el.dataset.interval ?? 0) || 1e3
    document.addEventListener("hz:completed", this)
    window.app.disconnectWatcher?.(el, this)   // <-- borrowed teardown
    this.update(Date.now())
  }

  disconnectedCallback() {
    timer.remove(this)
    document.removeEventListener("hz:completed", this)
  }
  // ...
}
```

Two things stand out compared to the simple case:

1. **"Connected" is manual.** `_load` is the moment of construction, and the
   `el._` guard exists because, unlike a web component, nothing stops the same
   element from being initialized twice.
2. **"Disconnected" is borrowed.** There's no native callback when the element
   leaves the DOM, so the app provides a `disconnectWatcher` — a single
   `MutationObserver` on `document.body` that calls `disconnectedCallback()` on
   registered instances when their node is removed. The timer leans on that to
   clean up its `setInterval` and its event listener.

This is the honest tradeoff: `_action` gives you next to nothing for free, so
when you *do* need real component semantics you reassemble them yourself from a
load hook, a guard flag, and a shared disconnect watcher. For one timer that's
fine. If half your page were stateful widgets, you'd feel the missing
lifecycle.

## Comparing the three

All three solve the same underlying problem — *attach behavior to HTML without
an SPA framework* — but they sit at different points on the
simplicity-vs-encapsulation curve.

### Web components

Pros:

- Real, browser-native lifecycle: `connectedCallback`,
  `disconnectedCallback`, `attributeChangedCallback`.
- Encapsulation, optional Shadow DOM, and a proper custom element registry.
- Standard — no library to ship.

Cons:

- Custom element names must contain a dash, and you generally wrap your
  semantic HTML in a non-semantic element.
- Built-in/customized elements (the `is=` form) aren't supported in Safari, and
  even there you get only one behavior per element.
- You re-learn and re-implement APIs that native elements already give you, and
  composing several behaviors means nesting several elements.

### HTML Traits

Pros:

- Composition: `traits="elastic-textarea character-limit"`, multiple,
  ordered behaviors on **one** element, no wrappers.
- Keeps the native element (and its native attributes like `maxlength`), so you
  learn less and reimplement nothing.
- Built for progressive enhancement; mirrors the web-component class API
  (`constructor(el)`, `disconnectedCallback`) so it's familiar.

Cons:

- It's still "components": you define a class and register it for every
  behavior, which is more than some interactions deserve.
- A library you ship, and a partial reimplementation of web components — no
  Shadow DOM, never a true custom element.

### _action

Pros:

- The smallest of the three (~60 lines, one set of delegated listeners). No
  per-element registration, no definitions — just name a function on
  `window.app` and point an attribute at it.
- Naturally composable (`_submit="reset clearAutoFocus"`) and form-aware (it
  falls back to the owning form), which is exactly what MPA-style pages need.
- Works with server-morphed HTML out of the box because it's delegated at the
  document.
- Right-sized for the common case, which is "run this function on this event,"
  not "instantiate a stateful component."

Cons:

- No lifecycle by default. Initialization is a manual `_load` hook (plus a guard
  flag to avoid double-init), and teardown only exists if you opt into the
  shared `disconnectWatcher`.
- No encapsulation — every handler is a global on `window.app`, so naming is
  on you.
- It's event handlers, not components: for genuinely stateful widgets (the game
  timer) you end up rebuilding the very lifecycle that traits and web components
  hand you.

## Which one when?

I think of it as a ladder, not a competition:

- **`_action`** for the 90% that is "on this event, call this function" —
  auto-submit, reset, confirm, toggle a class. It's the default reach.
- **HTML Traits** when a behavior is genuinely a reusable, stateful enhancement
  of a native element and you want clean composition without wrappers.
- **Web components** when you need true encapsulation, Shadow DOM, or you're
  shipping a widget for other people's pages to consume.

The pattern I keep coming back to is that most "interactivity" on a server-driven
page isn't a component at all. `_action` lets me stop pretending it is.
