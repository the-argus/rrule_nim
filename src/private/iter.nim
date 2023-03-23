import std/options
import std/times
import sugar

import r_options

type
  QueryMethod* = enum
    between, before, after, all

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

proc getValue(self: IterResult): Option[seq[DateTime]] =
    let res = self.contents
    
    # deal with edge case of no result
    if (res.len == 0):
      return none(seq[DateTime])

    # the area of the contents being selected for return. default last item
    var slice = (res.len-1)..(res.len-1)
    
    # between and all are exceptions
    if self.methodType == between or self.methodType == all:
        # return all items in contents
        slice = 0..(res.len-1)

    result = some(res[slice])

proc iter*(iterResult: var IterResult, options: ParsedOptions): Option[seq[DateTime]]=
  let
    count: number = options.count.get(0)
    dtstart: DateTime = options.dtstart
    freq: Frequency = options.freq
    interval: number = options.interval
    until: DateTime = options.until.get(DateTime.default)
    bysetpos: seq[number] = options.bysetpos


  if count == 0 or interval == 0:
    return iterResult.getValue()
