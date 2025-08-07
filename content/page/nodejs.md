---
title: Node JS
type: Page
---

## Determine All Dependencies

To determine all dependencies in a Node.js project do this:

```bash
npm list --all > dependencies.txt
```

You can change the depth to see more or less of the dependencies. For example:

```bash
npm list --depth=<Number>
```

## Determine Vulnerabilities

To determine vulnerabilities in a Node.js project with package names do this:

```bash
npm audit
```
