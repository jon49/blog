### Installing Postgres

You are supposed to be able to install postgres with sudo

```
sudo apt-get install postgresql-9.4
```

but it didn't work for me. So, I just ended up using the Ubuntu GUI installer. Since I'm using Xubuntu postgresql must not have been automatically installed. After install you can get it running by typing

```
sudo su - postgres
```

Which I assume stands for "switch user" to postgres and starts postgres. When you want to quit just type `exit`.

### Setting Up Example Database

I'm using the excellent tutorial [PostGrest Introduction](http://blog.jonharrington.org/postgrest-introduction/). So, much of this is just the same, with maybe some hassles that I ran into.

Apparently he uses `sqitch` which abstracts database management. I'll just use the postgres GUI which is called `pgadmin3`.


### Installing PostgREST

To download and install postgREST just type:

```
wget "https://github.com/begriffs/postgrest/releases/download/v0.3.0.3/postgrest-0.3.0.3-ubuntu.tar.xz"
```

I'm supposed to be able to extract it with the following command:

```
tar zxf postgrest-0.3.0.3-ubuntu.tar.xz
```

Which, again, didn't work for me - it complained something about not a `gzip`. But right clicking on the file and `extract here` worked fine.




