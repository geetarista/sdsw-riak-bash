### Resolving Conflicts ###

# Vector Clocks

# A vector clock is a token that distributed systems like Riak use to keep the order of conflicting key-value updates intact.
# You may think “just timestamp the values and let the last value win,” but in a server cluster this only works if all server clocks are perfectly synchronous.

# See all conflicting versions so we can resolve them manually.
# Bob puts Bruiser in the system with his chosen score of 3, and client ID of bob.
curl -X PUT http://localhost:8098/riak/animals \
  -H "Content-Type: application/json" \
  -d '{"props":{"allow_mult":true}}'

# Jane and Rakshith both pull Bruiser’s data that Bob created (you’ll have much more header information, we’re just showing the vector clock here). Note that Riak encoded Bob’s vclock, but under the covers it’s a client and a version (and timestamp, so yours will be different from the one shown).
curl -i -X PUT http://localhost:8098/riak/animals/bruiser \
  -H "X-Riak-ClientId: bob" \
  -H "Content-Type: application/json" \
  -d '{"score" : 3}'

# Jane makes her update to score 2, and includes the most recent vector clock she received from Bob’s version. This is a signal to Riak that her value is an update of Bob’s version.
curl -i http://localhost:8098/riak/animals/bruiser?return_body=true X-Riak-Vclock: a85hYGBgzGDKBVIs7NtEXmUwJTLmsTI8FMs5zpcFAA== {"score" : 3}

# Since Jane and Rakshith pulled Bob’s data at the same time, he also submits an update (of score 4) using Bob’s vector clock.
curl -i -X PUT http://localhost:8098/riak/animals/bruiser \ -H "X-Riak-ClientId: jane" \ -H "X-Riak-Vclock: a85hYGBgzGDKBVIs7NtEXmUwJTLmsTI8FMs5zpcFAA==" \ -H "Content-Type: application/json" \ -d '{"score" : 2}'

# When Jane rechecks the score she sees not a value, as expected, but rather an HTTP code for Multiple Choices, and a body containing two “sibling” values.
curl http://localhost:8098/riak/animals/bruiser?return_body=true Siblings: 637aZSiky628lx1YrstzH5 7F85FBAIW8eiD9ubsBAeVk

# Riak stored these versions in a multipart format, so she can retrieve the entire object by accepting that MIME type.
curl -i http://localhost:8098/riak/animals/bruiser?return_body=true \ -H "Accept: multipart/mixed" HTTP/1.1 300 Multiple Choices X-Riak-Vclock: a85hYGBgyWDKBVHs20Re...OYn9XY4sskQUA Content-Type: multipart/mixed; boundary=1QwWn1ntX3gZmYQVBG6mAZRVXlu Content-Length: 409 --1QwWn1ntX3gZmYQVBG6mAZRVXlu Content-Type: application/json Etag: 637aZSiky628lx1YrstzH5 {"score" : 4} --1QwWn1ntX3gZmYQVBG6mAZRVXlu Content-Type: application/json Etag: 7F85FBAIW8eiD9ubsBAeVk {"score" : 2} --1QwWn1ntX3gZmYQVBG6mAZRVXlu--
# Notice that the “siblings” shown above are HTTP Etags (which Riak called vtags) to specific values. An interesting sidenote is that you can use the vtag parameter in the URL to retrieve only that version: curl http://localhost:8098/riak/animals/bruiser?vtag=7F85FBAIW8eiD9ubsBAeVk will return {"score" : 2}.

# Jane’s job now it to use this information to make a reasonable update. She decides to average the two scores and update to 3, using the vector clock given to resolve the conflict.
curl -i -X PUT http://localhost:8098/riak/animals/bruiser?return_body=true \ -H "X-Riak-ClientId: jane" \ -H "X-Riak-Vclock: a85hYGBgyWDKBVHs20Re...OYn9XY4sskQUA" \ -H "Content-Type: application/json" \ -d '{"score" : 3}'
# Now when Bob and Rakshith retrieve bruiser’s information, they’ll get the resolved score.

curl -i http://localhost:8098/riak/animals/bruiser?return_body=true HTTP/1.1 200 OK X-Riak-Vclock: a85hYGBgyWDKBVHs20Re...CpQmAkonCcHFM4CAA== {"score" : 3}
# Any future requests will receive score 3.

# See vclock properties
curl http://localhost:8098/riak/animals

### Pre/Post Commit Hooks ###
# Set a bucket’s precommit property to use the JavaScript function name (not the file name).
curl -X PUT http://localhost:8098/riak/animals \
  -H "content-type:application/json" \
  -d '{"props":{"precommit":[{"name" : "good_scope"}]}}'

# Fails due to pre-commit hook
curl -i -X PUT http://localhost:8098/riak/animals/bruiser \
  -H "Content-Type: application/json"
  -d '{"score" : 5}'

### Extending Riak ###

## Search

# install riak_search_kv_hook, Erlang module’s precommit function, in a new animals bucket with the following command.
curl -X PUT http://localhost:8098/riak/animals \
  -H "Content-Type: application/json" \
  -d '{"props":{"precommit": [{"mod": "riak_search_kv_hook","fun":"precommit"}]}}'

# Show that the hook has been added
curl http://localhost:8098/riak/animals

# Upload a few animals
curl -X PUT http://localhost:8098/riak/animals/dragon \
  -H "Content-Type: application/json" \
  -d '{"nickname" : "Dragon", "breed" : "Briard", "score" : 1 }'
curl -X PUT http://localhost:8098/riak/animals/ace \
  -H "Content-Type: application/json" \
  -d '{"nickname" : "The Wonder Dog", "breed" : "German Shepherd", "score" : 3 }'
curl -X PUT http://localhost:8098/riak/animals/rtt
  -H "Content-Type: application/json" \
  -d '{"nickname" : "Rin Tin Tin", "breed" : "German Shepherd", "score" : 4 }'

# Select any breed that contains the word Shepherd as XML
curl http://localhost:8098/solr/animals/select?q=breed:Shepherd

# Or as JSON
curl http://localhost:8098/solr/animals/select?q=breed:Shepherd&wt=json

# Multiple query parameters
curl http://localhost:8098/solr/animals/select\
  ?wt=json&q=nickname:rin%20breed:shepherd&q.op=and

## Indexing

# Index by the university name that this dog is a mascot for (butler), as well as the version number (Blue 2 is the second bulldog mascot)
curl -X PUT http://localhost:8098/riak/animals/blue
  -H "x-riak-index-mascot_bin: butler"
  -H "x-riak-index-version_int: 2"
  -d '{"nickname" : "Blue II", "breed" : "English Bulldog"}'

### Exercises ###

# Create your own index that defines the animals schema. Specifically, set the score field to integer type, and query it as a range.
# Start up a small cluster of 3 servers (such as 3 laptops, or EC2 instances) and install Riak on each. Set up the servers as a cluster. Install the Google stock dataset, located on the Basho website.
