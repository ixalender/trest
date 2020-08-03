source ./trest.sh

xml_res="$(request "GET" "https://run.mocky.io/v3/bf224183-0ecc-45a9-9271-a6d4bb7641ff")"

assert_equal $(get_xml_data "//note/to" "$xml_res") "Tove" "XML parse"
assert_equal $(get_xml_data "//note/tasks/task[1]" "$xml_res") "Eat" "XML parse first element of list"
assert_equal $(get_xml_data "//note/tasks/task[1]/@type" "$xml_res") "done" "XML parse attribute"
