---
title: "_action: Declarative Event Handlers in an Attribute"
url: /action-attributes/
date: 2026-06-24
description: Introducing _action, a tiny event-delegation layer, the lifecycle-aware variant that grew out of it, and how both compare with HTML Traits and web components.
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
and the whole thing is about 50 lines. (There is now a second, lifecycle-aware
version of the same file sitting next to it — I'll get to that once the problem
it solves shows up.) Instead of defining a behavior and registering it, you name
a function and bind it to an event with an attribute:

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

## Giving it a lifecycle

That reassembly bothered me enough that I wrote a second version of the file:
[`_action.lifecycle.ts`](https://github.com/jon49/jon49-web/blob/master/lib/_action.lifecycle.ts).
It is the same dispatcher — same delegated listeners, same attribute lookup,
same `window.app` registry — with the missing half of the component story folded
in. You import one or the other, never both:

```js
import "@jon49/web/_action.lifecycle.js"
```

Three things change.

**A `_load` handler can return an instance.** If the returned object has a
`disconnectedCallback`, the dispatcher registers it for teardown. That is the
entire contract — nothing to look up, no registration call buried in your
constructor:

```js
if (e.type === "load") {
  if (!hasLoaded.get(target)?.includes(action)) {
    hasLoaded.get(target)?.push(action) || hasLoaded.set(target, [action])
    let result = fn.call(null, { app: w.app, ev: e, target, el: target, form })
    if (result?.disconnectedCallback) {
      watcher.register(target, result)
    }
  }
} else {
  fn.call(null, { app: w.app, ev: e, target, el: target, form })
}
```

**Run-once is tracked per element, not per attribute.** The original leaned on
`removeAttribute("_load")` — the attribute is a fuse that burns itself out. That
works right up until something puts it back, which is exactly what a morph does:
the morph library syncs attributes from the server markup onto the existing
node, so `_load="gameTimer"` reappears on an element that already has a live
timer behind it. Hence the `el._` flag in the old code.

The lifecycle version stops removing the attribute at all, and keeps a `WeakMap`
from element to the action names already run on it:

```js
// `_load` is left on the element. `hasLoaded` is what enforces run-once, and it
// does so per element+action, so stripping the attribute buys nothing — idiomorph
// restores it from the server markup on the next morph anyway.
function handleLoad() {
  for (let el of doc.querySelectorAll("[_load]")) {
    let action = el.getAttribute("_load")
    if (!action) continue
    handleCall(new Event("load"), el, action)
  }
}
```

`_load` goes back to being a plain, permanent declaration — *this element has
this behavior* — and element identity is what decides whether the handler
actually fires. The guard flag disappears, and so does the whole category of
confusion where the markup and the initialization state disagree about what has
already happened. It's tracked per name, so an element whose `_load="a b"` later
becomes `_load="a b c"` runs only `c`.

**Teardown sweeps by `isConnected`.** The first cut of the watcher walked
`mutation.removedNodes` and asked `node.contains(el)` for every registered
element. That both misses removals it can't attribute to a single removed node
and costs `O(registry × removedNodes)`:

```js
class DisconnectWatcher {
  registry = new Map()

  constructor() {
    let observer = new MutationObserver(() => this.sweep())
    observer.observe(document.documentElement, { childList: true, subtree: true })
    document.addEventListener("hz:completed", () => this.sweep())
  }

  // Keying off `isConnected` catches removals the observer can't attribute to a
  // single removed node (moves into detached trees, nodes idiomorph discards
  // rather than morphs) and keeps this O(registry) instead of
  // O(registry * removedNodes).
  sweep() {
    if (this.registry.size === 0) return
    for (let [el, instance] of this.registry) {
      if (!el.isConnected) {
        this.registry.delete(el)
        // Forget the run-once record too, so a re-attached element gets
        // re-initialized rather than staying dead after its disconnect.
        hasLoaded.delete(el)
        instance.disconnectedCallback()
      }
    }
  }

  register(el, instance) {
    this.registry.set(el, instance)
  }
}
```

Asking each registered element whether it is still connected is `O(registry)`
and catches every way an element can leave — moves into detached trees, and
nodes the morph library discards rather than morphs, included. It reads nothing
but `isConnected`, which is also why it works unchanged under either swap
module. The extra `hz:completed` listener means a swap cleans up at a known
point rather than whenever the observer's microtask happens to run.

Notice what `sweep` clears alongside the registry entry: the element's
`hasLoaded` record. That's the other half of leaving `_load` on the element. The
attribute is still sitting there, so an element that leaves the DOM and comes
back gets initialized again, rather than returning as a dead node carrying a
declaration that will never fire. Connect, disconnect, re-connect — which is
precisely what `connectedCallback` gives a custom element, and the reason to
have bothered.

### Identity is the contract

Both records — the run-once `WeakMap` and the disconnect registry — are keyed on
the element reference. So a component's lifecycle is exactly the lifetime of its
DOM node, no more and no less. That's a one-sentence rule with a sharp edge on
it, and which side you land on depends on how server HTML gets into the page.

`htmz-be` replaces nodes outright. Every swap hands you a new element, so every
swap is a real disconnect followed by a real re-init. There is nothing to think
about.

`htmz-morph` preserves them, which is the whole point of morphing — and I
recently moved it from morphdom to
[Idiomorph](https://github.com/bigskysoftware/idiomorph). Idiomorph matches
nodes by id-set intersection rather than morphdom's positional walk, so an
element keeps its identity across a re-render that inserts or reorders siblings,
and so does the component riding on it. That is exactly the property this
lifecycle needs.

The edge shows up on elements with no `id`. Idiomorph matches those
positionally, so an id-less element in a re-rendered list can be morphed in
place to hold *different content* — a different row, a different player, a
different record. It never leaves the document. `sweep()` sees `isConnected`, no
`disconnectedCallback` runs, `hasLoaded` goes on suppressing `_load`, and the
component keeps running against markup it was never initialized for. Anything
that read its configuration once in its constructor is now quietly driving
someone else's row.

The dispatcher can't defend against this: a node that never disconnected is
indistinguishable from a node that never changed. So the rule is simply **give
every `_load` element a stable `id`**. It's a real constraint, and worse, it's
one that fails silently — which is why it's written at the top of the module
rather than left for someone to rediscover.

### What the timer looks like now

Registration collapses to one expression — the `el._` guard is gone, and with it
the early `return` it needed:

```js
window.app.gameTimer = ({ el }) => new GameTimer(el)
```

And the class stops reaching outside itself:

```js
class GameTimer {
  constructor(el) {
    this.el = el
    this.interval = +(el.dataset.interval ?? 0) || 1e3
    document.addEventListener("hz:completed", this)
    this.update(Date.now())
  }

  disconnectedCallback() {
    timer.remove(this)
    document.removeEventListener("hz:completed", this)
  }
  // ...
}
```

That is `constructor(el)` plus `disconnectedCallback()` — the same shape HTML
Traits and web components use, reached through an attribute instead of a
registry, with no dash in the tag name and no wrapper element. The file grew
from about 50 lines to about 95. In exchange, the case that used to force me up
a rung of the ladder mostly stopped forcing me.

It is worth being clear about what you're buying with those 40 lines: a
`MutationObserver` over the whole document and a registry that never shrinks
until something leaves the DOM. That is precisely the machinery `_action` was
avoiding. Which is why they're two files — pages that only auto-submit forms
should not pay for a watcher they never register with.

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

- The smallest of the three (~50 lines, ~95 with the lifecycle, one set of
  delegated listeners). No per-element registration, no definitions — just name
  a function on `window.app` and point an attribute at it.
- Naturally composable (`_submit="reset clearAutoFocus"`) and form-aware (it
  falls back to the owning form), which is exactly what MPA-style pages need.
- Works with server-morphed HTML out of the box because it's delegated at the
  document.
- Right-sized for the common case, which is "run this function on this event,"
  not "instantiate a stateful component."
- Lifecycle is opt-in rather than absent: swap the import for
  `_action.lifecycle` and a `_load` handler that returns an object with a
  `disconnectedCallback` gets construction and teardown handled for it.

Cons:

- The plain version has no lifecycle at all. Initialization is a manual `_load`
  hook plus a guard flag to avoid double-init, and there is no teardown.
- The lifecycle version costs you the thing you were avoiding: a document-wide
  `MutationObserver` and a registry, for about 40 more lines of code — plus a
  fair amount of comment explaining when the thing bites.
- No encapsulation — every handler is a global on `window.app`, so naming is
  on you.
- `_load` only fires on window `load` and on `hz:completed`. HTML you insert
  some other way (your own `innerHTML`, a third-party script) is never
  initialized unless you dispatch the event yourself.
- Because lifecycle is keyed on element identity, pairing it with a morphing
  swap means every `_load` element needs a stable `id` — and forgetting one
  fails silently rather than loudly.
- Still event handlers with a lifecycle bolted on, not components: there's no
  `attributeChangedCallback`, no Shadow DOM, and no encapsulated internals.

## Which one when?

I think of it as a ladder, not a competition:

- **`_action`** for the 90% that is "on this event, call this function" —
  auto-submit, reset, confirm, toggle a class. It's the default reach.
- **`_action.lifecycle`** once even one thing on the page owns an interval, a
  listener, or a subscription. Same attributes, same registry: the handlers with
  something to clean up start returning an instance, and the rest carry on
  untouched. The one new obligation is an `id` on every `_load` element if
  you're morphing.
- **HTML Traits** when you want several ordered, independently reusable
  behaviors composed onto one native element, which `_load` doesn't model as
  well.
- **Web components** when you need true encapsulation, Shadow DOM, or you're
  shipping a widget for other people's pages to consume.

Adding the lifecycle moved that boundary further than I expected. The soccer app
now sits entirely on the first two rungs: the timer was the only thing that ever
needed real component semantics, and it turns out real component semantics is
about 40 lines of dispatcher, not a class registry and a dash in the tag name.

The pattern I keep coming back to is that most "interactivity" on a server-driven
page isn't a component at all. `_action` lets me stop pretending it is — and
when something genuinely *is* one, `_action.lifecycle` lets me say so without
changing how it's wired up.
