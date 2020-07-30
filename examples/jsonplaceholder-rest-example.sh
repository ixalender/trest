source ./trest.sh

list=$(request "GET" "https://jsonplaceholder.typicode.com/posts")
assert_gt $(get_json_data ". | length" "$list") "0" "List count eq 0 test"
assert $(get_json_data ". | length" "$list") | gt "0" | describe "List count gt 0 test"
assert $(get_json_data ". | length" "$list") | lt "0" | describe "List count lt 0 test"

resource=$(request \
    "GET" \
    "https://jsonplaceholder.typicode.com/posts/1"
    )
assert_equal $(get_json_data ".userId" "$resource") "1" "User Id assert"
assert_equal $(get_json_data ".id" "$resource") "1" "Respurce Id assert"
assert $(get_json_data ".id" "$resource") \
    | eq "1" \
    | describe "Respurce Id assert"

patch_data()
{
  cat <<EOF
{
    "title": "Paul Rudd's Life"
}
EOF
}

glob_request_headers=("Content-type: application/json; charset=UTF-8")
build_headers
resource=$(request \
    "PATCH" \
    "https://jsonplaceholder.typicode.com/posts/1" \
    "$(patch_data)"
    )
clear_headers
assert_equal "$(get_json_data ".title" "$resource")" "Paul Rudd's Life" "Test the patched post title"