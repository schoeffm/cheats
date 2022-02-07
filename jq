# Check the lenght of an array
jq '.checks | lenght'

# process each array item individually
jq '.checks[] | .name'

# use -r for raw-output (without quotes) 
jq -r '.checks[1] | .name'

# use select to filter entries by value (use test for regex)
jq '.checks[] | select(.state == "UP") | select (.name|test(".*post.*"))'
jq '.checks[] | select(.data."api-versions"=="2")'

# Slicing works by indexing the start/end-point 2:3 (first 
# inclusive, second exclusive)
jq '.[2:3]'
jq '.[:3]'
jq '.[-2:]'

# use map to keep array structure of input
jq 'map(select(.owner=="q442185" and .resource_id=="4711"))'

# escape " to use variable interpolation
jq "map(select(.owner==\"${sa_id}\" and .resource_id==\"${cluster_id}\"))")
# ... or, the jq-native way (introducing size-variable with value of $vm)
jq --arg size "$vm" '.[] | select(.name==$size) | .memoryInMb'

# Change output structure by introducing new objects/arrays:
jq '[.checks[] | { service: .name, status: .state }]'

# use properties as keys in the new structure:
jq '.checks[1] | { (.name): .state }'

# join is useful for preparing scripting-input (also -c is handy here)
jq '[.checks[] | .name ] | join(" ")'
jq '[.checks[] | .name ] | join(" ")' -c

# Use add in case you’d like to sum things up - to convert types use 
# tonumber or tostring etc.:
jq '[.checks[] | .data?."api-versions" | select(. != null) | tonumber ] | add'

# split in combination with first and last are handy when extracting 
# things from property-values itself:
jq '.checks[].data.buildtime | select(. != null) | split("T") | last'

# working with variables in bash scripts (caching intermediary results)
# don't use 'echo $variable' since it could contain control-chars that result in errors
printf '%s' "$variable" | jq '.name'

# '?' does not output even an error when . is not an array or an object.
# => so if foo.array doesn't exist this doesn't quit with an error 
jq '.foo.array[]? | { (.name): .state  }'
