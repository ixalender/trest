set -e
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)"
cd $script_path
source ./../trest.sh

# Request params tests
test_url=$(host_url "http://localhost:8080" \
    | add_param "param1=1" \
    | add_param "param2=2" \
    )
assert_equal "$test_url" "http://localhost:8080?param1=1&param2=2&" "Url build"

glob_request_headers=("Header1:value1" "Content-type: application/json; charset=UTF-8")
build_headers
assert_equal "${glob_curl_headers[0]}" "-H" "Headers build"
assert_equal "${glob_curl_headers[1]}" "Header1:value1" "Headers build"
assert_equal "${glob_curl_headers[2]}" "-H" "Headers build"
assert_equal "${glob_curl_headers[3]}" "Content-type: application/json; charset=UTF-8" "Headers build"

clear_headers
assert_equal "${glob_curl_headers[0]}" "" "Clear headers"

# XML response tests
fixture_url=$(host_url "file:///"$script_path"/fixtures/test.xml")
xml_res="$(request "GET" "$fixture_url")"
assert_equal $(get_xml_data "//note/to" "$xml_res") "Tove" "XML parse"
assert_equal $(get_xml_data "//note/tasks/task[1]" "$xml_res") "Eat" "XML parse first element of list"
assert_equal $(get_xml_data "//note/tasks/task[1]/@type" "$xml_res") "done" "XML parse attribute"

# JSON response tests
fixture_url=$(host_url "file:///"$script_path"/fixtures/test.json")
json_res="$(request "GET"  "$fixture_url")"
assert_equal $(get_json_data ".note.to" "$json_res") "Tove" "JSON parse"
assert_unequal $(get_json_data ".note.to" "$json_res") "John" "JSON parse"
assert_equal $(get_json_data ".note.tasks[0].text" "$json_res") "Eat" "JSON parse first element of object list"

# Assertion tests
tasks_length=$(get_json_data ".note.tasks | length" "$json_res")

assert_equal $tasks_length 2 "Test assert_equal int"
assert_unequal $tasks_length 3 "Test assert_unequal int"

assert $tasks_length | gt 0 | describe "Test pipe assert | gt | describe"
assert $tasks_length \
    | ge 2 \
    | describe "Test pipe assert | ge | describe"
assert $tasks_length \
    | ge 1 \
    | describe "Test pipe assert | ge | describe"
assert $tasks_length \
    | eq 2 \
    | describe "Test pipe assert | eq int | describe"
assert $(get_xml_data "//note/to" "$xml_res") \
    | eq "Tove" \
    | describe "Test pipe assert | eq string | describe"
assert $tasks_length \
    | ne 3 \
    | describe "Test pipe assert | ne int | describe"
assert $(get_xml_data "//note/to" "$xml_res") \
    | ne "John" \
    | describe "Test pipe assert | ne string | describe"
assert $tasks_length \
    | lt 3 \
    | describe "Test pipe assert | lt | describe"
assert $tasks_length \
    | le 3 \
    | describe "Test pipe assert | le | describe"
assert $tasks_length \
    | le 2 \
    | describe "Test pipe assert | le | describe"

assert_gt $tasks_length 0 "Test assert_gt"
assert_ge $tasks_length 2 "Test assert_ge"
assert_ge $tasks_length 1 "Test assert_ge"
assert_lt $tasks_length 3 "Test assert_lt"
assert_le $tasks_length 3 "Test assert_le"
assert_le $tasks_length 2 "Test assert_le"

assert_true `[ "$tasks_length" -eq 2 ] && [ "$tasks_length" -ne 3 ] && echo 1 || echo 0` "Test assert_true"
