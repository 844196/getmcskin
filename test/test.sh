#!/bin/bash

# common function
function countDown() {
    for i in $(seq "${1}" -1 1)
    do
        if [[ $(( i % 10 )) = "0" ]]; then
            printf "%d.. " "${i}" 1>&2
        fi
        if [[ "${i}" -le "5" ]]; then
            printf "%d " "${i}" 1>&2
        fi
        sleep 1
    done
    printf "\n" 1>&2
    return 0
}


# test
testEchoUsage() {
    ./getmcskin -h
    assertEquals 0 $?
}

testEchoVersion() {
    ./getmcskin -v
    assertEquals 0 $?
}

testFalseExitNoUsername() {
    ./getmcskin
    assertEquals 255 $?
}

testFalseExitInvaildOptionSize() {
    ./getmcskin -s foo 844196
    assertEquals 3 $?
}

testFalseExitInvaildOptionOutputPath() {
    ./getmcskin -o /foo/save.png 844196
    assertEquals 4 $?
}

testTrueExitPipe() {
    countDown '30'
    echo '844196' | ./getmcskin
    assertEquals 0 $?
}

testTrueExitArgs() {
    countDown '30'
    ./getmcskin 844196
    assertEquals 0 $?
}


. ./shunit2-2.1.6/src/shunit2
