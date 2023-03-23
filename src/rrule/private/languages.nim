import std/tables
import regex

type
  Language* = object
    dayNames: seq[string]
    monthNames: seq[string]
    tokens: Table[string, Regex]

let englishLanguage: Language = Language(
  dayNames: @[
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ],
  monthNames: @[
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ],
  tokens: {
    "SKIP": re"^[ \r\n\t]+|^\.$",
    "number": re"^[1-9][0-9]*",
    "numberAsText": re"(?i)^(one|two|three)",
    "every": re"(?i)^every",
    "day(s)": re"(?i)^days?",
    "weekday(s)": re"(?i)^weekdays?",
    "week(s)": re"(?i)^weeks?",
    "hour(s)": re"(?i)^hours?",
    "minute(s)": re"(?i)^minutes?",
    "month(s)": re"(?i)^months?",
    "year(s)": re"(?i)^years?",
    "on": re"(?i)^(on|in)",
    "at": re"(?i)^(at)",
    "the": re"(?i)^the",
    "first": re"(?i)^first",
    "second": re"(?i)^second",
    "third": re"(?i)^third",
    "nth": re"(?i)^([1-9][0-9]*)(\.|th|nd|rd|st)",
    "last": re"(?i)^last",
    "for": re"(?i)^for",
    "time(s)": re"(?i)^times?",
    "until": re"(?i)^(un)?til",
    "monday": re"(?i)^mo(n(day)?)?",
    "tuesday": re"(?i)^tu(e(s(day)?)?)?",
    "wednesday": re"(?i)^we(d(n(esday)?)?)?",
    "thursday": re"(?i)^th(u(r(sday)?)?)?",
    "friday": re"(?i)^fr(i(day)?)?",
    "saturday": re"(?i)^sa(t(urday)?)?",
    "sunday": re"(?i)^su(n(day)?)?",
    "january": re"(?i)^jan(uary)?",
    "february": re"(?i)^feb(ruary)?",
    "march": re"(?i)^mar(ch)?",
    "april": re"(?i)^apr(il)?",
    "may": re"(?i)^may",
    "june": re"(?i)^june?",
    "july": re"(?i)^july?",
    "august": re"(?i)^aug(ust)?",
    "september": re"(?i)^sep(t(ember)?)?",
    "october": re"(?i)^oct(ober)?",
    "november": re"(?i)^nov(ember)?",
    "december": re"(?i)^dec(ember)?",
    "comma": re"(?i)^(,\s*|(and|or)\s*)+",
  }.toTable
)

proc tokens*(lang: Language): Table[string, Regex] =
  return lang.tokens
proc english*(staticType: typedesc[Language]): Language =
  result = englishLanguage
