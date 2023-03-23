import std/options
import std/times

when defined(use_cdouble):
  type number* = cdouble
else:
  type number* = float

type
  Frequency* = enum
    YEARLY,
    MONTHLY,
    WEEKLY,
    DAILY,
    HOURLY,
    MINUTELY,
    SECONDLY

  OptionBase = object of RootObj
    freq: Frequency
    interval: number
    count: Option[number]
    until: Option[DateTime]
    tzid: Option[string]
    bynweekday: Option[seq[seq[number]]]
    byeaster: Option[number]

  Options* = object of OptionBase
    dtstart: Option[DateTime]
    wkst: WeekDay
    bysetpos: Option[seq[number]]
    bymonth: Option[seq[number]]
    bymonthday: Option[seq[number]]
    bynmonthday: Option[seq[number]]
    byyearday: Option[seq[number]]
    byweekno: Option[seq[number]]
    byweekday: Option[seq[WeekDay]]
    byhour: Option[seq[number]]
    byminute: Option[seq[number]]
    bysecond: Option[seq[number]]

  ParsedOptions* = object of OptionBase
    dtstart: DateTime
    wkst: number
    bysetpos: seq[number]
    bymonth: seq[number]
    bymonthday: seq[number]
    bynmonthday: seq[number]
    byyearday: seq[number]
    byweekno: seq[number]
    byweekday: seq[number]
    byhour: seq[number]
    byminute: seq[number]
    bysecond: seq[number]
let
  defaultOptions* = Options(
    freq: Frequency.YEARLY,
    dtstart: none(DateTime),
    interval: 1,
    wkst: WeekDay.dMon,
    count: none(number),
    until: none(DateTime),
    tzid: none(string),
    bysetpos: none(seq[number]),
    bymonth: none(seq[number]),
    bymonthday: none(seq[number]),
    bynmonthday: none(seq[number]),
    byyearday: none(seq[number]),
    byweekno: none(seq[seq[number]]),
    byweekday: none(seq[WeekDay]),
    bynweekday: none(seq[seq[number]]),
    byhour: none(seq[number]),
    byminute: none(seq[number]),
    bysecond: none(seq[number]),
    byeaster: none(number)
  )

# expose some fields read-only
proc dtstart*(opt: ParsedOptions): DateTime = opt.dtstart
proc freq*(opt: ParsedOptions): Frequency = opt.freq
proc interval*(opt: ParsedOptions): number = opt.interval
proc until*(opt: ParsedOptions): Option[DateTime] = opt.until
proc bysetpos*(opt: ParsedOptions): seq[number] = opt.bysetpos
proc count*(opt: ParsedOptions): Option[number] = opt.count
