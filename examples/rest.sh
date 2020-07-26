source ./trest.sh

generate_post_data()
{
  cat <<EOF
{
  "account": {
    "email": "$email",
    "screenName": "$screenName",
    "type": "$theType",
    "passwordSettings": {
      "password": "$password",
      "passwordConfirm": "$password"
    }
  }
}
EOF
}

list=$(request "GET" "https://jsonplaceholder.typicode.com/posts")
assert_gt $(get_json_data ". | length" "$list") "0" "List count test"
assert $(get_json_data ". | length" "$list") | gt "0" | describe "List count test"

headers=("Content-type :application/json; charset=UTF-8")
resource=$(request \
    "GET" \
    "https://jsonplaceholder.typicode.com/posts/1" \
    $(build_headers "${headers[@]}")
    )
assert_equal $(get_json_data ".userId" "$resource") "1" "User Id assert"
assert_equal $(get_json_data ".id" "$resource") "1" "Respurce Id assert"
assert $(get_json_data ".id" "$resource") \
    | eq "1" \
    | describe "Respurce Id assert"