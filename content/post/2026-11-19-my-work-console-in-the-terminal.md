---
title: I Moved My Work Console into the Terminal
url: /my-work-console-in-the-terminal/
date: 2026-11-19
description: Five days after I wrote about my browser-based work console, I stopped using it. Here's the terminal client that replaced it, how it got built in an hour and shaped over two days, and a spec detailed enough to build your own.
tags:
    - ai
    - claude
    - workflow
---

Six days ago I wrote about [the small app that runs my day](/my-own-work-console/): a local server that holds my work items, coordinates my Claude Code sessions, and gives me a session console in the browser. I said the session console had changed my day more than anything else.

I've stopped using it. Not the server, which runs everything the same as before, but the browser page. I now live in a full-screen terminal app that talks to the same server. This post is about that app. The first half tells you what it's like and how it came about. The second half is a spec: enough detail that you, or your Claude, could build one without seeing my code.

## Why leave the browser?

My Claude sessions already run in terminals. Every time one needed me, I went to the browser, read the session's state, clicked into it, and often then went *back* to a terminal to actually answer it. The browser was a waiting room between two terminals.

So on Tuesday morning I asked:

> I would like a TUI client for this. Everything should be full screen. So, the alerts and keyboard shortcuts should be shown at the top to help me know what I should push to go to the different screens.

Claude asked whether I wanted a monitor or a full client. I said:

> Full client, I want to answer sessions from the terminal

