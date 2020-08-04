#!/bin/bash

COLOR_RED='\033[0;91m'
COLOR_GREEN='\033[0;92m'
COLOR_YELLOW='\033[0;93m'
COLOR_BLUE='\033[0;94m'
COLOR_NONE='\033[0m'

CURL_TIMEOUT=15

# @param $1 string Text to format
function to_upper() {
    echo "$1" | awk '{print toupper($0)}'
}

# @param $1 string Text to convert
# @param $2 string From encodding
function to_utf8() {
    echo $(echo "$1" | iconv -f $2 -t utf8)
}

# @param $1 string Text to print
# @param $2 optional[string] Color
# @param $3 optional[int] Column size
function prt() {
    if [ -z "$3" ]
        then
            printf "$2$1" > /dev/tty
    else
        printf "$2%-$3s %s" "$1" > /dev/tty
    fi
    printf "$COLOR_NONE%s" "" > /dev/tty
}

# @param $1 string Text to print as line
function prtln() {
    echo $1 > /dev/tty
}

# Extract result tag data from xml
# @param $1 string Xml path (//root/child/subchild)
# @param $2 string Xml data
function get_xml_data() {
    local path=$1
    local data=$2
    echo $(xmllint --xpath "string(//$path)" - <<< $data)
}

# @param $1 string JSON path (root.child.subchild)
# @param $2 string JSON object
function get_json_data() {
    local path=$1
    local data=$2
    echo "${data}" | tr '\r\n' ' ' | jq -r "$path"
}

# @param $1 int Condition
# @param $2 string Description
function _assert_exp() {
    local expression=$1
    local descriptrion=$2

    if [ -z "$expression" ]; then
        prt "ERROR: No expression\n" ${COLOR_RED}
        exit 1
    fi

    if [ -n "$descriptrion" ]; then
        prt "$descriptrion" ${COLOR_NONE} 50
    fi
    
    if [ "$expression" = 1 ]; then
        prt "SUCCEED" ${COLOR_GREEN} 7
    else
        prt "FAILED" ${COLOR_RED} 7
        prt "${BASH_SOURCE[2]}:${BASH_LINENO[1]}" ${COLOR_NONE}
    fi
    prt "\n"
}

function assert_true() {
    local desc=$2
    local res=0

    [ "$1" -eq 1 ] && res=1

    _assert_exp $res "$desc"
}

function assert_equal() {
    local val1=$1
    local val2=$2
    local desc=$3
    local res=0

    [ "$val1" = "$val2" ] && res=1

    _assert_exp $res "$desc"
}

function assert_unequal() {
    local desc=$3
    local res=0

    [[ $1 != $2 ]] && res=1

    _assert_exp $res "$desc"
}

function assert_gt() {
    local desc=$3
    local res=0

    [[ $1 -gt $2 ]] && res=1

    _assert_exp $res "$desc"
}

function assert_ge() {
    local desc=$3
    local res=0

    if [[ $1 -ge $2 ]]; then
        res=1
    fi

    _assert_exp $res "$desc"
}

function assert_lt() {
    local desc=$3
    local res=0
    
    [[ $1 -lt $2 ]] && res=1

    _assert_exp $res "$desc"
}

function assert_le() {
    local desc=$3
    local res=0

    [[ $1 -le $2 ]] && res=1

    _assert_exp $res "$desc"
}

# Pipeline assertion

function assert() {
    echo "$1"
}

function eq() {
    local ret=0
    while read data; do
        [ "$data" = "$1" ] && ret=1
    done
    echo $ret
}

function ne() {
    local ret=0
    while read data; do
        [ "$data" != "$1" ] && ret=1
    done
    echo $ret
}

function gt {
    local ret=0
    while read data; do
        [ $data -gt $1 ] && ret=1
    done
    echo $ret
}

function ge {
    local ret=0
    while read data; do
        [ $data -ge $1 ] && ret=1
    echo $ret
    done
}

function lt {
    local ret=0
    while read data; do
        [[ $data -lt $1 ]] && ret=1
    done
    echo $ret
}

function le {
    local ret=0
    while read data; do
        [ $data -le $1 ] && ret=1
    done
    echo $ret
}

function describe() {
    while read data; do
        _assert_exp $data "$1"
    done
}

# @param $1 string Delimiter
function _join_by { local d=$1; shift; echo "$1"; shift; printf "%s" "${@/#/$d}"; }

# Globally creates curl headers from global request_headers array
# @note: Yeah, global is sucks, but there are no good ways to isolate this process 
#        without breaking compatibility with old Bash versions.
function build_headers() {
    local idx=0
    glob_curl_headers=()

    for h in "${glob_request_headers[@]}"
    do
        glob_curl_headers[idx++]='-H'
        glob_curl_headers[idx++]=$h
    done

    local dec=$(declare -p glob_curl_headers)
    eval ${dec[@]}
}

function clear_headers() {
    glob_curl_headers=()
    local dec=$(declare -p glob_curl_headers)
    eval ${dec[@]}
}

# @param $1 string Host
function host_url() {
    echo "$1?"
}

# Pipeline function to add parameter to given Url
# @param $1 string Pair of parameter and value (param_name=value)
function add_param() {
    local ret=''
    while read data; do
        ret="$data$1&"
    done
    echo $ret
}

# @param $1 string Method
# @param $2 string Url
# @param $3 string Data [xml|json]
function request() {
    local method=$1
    local url=$2
    local data=$3
    local resp=""

    if [ -n "$data" ]; then
        resp=$(curl -s -d "$data" "${glob_curl_headers[@]}" -X "$method" "$url")
    else
        resp=$(curl -s "${glob_curl_headers[@]}" -X "$method" "$url")
    fi
    
    if [[ $resp == '' ]]; then
        prt "Unable to connect to $url\n"
        exit 1
    fi

    echo $resp
}
