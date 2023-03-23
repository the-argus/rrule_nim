# Package

version       = "0.0.1"
author        = "the-argus"
description   = "A library for working with recurrence rules for calendar dates as defined in the iCalendar RFC."
license       = "GPL v3"
srcDir        = "src"

# Dependencies

requires "nim >= 1.0.0"
requires "regex >= 0.20.0"

task test, "Runs the test suite":
  exec "nim c -r tests/tinit"
  exec "rm tests/tinit"
