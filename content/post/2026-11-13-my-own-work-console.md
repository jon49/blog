---
title: I Replaced My Work-Items File with an App Claude Built in a Week
url: /my-own-work-console/
date: 2026-11-13
description: A clickable tour of the small local app that now runs my day with Claude Code (triage, a session console, coordination and time tracking), and a recipe for building your own.
tags:
    - ai
    - claude
    - workflow
---

In [How I Use AI to Write Software](/how-i-use-ai/) I described a single HTML work-items file that planned my sprint, and an append-only text file that let my Claude sessions take turns. Both are gone now. A month later they'd been replaced by a small app that Claude built in six working days, and it has changed my day more than anything else in that post.

This post lets you click through a copy of it. Then it tells you how to build your own, because I think you should.

## Why the files had to go

The HTML file worked for one project. I work across six, so I had six of them, and each was rebuilt by a different Claude session with its own idea of the format. They drifted apart. Running six QA sweeps meant six long prompts. And as I ran more sessions at once, my prompts started to look like this:

> Start the next available … work item set to Approved. … Note that ../storefront ../storefront-2 are picking out items right now too. Don't choose the same one.

I was the lock. That doesn't scale past about three sessions. (I've changed the names in every prompt I quote, fixed typos, and marked cuts with “…”.)

So one morning I asked for this:

> I have 6 projects that I work across and I have triage documents … which help me organize them. I would like this to be more uniform and I would like you to create an application with a SQLite DB and a single page I can go to which is generated from the application, and I can choose which project to look at on that single page.

Claude's first version wrote the page to a file. I said, *"I want all the data to live in the SQLite DB and then the Python app generates the page on the fly."* By the end of that day it was also coordinating my sessions.

## Click through it

