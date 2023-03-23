import std/options
import std/times
import sugar

import r_options

type
  QueryMethod* = enum
    between, before, after

  IterArgs* = object
    # could include an option for being inclusive or not...
    before: DateTime
    after: DateTime
    dt: DateTime

  IterResult* = object of RootObj
    methodType: QueryMethod
    args: IterArgs

    minDate: Option[DateTime]
    maxDate: Option[DateTime]

    contents: seq[DateTime]
    total: int

  CallbackIterResult = object of IterResult
    iter: (DateTime, number) -> bool

let defaultIterArgs* = IterArgs()

proc initIterResult*(
    methodType: QueryMethod,
    args: IterArgs = defaultIterArgs
  ): IterResult =

  var
    minDate = none(DateTime)
    maxDate = none(DateTime)

  if methodType == between:
    maxDate = some(args.before)
  elif methodType == before:
    maxDate = some(args.dt)
  elif methodType == after:
    minDate = some(args.dt)


  result = IterResult(
    methodType: methodType,
    args: args,
    minDate: minDate,
    maxDate: maxDate,
    contents: @[],
    total: 0
  )

proc add(self: var IterResult, date: DateTime) =
  self.contents.add(date)


# Add a date to result if it fits criteria
#
# date: the date that may be added to the result list.
#
# return: true if it makes sense to continue iteration
# over a chronological list of dates, or false if not.
proc accept(self: var IterResult, date: DateTime): bool =
  let
    tooEarly = self.minDate.isSome and date < self.minDate.get()
    tooLate = self.maxDate.isSome and date > self.maxDate.get()

  if self.methodType == between:
    if tooEarly:
      return true
    if tooLate:
      return false
  elif self.methodType == before:
    if tooLate:
      return false
  elif self.methodType == after:
    if tooEarly:
      return true
    self.add(date)
    return false

  self.add(date)
  return true

proc iter*(options: Options) =
  discard
