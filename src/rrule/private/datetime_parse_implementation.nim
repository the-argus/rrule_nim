import std/times

proc toDateTime*(s: string): DateTime

when defined(datetime_parse):
  import datetime_parse
  proc toDateTime(s: string): times.DateTime =
    return datetime_parse.parse(s)
else:
  import rfc3339
  proc toDateTime(s: string): times.DateTime =
    let
      date: rfc3339.DateTime = rfc3339.to_date(s)
      epoch = date.to_epoch()

    return fromUnix(epoch).utc

