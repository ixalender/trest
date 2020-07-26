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

    if [ "$1" -eq 1 ]; then
        res=1
    fi

    _assert_exp $res "$desc"
}

function assert_equal() {
    local val1=$1
    local val2=$2
    local desc=$3
    local res=0

    if [ "$val1" = "$val2" ]; then
        res=1
    fi

    _assert_exp $res "$desc"
}

function assert_unequal() {
    local desc=$3
    local res=0

    if [[ $1 != $2 ]]; then
        res=1
    fi

    _assert_exp $res "$desc"
}

function assert_gt() {
    local desc=$3
    local res=0

    if [[ $1 -gt $2 ]]; then
        res=1
    fi

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

    if [[ $1 -lt $2 ]]; then
        res=1
    fi

    _assert_exp $res "$desc"
}

function assert_le() {
    local desc=$3
    local res=0

    if [[ $1 -le $2 ]]; then
        res=1
    fi

    _assert_exp $res "$desc"
}

# Pipeline assertion

function assert() {
    echo "$1"
}

function eq() {
    ret=0
    while read data; do
        if [ $data -eq $1 ]; then
            ret=1
        fi
    done
    echo $ret
}

function ne() {
    ret=0
    while read data; do
        if [ $data -ne $1 ]; then
            ret=1
        fi
    done
    echo $ret
}

function gt {
    ret=0
    while read data; do
        if [ $data -gt $1 ]; then
            ret=1
        fi
    done
    echo $ret
}

function ge {
    ret=0
    while read data; do
        if [ $data -ge $1 ]; then
            ret=1
        fi
    done
    echo $ret
}

function lt {
    ret=0
    while read data; do
        if [ $data -lt $1 ]; then
            ret=1
        fi
    done
    echo $ret
}

function le {
    ret=0
    while read data; do
        if [ $data -le $1 ]; then
            ret=1
        fi
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

# @param $1 array Headers
function build_headers() {
    local headers_array=("$@")
    local idx=0
    local headers_out=()

    for h in "${headers_array[@]}"
    do
        headers_out[i++]='-H'
        headers_out[i++]="'$h'"
    done

    dec=$(declare -p headers_out)
    eval ${dec[@]}
    echo $(_join_by " " ${headers_out[@]})
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
# @param $3 string Headers
# @param $4 string Data [xml|json]
function request() {
    local method=$1
    local url=$2
    local headers=$3
    local data=$4

    local resp=$(curl -s -X "$method" "$url" "$headers" "$data")
    
    if [[ $resp == '' ]]; then
        prt "Unable to connect to $url\n"
        exit 1
    fi
    # echo $CORE_URL > /dev/tty
    echo $resp
}
