import std/tables
import std/options
import regex


type
  Parser* = object
    rules: Table[string, Regex]
    text: string
    symbol: Option[string]
    value: Option[RegexMatch]
    done: bool

# supported way to create a new parser
# param rules: regex tokens to be use for parsing words
proc initParser*(rules: Table[string, Regex]): Parser
# prepare parser, parse the first symbol
# text: text that will be parsed
# return: true if first symbol was successfully parsed
# false if not.
proc start*(self: var Parser, text: string): bool
# parse the next symbol in the text
# return: true if symbol was successfully parsed
# false if not.
proc nextSymbol*(self: var Parser): bool

# check if the current symbol is equal to param name.
# if it is, perform nextSymbol.
# return bool: whether or not value is null
proc accept(self: var Parser, name: string): bool

# accept but it always uses the number regex
proc acceptNumber*(self: var Parser): bool

# accept, but throw an error if false
proc expect*(self: var Parser, name: string)

# retrieve the first match of the value regex match,
# if it exists
proc valueFirstMatch*(self: var Parser): Option[string]

# helper
proc first(rm: RegexMatch, text: string): string =
  return rm.groupFirstCapture(0, text)

proc valueFirstMatch(self: var Parser): Option[string] =
  if self.value.isSome:
    return first(self.value.get(), self.text).some
  else:
    return string.none

proc initParser(rules: Table[string, Regex]): Parser =
  # parser that is done by default
  return Parser(rules: rules, done: true)

proc accept(self: var Parser, name: string): bool =
  if self.symbol.get("") == name:
    if self.value.isSome:
      let v = self.value.isSome
      discard self.nextSymbol()
      return v

    discard self.nextSymbol()
    return true

  return false

proc acceptNumber*(self: var Parser): bool =
  return self.accept("number")

proc expect(self: var Parser, name: string) =
  if not self.accept(name):
    raise newException(ValueError, "expected " & name & " but found " & self.symbol.get("NO SYMBOL FOUND"))

proc start(self: var Parser, text: string): bool =
  self.text = text
  self.done = false
  return self.nextSymbol

proc nextSymbol(self: var Parser): bool =
  var
    best: Option[RegexMatch] = none(RegexMatch)
    bestSymbol: Option[string] = none(string)

  self.symbol = none(string)
  self.value = none(RegexMatch)

  while true:
    if self.done:
      return false
    
    # reset best match if we skipped last iteration
    best = none(RegexMatch)
    
    # go through all rules and find best match
    for name, rule in self.rules.pairs():
      var match = RegexMatch()
      let matched: bool = self.text.find(rule, match)

      if matched:
        # reducing match to the first primary capture, for length comparison
        if best.isNone or match.first(self.text).len > best.get(RegexMatch()).first(self.text).len:
          # great, better match found
          best = some(match)
          bestSymbol = some(name)
    
    # put the results of the search into self
    if best.isSome:
      # cut off to end of match
      self.text = self.text[best.get(RegexMatch()).first(self.text).len..(self.text.len-1)]
      self.done = self.text.len == 0
    else:
      # no best found
      self.done = true
      self.symbol = none(string)
      self.value = none(RegexMatch)
      return false

    if bestSymbol.get("") != "SKIP":
      break

  # this will only happen if we got "SKIP"
  self.symbol = bestSymbol
  self.value = best

  return true
