#!/usr/bin/env python3

import time
import signal
import sys
import os
from subprocess import run

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GLib

# TODO Accept arguments to customize times and only enable break if argument is given
# TODO Clean up messy code

def abort(signal, frame):
    run(["notify-send", "-i", "edit-delete", "Timer aborted"])
    cleanExit()

def cleanExit():
    try:
        os.remove(lockFile)
    except:
        pass
    sys.exit(0)

class Timer:
    def __init__(self, progressbar, timeUp, timeDown):
        self.bar = progressbar
        self.timeUp = timeUp
        self.timeDown = timeDown
        self.stepUp = 1/timeUp
        self.stepDown = -1/timeDown
        self.counter = 0
        self.goingUp = True

    def __call__(self, *args):
        if self.counter == self.timeUp:
            self.goingUp = False
            self.counter = self.timeDown
            run(["notify-send", "-i", "starred",
                "Time over!", "You can now take a break"])

        if self.goingUp:
            step = self.stepUp
            self.counter += 1
        else:
            step = self.stepDown
            self.counter -= 1

        bar.set_fraction(bar.get_fraction() + step)

        if not self.goingUp and self.counter == 0:
            run(["notify-send", "Break is over"])
            cleanExit()

        return True

signal.signal(signal.SIGINT, abort)
signal.signal(signal.SIGTERM, abort)

lockFile = '/tmp/atmoz-timeline.lock'
existing_pid = 0
try:
    with open(lockFile, 'r') as f:
        existing_pid = f.read()
    f.closed
except:
    pass

if existing_pid == 0:
    with open(lockFile, 'w') as f:
        f.write(str(os.getpid()))
    f.closed
else:
    print("killing '" + existing_pid + "'")
    run(["kill", existing_pid])
    cleanExit()

#settings = Gtk.Settings.get_default()
#settings.set_property("gtk-theme-name", "Numix")
#settings.set_property("gtk-application-prefer-dark-theme", True)

window = Gtk.Window(title="timeline")
#window.connect("destroy", Gtk.main_quit)

window.set_type_hint(Gdk.WindowTypeHint.DOCK)
window.set_default_size(1000,4)
window.set_gravity(Gdk.Gravity.SOUTH)
window.move(0, window.get_screen().height() - window.get_size()[1])

bar = Gtk.ProgressBar()
bar.set_fraction(0.0)

window.add(bar)
window.show_all()

run(["notify-send", "-i", "appointment-new", "Timer started"])

timer = Timer(bar, 25*60, 5*60)
GLib.timeout_add(1000, timer)
GLib.MainLoop().run()

#Gtk.main()
