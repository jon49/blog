---
title: Reasons to Not Do Most of Your Logic in SQL
draft: true
tags:
  - SQL
---

### Reasons

- Use all one language, like C# only with very little SQL
- Business logic in multiple places. When putting the logic in SQL and C# can
  become difficult to maintain.

### Cons

When putting all your logic in your code base like C# your queries become really
inefficient.

### Pros

When putting all your logic in your code base like SQL your queries become much
more efficient.

