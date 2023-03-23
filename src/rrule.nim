import std/times
import std/options
import sugar

import private/r_options
import private/iter

type
  RRule* = object
    origOptions*: Options
    options*: ParsedOptions

proc freqIsDailyOrGreater*(freq: Frequency): bool =
  freq > Frequency.HOURLY

proc initRRule*(): RRule =
  RRule(origOptions: defaultOptions)

# TODO: implement this
proc between*(
  self: RRule, after: DateTime, before: DateTime, inclusive: bool = false,
  lambda: Option[(DateTime, number) -> bool] = none((DateTime, number) -> bool)
  ): seq[DateTime] =
  if lambda.isSome:
    iter(self.origOptions)
