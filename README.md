# sdsw-riak-bash

These are my notes, scratches, and exercises while going through the Riak section of [Seven Databases in Seven Weeks](http://pragprog.com/book/rwdata/seven-databases-in-seven-weeks).

It just uses a bash shell for all the `curl` calls made.

## Setup

The book builds Riak from source, whereas I decided to try it with homebrew. The examples in the book use port 8091, but the homebrew installation uses 8098. Also, the book assumes three nodes of Riak, but I just used the default setup with homebrew.

Install riak:

```bash
brew install riak
```

To start the riak server:

```bash
riak start
```

Location of the Riak app.config:

```bash
"`brew --prefix riak`/libexec/etc/app.config"
```

Make sure these settings are as follows in the app.config:

```erlang
[
  {js_source_dir, "/Users/yourname/path/to/repo"},
  {riak_search, [
                 {enabled, true}
                ]},
  {riak_kv, [
    {storage_backend, riak_kv_eleveldb_backend}
  ]}
]
```

Then restart the riak server:

```bash
riak restart
```

For the Ruby script, you'll need to run

```bash
gem install riak-client json
```

## Resources

Learn more Riak:

[Riak Documentation](http://wiki.basho.com/)
[API Documentation](http://wiki.basho.com/HTTP-API.html)
[Riak Handbook](http://riakhandbook.com/)

## License

The code taken frome the book comes with the following copyright/disclaimer:

> Copyrights apply to this source code. You may use the source code in your own projects, however the source code may not be used to create training material, courses, books, articles, and the like. We make no guarantees that this source code is fit for any purpose.

Anything else in this repository is licensed by me under the MIT license. See `LICENSE` for more information.
