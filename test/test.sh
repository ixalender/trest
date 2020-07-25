set -e
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)"
cd $script_path
source ./../trest.sh

# Request params tests
test_headers=("Header1:value1" "Header2:value2")
test_url=$(host_url "http://localhost:8080" \
    | add_param "param1=1" \
    | add_param "param2=2" \
    )
assert_equal "$test_url" "http://localhost:8080?param1=1&param2=2&" "Url build"
assert_equal "$(build_headers ${test_headers[@]})" "-H Header1:value1 -H Header2:value2" "Headers build"

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

[ "$(build_headers ${test_headers[@]})" == "-H Header1:value1 -H Header2:value2" ] &&
echo "Tests OK!" && exit 0 || echo "Error on execute tests!" && exit 1
