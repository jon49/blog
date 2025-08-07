
I'm finally giving in and reading the book and doing the courses for "The Road to React."

In the introduction he made it sound like SPA's don't need to hit a server on every page navigation. Which would only be true if you don't need to interact with others, like my personal apps that I write. So, it is a bit off putting that the author is misleading there. I do think what he meant was that you don't need to get the HTML for each page navigation.

Into the world of complexity and out of the world of simplicity that I like to be in! And into the world of employability! :-D


Question: Why is it beneficial to extract components in React?
– Answer: Extracting components promotes reusability, maintainability, and a cleaner
component structure.

Me> But it can be overdone when an item is abstracted away and you can no longer view the structure altogether.
Fri 10:03 AM
Message from you, Question: How do you decide when to extract a component? – Answer: Extract a component when you find repeated UI patterns or functionality within your code. Me> This can cause leaky abstractions. Sometimes it is better to repeat code. A nice balance is needed., Friday, January 31 2025, 10:03 AM.

Question: How do you decide when to extract a component?
– Answer: Extract a component when you find repeated UI patterns or functionality within
your code.

Me> This can cause leaky abstractions. Sometimes it is better to repeat code. A nice balance is needed.
Message from you, Question: Is it possible to extract components across different files? – Answer: Yes, extracting components into separate files promotes better file organization and modularity. Me> Once again this can go too far as we see in many React code bases where you can no longer understand the HTML as you have to go to 50 different files to understand 1 HTML page. It can be better to keep it altogether so you can understand all the nuances of a single page. Also, too many components can cause leaky abstractions. Many times native HTML tags can be better as you can change it as you like depending on the page you are on. Where components lock in the behavior and appearance of your HTML., Friday, January 31 2025, 10:06 AM.
Question: Is it possible to extract components across different files?
– Answer: Yes, extracting components into separate files promotes better file organization
and modularity.

Me> Once again this can go too far as we see in many React code bases where you can no longer understand the HTML as you have to go to 50 different files to understand 1 HTML page. It can be better to keep it altogether so you can understand all the nuances of a single page. Also, too many components can cause leaky abstractions. Many times native HTML tags can be better as you can change it as you like depending on the page you are on. Where components lock in the behavior and appearance of your HTML.
Fri 10:07 AM
Message from you, AKA, keeping it too DRY causes unnecessary complexity., Friday, January 31 2025, 10:07 AM.

AKA, keeping it too DRY causes unnecessary complexity.
Brian Haddad
 •
Fri 10:11 AM
Message from Brian Haddad, lol Yeah. When I first got started in programming I wanted to extract everything into reusable blocks of code but eventually I learned that not everything that seems like it should be extracted should actually be extracted. I think that's a common issue with new or inexperienced programmers., Friday, January 31 2025, 10:11 AM.

lol Yeah. When I first got started in programming I wanted to extract everything into reusable blocks of code but eventually I learned that not everything that seems like it should be extracted should actually be extracted. I think that's a common issue with new or inexperienced programmers.
Fri 10:13 AM
Message from you, Yes, me too. But these guys have decades of experience and they are still doing it. What's wrong with React developers?, Friday, January 31 2025, 10:13 AM.

Yes, me too. But these guys have decades of experience and they are still doing it. What's wrong with React developers?
Brian Haddad
 •
Fri 10:19 AM
Message from Brian Haddad, React dev: "Guys, I finally did it! I came up with the ultimate abstraction! Everything is essentially the same component now!" React dev2: "Awesome! How's it work?" React dev: "The syntax is easy. You enclose a tag name and a bunch of attributes in less-than and greater-than symbols. I call it a 'tag'. Then you can insert some content or nest other tags inside before closing the tag. Turns out the browser already supports this mega-abstraction too!" Everyone else: "... uh... isn't that just how HT..." React dev2: "WOAH! You've just blown my mind!", Friday, January 31 2025, 10:19 AM.

React dev: "Guys, I finally did it! I came up with the ultimate abstraction! Everything is essentially the same component now!"

React dev2: "Awesome! How's it work?"

React dev: "The syntax is easy. You enclose a tag name and a bunch of attributes in less-than and greater-than symbols. I call it a 'tag'. Then you can insert some content or nest other tags inside before closing the tag. Turns out the browser already supports this mega-abstraction too!"

Everyone else: "... uh... isn't that just how HT..."

React dev2: "WOAH! You've just blown my mind!"

---

I finally understand why React devs have such small components. React reruns that code every time there is a change in the state. So, you don't want to rerun a huge function with lots of moving pieces. So, you are forced to create small functions.

Now, even though it is running that whole function over again it only updates the change that happened in the DOM, I'm assuming it does a diff on that small DOM segment that was changed. And I'm assuming that some of the built-in React functions that are called in the component are memoized. So, the overhead isn't as bad as it could be. But my goodness, JS has to be pretty good to handle all this unnecessary overhead. A lot of work must go into React to make it work efficiently too.

---

I've been reading "The Road to React" and working through its tutorials. It
pretty good. It helps me understand how it works better and why it uses what it
does.

I'm still not the biggest fan of React as its model is highly inefficient and
bloated. The newer front end frameworks do a better job keeping the memory down
and not repeating all the work like React does. But I understand the _why_ of
React now.

Also, I can see why developers went towards CSS frameworks like Tailwind. But
with the advent of layering in CSS I don't think that makes so much sense
anymore and makes the old component w/ CSS model of programming obsolete.

Now, we just need to wait for devs and frameworks to catch up to these new
models.

Also, web components tend to be made for the HTMX model of programming with the
back end in mind. So, I think that is part of the reason front end devs dislike
it so, even though it is a very good model for SSR. But the light DOM in web
components makes more sense than the shadow DOM as the light DOM makes it so you
can progressively enhance your application. This is how I used it in my Cash
tracking app that I made, I was able to progressively enhance the app from no JS
enabled to make it partially offline capable.

I'm still not a fan of react though. I understand a lot of the design decisions
better but it's design causes leaky abstractions, bloat, monolithic design on
the front end, it couples the API and itself (which is natural), it encourages a
lot of indirection, and it puts a lot of unnecessary state on the front end
which causes a lot of complexity.

