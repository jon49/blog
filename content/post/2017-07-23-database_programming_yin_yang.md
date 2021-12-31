---
url: /database-programming-yin-yang/
date: 2017-07-23
title: Database Programming Yin Yang
tags:
  - SQL Server
  - SQL
  - SQL Server Data Tools
---

There are two different ways people like to write their SQL scripts when calling
the database. One way is to write the SQL statements in their application code.
Sometimes they will write an
[ORM](https://en.wikipedia.org/wiki/Object-relational_mapping) to make this
process similar to their language constructs. Sometimes they will write the SQL
code directly in procedures.

### Pros and Cons of Developing in the Application

- **Pros**
    - Low friction between application and database.
        - Any refactoring in your application is simple since all your code is
          accessed in the same location.
    - Need to know only single language (back end language)

- **Cons**
    - ORMs can create inefficient code
        - E.g., code can compile but you don't know if it will be lazy since you
          don't know if Entity Framework translated the query as expected.
    - Obfuscates SQL Code
    - Can make refactoring database difficult
        - Don't know what SQL statements are being used since they are created
          in the application.

### Pros and Cons of Developing in the Database

- **Pros**
    - Refactoring database is much easier
        - Especially useful when you have multiple applications using the same
          database.
    - [Hot swapping your code.](https://en.wikipedia.org/wiki/Hot_swapping)
    - SQL Server allows you to get insights into what routines are related to
      one another and to tables.
    - It's trivial to determine what routine may be using too many resources and
      needs to be tuned for performance.

- **Cons**
    - If you change the parameters or return structure of your stored procedures
      in you database then you will need to update both the database stored
      procedure and the application.

- **Mitigations**
    - Generate JSON from your database to reduce friction between the
      application and the database. This is possible when you are returning
      simple data that you don't need to manipulat too much.
    - Possibly validate JSON directly received from user.
        - My experience hasn't been very good with this.
    - Use tooling for your database to make it easier to use; I would use this
      tooling regardless where you are creating your queries.
        - [SQL Server Data
          Tools](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt)
            - This also helps with seeing what scripts are related to each other
              and being able to go to the definition of a procedure.

### Conclusion

Depending on the size of your organization it might be difficult to actually get
code in your database. Which seems odd to me, they will let you write SQL in
your application but not let you easily add a procedure to your database? Maybe
because they aren't using `tSQLt` to test their stored procedures? Not sure. I
think many times when it is difficult to get code on your database it might be
equally difficult to release the application, so both would have friction.

So, do you keep your code in the application or the database? It probably
depends. You will get some coupling between the application and the stored
procedures though; returning JSON can definitely help alleviate some of that
coupling though. If your application only sends back JSON to the user then I
think this method might work for you; if you only have simple queries it might
not be worthwhile but I've always had to write more intricate queries, so I
haven't had that luxury. In T-SQL you can also send back errors over 50,000 and
use those as `HTTP Status Codes`. I've found name spacing the SQL code by
application with schemas makes it easier to know which application the stored
procedures rely on.

If you use an ORM you don't need to learn yet another language. I would think
that SQL code is so important to development that it should probably be the
first language that is learned rather than the second.

If you were to really go crazy you could start defining your endpoints in your
database too and just do everything in the database. Almost like
[PostgRest](https://postgrest.com/en/v0.4/) and many others do. Of course, if
you go to this extreme you would need your database to be able to scale
horizontally assuming it would need to eventually scale in the first place. Many
databases don't really need to scale since they might be an internal app for the
company. Most applications don't become huge, at least the ones I've worked on.

I'm sure there might be other pros and cons. Let me know what other ones you
think of!

### Addendum

**Problems with DAO**

- When using the DAO pattern it can be difficult to query the data in different
  ways, you end up creating multiple methods like `listBy*`.
    - You can get around this problem by using a lambda expression for the where
      clause. But then it becomes difficult to test the method since all the
      logic is spread around your entire application. You also don't know if the
      where clause that is sent in actually works - not sure why that would be
      the case.
    - Another solution is by using the [Specification
      Pattern](https://en.wikipedia.org/wiki/Specification_pattern)

### Update

2017-10-15 - Added some more pros to developing database first.  
2017-11-20 - From [Steve Smith's interview on .NET Rocks!](https://dotnetrocks.com/?show=1494)
             Starts around 50 minutes 11 second mark.

