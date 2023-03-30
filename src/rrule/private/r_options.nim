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
proc on(ttr: var Parser, options: var Options)
proc decodeM(ttr: var Parser): Option[number]
proc decodeNTH(ttr: var Parser): Option[number]
proc decodeWKD(ttr: var Parser): Option[string]

proc fromText*(staticType: typedesc[Options], text: string): Option[Options] =
  var
    ttr: Parser = initParser(rules=Language.english.tokens)
    options = defaultOptions

  if not ttr.start(text):
    return none(Options)

  ttr.expect("every")

  let
    matchBefore = ttr.someValueFirstMatch
    n = ttr.acceptNumber()

  if n:
    options.interval = number(parseInt(matchBefore))
  if ttr.isDone:
    raise newException(Exception, "Unexpected end")

  # different changes to make to options based on the current symbol
  case ttr.someSymbol:
    of "day(s)":
      options.freq = Frequency.DAILY
      if ttr.nextSymbol():
        at(ttr, options)
        f(ttr, options)
    of "weekday(s)":
      options.freq = WEEKLY
      options.byweekday = @[dMon, dTue, dWed, dThu, dFri].some
      ttr.nextSymbol()
      f(ttr, options)
    of "week(s)":
      options.freq = WEEKLY
      if ttr.nextSymbol():
        on(ttr, options)
        f(ttr, options)
    of "hour(s)":
      discard
    of "minute(s)":
      discard
    of "month(s)":
      discard
    of "year(s)":
      discard
    of "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday":
      discard

    of "january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december":
      discard

    else:
      raise newException(Exception, "Unknown symbol")

  return options.some

proc at(ttr: var Parser, options: var Options) =
  let
    at = ttr.accept("at")
    matchBefore = ttr.someValueFirstMatch
  if not at:
    return

  while true:
    var num = ttr.acceptNumber()
    if not num:
      raise newException(Exception, "Unexpected symbol " & ttr.someSymbol & ", expected hour.")
    options.byhour = some(@[parseInt(matchBefore).number])

    while ttr.accept("comma"):
      num = ttr.acceptNumber()
      if not num:
        raise newException(Exception, "Unexpected symbol " & ttr.someSymbol & ", expected hour.")
      # unsafe get, but we can only reach this point in the code if we've just
      # set options.byhour to an actual seq
      options.byhour.get().add(parseInt(matchBefore).number)

    # TODO: ensure that this doesnt cause problems. copied from JS code, and its
    # possible that JS runs both functions before checking their outputs
    let separatorSymbolIsNext = ttr.accept("comma") or ttr.accept("at")

    if not separatorSymbolIsNext:
      break

proc f(ttr: var Parser, options: var Options) =
  if ttr.someSymbol == "until":
    var date: DateTime
    try:
      date = toDateTime(ttr.text)
    except:
      raise newException(Exception, "Cannot parse \"until\" date: " & ttr.text)

    options.until = date.some
  elif ttr.accept("for"):
    options.count = parseInt(ttr.someValueFirstMatch).number.some
    ttr.expect("number")

proc on(ttr: var Parser, options: var Options) =
  let
    hasOn = ttr.accept("on")
    hasThe = ttr.accept("the")

  if not (hasOn or hasThe): return

  while true:
    let
      nth = ttr.decodeNTH
      wkd = ttr.decodeWKD
      m = ttr.decodeM

    if nth.isSome:
      if wkd.isSome:
        discard ttr.nextSymbol()
        if options.byweekday.isNone:
          options.byweekday = some(seq[WeekDay](@[]))
        var initial = options.byweekday.get()
        initial.add()
      else:
        if options.bymonthday.isNone:
          options.bymonthday = some(seq[number](@[]))
        var initial = options.bymonthday.get()
        initial.add(nth.get())
        options.bymonthday = initial.some
        discard ttr.accept("day(s)")
    elif wkd.isSome:
      discard ttr.nextSymbol()
      if options.byweekday.isNone:
        options.byweekday = some(seq[WeekDay](@[]))
      var initial = options.byweekday.get()
      initial.add()
      options.byweekday = initial.some
    elif ttr.someSymbol == "weekday(s)":
      discard ttr.nextSymbol()
      if options.byweekday.isNone:
        options.byweekday = @[dMon, dTue, dWed, dThu, dFri].some
    elif ttr.someSymbol == "week(s)":
      discard ttr.nextSymbol()

      let
        v = ttr.someValueFirstMatch
        num = ttr.acceptNumber()

      if not num:
        raise newException(Exception, "Unexpected symbol " & ttr.someSymbol & "; expected monthday.")

      options.byweekno.get().add(parseInt(v).number)
    elif m.isSome:
      discard ttr.nextSymbol
      if options.bymonth.isNone:
        options.bymonth = some(seq[number](@[]))
      var initial = options.bymonth.get()
      initial.add(m.get())
      options.bymonth = initial.some
    else:
      return
    
    # TODO: compare with how JS executes statements like this... would all get executed before evaluation? how does nim do it
    let isSeparator = ttr.accept("comma") or ttr.accept("the") or ttr.accept("on")

    if not isSeparator:
      break


proc decodeM(ttr: var Parser): Option[number] =
  case ttr.someSymbol:
    of "january":
      result = 1.number.some
    of "february":
      result = 2.number.some
    of "march":
      result = 3.number.some
    of "april":
      result = 4.number.some
    of "may":
      result = 5.number.some
    of "june":
      result = 6.number.some
    of "july":
      result = 7.number.some
    of "august":
      result = 8.number.some
    of "september":
      result = 9.number.some
    of "october":
      result = 10.number.some
    of "november":
      result = 11.number.some
    of "december":
      result = 12.number.some
    else:
      result = number.none

proc decodeWKD(ttr: var Parser): Option[string] =
  let sym = ttr.someSymbol

  const days: array[7, string] = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

  if sym in days:
    return sym[0..2].toUpperAscii.some
  else:
    return string.none

# may err: includes parseInt and requires the parsed
# symbols to be within a range
proc decodeNTH(ttr: var Parser): Option[number] =
  case ttr.someSymbol:
    of "last":
      discard ttr.nextSymbol()
      result = -1.number.some
    of "first":
      discard ttr.nextSymbol()
      result = 1.number.some
    of "second":
      discard ttr.nextSymbol()
      if ttr.accept("last"):
        result = -2.number.some
      else:
        result = 2.number.some
    of "third":
      discard ttr.nextSymbol()
      if ttr.accept("last"):
        result = -3.number.some
      else:
        result = 3.number.some
    of "nth":
      let v = parseInt(ttr.someValueFirstMatch)
      if v < -366 or v > 366:
        raise newException(Exception, "Nth out of range: " & $v)

      discard ttr.nextSymbol()

      if ttr.accept("last"):
        result = (-v).number.some
      else:
        result = v.number.some
    else:
      result = number.none

# expose some fields read-only
proc dtstart*(opt: ParsedOptions): DateTime = opt.dtstart
proc freq*(opt: ParsedOptions): Frequency = opt.freq
proc interval*(opt: ParsedOptions): number = opt.interval
proc until*(opt: ParsedOptions): Option[DateTime] = opt.until
proc bysetpos*(opt: ParsedOptions): seq[number] = opt.bysetpos
proc count*(opt: ParsedOptions): Option[number] = opt.count