Everything below is made up: a small online bookshop with three projects, Priya as product owner and Marco as tester (they're back from the last post). Nothing does real work. Buttons that would do something tell you what would have happened. The panel explains the screen you're on: **In my day** is what it does for me, and **How it's built** is how it works. Follow **Try next**, or wander.

<div style="width:min(1200px, calc(100vw - 32px));position:relative;left:50%;transform:translateX(-50%);margin:1.5rem 0 0.5rem">
<iframe name="demo" id="demo" src="/triage-demo/" title="A clickable tour of the triage app" loading="lazy" allow="clipboard-write" style="display:block;width:100%;height:min(780px, 85vh);border:1px solid var(--b-line, #ccc);border-radius:10px;margin:0"></iframe>
</div>

<p style="text-align:center;font-size:0.9rem"><a href="/triage-demo/" target="_blank" rel="noopener">Open the tour full screen ↗</a></p>

<script>
document.addEventListener('click', function (e) {
  var a = e.target.closest('a[target="demo"]');
  if (!a) return;
  var demo = document.getElementById('demo');
  try { demo.contentWindow.location.replace(a.href); e.preventDefault(); } catch (err) { /* let the link navigate the frame */ }
  demo.scrollIntoView({ behavior: 'smooth', block: 'start' });
});
</script>

## A normal day, through the app

The links in this section change the demo above.

1. **I open the <a href="/triage-demo/#sessions" target="demo">session console</a>.** Five sessions are running from yesterday. Two <a href="/triage-demo/#sessions/storefront~2" target="demo">need me</a>: one wants permission to run E2E tests, and one <a href="/triage-demo/#sessions/mobile" target="demo">has a question</a>. I answer both with a key press. I never opened a terminal.
2. **I read what finished overnight.** One session's turn <a href="/triage-demo/#sessions/warehouse" target="demo">has ended</a> and its last reply says the PR is up. I read the PR in the tracker and set it to auto-complete myself. That's my sign that I've read and understood it.
3. **I pick the next work.** The <a href="/triage-demo/#triage/storefront" target="demo">project page</a> shows my open items grouped into <a href="/triage-demo/#triage/storefront/gift-cards" target="demo">session cards</a>. I click **+ New session**, pick the card, and the session starts with `Start http://localhost:8765/#storefront/gift-cards`. That's the whole prompt.
4. **Sessions take turns without me.** Two of them want the desktop for E2E tests. The second one <a href="/triage-demo/#coordination" target="demo">waits in the queue</a> and starts when the first releases it.
5. **Someone needs me.** Priya @-mentions me on a story. It <a href="/triage-demo/#sessions/notices" target="demo">shows up in the console</a>, not in my email. Clicking it opens **New session** with a prompt filled in. I pick the folder, and the session reads the comment and tells me what it changes.
6. **After a deploy**, `/qa-sweep storefront` checks everything that shipped and leaves a <a href="/triage-demo/#triage/storefront/sweep" target="demo">summary</a>.
7. **At the end of the day**, the <a href="/triage-demo/#sessions/timer" target="demo">timer</a> has followed my clicks all day. `/timesheet` turns it into hours per work item and posts them after I approve.

The two big changes from October: I'm no longer the lock, and I'm no longer reading terminals to find out what needs me.

## Build your own

You can't have my code. It lives in my employer's repository and it's shaped around their tracker. I don't think you want it anyway: the point is that this kind of tool is now cheap enough to build for exactly how *you* work. Here's the recipe.

### The pieces

<div style="overflow-x:auto;margin:0 0 1.5rem"><svg viewBox="0 0 640 230" role="img" aria-label="The tracker's REST API syncs into a SQLite file. One Python server reads the file to serve the page and MCP tools. Claude Code sessions call the tools and report through hooks." style="width:100%;min-width:520px;height:auto;display:block">
<style>.tgd-r{fill:none;stroke:currentColor;stroke-width:1.5}.tgd-h{fill:none;stroke:#bf616a;stroke-width:2.5}.tgd-x{fill:currentColor;font:14px system-ui,sans-serif}.tgd-a{stroke:currentColor;stroke-width:1.5;fill:none}</style>
<rect class="tgd-r" x="10" y="20" width="170" height="50" rx="8"/><text class="tgd-x" x="95" y="50" text-anchor="middle">Tracker REST API</text>
<rect class="tgd-r" x="10" y="150" width="170" height="50" rx="8"/><text class="tgd-x" x="95" y="180" text-anchor="middle">SQLite file</text>
<rect class="tgd-h" x="240" y="150" width="170" height="50" rx="8"/><text class="tgd-x" x="325" y="180" text-anchor="middle">Python server</text>
<rect class="tgd-r" x="240" y="20" width="170" height="50" rx="8"/><text class="tgd-x" x="325" y="50" text-anchor="middle">Page in the browser</text>
<rect class="tgd-r" x="460" y="150" width="170" height="50" rx="8"/><text class="tgd-x" x="545" y="172" text-anchor="middle">Claude Code</text><text class="tgd-x" x="545" y="190" text-anchor="middle">sessions (4–7)</text>
<path class="tgd-a" d="M95 70 V 148 M89 140 L95 148 L101 140"/><text class="tgd-x" x="103" y="115">sync</text>
<path class="tgd-a" d="M182 175 H 238 M190 169 L182 175 L190 181"/>
<path class="tgd-a" d="M325 150 V 72 M319 80 L325 72 L331 80"/><text class="tgd-x" x="333" y="115">HTML</text>
<path class="tgd-a" d="M412 165 H 458 M420 159 L412 165 L420 171 M450 159 L458 165 L450 171"/><text class="tgd-x" x="414" y="150">MCP tools</text>
<path class="tgd-a" d="M458 188 H 412 M420 182 L412 188 L420 194"/><text class="tgd-x" x="420" y="215">hooks</text>
</svg></div>

- **A SQLite file** holds everything: work items, cards, waits, claims, messages, session state, time.
- **One Python process**, standard library only, serves the page and an MCP endpoint (`/mcp`, plain JSON-RPC over HTTP). One process means one place for the rules, and each tool call is one transaction, so parallel sessions can't overwrite each other.
- **A sync** pulls from the tracker's REST API. Mine is Azure DevOps; GitHub Issues, Jira or Linear would work the same way.
- **Claude Code hooks** report what each session is doing: SessionStart, Stop, PermissionRequest, PostToolUse and a few more. They're a small script registered in `~/.claude/settings.json`.
- **Skills** hold the procedures that span tools, like `/qa-sweep` and `/timesheet`.

By the end it was about 6,300 lines of Python, 3,000 lines of tests and one 900-line HTML page, all written by Claude, over 54 commits in six working days.

### The order to build it in

This is the order I'd recommend. It's close to what actually happened, and each step is useful by itself. The quotes are my real prompts, lightly edited.

**1. The page from a database (half a day).** Start with the prompt above. Ask for one page per project, rendered on every request, and a `sync` from your tracker. Group items into *session cards*: items that touch the same code, worked in one Claude session. Give every card a slug and a "copy start line" button.

**2. Tools instead of HTML (the same day).** Expose the operations as MCP tools (`get_session`, `set_session`, `place_item`, `check`) and register the server with `claude mcp add --transport http`. Now Claude changes the triage through tools and never edits a page. Add a `check` tool that lists rule breaks, such as an open item that isn't on any card, and tell Claude it isn't done until `check` says ok.

**3. Coordination (the same afternoon).**

> Can we have the app help with coordination between instances of the projects? So they just call the app now instead of using files. And they can send messages to each other. This would also be nice for E2E tests that need the computer …

That's `claim` / `release` with a first-come queue and claims that lapse, plus `send_message`. A wrapper command (`run --claim desktop -- <command>`) waits its turn for unattended E2E runs. Give each session a unique name too (`storefront~2` for a second session in the same checkout). Mine were first named after their folder, which broke the day I ran two sessions in the same folder.

**4. Write through the server (day 2).** Every `az boards` call asked me for permission. So I asked:

> Can't we have it work with the triage app so it doesn't have to ask permission to write a work item?

Then the same for pull requests, with one boundary: there's no tool to complete or auto-complete a PR, because I do that myself once I've read it. This step had a side effect I didn't expect. **Rules moved from my prompts into code.** The tools refuse a bug with no "why missed", a PR title with the item number in it, and an update to an item someone else changed since Claude read it. A rule in a prompt holds most of the time. A rule in a tool holds every time.

**5. A local cache for QA sweeps, plus a skill (day 2).** The sweep tool syncs once and returns a worklist from the database, so a sweep doesn't make hundreds of command-line calls. `/qa-sweep` became a skill with per-project rules, so changing how I sweep is one edit, not six.

**6. The session console (day 3, the next Monday).**

> Would it be possible to have a new page on the app where I can start new work sessions … and have a single control panel where I communicate with those sessions? And then also, when I click on different sessions it shows a short summary of what I'm working on in that session, including a diagram, screenshot, flowchart or image …

The hooks report each session's state, and a `set_brief` tool lets sessions describe themselves with a summary, a plan and a picture they draw. Sessions started from the console run inside tmux, so the server can type into them. This one took most of a day, plus several small follow-ups as I used it: sort by what needs me, a wider reply panel with history, "working in background" as its own state, and keeping my cursor when the page refreshes.

**7. Time tracking (the same day).**

> Right now I track time by typing R into the console … It would be nice to start tracking it in the application itself … So, if I click on an item in the session then it knows I'm working on it and should automatically start tracking there.

**8. Notices (day 4).**

> When someone @ me in a PR comment or work item comment, then I should be notified in the app. I want you to check every 15 minutes.

A few minutes later I added: *"The @-mentions are sent to my email. But I don't really look at my emails, especially for those things."*

**9. Then just use it, and fix what annoys you.** My latest fix came from closing my laptop overnight: the sessions had died, and the next morning I didn't know what I'd been working on. I asked for a restart button, then changed my mind: *"If I don't need a button to restart them after I close the lid, that would be even more ideal."* Now they come back by themselves.

### A prompt to start with

Paste this into Claude Code in an empty folder, with your tracker filled in:

```text
I track my work in <GitHub Issues | Jira | Linear | Azure DevOps>, across
these projects: <list>. Build me a small local app in Python, standard
library only:

- a SQLite database, and a `sync` command that pulls my open work items
  through the tracker's REST API (or its CLI);
- a server on localhost that renders one page per project from the database
  on every request, and never writes an HTML file;
- "session cards": groups of items that touch the same code and should be
  worked in one Claude session. Each has a topic slug and a "copy start line"
  button that copies `Start http://localhost:8765/#<project>/<slug>`;
- the same operations as MCP tools over HTTP at /mcp (get_project,
  get_session, set_session, place_item, check), registered with Claude Code,
  so Claude changes the triage only through the tools.

Write the tests first. Ask me questions before you start.
```

Then live with it for a day before you ask for step 3.

### What I learned building it

- **Build for one person: you.** Every feature came from a moment of annoyance, described in one or two sentences. None of it needed a spec longer than that, because I was the only user.
- **Put rules in tools, not prompts.** The biggest jump in reliability came from tools that refuse to break my rules.
- **Standard library only** kept it portable. Setting it up on another machine is a `.env` file and a setup script, with Python, the tracker's CLI and tmux already installed.
- **Ask for the boring quality once.** *"Make sure it is AAA standard for contrast"* got me a test that checks every colour pair in both themes, and it's stayed true through every change since.
- **Warn the other sessions before a restart.** The session that restarts the server first sends every other session a message: the tools will be down for a few seconds, so retry once they're back. Without it, a session whose tool call fails has no idea why.

## What still goes wrong

- **Windows and WSL.** The server runs under Windows Python because Hyper-V's firewall times out a Windows browser on a port that WSL listens on. Claude Code runs in WSL. Most of my bugs lived in that gap.
- **Hooks can't do everything.** Some hook events can't add to the session's context, so a message can wait until the session's next step. Waking an idle session needs a small relay, which costs a cent or two.
- **It's mine.** It knows my rules, my tracker fields and my projects. For a team it needs settings per developer. I've started on that (a `.env` and a setup script), but it's not a product and I don't want it to be.

## If you try one thing this week

Build step 1 for one project, then use it for a day. If it helps, the rest of the steps will suggest themselves. That's how mine happened.
