import std/options
import std/times
import std/strutils
import parser
import languages
import datetime_parse_implementation

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
    byweekno: none(seq[number]),
    byweekday: none(seq[WeekDay]),
    bynweekday: none(seq[seq[number]]),
    byhour: none(seq[number]),
    byminute: none(seq[number]),
    bysecond: none(seq[number]),
    byeaster: none(number)
  )

proc at(ttr: var Parser, options: var Options)
proc f(ttr: var Parser, options: var Options)

proc fromText*(staticType: typedesc[Options], text: string): Option[Options] =
  let options = defaultOptions
  var ttr: Parser = initParser(rules=Language.english.tokens)

  if not ttr.start(text):
    return none(Options)

  ttr.expect("every")

  let
    matchBefore = ttr.valueFirstMatch
    n = ttr.acceptNumber()

  if n:
    options.interval = parseInt(matchBefore)
  if ttr.isDone:
    raise newException(Exception, "Unexpected end")

  # different changes to make to options based on the current symbol
  case ttr.someSymbol:
    of "day(s)":
      options.freq = Frequency.DAILY
      if ttr.nextSymbol():
        at(ttr, options)
        f(ttr, options)
      break
    of "weekday(s)":
      break
    of "week(s)":
      break
    of "hour(s)":
      break
    of "minute(s)":
      break
    of "month(s)":
      break
    of "year(s)":
      break
    of "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday":
      break

    of "january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december":
      break

    else:
      raise newException(Exception, "Unknown symbol")

  return options

proc at(ttr: var Parser, options: var Options) =
  let
    at = ttr.accept("at")
    matchBefore = ttr.valueFirstMatch
  if not at:
    return

  while true:
    var num = ttr.acceptNumber()
    if not num:
      raise newException(Exception, "Unexpected symbol " & ttr.someSymbol & ", expected hour.")
    options.byhour = some(@[parseInt(matchBefore.get("")).number])

    while ttr.accept("comma"):
      num = ttr.acceptNumber()
      if not num:
        raise newException(Exception, "Unexpected symbol " & ttr.someSymbol & ", expected hour.")
      # unsafe get, but we can only reach this point in the code if we've just
      # set options.byhour to an actual seq
      options.byhour.get().add(parseInt(matchBefore.get("")).number)

    let separatorSymbolIsNext = ttr.accept("comma") or ttr.accept("at")

    if not separatorSymbolIsNext:
      break

proc f(ttr: var Parser, options: var Options) =
  if ttr.someSymbol == "until":
    let date = toDateTime(ttr.text)


# expose some fields read-only
proc dtstart*(opt: ParsedOptions): DateTime = opt.dtstart
proc freq*(opt: ParsedOptions): Frequency = opt.freq
proc interval*(opt: ParsedOptions): number = opt.interval
proc until*(opt: ParsedOptions): Option[DateTime] = opt.until
proc bysetpos*(opt: ParsedOptions): seq[number] = opt.bysetpos
proc count*(opt: ParsedOptions): Option[number] = opt.count
