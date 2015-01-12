#!/bin/bash

testTrueExitPipe() {
    echo 844196 | ~/getmcskin.sh
    assertEquals 0 $?
}

testTrueExitArgs() {
    sleep 60
    ~/getmcskin.sh 844196
    assertEquals 0 $?
}

testFalseExitNoUsername() {
    ~/getmcskin.sh
    assertEquals 1 $?
}

testFalseExitIlligalOptionSize() {
    ~/getmcskin.sh -s foo 844196
    assertEquals 1 $?
}

testFalseExitIlligalOptionFilename() {
    ~/getmcskin.sh -o /foo/save.png 844196
    assertEquals 1 $?
}

testFalseExitNetworkError204() {
    ~/getmcskin.sh 843262
    assertEquals 204 $?
}


. shunit2
