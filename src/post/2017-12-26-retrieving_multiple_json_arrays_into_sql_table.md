---
title: Retrieving Multiple JSON Arrays into Single SQL Table
tags:
  - sql
  - sql-server
  - json
---

Now that SQL Server is working better with `JSON` it is becoming easier to just
put plain `JSON` into columns. It's nice to be able to query the `JSON` directly
in the database. The other day I was wanted to get a list of values in arrays.
Here's how I did it.

First let's set up the table:

```sql
DECLARE @JSON TABLE
( JsonID INT PRIMARY KEY IDENTITY(1, 1)
, JsonData nvarchar(max) NOT NULL
);
```

Some test data:

```sql
INSERT INTO @JSON (JsonData)
VALUES
    (N'{"json":[{"name": 1},{"name": 2}]}'),
    (N'{"json":[{"name": 3},{"name": 4}]}'),
    (N'{"json":[{"name": 4},{"name": 5}]}');
```

To get the arrays we need to use a `JSON_QUERY` function which let's us get at
inner `JSON`.

```sql
SELECT JSON_QUERY(t.JsonData, '$.json') arrays
FROM @JSON t
WHERE t.JsonData IS NOT NULL
```

Now to get the values in the arrays we need to use the `JSON_VALUE` function.
This is where it gets tricky. You can't just simply use the `JSON_VALUE`
function. You can't make the query above the `FROM` clause. You must use `CROSS
APPLY`

```sql
SELECT n.[Name]
FROM @JSON t
CROSS APPLY (
    SELECT JSON_VALUE(a.value, '$.name') [Name]
    FROM OPENJSON((
        SELECT JSON_QUERY(t.JsonData, '$.json') JsonArray ), '$') a
    ) n
```

Now, let's make sure that there are no `null` values and that we don't repeat
any of the values.

```sql
SELECT n.[Name]
FROM @JSON t
CROSS APPLY (
    SELECT JSON_VALUE(a.value, '$.name') [Name]
    FROM OPENJSON((
        SELECT JSON_QUERY(t.JsonData, '$.json') JsonArray ), '$') a
    ) n
WHERE t.JsonData IS NOT NULL
GROUP BY n.[Name]
```

