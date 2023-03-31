# Package

version       = "0.0.1"
author        = "the-argus"
description   = "A library for working with recurrence rules for calendar dates as defined in the iCalendar RFC."
license       = "GPL v3"
srcDir        = "src"

# Dependencies

requires "nim >= 1.0.0"
requires "regex >= 0.20.0"
requires "datetime_parse >= 0.1.0"
requires "rfc3339 >= 0.1.1"

task test, "Runs the test suite":
  exec "nim c -r tests/tinit"
  exec "nim c -r tests/tparse_text"
  exec "rm tests/tparse_text"
  exec "rm tests/tinit"
