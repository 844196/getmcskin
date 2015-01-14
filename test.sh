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
    local usage="$(~/getmcskin.sh -h 2>&1)"
    assertNotNull "${usage}"
    assertEquals 0 $?
}

testEchoVersion() {
    local version="$(~/getmcskin.sh -v 2>&1)"
    assertNotNull "${version}"
    assertEquals 0 $?
}

testFalseExitNoUsername() {
    ~/getmcskin.sh >/dev/null 2>&1
    assertEquals 255 $?
}

testFalseExitInvaildOptionSize() {
    ~/getmcskin.sh -s foo 844196 >/dev/null 2>&1
    assertEquals 3 $?
}

testFalseExitInvaildOptionOutputPath() {
    ~/getmcskin.sh -o /foo/save.png 844196 >/dev/null 2>&1
    assertEquals 4 $?
}

testTrueExitPipe() {
    countDown '30'
    echo '844196' | ~/getmcskin.sh >/dev/null 2>&1
    assertEquals 0 $?
}

testTrueExitArgs() {
    countDown '30'
    ~/getmcskin.sh 844196 >/dev/null 2>&1
    assertEquals 0 $?
}


. shunit2
