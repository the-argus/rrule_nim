import std/times
import sugar
import rrule/private/r_options
import rrule/private/languages

type
  RRule* = object
    origOptions*: Options
    options*: ParsedOptions

proc freqIsDailyOrGreater*(freq: Frequency): bool =
  freq > Frequency.HOURLY

proc initRRule*(): RRule =
  RRule(origOptions: defaultOptions)

proc fromText*(rruleType: typedesc[RRule], text: string): RRule =
  let
    options = Options.fromText(text)
    parsed = options.parseOptions()

  RRule(origOptions: options, options: parsed)

proc between*(self: RRule, after: DateTime, before: DateTime, mapFunc: (d: DateTime, l: number) -> bool = ((d: DateTime, l: number) => false)): seq[DateTime] =
  assert before < after

  let
    dtstart = self.options.dtstart
    freq = self.options.freq
    interval = self.options.interval
    until = self.options.until
    bysetpos = self.options.bysetpos

  var count = self.options.count

  return @[]

export Options
export r_options.fromText
export languages.Language
export languages.english
