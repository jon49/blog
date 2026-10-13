---
title: How I Use AI to Write Software (Without Writing the Code Myself)
url: /how-i-use-ai/
date: 2026-10-12
description: Six months of working with Claude Code every day, covering the loop every story goes through, how I teach it, running several sessions at once, and the one HTML file that plans my sprint.
tags:
    - ai
    - claude
    - workflow
---

Six months ago I stopped typing code. Not because I stopped writing software, but because I changed what my job is. Claude does the typing. I do the deciding, the reviewing, and the correcting.

This post is the workflow I've settled into. It isn't a sales pitch. Parts of it are clunky, some of it went badly wrong before it went right, and all of it is still changing. But it works well enough that I haven't committed a line of code by hand since March.

## Making it a game

To make AI-assisted development more enjoyable, I turn it into a game. The goal is simple: get as much work done as possible. How many work items can I get done in a day? How many in a week?

I didn't start out there. Over these six months I've gotten faster and faster, so averaged out, the totals below look a lot more modest than a good day does now. These days I land somewhere between 10 and 20 work items on most days. My best day so far was 36, which was pretty amazing. But I didn't get there by typing faster or writing cleverer prompts. I got there by building workflows: a repeatable loop that keeps several streams of work moving at once and keeps me out of the way of the parts that don't need me. The game keeps it fun. The workflow makes the score possible.

The rest of this post is that workflow.

## The principles, in one minute

These five ideas run through everything below:

| Principle | What it means |
|---|---|
| **A collaborator, not an oracle** | Output is a draft I evaluate. My name is still on the pull request. |
| **Context is the #1 lever** | Most bad output comes from under-specified input. |
| **Plan before you execute** | Agree on the approach before any code is written. |
| **Trust, but verify** | Nothing ships unread or untested. |
| **Reflect and improve** | When something goes wrong, change the process, not just the result. |

## Six months in numbers

From my Claude history and git logs, roughly March through September:

- **~5,000 prompts typed**, with a median length of **76 characters**
- **~2,750 commits** written by Claude. Before March I averaged about 84 commits a month. Since then it's been around 440, about five times as many.
- **400+ work items** started with a "Start …" prompt, far more of them in the later months than the early ones
- **~350 specs, plans and write-ups** committed to `docs/` folders
- **~570 memory notes** that Claude wrote itself so it doesn't repeat mistakes
- **~390 subagent runs**, where Claude hands part of the work to another Claude

Commits aren't productivity, so here's the number I care about more: **64% of Claude's commits touch a test file**, compared with **4% of mine** before I switched. Going faster didn't cost quality. The process got stricter, because tests are cheap to write now.

## The story loop

Every bundle of stories goes through the same loop. Once Claude knows the routine, my job is to make decisions, not to type.

1. **`/clear` and "Start C:/r/my-triage-document.html#s-1"** — I point Claude at the next session card in my work-items file (more on that below). One line, and it starts a whole bundle of work items that share similar context.
2. **Claude sets up** — reads the card, the stories on it and the repo's memory file, sets the work items to In Progress, creates a branch or worktree.
3. **Brainstorm** — it asks me one to three questions. I usually answer "1" or "2".
4. **Design, then "Go"** — I approve the *approach*, not the code. If there's a lot to digest, I have it written up as an HTML document and read that instead of scrolling a terminal.
5. **Test first** — a failing test (red), then the fix (green).
6. **Verify** — the full test suite, not just the new test. For anything visible, Claude also runs the E2E tests and navigates the app itself, so it's rare that I need to look at it myself.
7. **Pull request** — I read the description and scan the code. Anything worth doing later becomes a new work item before the PR goes out. Nothing gets left in a comment or a chat. If the code is off, no worries: I send Claude back in to fix it.
8. **Remember** — it saves what it learned. I ask "PR URL?" and then `/clear`.
9. **Merge and deploy** — reviewed, merged, deployed to the QA environments.
10. **QA sweep and re-plan** — Claude checks everything that shipped, closes what it can prove, hands the rest to testers with a step-by-step test guide, the item to test with, and marked-up screenshots, and refreshes the work-items file. Then I go back to step 1.

