### BASICS ###

# Add a value to Riak
curl -v -X PUT http://localhost:8098/riak/favs/db \
  -H "Content-Type: text/html" \
  -d "<html><body><h1>My new favorite DB is RIAK</h1></body></html>"

# Retrieve the value
curl http://localhost:8098/riak/favs/db

# Put a value in a bucket
curl -v -X PUT http://localhost:8098/riak/animals/ace \
  "Content-Type: application/json" \
  -d '{"nickname" : "The Wonder Dog", "breed" : "German Shepherd"}'

# View the list of buckets
curl -X GET http://localhost:8098/riak?buckets=true

# Return the body
curl -v -X PUT http://localhost:8098/riak/animals/polly?returnbody=true \
  -H "Content-Type: application/json" \
  -d '{"nickname" : "Sweet Polly Purebred", "breed" : "Purebred"}'

# Generate a key when passing it as a POST
curl -i -X POST http://localhost:8098/riak/animals \
  -H "Content-Type: application/json" \
  -d '{"nickname" : "Sergeant Stubby", "breed" : "Terrier"}'

# Retrieve the value
curl http://localhost:8098/riak/animals/6VZc2o7zKxq2B34kJrm1S0ma3PO

# Remove the value
curl -i -X DELETE http://localhost:8098/riak/animals/6VZc2o7zKxq2B34kJrm1S0ma3PO

# Get list of keys
curl http://localhost:8098/riak/animals?keys=true

### LINKS ###

# Link Polly to Cage 1
# One way, Cage 1 knows about Polly, but not the other way
curl -X PUT http://localhost:8098/riak/cages/1 \
  -H "Content-Type: application/json" \
  -H "Link: </riak/animals/polly>; riaktag=\"contains\"" \
  -d '{"room" : 101}'

curl -i http://localhost:8098/riak/animals/polly

curl -X PUT http://localhost:8098/riak/cages/2 \
  -H "Content-Type: application/json" \
  -H "Link:</riak/animals/ace>;riaktag=\"contains\", </riak/cages/1>;riaktag=\"next_to\"" \
  -d '{"room" : 101}'

# Retrieve all links from Cage 1
curl http://localhost:8098/riak/cages/1/_,_,_

# Specify only following the Animals bucket
curl http://localhost:8098/riak/cages/2/animals,_,_

# Follow the cages next to this one
curl http://localhost:8098/riak/cages/2/_,next_to,_

# Only return Polly’s information, who is next to Ace’s cage
curl http://localhost:8098/riak/cages/2/_,next_to,0/animals,_,_

# Want Polly's information and cage 1
curl http://localhost:8098/riak/cages/2/_,next_to,1/_,_,_

# Arbitrary metadata
curl -X PUT http://localhost:8098/riak/cages/1 \
  -H "Content-Type: application/json" \
  -H "X-Riak-Meta-Color: Pink" \
  -H "Link: </riak/animals/polly>; riaktag=\"contains\"" \
  -d '{"room" : 101}'

### MIME Types ###

curl -X PUT http://localhost:8098/riak/photos/polly.jpg \
  -H "Content-type: image/jpeg" \
  -H "Link: </riak/animals/polly>; riaktag=\"photo\"" \
  --data-binary @polly.jpg

curl http://localhost:8098/riak/photos/polly.jpg

### Exercises

# Using PUT, update animals/polly to have a Link pointing to photos/polly.jpg

# POST a file of a MIME type we haven’t tried (such as application/pdf), find the generated key, and hit that URL from a web browser

# Create a new bucket type called medicines, PUT a JPEG image value (with proper MIME type) keyed as antibiotics and link to the animal Ace (poor sick puppy)
