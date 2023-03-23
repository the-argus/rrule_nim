import private/r_options

type
  RRule* = object
    origOptions*: Options
    options*: ParsedOptions

proc freqIsDailyOrGreater*(freq: Frequency): bool =
  freq > Frequency.HOURLY

proc initRRule*(): RRule =
  RRule(origOptions: defaultOptions)
