echo ">>> BEGINNING TINIT TEST"

import rrule

let
  basicopts = rrule.Options()
  parsedOpts = rrule.Options.fromText("test")

  lang = rrule.Language.english
