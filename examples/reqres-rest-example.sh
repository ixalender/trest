source ./trest.sh

pault_rudd_data()
{
  cat <<EOF
{
    "name": "Paul Rudd",
    "job": "actor",
    "movies": ["I Love You Man", "Role Models"]
}
EOF
}

glob_request_headers=("Content-Type: application/json")
build_headers
resource=$(request \
    "POST" \
    "https://reqres.in/api/users" \
    "$(pault_rudd_data)"
    )
clear_headers
assert_equal "$(get_json_data ".name" "$resource")" "Paul Rudd" "Test new actor's name"
assert_equal $(to_upper "$(get_json_data ".job" "$resource")") "ACTOR" "Test new actor's job"
assert_equal "$(get_json_data ".movies | length" "$resource")" "2" "Test new actor's movies count"
assert_equal "$(get_json_data ".movies[0]" "$resource")" "I Love You Man" "Test new actor's movies first movie"