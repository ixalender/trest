set -e
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)"
cd $script_path
source ./../trest.sh

# Request params tests
test_headers=("Header1:value1" "Content-type: application/json; charset=UTF-8")
test_url=$(host_url "http://localhost:8080" \
    | add_param "param1=1" \
    | add_param "param2=2" \
    )
assert_equal "$test_url" "http://localhost:8080?param1=1&param2=2&" "Url build"
assert_equal "$(build_headers "${test_headers[@]}")" "-H 'Header1:value1' -H 'Content-type: application/json; charset=UTF-8'" "Headers build"

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
assert_equal $(get_json_data ".note.tasks[0].text" "$json_res") "Eat" "JSON parse first element of object list"

# Assertion tests
tasks_lenght=$(get_json_data ".note.tasks | length" "$json_res")

assert $tasks_lenght | gt 0 | describe "Test pipe assert | gt | describe"
assert $tasks_lenght \
    | ge 2 \
    | describe "Test pipe assert | ge | describe"
assert $tasks_lenght \
    | ge 1 \
    | describe "Test pipe assert | ge | describe"
assert $tasks_lenght \
    | eq 2 \
    | describe "Test pipe assert | eq | describe"
assert $tasks_lenght \
    | ne 3 \
    | describe "Test pipe assert | ne | describe"
assert $tasks_lenght \
    | lt 3 \
    | describe "Test pipe assert | lt | describe"
assert $tasks_lenght \
    | le 3 \
    | describe "Test pipe assert | le | describe"
assert $tasks_lenght \
    | le 2 \
    | describe "Test pipe assert | le | describe"

assert_gt $tasks_lenght 0 "Test assert_gt"
assert_ge $tasks_lenght 2 "Test assert_ge"
assert_ge $tasks_lenght 1 "Test assert_ge"
assert_lt $tasks_lenght 3 "Test assert_lt"
assert_le $tasks_lenght 3 "Test assert_le"
assert_le $tasks_lenght 2 "Test assert_le"

# [ "$(build_headers ${test_headers[@]})" == "-H Header1:value1 -H Header2:value2" ] &&
# echo "Tests OK!" && exit 0 || echo "Error on execute tests!" && exit 1
