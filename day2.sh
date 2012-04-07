# Generate hotel data
ruby hotel.rb

### Mapreduce ###

curl -X POST -H "content-type:application/json" \
  http://localhost:8098/mapred --data "{\"inputs\": [[\"rooms\",\"101\"],[\"rooms\",\"102\"], [\"rooms\",\"103\"] ], \"query\": [{\"map\": {\"language\": \"javascript\", \"source\": \"function(v) {/* From the Riak object, pull data and parse it as JSON */ var parsed_data = JSON.parse(v.values[0].data); var data = {}; /* Key capacity number by room style string */ data[parsed_data.style] = parsed_data.capacity; return [data]; }\"} } ] }"

# Stored functions
curl -X PUT -H "content-type:application/json" \
  http://localhost:8098/riak/my_functions/map_capacity --data "function(v) { var parsed_data = JSON.parse(v.values[0].data); var data = {}; data[parsed_data.style] = parsed_data.capacity; return [data]; }"

curl -X POST -H "content-type:application/json" \
  http://localhost:8098/mapred --data "{ \"inputs\":[ [\"rooms\",\"102\"],[\"rooms\",\"102\"],[\"rooms\",\"103\"] ], \"query\":[ {\"map\":{ \"language\":\"javascript\", \"bucket\":\"my_functions\", \"key\":\"map_capacity\" }} ] }"

# Built-in Functions
curl -X POST http://localhost:8098/mapred \
  -H "content-type:application/json" --data "{ \"inputs\":[ [\"rooms\",\"102\"],[\"rooms\",\"102\"],[\"rooms\",\"103\"] ], \"query\":[ {\"map\":{ \"language\":\"javascript\", \"name\":\"Riak.mapValuesJson\" }} ] }"

# Reducing
curl -X POST -H "content-type:application/json" \
  http://localhost:8098/mapred --data "{ \"inputs\":\"rooms\", \"query\":[ {\"map\":{ \"language\":\"javascript\", \"bucket\":\"my_functions\", \"key\":\"map_capacity\" }}, {\"reduce\":{ \"language\":\"javascript\", \"source\": \"function(v) { var totals = {}; for (var i in v) { for(var style in v[i]) { if( totals[style] ) totals[style] += v[i][style]; else totals[style] = v[i][style]; } } return [totals]; }\" }} ] }"

## Reducer Patterns ##

# Key Filters
curl -X POST -H "content-type:application/json" \
  http://localhost:8098/mapred --data "{ \"inputs\":{ \"bucket\":\"rooms\", \"key_filters\":[[\"string_to_int\"], [\"less_than\", 1000]] }, \"query\":[ {\"map\":{ \"language\":\"javascript\", \"bucket\":\"my_functions\", \"key\":\"map_capacity\" }}, {\"reduce\":{ \"language\":\"javascript\", \"source\": \"function(v) { var totals = {}; for (var i in v) { for(var style in v[i]) { if( totals[style] ) totals[style] += v[i][style]; else totals[style] = v[i][style]; } } return [totals]; }\" }} ] }"

# Link Walking with Mapreduce
curl -X POST -H "content-type:application/json" \
  http://localhost:8098/mapred --data "{ \"inputs\":{ \"bucket\":\"cages\", \"key_filters\":[[\"eq\", \"2\"]] }, \"query\":[{\"link\":{ \"bucket\":\"animals\", \"keep\":false }}, {\"map\":{ \"language\":\"javascript\", \"source\": \"function(v) { return [v]; }\" }} ] }"

### Of Consistency and Durability ###

# The n_val bucket property stores the number of nodes to replicate a value to (the N value); it’s 3 by default.
curl -X PUT http://localhost:8098/riak/animals \
  -H "Content-Type: application/json" \
  -d '{"props":{"n_val":4}}'

# We can set the W value to the number of successful writes which must occur before our operation is considered a success.
curl -X PUT http://localhost:8098/riak/animals \
  -H "Content-Type: application/json" \
  -d '{"props":{"w":2}}'

# The R value is the number of nodes which must be read in order to be considered a successful read.
curl -X PUT http://localhost:8098/riak/animals \
  -H "Content-Type: application/json" \
  -d '{"props":{"r":3}}'

# We may choose the number of nodes we wish to read by setting an r parameter in the URL per request.
curl http://localhost:8098/riak/animals/ace?r=3

# Durable writes: slower, but reduces risk
curl -X PUT http://localhost:8098/riak/animals \
  -H "Content-Type: application/json" \
  -d '{"props":{"dw":"one"}}'

### Exercises ###

# Write map and reduce functions against the rooms bucket to find the total guest capacity per floor

# Extend the above function with a filter to only find the capacities for rooms on floors 42 and 43
