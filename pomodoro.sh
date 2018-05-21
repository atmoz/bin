#!/bin/bash
set -eux

pomodoroLength=25
breakLength=5

notifyId="$(basename "$0")"
notifyFile="/tmp/notify-id-$notifyId"
lockFile="/tmp/notify-lock-$notifyId"

function notify() {
    notify-send --replace-file="$notifyFile" "$@"
}

function cleanup() {
    rm -f "$lockFile"
}

function abort() {
    notify -i edit-delete "Timer aborted"
    exit 0
}

function startPomodoro() {
    notify -i appointment-new "Timer started!"
    timeline "$pomodoroLength" m
    notify -i starred "Pomodoro completed!" \
        "Take a short break. Locking screen in 25 seconds ..."
    timeline 25 s inc
    lock
    startBreak
}

function startBreak() {
    timeline "$breakLength" m
    notify "Break is over"
}

trap "cleanup" EXIT
trap "abort" HUP INT TERM

if [ -f "$lockFile" ]; then
    # TODO: Improve termination of process (if possible)
    kill "$(cat "$lockFile")" # can be unsafe (e.g. not deleted after reboot)
    #pkill -xo "$notifyId" # assuming id is unique (pomodoro)
    exit 0
else
    echo $$ > "$lockFile"
    startPomodoro
fi


