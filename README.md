<p align="center"><img src="https://ixalender.com/img/trest.png" style="width: 681px;"></p>

# Trest

Tiny API test library.


## Requirements

Install **[jq](https://stedolan.github.io/jq/download/)** if you need to test and parse JSON responses.

## Using Trest
1. Copy trest.sh somewhere in a structure of your project of integration tests.

2. Create some test shell script and write a simple test
```sh
source ./trest.sh

list=$(request "GET" "https://jsonplaceholder.typicode.com/posts")

assert_gt $(get_json_data ". | length" "$list") "0" "List count eq 0 test"

assert $(get_json_data ". | length" "$list") \
    | gt "0" \
    | describe "List count gt 0 test"

assert $(get_json_data ". | length" "$list") | lt "0" | describe "List count lt 0 test"
```
3. Run your test shell script
```
sh ./sometests.sh
```
It'll show results
```
List count eq 0 test                               SUCCEED 
List count gt 0 test                               SUCCEED 
List count lt 0 test                               FAILED  ./sometests.sh:6
```

Slightly more examples in `./examples` directory of source code.

## Development

Run tests
```
$ make test
```
