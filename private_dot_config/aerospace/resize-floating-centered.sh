#!/opt/homebrew/bin/bash

set -o errexit
set -o nounset
set -o pipefail

osascript -e "
tell application \"System Events\"
  set _app to name of first application process whose frontmost is true
  tell process _app
    set _window to front window
    set {x, y, width, height} to _window's position & _window's size
    set position of _window to {x - ($1 / 2), y - ($2 / 2)}
    set size of _window to {width + $1, height + $2}
  end tell
end tell
"
