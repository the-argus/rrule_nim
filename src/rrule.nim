import private/r_options
import private/languages

type
  RRule* = object
    origOptions*: Options
    options*: ParsedOptions

proc freqIsDailyOrGreater*(freq: Frequency): bool =
  freq > Frequency.HOURLY

proc initRRule*(): RRule =
  RRule(origOptions: defaultOptions)

export Options
export r_options.fromText
export languages.Language
export languages.English
