import std/times
import std/options

type number = float

if defined(use_cdouble):
  type 
    number = cdouble
else:
  type
    number = float

type
  Frequency* = enum
    YEARLY,
    MONTHLY,
    WEEKLY,
    DAILY,
    HOURLY,
    MINUTELY,
    SECONDLY
  RRule* = object

  Options* = object
    freq: Frequency
    dtstart: Option[DateTime]
    interval: number
    wkst: WeekDay
    count: Option[number]
    until: Option[DateTime]
    tzid: Option[string]
    bysetpos: Option[seq[number]]


proc freqIsDailyOrGreater*(freq: Frequency): bool =
  freq > Frequency.HOURLY

proc initRRule*(): RRule =
  RRule()