(As before, I've changed names in the prompts I quote, fixed typos, and marked cuts with "…".)

## Click through it

Below is a copy of it you can drive. Click the terminal and use your keyboard: the same keys I use. Or use the buttons under it. Like last time, everything is made up: the small online bookshop, its three projects, Priya as product owner and Marco as tester. Nothing does real work. The panel explains the screen you're on: **In my day** is what it does for me, and **How it's built** is how it works. Follow **Try next**, or wander.

<div style="width:min(1200px, calc(100vw - 32px));position:relative;left:50%;transform:translateX(-50%);margin:1.5rem 0 0.5rem">
<iframe name="demo" id="demo" src="/tui-demo/" title="A keyboard-driven tour of the terminal console" loading="lazy" allow="clipboard-write" style="display:block;width:100%;height:min(780px, 85vh);border:1px solid var(--b-line, #ccc);border-radius:10px;margin:0"></iframe>
</div>

<p style="text-align:center;font-size:0.9rem"><a href="/tui-demo/" target="_blank" rel="noopener">Open the tour full screen ↗</a></p>

<script>
document.addEventListener('click', function (e) {
  var a = e.target.closest('a[target="demo"]');
  if (!a) return;
  var demo = document.getElementById('demo');
  try { demo.contentWindow.location.replace(a.href); e.preventDefault(); } catch (err) { /* let the link navigate the frame */ }
  demo.scrollIntoView({ behavior: 'smooth', block: 'start' });
});
</script>

Every screen has the same two lines at the top. The first has the screen keys on the left, and on the right the alerts: how many sessions need me, the mentions and reviews waiting in the tracker, and the timer. The second line has the keys for the screen I'm on. Everything else is the screen itself.

## A morning with it

The links in this section change the demo above.

1. **I open a terminal and run `python3 triage.py tui`.** <a href="/tui-demo/#sessions" target="demo">Two sessions need me</a>. I press **Enter** on the first, <a href="/tui-demo/#attach/storefront~2" target="demo">see it wants to run the E2E suite</a>, press **1** to allow it, and **Ctrl-O** back out. The second <a href="/tui-demo/#attach/mobile" target="demo">has a question</a>. Same thing. I never touch the mouse.
2. **i** on a session that worked overnight shows me <a href="/tui-demo/#brief/storefront" target="demo">its brief</a>: the summary and plan it keeps up to date for me. **m** shows <a href="/tui-demo/#replies/storefront" target="demo">its replies to me</a>, newest at the bottom. That's usually all I need to know whether to look closer.
3. **F2**: Priya <a href="/tui-demo/#notices" target="demo">mentioned me</a> on a story. **Enter** opens <a href="/tui-demo/#new" target="demo">a new session</a> with a prompt already written, which tells it to read the comment and tell me what it means, without replying. I press **Enter** again and it's running.
4. **F5** shows <a href="/tui-demo/#prs" target="demo">a PR with "2 to answer"</a> in red. **Enter** starts a session that works through the reviewers' comments and shows me its changes and draft replies before it pushes anything.
5. **F3**, **→** to <a href="/tui-demo/#triage/warehouse" target="demo">the Warehouse project</a>, **j**, **Enter** on the next card. Another session starts in its own git worktree.
6. Later I need a session from last week. **/** and `gift` <a href="/tui-demo/#search" target="demo">filters the list</a> to the sessions about gift cards, live ones first, then ended ones going back a week.
7. While I'm reading something else, a session <a href="/tui-demo/#flash" target="demo">starts waiting on me</a>. The count flashes and the terminal beeps once.

## How it came together

This is the part that surprised me. The first working version took about **an hour**. Claude wrote a design doc with the options, I picked one, it wrote a plan, and subagents built it test-first. I was using it about 45 minutes after I first asked.

Then I used it for two days and kept saying what annoyed me. That's where it actually got good.

**The clever part I deleted.** The design gave me a choice: mirror each session's screen inside the TUI and answer through the server, or attach to the session's real terminal. I said *"C, go with both."* The mirror came with a careful set of rules so I couldn't answer a prompt by accident: the number keys went to the session only when the text box was empty, the prompt had been showing for at least a second, and only once until the screen refreshed. It worked. Then I used it for an afternoon and wrote:

> When I click enter it should go straight to the console like I am typing Ctrl-A and that other screen shouldn't exist anymore.

The real terminal was always better than a copy of it. All that careful code went, and the TUI got simpler.

**Getting back.** Attaching to a tmux session left me in tmux, and tmux's own detach key is two keystrokes I kept forgetting. *"When I do Ctrl-A to open a session, how do I go back to the main screen?"* Now the TUI binds **Ctrl-O** in that tmux server before it attaches. Then: *"When I type Ctrl-O it should take me back to the location I was before on the screen."* It does now.

**Vim keys, eventually.** I asked to move with the keys under my right hand:

> I would like to be able to move around on other pages with j,k,l,; in addition to using arrows.

Claude did what I said. Then I said *"Wait, that isn't the normal way j,k,l,; work. j should be up, k down…"*, then *"Sorry, j should be down and k is up"*, then *"l is right, h is left."* Four commits in five minutes, and the mistakes were mine. It's **h j k l** now, like vim, plus **g** and **G** for top and bottom, plus **Ctrl-H** and **Ctrl-L** to flip through the screens. The lesson isn't about vim. Claude will build exactly what you say, so when the result feels wrong, it's often your description that was wrong.

**Small things that mattered.** A colour for each state (*"maybe green for working"*). A count of notices on the F2 label, then removing it three minutes later because the alert on the right already showed it. The ⏱ next to the session I'm timing. Titles from Claude Code's own `/rename`, so a session shows what I called it. Ignoring pastes outside a text box, so a paste's newlines can't act as Enter presses. Every one of these was a sentence or two from me and a few minutes from Claude.

**The PRs page** came from one evening's question: *"I would like a page or a place I can look and see all the active PRs that I have out, including their URLs."* Then *"can you have it tell me if they have comments waiting for me…?"* Then, the next morning: *"if I type Enter then I would like it to open a new session and start resolving the issues. But, I would like to be able to open the PR itself too, just with a different character."* That's **o**.

By the end of the second day the TUI was about 1,700 lines of Python and 700 lines of tests, standard library only (curses and urllib). The first version needed one new read-only endpoint on the server; the PRs page and search each added a little more.

## What I'd tell you

- **A second front end is cheap when the first one did the work.** All the rules (who can type into a session, what a timer click means, what a notice launch dismisses) live in the server. The TUI holds no state of its own, so it behaves exactly like the browser did, and it took an hour.
- **Try the real thing before building a copy of it.** My best design decision was deleting the feature I'd asked for.
- **Use it for a day before you judge it.** Nothing on the list above was in the design. All of it came from using it.

If you built the browser version from my last post, the spec below is the next step. If you didn't, the spec says what the server has to provide, so you can build both.

---

## The spec

This is how my TUI works, written so you can rebuild it. Where I say "must", a test pins it and I'd keep it. Everything else is a choice you can make differently.

### Scope

- **Goal:** do everything the browser console did, from one full-screen terminal: see what needs me, answer sessions, start sessions, act on notices and PRs.
- **Not in scope:** editing the triage (cards, tiers, waits). Claude sessions do that through the server's tools. Theme and text-size settings mean nothing in a terminal.
- **Anti-goal:** a second source of truth. The TUI reads and writes everything through the server. If it crashes, nothing is lost.

### Where it runs

```text
  Windows                                   WSL (Linux)
 ┌─────────────────────────────┐          ┌──────────────────────────────────────────┐
 │ triage server (Python)      │◀─ HTTP ──│ TUI: python3 triage.py tui (curses)      │
 │  /sessions/... JSON         │          │   │                                      │
 │  /mcp (JSON-RPC tools)      │          │   └─ tmux -L triage attach -t L<id> ───┐ │
 │  SQLite                     │─ tmux ──▶│ tmux server "triage": one session per  ◀┘ │
 └─────────────────────────────┘ (wsl.exe)│ console-started Claude Code session      │
                                          └──────────────────────────────────────────┘
```

- **Python 3, standard library only:** `curses` for drawing, `urllib` for HTTP, `subprocess` for tmux, `threading` for polling.
- **The server's URL** comes from config (`http://localhost:8765/` by default), overridable with `TRIAGE_SERVER`.
- **The TUI is a subcommand of the server's CLI** (`triage.py tui`), imported lazily so the server never loads curses.
- **Sessions the console starts** run in tmux on their own socket (`tmux -L triage`), each in a tmux session named `L<launch id>`, not the agent name, because the name is only known after Claude checks in. The TUI runs on the same side as tmux, so it attaches directly.
- **The expected terminal** is Windows Terminal: it passes F-keys, Alt-keys and 256 colours. The minimum size is 80×20; below that the TUI draws only "make the window bigger".

### What the server must provide

The TUI is a thin client. If you're building from my last post, you have most of this. Every `POST` carries the header `X-Triage: 1`, which a browser can't send cross-origin without a preflight the server never approves. That's the server's guard against other web pages driving your terminals. Every `GET` under `/sessions` must come with a localhost `Host` header.

| Call | Returns / does |
|---|---|
| `GET /sessions/state` | Everything the top bar and the Sessions and Notices screens need, in one poll (below). |
| `GET /sessions/a/<agent>` | One session's detail: `state`, `title`, `item {id, title}`, `branch`, `launch_id`, `ended`, `brief {summary, plan[{step, state: done\|now\|todo}], stale, updated_age}`, `replies [{text, age, cut}]` newest first. |
| `GET /sessions/ended` | Sessions that ended too long ago to be in the state list, back a week, for search. |
| `GET /sessions/messages` | The last 50 messages between sessions, read-only. It must not mark anything read. This was the only endpoint I had to add. |
| `GET /sessions/checkouts?project=<key>` | For the new-session form: the project's main checkout (`main`), its `cards [{slug, name}]`, and the `commands [{name, help, args}]` a session can start on. |
| `POST /sessions/launch` | Starts a session. Body: `project`, plus one of `card`, `item_id`, `prompt`, or `command` with `args`. Optional `notice` (dismiss this notice once started), `pr_id` (clear my notices on this PR), `branch`. Returns `tmux`, `worktree`, `reused`, `warning`. |
| `POST /sessions/notices/dismiss` | `{key}`: dismiss a notice for good. |
| `POST /sessions/timer` | `{action: start\|stop, agent}`: returns the new timer. |
| `POST /sessions/a/<agent>/ask-brief` | Asks the session to rewrite its brief: typed in if the console started it, sent as a message otherwise. |
| `POST /sessions/a/<agent>/end` | Ends a console session: types `/exit`, and kills its tmux session after 10 s. |
| `POST /mcp` tools | `list_projects`, `get_project` (the triage page's data), `claims`, `who`, `my_prs`. Called as JSON-RPC `tools/call`; the result's first content item is JSON text. |

`/sessions/state` holds:

- `sessions`: already ordered by the server, each with `agent`, `state` (`permission`, `question`, `starting`, `your_turn`, `idle`, `working`, `background`, `ended`), `state_age` in seconds, `title`, `item {id, title}`, `project`, `branch`, `launch_id`, `ended`, `last_action {tool, target}`.
- `need_you`: the count of sessions in `permission` or `question`.
- `timer`: `{state: running|paused|stopped, agent, elapsed}`.
- `notices`: `[{key, kind: mention|review, project, item_id, pr_id, who, age, title, excerpt, url, prompt}]`, newest first. `prompt` is the first prompt for a session about it.
- `notice_chip {text}`, like "1 mention · 1 review", and `notice_check {age, error}` from the last tracker poll.

`my_prs` returns `prs` and `errors` (one per project it couldn't read). Each PR has `id`, `repo`, `project`, `title`, `url`, `source` and `target` branches, `age`, `draft`, `auto_complete`, `votes {approved, waiting, rejected}` and `comments`. `comments` is `null` when they couldn't be read, otherwise `{waiting, handled, waiting_on_me: [{who, text}]}`. A thread is *waiting* when it's still active and someone other than me wrote last. It's *handled* when I wrote last or it's resolved.

### The frame

```text
line 0   screen keys ............................................ alerts
line 1   keys for this screen, or a status message, or a y/n question
line 2   ──────────────────────────────────────────────────────────────
line 3+  the screen
```

**Line 0, left:** `F1 Sessions  F2 Notices  F3 Triage  F4 Coord  F5 PRs`, the current screen bold and underlined. **Right:** the alerts, in this order:

| Alert | Text | Style | Drop order |
|---|---|---|---|
| Server down | `server unreachable` | white on red | never |
| Need you | `● 2 need you` | bold red; reverse video for 3 s when a new session joins, and one bell | never |
| Notices | `✉  1 mention · 1 review` | bold yellow | second |
| Timer | `⏱ storefront 0:42` (+ ` paused`) | dim | first |

When the line is too narrow, it tries in order: drop the timer, drop the notices, shorten the screen keys to `F1 F2 F3 F4 F5`, then show only the must-keep alerts followed by the short keys. A test checks the bar at several widths.

**Line 1** is the hint line for the current screen. A status message replaces it for a few seconds (5 by default, 12 for a launch warning). A y/n question replaces it until it's answered. On Sessions with a search active, it shows the search instead.

**Colours** use the terminal's default background (`use_default_colors`, background `-1`) so the TUI reads on both light and dark terminal themes. Styles map to the eight basic colours plus bold, dim, underline and reverse: *alert* red bold, *warn* yellow bold, *ok* green bold, *idle* blue bold, *info* and *key* cyan, *dim* dim, *sel* reverse. Session states: permission and question → alert, starting → warn, your_turn → info, idle → idle, working → ok, background → its own, ended → dim. Work-item states on the Triage screen get colours the same way (Blocked red, In Progress green, and so on).

### Keys everywhere

| Key | Does |
|---|---|
| `F1`–`F5`, or `1`–`5` outside a text box | Switch screens. F-keys work everywhere, even mid-form (they abandon the form). |
| `Ctrl-L` / `Ctrl-H` | Next / previous screen, wrapping. |
| `h j k l` | `← ↓ ↑ →`, outside a text box. |
| `g` / `G` | Top / bottom of any list or view. |
| `?` | Help: every key by screen, and the command that starts the server. |
| `r` | Refresh now (clears the caches). |
| `q` | Quit. |
| `Esc` | Back, or clear. |

Switching screens resets the selection and any search. Coming back from a view, help or the form keeps it.

### F1 Sessions

**Groups**, in this order, each with a heading, empty ones left out: **NEEDS YOU** (permission, question, starting), **STOPPED** (your_turn, idle), **WORKING** (working, background, and anything unknown), **ENDED**. Inside a group, keep the server's order. Mine sorts by what needs me first, longest-waiting first.

**A row:** a two-character timer mark (`⏱ ` on the timed session, dim when paused), the agent name padded to 21, the state padded to 11 in its colour, the age (`4m`, `3h`, `2d`), a label up to 48 characters, then the last tool and its target (`Bash: npm run e2e`). The label is the session's title then ` · #<item>`, or `#<item> <item title>` when there's no title. A session's title is Claude Code's own, and wins once you `/rename` it.

**The selection follows the session**, not the row number. Each poll can reorder the list, so keep the selected session's key and find it again after every poll. If it's gone, stay on the same row.

| Key | Does |
|---|---|
| `Enter` | Attach to the session's terminal (below), and start the timer on it. A session the console didn't start has no terminal here: say so on the status line. |
| `i` | Its brief view. |
| `m` | Its replies view. |
| `n` | New session form. |
| `t` / `T` | Start the timer on it / stop the timer. |
| `x` | "End storefront? y/n". `y` ends it. |
| `/` | Search. |

**Search**, like vim's `/`: type words, and only sessions whose agent, label, item title, project or branch contain *all* of them stay (case-insensitive). Opening search also fetches `GET /sessions/ended`, and those older sessions are added after the listed ones, so live sessions come first. While typing, `↑ ↓` move, `Backspace` on an empty box or `Esc` closes it, and `Enter` keeps the filter so `j k` and the other keys work inside it. `Esc` then clears it. Line 1 shows `/gift  2 matches  Enter keep  Esc clear`, and the cursor sits in it.

**The brief view (`i`)** shows a header (agent · state · title · item · branch), then the summary wrapped to the width, then PLAN with `✓` done, `▶` now, `·` todo, then "Updated 2h ago". A brief the server marks stale gets a warning line on top. `b` asks the session for a fresh one, refused for an ended session. **The replies view (`m`)** shows each reply under a `— 12m ago` heading, oldest first so the newest is at the bottom, and opens scrolled to the bottom. In both: `↑ ↓ PgUp PgDn` scroll, `g G` jump, `i` / `m` switch, `Enter` attaches, `Esc`, `q`, `←` or `Ctrl-O` go back. The detail refreshes every 2 s while a view is open. If the view was opened on a session still starting (`L<id>`), follow it to its real agent name once it checks in.

### Attaching to a session

This is what replaced the mirror, and it's short:

1. Work out the tmux target: `L<launch_id>`. Ended sessions and sessions the console didn't start have none.
2. Before every attach, set three things on the `triage` tmux server, so they survive that server restarting:
   - `bind-key -n C-o detach-client`, so **Ctrl-O** comes back to the TUI;
   - `set-option -s extended-keys on` and `set-option -s terminal-features[90] xterm*:extkeys`, so Shift-Enter reaches Claude Code as its own key (a new line) and not a plain Enter. Use a fixed index, not `-a`, so repeating it never grows the list.
3. `curses.def_prog_mode()` and `curses.endwin()`, print "Attaching to L42. To return to the triage TUI, press Ctrl-O.", and run `tmux -L triage attach -t L42` in the same terminal, with `TMUX` removed from the environment so it nests if you're already in another tmux.
4. If the TUI itself runs inside the `triage` tmux server, use `switch-client -t L42` instead, and the way back is tmux's own `Ctrl-B d`.
5. When tmux returns: `curses.reset_prog_mode()`, turn bracketed paste back on, clear and redraw. The model was never touched, so the screen, selection and search are exactly as they were.

All tmux calls use argument lists, never a shell string.

### F2 Notices

A list, newest first: kind, project, `#item` or `PR id`, who, age, title. Under it, the selected notice's excerpt, wrapped. At the bottom, "Checked 4m ago", or the last check's error in the error colour. Usually that's an expired tracker login, and seeing it here is how I find out.

| Key | Does |
|---|---|
| `Enter` | New-session form with the notice's project and `prompt` filled in, and `notice` set, so the launch dismisses it. |
| `d` | Dismiss. |
| `o` | Open its URL in the Windows browser: `wslview <url>` if installed, else `cmd.exe /c start "" <url>` with `&` escaped as `^&`. |
| `n` | New session, blank. |

The server writes the prompt to say *read and report only*: a review session doesn't vote or comment, and a mention session doesn't reply. I decide that.

### F3 Triage

Read-only, one project at a time. The top row lists the projects, with the current one in `[brackets]`. `← →` switch, wrapping. Then "Sprint 14 · PO Priya · QA Marco". Then the rows:

- For each tier, a heading (NOW, NEXT…), then its cards: `▸ Gift cards` in bold, a dim `next: …` line, and its items.
- Then NOT ON A CARD, UP FOR GRABS, WITH OTHERS (items), and WAITING ON OTHERS (who, and what we're waiting for).
- An item row is `#4212   In Progress    Sam Smith     Gift card balance check`. The state is in its colour, and the assignee is dim unless it's me.

Only card and item rows can be selected. `↑ ↓` skip the headings. `Enter` on a card opens the form with that card, and on an item with that item. `o` opens the item's page on the server. Cache each project's data for 30 s, since it only changes on a sync. After a failed call, wait 10 s before trying again, so a down server doesn't stall every keypress.

### F4 Coordination

Three read-only sections, refreshed every 5 s: CLAIMS (resource, holder, purpose, queue), SESSIONS (agent, state, last seen, status text from `who`), and MESSAGES (time, `sender → to: body`, HTML stripped, as many as fit).

### F5 PRs

Opening the screen starts a background read of `my_prs`, because it asks the tracker once per project and can take seconds. It re-reads after 2 minutes while the screen stays open. Until the first answer: "Reading your pull requests…". Each PR takes two or three lines:

```text
!1043   storefront        2d  auto ✓1 …1 2 to answer →main  Show gift card balance on the account page
         https://git.example.com/bookshop/storefront/pull/1043
         ↳ Priya: Can we hide the balance when it's zero?  (+1 more)
```

Line 1: id, repo, age, `draft` (yellow), `auto` (green, auto-complete is set), votes as `✓n` approved, `…n` waiting for author, `✗n` rejected, then the comments state (`N to answer` red, `all answered` green, or `comments not read` dim), then the target branch and title. Line 2: the URL. Line 3, only when something waits on me: the newest such comment and how many more. At the bottom: projects that couldn't be read, and "read 40s ago · r refreshes".

| Key | Does |
|---|---|
| `Enter` | New-session form with a prompt to edit first: *Resolve the open review comments on PR &lt;url&gt; (&lt;title&gt;), branch &lt;source&gt;. Read its threads with the get_pr tool, work on that branch, and make the fixes the reviewers ask for. Show me the changes and your draft reply to each thread before you push or post anything.* The launch carries `pr_id` and `branch`, and the server clears my notices on that PR. |
| `o` | Open the PR. |
| `C` | Copy the URLs of all my PRs in the same repo, one per line, to hand to a reviewer. On Windows, pipe to `clip.exe` as UTF-16-LE with CRLF line ends. |
| `P` | Open that repo's active-PR list. |

### The new-session form

A full-screen form, in steps. `Esc` goes back a step, or closes the form at the first step. On success, the TUI returns to Sessions and says "Started L42, making worktree …", or shows the server's warning for 12 s.

1. **Project**, from `list_projects`. Skipped when the caller filled it in.
2. **What**: "Prompt…", "Work item number…", one "Card: <name>" per card, one "Command: /<name>  <help>" per command. The form's title shows where it will start: the project's main checkout. The server puts every session in its own git worktree there, so I no longer pick a checkout.
3. **Text**, for a prompt, an item number (digits, optional `#`) or a command's arguments. `Enter` starts it, and `Alt-Enter` or `Ctrl-J` adds a line. A paste goes in as text.
4. **Confirm**, when the caller filled in a card or an item: one line, "Start on #4212", and `Enter`.

A notice or a PR opens straight at step 3 with the prompt filled in, so I can edit it before it runs. After a launch, flush the keyboard buffer, so type-ahead doesn't land on the Sessions screen.

### Input: the parts that bite

- **Raw mode** (`curses.raw()`, `nonl()`, `keypad(True)`), so `Ctrl-C`, `Ctrl-H`, `Ctrl-L`, `Ctrl-O` and `Ctrl-S` arrive as keys and not as signals or flow control. Under `nonl()`, Enter is `\r` and `Ctrl-J` is `\n`.
- **Set `ESCDELAY=25`** before curses starts, or every `Esc` waits a full second.
- **Read escape sequences yourself.** After an `ESC`, read up to five more characters without blocking. Nothing → `Esc`. `\r` or `\n` → `Alt-Enter`. `[200~` → a bracketed paste. Anything else is dropped, so a stray Alt-chord never reaches a prompt.
- **Bracketed paste is on** (`\e[?2004h`) while the TUI runs, and back on after every attach. A paste is everything up to `\e[201~`. It goes into the form's text box or the search box (newlines become spaces there). Anywhere else it's *ignored*, with "Ignored a paste: attach to the session (Enter) and paste there". Without this, the newlines in a paste act as Enter presses on whatever is selected.
- **Flush type-ahead when a y/n question opens** (`curses.flushinp()`), so keys typed before it appeared can't answer it.
- **One bad answer must not take the client down.** Every action and every draw is wrapped: a failure becomes a status-line message.

### Refresh

- **A poll thread** calls `GET /sessions/state` every 2 s and hands the result to the UI thread under a lock. A `wake` event lets an action ask for an immediate poll, for example after ending a session.
- **The UI loop** wakes on a key or every 250 ms, applies the latest poll, refreshes what the current screen needs, and redraws everything (`erase`, draw, `refresh`). Curses only sends what changed.
- **Cadences:** session detail 2 s (only while a view is open), Coordination 5 s, Triage 30 s cache, PRs 2 minutes in the background, retry after a failure 10 s.
- **Server down:** the poll stores the error, the top bar says `server unreachable`, and polling carries on. The help screen shows the command that starts the server.
- **A refused action** (a 409 or a 400) shows the server's `error` text on the status line for 5 s.

### How the code is split

The part worth copying is the split, because it makes a curses app testable:

- **`tui_core.py`, no curses:** the HTTP client (with an injectable `urlopen`), the tmux helper (with an injectable `run`), the `Model`, the key router, the grouping, search and label functions, the top-bar layout, and the PR rows.
- **The key router is a pure function:** `route_key(model, key, now) → [actions]`. It changes the model and returns what the shell must do, as tuples: `("attach", "L42")`, `("timer", "start", agent)`, `("new_session", prefill)`, `("open_url", url)`, `("copy", text)`, `("dismiss", key)`, `("end", agent)`, `("refresh",)`, `("quit",)`. Tests drive it with key names and check the model and the actions, with no terminal anywhere.
- **`tui.py`, the shell:** reads keys and turns them into names (`"Enter"`, `"C-o"`, `"F3"`, `"j"`), runs the actions, owns the poll thread and the form, and draws the model. The Triage screen and the form have their own small key handlers here, because they need data the router doesn't hold.
- **Layout functions return segments** (`[(text, style)]`), and the shell maps styles to curses attributes. That's how the top bar can be tested at several widths as plain strings.

**Tests I'd write first:** the key router (every key on every screen, confirmations, search typing versus search kept, F-keys inside the form); the selection following a session across a reorder; grouping and ordering; the search matching all words, and the older ended sessions coming after the live ones; the top bar at 80, 100 and 160 columns with and without each alert; attach target and argv (inside and outside tmux, `TMUX` dropped); pastes ignored outside a text box; the PR rows and prompt; and a fake client that records calls and can raise errors.

### Build it in this order

Each step is usable by itself. These are close to my real prompts.

1. **The client and the Sessions screen.** *"I would like a TUI client for [my server]. Everything should be full screen. The alerts and keyboard shortcuts should be shown at the top … Full client, I want to answer sessions from the terminal."* Ask for the design first, and for the core/shell split above.
2. **Attach, and the way back.** Enter attaches to the real tmux session, and `Ctrl-O` returns. Skip the mirror. I built it and deleted it the same day.
3. **Notices and Triage.** Both start sessions through the same form.
4. **Your keys.** Colours per state, vim keys, `Ctrl-H`/`Ctrl-L`, the timer mark. Get the vim keys right the first time: **h j k l** is ← ↓ ↑ →.
5. **Brief and replies.** `i` and `m`, so you can decide without attaching.
6. **PRs.** *"I would like a page … where I can see all the active PRs that I have out, including their URLs."* Then the comments waiting on you, then Enter to start a session that resolves them.
7. **Search.** *"…go into search mode with the character "/" (similar to vim) and it brings up active items first and then old items."*

### A prompt to start with

If you have a server like the one in [my last post](/my-own-work-console/), paste this into Claude Code in its repo:

```text
Add a full-screen terminal client for this server: `python3 <cli> tui`,
standard library only (curses, urllib, threading, subprocess).

- It holds no state of its own: every read and write goes through the
  server's existing HTTP endpoints and MCP tools, like the browser page.
- Two fixed lines on top: screen keys (F1 Sessions, F2 Notices, F3 Triage,
  F4 Coordination, F5 PRs) and the alerts (sessions that need me, notices,
  the timer) on line 1, the current screen's keys on line 2.
- Sessions grouped Needs you / Stopped / Working / Ended, in the server's
  order; the selection follows the session when the list reorders.
- Enter attaches to the session's tmux session in the same terminal, and
  Ctrl-O (bound in tmux before attaching) comes back to where I was.
- Put the model, the key router and the layout in a module with no curses,
  and make the router a pure function: (model, key, now) -> actions.
  Write the tests first.

Write a short design first and ask me what you need to.
```

Then use it for a day, and tell it what bugs you. That's where mine came from.
