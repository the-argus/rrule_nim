import std/times

proc toDateTime(s: string): DateTime

when defined(datetime_parse):
  import datetime_parse
  proc toDateTime(s: string): DateTime =
    return datetime_parse.parse(s)
else:
  import rfc3339
  proc toDateTime(s: string): DateTime =
    return rfc3339.to_date(s)