Steps 1, 3, 4, 7 and 10 are where my attention goes. Claude does the rest (or the pipeline does), and I review what it produced.

### The engine behind the loop: superpowers

Most of steps 3 through 6 come from the free [superpowers](https://github.com/obra/superpowers) plugin for Claude Code. It adds *skills*: reusable ways of working that Claude switches on by itself when a task needs them.

| Skill | Times it ran | What it does |
|---|---|---|
| brainstorming | 100 | Asks me questions, proposes a design |
| systematic-debugging | 51 | Finds the root cause before fixing anything |
| test-driven-development | 50 | Failing test first |
| writing-plans | 18 | Turns a design into a task-by-task plan |
| subagent-driven-development | 16 | Hands each task to a fresh agent, then reviews it |
| using-git-worktrees | 13 | An isolated workspace per story |
| verification-before-completion | 5 | Evidence before "done" |

I almost never ask for these by name. That's why my prompts can be "Start …#s-1" and "Go": the discipline of asking first, designing, testing first and verifying is built into the plugin, so I don't have to request it every time. It's opinionated, and occasionally too heavy for a one-line fix. Then I say "skip the brainstorm, it's a one-liner."

I never use plan mode. Brainstorming followed by design approval does that job.

### The tracker, driven from the terminal

Claude reads and updates work items and pull requests itself through the tracker's command-line tool, so I'm not copying and pasting between a browser and a terminal. It reads the story, its acceptance criteria and its comments, sets the state, opens the PR with the work item linked and a reviewer added, files follow-up items, and posts test guides for testers.

The rules for doing that live in my global instructions file: always link the PR to its work item, keep the item number out of the PR title, and leave the item In Progress while the PR is open.

## My prompts are short, on purpose

My most common replies over six months:

| Reply | Count |
|---|---|
| 1 | 108 |
| continue | 77 |
| 2 | 39 |
| it looks good | 33 |
| go | 31 |
| proceed | 29 |
| html | 24 |
| what's the PR url? | 23 |

This contradicts the usual advice to write long, detailed prompts, so it's worth explaining. In April, a typical prompt of mine started like this: *"Use ./memory.md. I need you to work on the following stories. Each story should have its own branch…"* By September it was just *"Start C:/r/my-triage-document.html#s-1"*.

The context didn't go away. It moved into files that Claude reads at the start of every session. I did the detailed prompting once, and now every session gets it for free.

"1" and "2" are answers to Claude's multiple-choice questions while brainstorming. "html" is my answer when it asks what format a write-up should be.

## Teaching Claude: correct it once, never again

Claude doesn't remember yesterday unless you give it somewhere to write things down. In April I typed, frustrated: *"That's impossible, you don't have a memory even when I spell it out for you."* Everything in this section came from that.

### Three layers of memory

1. **Global rules** (`~/.claude/CLAUDE.md`): how I work, in every repository. Link PRs to work items, keep item numbers out of PR titles, write documents for people as HTML, always give full file paths, only write code comments that a future edit needs.
2. **Repo memory** (`memory.md` in each repo, plus one per area such as `db/`, `api/`, `ui/`, `e2e/`): committed to git, so it's shared with the team and with any AI tool. Each repo's `CLAUDE.md` is one line, `@./memory.md`, and the real guidance is a plain file that people can read too.
3. **Auto memory**: notes Claude writes itself. There are three kinds: feedback (my corrections), reference (how-tos), and project (story history). They're indexed, so only the relevant ones get loaded.

The repo memory has a side benefit I didn't expect: there's far more written documentation of how our systems work now than there was before AI. That's a real answer to the bus-factor question.

### Every correction becomes a rule

| What I said | The rule it became |
|---|---|
| "You need to link the work item to the PR. Add that to memory so you don't forget." | Always link the PR to its work item, then verify that the link exists |
| "Always use PowerShell to work with git." | From WSL, git can't authenticate to the remote, so use `git.exe` |
| "Remember to set the story to In Progress when you start it." | In Progress for the whole PR lifecycle, and never moved on its own |
| "Where's the HTML file to read that? Add that to your global memory." | Documents for people are self-contained HTML |
| "There should be a global rule not to put the item number in the PR title." | Clean PR titles; the link carries the number |
| "That's not something that should be in your memory. It's something you should look up." | Memory is for lasting lessons, not facts that change |

When Claude does something wrong, don't just fix it. Say "remember this" or "add that to the global memory," and it's fixed in every future session.

The last row matters too. Memory can go stale. A story's status belongs in the tracker, not in a memory file.

My favorite note is one Claude wrote after I caught a test that proved nothing:

> The re-arranged test still passed, and also passed against a build with the fix removed. It had stopped testing what its name claimed.

That's Claude learning to be skeptical of its own tests.

## The work-items file: one HTML page that runs my sprint

Before I start anything, I open one file. It began with a simple prompt:

> I have these work items. Please group them into what can be worked on in the same PR or the same Claude session, because they touch similar code, and put the results in an HTML file.

It has grown a lot since. I used to keep two documents, a triage plan and a separate QA-sweep report. Now they're one file, and it's the only planning document I use. Claude rebuilds it from the tracker's live state every time I ask. It holds:

- **Status tiles**: is the build green, how many items are open with me, and what the last sweep closed.
- **"Needs you, in one list"**: everything that's waiting on *me* — reviews, go/no-go calls, and questions to take to the product owner.
- **The latest QA sweep**: what was checked, against which build, and what happened to each item.
- **Priority order at a glance**: one row per *session*. A session is a group of items that touch the same code, so the context from one helps with the next.
- **Session cards**: each item with its state and a note on what's known, what's next, and what it collides with.
- **Decisions that block work**: the questions only a person can answer.
- **Housekeeping**: scratch folders and worktrees that can be deleted.
- **An appendix with the standing QA-sweep brief**: the rules Claude follows whenever I ask for a sweep.

Here's what one looks like. The app, the people and every item are made up, but the structure and tone match my real file, trimmed down:

<style>
.triage-demo{--bg:#fbfaf7;--panel:#fff;--ink:#1d1d1b;--muted:#66645e;--line:#e3e0d8;--a:#b3261e;--a-bg:#fdecea;--b:#9a5b00;--b-bg:#fff4df;--c:#2f5d8a;--c-bg:#e8f0f8;--ok:#2e6b3a;--ok-bg:#e6f3e8;--v:#6b3fa0;--v-bg:#f1eaf9;--note-bg:#f4f2ec;--link:#1f5fa8;background:var(--bg);color:var(--ink);font:14px/1.55 "Segoe UI",system-ui,-apple-system,sans-serif;border:1px solid var(--line);border-radius:12px;padding:20px 18px;margin:24px 0;max-height:900px;overflow:auto}
@media (prefers-color-scheme:dark){.triage-demo{--bg:#16171a;--panel:#1f2024;--ink:#e9e7e2;--muted:#a19e96;--line:#34353a;--a:#ff8a80;--a-bg:#3a1f1d;--b:#f0b458;--b-bg:#35291a;--c:#8db8e6;--c-bg:#1c2a38;--ok:#8fd19b;--ok-bg:#1c3022;--v:#c7a6f0;--v-bg:#2a2236;--note-bg:#25262a;--link:#8db8e6}}
.triage-demo *{box-sizing:border-box}
.triage-demo h1{font-size:22px;margin:0 0 4px;border:0;padding:0}
.triage-demo h2{font-size:17px;margin:28px 0 10px;padding-bottom:5px;border-bottom:2px solid var(--line)}
.triage-demo h3{font-size:15px;margin:0}
.triage-demo h4{font-size:14px;margin:14px 0 4px}
.triage-demo p,.triage-demo li{margin:4px 0}
.triage-demo a,.triage-demo .wi{color:var(--link);text-decoration:underline;text-underline-offset:2px}
.triage-demo .sub{color:var(--muted);margin:0 0 14px}
.triage-demo .stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:8px;margin:14px 0}
.triage-demo .stat{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:8px 12px}
.triage-demo .stat b{display:block;font-size:21px}
.triage-demo .stat span{color:var(--muted);font-size:12px}
.triage-demo .callout{background:var(--note-bg);border-left:4px solid var(--muted);border-radius:4px;padding:8px 12px;margin:10px 0}
.triage-demo .callout.warn{border-left-color:var(--b)}
.triage-demo .callout ol{margin:6px 0 0;padding-left:20px}
.triage-demo .wrap{overflow-x:auto}
.triage-demo table{width:100%;border-collapse:collapse;font-size:13px;margin:0;display:table}
.triage-demo th,.triage-demo td{text-align:left;padding:5px 7px;border:0;border-bottom:1px solid var(--line);vertical-align:top;background:none}
.triage-demo th{color:var(--muted);font-weight:600;font-size:11px;text-transform:uppercase;letter-spacing:.03em}
.triage-demo .session{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:12px 14px;margin:12px 0}
.triage-demo .session header{display:flex;flex-wrap:wrap;gap:8px;align-items:baseline;margin-bottom:6px}
.triage-demo .tag{display:inline-block;font-size:11px;font-weight:700;padding:1px 8px;border-radius:10px;white-space:nowrap;cursor:help}
.triage-demo .p0{color:var(--a);background:var(--a-bg)}
.triage-demo .pa{color:var(--v);background:var(--v-bg)}
.triage-demo .pb{color:var(--b);background:var(--b-bg)}
.triage-demo .pc{color:var(--c);background:var(--c-bg)}
.triage-demo .why{color:var(--muted);margin:2px 0 8px}
.triage-demo .id{white-space:nowrap}
.triage-demo .new{color:var(--ok);font-weight:700;font-size:11px}
.triage-demo code{font-family:Consolas,"Cascadia Mono",monospace;font-size:12px;background:var(--note-bg);padding:1px 4px;border-radius:3px;color:inherit}
.triage-demo details{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:10px 14px;margin:12px 0}
.triage-demo summary{cursor:pointer;font-weight:600}
.triage-demo ul,.triage-demo ol{padding-left:20px}
.triage-demo footer{color:var(--muted);font-size:12px;margin-top:24px}
</style>
<div class="triage-demo">
<h1>Sprint 14 &mdash; your open work</h1>
<p class="sub">Orders team, Sprint 14 (Mar 2 &rarr; Mar 13, day 6) &middot; <b>Refreshed Mar 9, ~15:00, after the sixth QA sweep and PR 712</b>, from the tracker's live state &middot; Scope: open items assigned to you in Sprints 13 and 14. <b>This is the only planning document.</b> The standing QA-sweep brief is in the appendix.</p>
<div class="stats">
<div class="stat"><b>GREEN</b><span>main <code>4e1c9a2</code>: CI build 1182 passed in all 3 QA environments (DB tests 412, API 298, E2E 61/64/64)</span></div>
<div class="stat"><b>27</b><span>open with you: 16 New, 5 In Progress, 4 QA, 2 Approved</span></div>
<div class="stat"><b>3</b><span>closed by the sixth sweep on measured evidence; 4 went to Marco with screenshots</span></div>
<div class="stat"><b>1</b><span>PR waiting on review (<span class="wi">712</span>, <span class="wi">#4127</span>)</span></div>
</div>
<div class="callout warn">
<b>Needs you, in one list.</b>
<ol>
<li><b>Review and merge PR <span class="wi">712</span> (<span class="wi">#4127</span>).</b> You chose the server-side fix: the order total is recalculated after a discount is removed. 4 new tests failed first; suite, lint and build are green locally. After merge it goes to Marco with screenshots.</li>
<li><b><span class="wi">#4133</span>: go or no-go on restarting the import worker on QA-east.</b> It's the only evidence left for the "resumes after restart" acceptance criterion, and it changes the host.</li>
<li><b>Take two questions to Priya together:</b> <span class="wi">#4140</span> (should partial refunds re-open an order?) and <span class="wi">#4141</span> (which date the monthly report groups by).</li>
<li><b>Small findings, not filed</b> (file any you want): <code>ui/orders/OrderHistory.js</code> is imported nowhere and could go with <span class="wi">#4119</span>.</li>
</ol>
</div>
<div class="callout">
<b>Sixth QA sweep, Mar 9 (~11:30&ndash;13:00).</b> PRs <span class="wi">705</span>, <span class="wi">708</span> and <span class="wi">710</span> moved five items to QA; the scope query returned 9 items at the start and 9 at the end. main <code>4e1c9a2</code> deployed in CI build 1182, and every stage passed. The 6 new tests from PR 708 were found by name, not from a total. <b>Closed:</b> <span class="wi">#4102</span> (search p95 went from ~640 ms to 70&ndash;95 ms, measured on the deployed code), <span class="wi">#4108</span> and <span class="wi">#4111</span> (DB-only, every acceptance criterion carried by named tests). <b>To Marco with screenshots:</b> <span class="wi">#4105</span>, <span class="wi">#4109</span>, <span class="wi">#4114</span>, <span class="wi">#4115</span>. <b>Stays with you:</b> <span class="wi">#4133</span> (see "Needs you"). Every item got a comment, including the ones that stay with you.</div>
<h2>Priority order at a glance</h2>
<div class="wrap"><table>
<thead><tr><th>#</th><th>Pri</th><th>Session</th><th>Items</th><th>PRs</th></tr></thead>
<tbody>
<tr><td>1</td><td><span class="tag p0" title="Priority 0, unblock: someone or something is waiting on this right now. Do these first.">0</span></td><td>Your QA work: 4 items in QA, plus PR 712</td><td><span class="wi">#4127</span> <span class="wi">#4133</span> <span class="wi">#4136</span> <span class="wi">#4138</span></td><td>&mdash;</td></tr>
<tr><td>2</td><td><span class="tag pa" title="Priority A, product owner's: stories they approved or sent back to you.">A</span></td><td>Checkout: discount and refund edge cases</td><td><span class="wi">#4140</span> <span class="wi">#4142</span> <span class="wi">#4143</span></td><td>1&ndash;2</td></tr>
<tr><td>3</td><td><span class="tag pa" title="Priority A, product owner's: stories they approved or sent back to you.">A</span></td><td>Monthly sales report: grouping and export</td><td><span class="wi">#4141</span> <span class="wi">#4146</span></td><td>1</td></tr>
<tr><td>4</td><td><span class="tag pb" title="Priority B, CI and tooling: work that makes every other session faster or safer.">B</span></td><td>CI: retry flaky E2E steps and un-gate the API suite</td><td><span class="wi">#4120</span> <span class="wi">#4121</span> <span class="wi">#4124</span></td><td>2</td></tr>
<tr><td>5</td><td><span class="tag pc" title="Priority C: everything else, in a sensible order.">C</span></td><td>Order history: lint, dead code and test gaps</td><td><span class="wi">#4119</span> <span class="wi">#4150</span></td><td>1</td></tr>
</tbody></table></div>
<h2>Priority 0 &mdash; unblock</h2>
<section class="session" id="s-1">
<header><span class="tag p0">0 &middot; 1</span><h3>Your QA work: 4 items in QA, plus PR 712</h3></header>
<p class="why">The sixth sweep closed three items and handed four to Marco. Every item below got a comment today. The first is back In Progress with a PR up; the other three need you.</p>
<div class="wrap"><table>
<thead><tr><th>ID</th><th>Title</th><th>Status</th><th>Notes</th></tr></thead>
<tbody>
<tr><td class="id"><span class="wi">#4127</span></td><td>Order total is wrong after a discount code is removed</td><td>In Progress &middot; PR <span class="wi">712</span></td><td><span class="new">NEW</span> Root cause: the total was cached before the discount was removed. 4 tests failed first, then passed. After merge: screenshots of the cart in all 3 environments to Marco.</td></tr>
<tr><td class="id"><span class="wi">#4133</span></td><td>Import worker resumes where it stopped after a restart</td><td>QA</td><td>ACs 1&ndash;3 met by named tests. <b>Open:</b> AC 4 needs a supervised restart on QA-east with a backlog queued. Waiting on your go.</td></tr>
<tr><td class="id"><span class="wi">#4136</span></td><td>Show a clear error when the payment provider times out</td><td>QA</td><td>Verified against the API. The error banner is user-visible, so it goes to a tester. That's blocked on a QA account with a test card in QA-west.</td></tr>
<tr><td class="id"><span class="wi">#4138</span></td><td>Speed up the order search query</td><td>QA</td><td>The deployed query measured 120&ndash;180 ms against a 100 ms AC. Stays with you: an index change or a revised AC.</td></tr>
</tbody></table></div>
</section>
<h2>Priority A &mdash; product owner's</h2>
<section class="session" id="s-2">
<header><span class="tag pa">A &middot; 2</span><h3>Checkout: discount and refund edge cases</h3></header>
<p class="why">All three touch <code>CheckoutService</code> and the same two tables. One session; a second PR only if <span class="wi">#4140</span>'s answer changes the refund flow. <b>Don't start this until PR 712 merges.</b> It edits the same file.</p>
<div class="wrap"><table>
<thead><tr><th>ID</th><th>Title</th><th>Status</th><th>Notes</th></tr></thead>
<tbody>
<tr><td class="id"><span class="wi">#4140</span></td><td>Partial refund leaves the order in the wrong state</td><td>New</td><td>Needs Priya's answer: should a partial refund re-open the order?</td></tr>
<tr><td class="id"><span class="wi">#4142</span></td><td>Stacked discount codes apply in a different order on mobile</td><td>New</td><td>Probably the same root cause as <span class="wi">#4127</span>. Re-check after 712 merges; it may just close.</td></tr>
<tr><td class="id"><span class="wi">#4143</span></td><td>Add an audit row when a discount is removed</td><td>Approved</td><td>Small, DB plus one API call. Do it last in the session.</td></tr>
</tbody></table></div>
</section>
<h2>Decisions that block work</h2>
<div class="wrap"><table>
<thead><tr><th>Item</th><th>Decision</th><th>Blocks</th></tr></thead>
<tbody>
<tr><td><span class="wi">#4133</span></td><td>Go-ahead for a supervised import-worker restart on QA-east with a backlog queued?</td><td>Closing <span class="wi">#4133</span></td></tr>
<tr><td><span class="wi">#4140</span></td><td>Priya: does a partial refund re-open the order?</td><td>Session A &middot; 2</td></tr>
<tr><td><span class="wi">#4138</span></td><td>Add the index, or relax the AC to 200 ms?</td><td>Closing <span class="wi">#4138</span></td></tr>
</tbody></table></div>
<h2>Housekeeping</h2>
<ul>
<li>The sixth sweep's scratch is in <code>C:\work\_qa-sweep-tmp\s6</code>. <code>s4</code> and <code>s5</code> can go.</li>
<li>Worktree <code>C:\work\orders-wt-4108</code> is merged and can be removed.</li>
</ul>
<h2>Appendix &mdash; standing brief for a QA sweep</h2>
<details open>
<summary>How to run the review (condensed)</summary>
<h4>1 &middot; Scope</h4>
<ul><li>Items in QA, assigned to me, in this sprint <b>and the previous one</b>. Re-run the query at the end, because items get added mid-sweep.</li></ul>
<h4>2 &middot; Give every item one of three dispositions</h4>
<div class="wrap"><table>
<thead><tr><th>Disposition</th><th>When</th><th>What I do</th></tr></thead>
<tbody>
<tr><td><b>Done</b></td><td>Every AC is carried by evidence I can verify myself, <b>and</b> the change isn't one a user can see.</td><td>Comment with the evidence for each AC, then close.</td></tr>
<tr><td><b>To a tester</b></td><td>Anything a user can see, however small and however well tested.</td><td>Post a step-by-step guide with named test data, then reassign.</td></tr>
<tr><td><b>Keep with you</b></td><td>It needs a decision, a code change, or a measurement no tester can make.</td><td>Post exactly what's blocking and the next actions. Don't close it.</td></tr>
</tbody></table></div>
<h4>3 &middot; Evidence standards</h4>
<ul>
<li>Check tests <b>by name</b>, never from a total. "121/121 green" is also what a suite that quietly lost two tests reports.</li>
<li>Match the <b>deployed commit</b>, not the version string.</li>
<li>Prefer a live probe to reading source. Source shows what <i>should</i> have deployed.</li>
<li>Reproduce a failure before blaming it on the environment, and get a negative control.</li>
<li>Don't trust remembered facts. Test data from the last sweep rots, so re-read it on the day.</li>
</ul>
</details>
<footer>Sources: the two-sprint QA scope query (start and end), work items and comments from the tracker API, CI build 1182 (stage results and named tests), and 18 headless-browser screenshots of the deployed QA sites.</footer>
</div>

A few things about it that matter more than they might look:

- **Each card is one Claude session.** Items that touch the same code go together, so the context from the first item helps with the next. The card also says when a session would collide with work already in flight. In my real file, one card said, roughly, *"another clone currently has uncommitted edits to these procedures. Carry on in that session; don't start a second one."* That's how I avoid collisions before they happen.
- **"Needs you" is the most valuable part.** After a sweep, most items close themselves or go to a tester. What's left is a short list of things only I can do, and it's at the top.
- **The QA sweep brief lives in the same file.** To run a sweep I just say *"Everything is merged and deployed. Do another QA sweep and update the work-items file."* Claude follows the brief, posts a comment on every item, and rebuilds the page.
- **Every card has an anchor, so it doubles as the prompt.** "Start C:/r/my-triage-document.html#s-1" hands a session the whole card: which items go together, the order to do them in, and what to watch out for. The stories themselves still carry what's needed to do the work; the card adds the bundling.

### The QA sweep

The first sweep prompt was long:

> Look at all the work items which are in QA and assigned to me. If they can be confirmed by you, like database tests and E2E tests, set the item to Done. If it needs a person to QA it, assign it to a tester and add a comment with a step-by-step guide on how to test it.

Now it's "do another QA sweep." The brief has grown with every pass, and each time a sweep got something wrong, the fix went into the brief. The "check tests by name, not by total" rule exists because a total once looked fine while two specific tests had quietly gone missing.

For every item that goes to a tester, Claude posts a step-by-step guide on how to test it, along with the specific item to test it with. The testers say the guides help most when they name specific test data that exists in each environment, so they don't have to go looking for a record that fits the scenario. Claude finds that data as part of the sweep. It also takes screenshots of the deployed sites and marks them up to show exactly where the change is. Testers can review those screenshots without navigating the app, so for anything that only needs visual feedback they can tell at a glance whether the change is right or should be rejected.

Anything it can't verify on its own ends up under "Needs you" in the work-items file. A lot of the time, my "manual QA" is just telling Claude it's OK to create fake data in the QA database so it can test the scenario itself.

## Working in parallel: four to seven sessions at once

While one session runs tests, I'm answering another session's questions. On a typical day I have four to seven sessions going across several clones of our repositories. Some are in their own clone, and some are git worktrees inside a clone.

Separate folders mean sessions can't edit each other's files. The hard part is **shared resources**: the local database server, the QA database, and the desktop itself when E2E tests drive the browser.

So the sessions talk to each other. There's an append-only coordination text file per codebase, with lines like:

```
CLAIM agent-4127 local SQL
NOTE  reserving migration 0190
RELEASE agent-4127
DONE  PR 712
```

It started with one prompt: *"I have two of you working and I don't want you both to be doing tests at the same time. Communicate with each other in this file."* My favorite line from one of those files is one agent backing off on its own:

> RETRACTING my 16:47 line. I did not re-read this file before posting it. The other session announced a full E2E run. The ports are yours.

**When it went wrong:** two sessions once claimed the same database instance in two different files. They ran tests against the same database for about eight hours and kept breaking each other's runs. Out of that came one coordination file instead of several, a real OS-level file lock for E2E runs (Claude wrote it after concluding that text coordination "cannot enforce anything"), and a separate local database instance for each clone.

Parallel work has coordination overhead. It isn't free.

### A tasks/ folder in every repo

Anything done more than twice becomes a one-word script, which Claude wrote and which both of us run:

| Script | What it does |
|---|---|
| `start.ps1` | Run the app locally |
| `test.ps1` | Rebuild, then run the chosen test suites |
| `run-with-lock.ps1` | Take the machine-wide lock before an E2E run |
| `remove-merged-branches.ps1` | Delete merged branches, and their worktrees when it's safe |

And one small trick makes 4–7 terminals manageable: every tab gets a title.

```powershell
cd C:\work\orders-2\; $HOST.UI.RawUI.WindowTitle = 'Orders 2';
```

## Keeping it honest

### Evidence before claims

A real example, with the details changed. I pasted in one slow API call in the morning. Claude filed the work item, created the branch, and built a timing harness: about 690 ms baseline on QA. It rewrote five stored procedures to be set-based. Then the safety check blocked it from changing the shared QA database, so it **stopped and asked me**. I said yes, and also asked it to check CPU time.

It ran an A/B/A test on QA, then restored the originals byte for byte: about 25% less CPU. It also found the real culprit. The slowest saves were cold compiles. I said "fold the compile fix into the same PR," the cold saves dropped from ~1.4 s to ~1.0 s, the whole DB test suite passed, and the PR merged the same afternoon.

Two things I like about that: it measured before and after on real data and put things back exactly as they were, and when a guardrail blocked it, it asked instead of working around the block.

### Habits that keep it honest

**Verification**
- A test must fail without the fix. Prove red, then green.
- Read the state back. Command-line tools can exit 0 and change nothing.
- Question the premise. Once the story itself was wrong, and Claude proved it with nearly 1,900 rows of QA data before changing anything.
- Fresh eyes: code review by a separate agent.
- Let Claude look at the app. It runs the E2E tests and navigates the app to check its own work, so I rarely have to click through it myself.

**Guardrails**
- Auto mode with a safety check: anything named "prod" or "production" is off limits.
- QA servers are read-only by default, and it asks before restarting anything.
- Personal data: *"a valid token is authentication, not authorization from the user."*
- When it's blocked, it hands me the command to run instead of finding a way around.

Every PR still gets human review. My name is on it.

## Not just code

Many of my prompts don't produce code at all:

- **Spikes and write-ups.** "Where do the 42–56 minutes of our E2E run go?" produced three measured full runs, an HTML write-up, and seven follow-up stories, which I then worked in parallel.
- **The backlog.** The work-items file above.
- **Test data.** Finding records in each QA environment that fit a test scenario, so testers don't have to hunt.
- **Diagnosing environments.** "The DB deployment has been failing in QA for some time. Figure out why and fix it. If a work item isn't already created, create one."

The HTML habit deserves a mention. Whenever there's a lot to understand, such as a root-cause analysis, a design with trade-offs, or spike results, I have Claude write it up as a self-contained HTML page with real tables, diagrams and charts. Then I read that instead of scrolling the terminal. It's a rule in my global instructions, and it's where most of those ~350 documents came from.

## What still goes wrong

- **Confident and wrong.** One session once told several other sessions that "git status lies." Another session challenged it, it tested the claim, and it retracted. (A timeout wrapper was killing the command.)
- **Scope drift.** It narrowed a story to one environment when the story didn't say to.
- **Environment friction.** WSL vs. Windows, git credentials, slow tools. Each one got fixed once, in memory.
- **Collisions** when parallel sessions share a resource. See the eight-hour one above.
- **Rate limits** on heavy days.

None of these go away. What changes is that each one gets fixed once and stays fixed.

## Stepping back

Running the loop is only half the job. Every so often I need to step back and think creatively about how to make the project itself better, not just close the next ticket. The loop makes the routine work fast, and that frees up time for exactly that kind of thinking.

## If you try one thing this week

- **Developers:** run `/init` in your repo, then keep a `memory.md`. Every time you correct Claude, say "add that to memory.md."
- **Everyone:** ask it to ask you questions before it does anything.
- **QA and product folks:** give it a list of work items and ask for a readable HTML summary or grouping.
- Install **superpowers** (via `/plugin`) and you get the ask-first, test-first loop without having to ask for it.
- Use **`/clear`** between tasks. One job per context. Sometimes I add a description, like `/clear checkout discount bundle`, which makes the session easy to look up later.
- **Never accept "done" without evidence:** the test output, the link, the number.
