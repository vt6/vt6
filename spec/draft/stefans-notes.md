# Stefan's notes

## Known requirements that are not yet accounted for

Clients need to...

* negotiate capabilities with server (esp. color depth)
* act on behalf of another client (when multiplexing)
* get terminal size in chars [1]
* notify client about terminal size [2]
* allocate screen areas [3]
* draw into screen areas, select which screen area stdout draws into
* watch input events [4] and control echoing

Servers need to...

* know which processes are in the foreground to correctly handle Ctrl-C (INT),
  Ctrl-\ (QUIT), Ctrl-Z (SUSP)

Note: Flow control need not be implemented in the protocol, only in the terminal.
Same for Ctrl-D. VT6 explicitly does not specify (or allow to configure) which
Ctrl-[key] combination generates which behavior in cooked and cbreak mode.

[1] Requires a more detailed discussion about what "terminal size" even is.
I'm thinking about distinguishing between "screen size" (how much is visible on
screen) and "terminal size" (how much screen area is buffered in the server,
i.e. "scrollback"). Applications should not have to care about the screen
height unless rendering a fullscreen display (i.e. curses-style), in which a
suitable screen area should be allocated.

[2] Maybe a generic notification method wherein instead of separate message
types for "get property" and "watch property", there is just "watch property"
that immediately triggers a "notify property" from the server.

[3] Need to discuss usecases where screen area allocations interact with
applications writing to stdout without an allocation. Especially relevant for
scenarios where legacy (VT100) applications and VT6 applications are mixed.

[4] At least equivalent to cbreak mode, raw mode, and GPM. Maybe higher
granularity. Unclear: Is key event presented on stdin or VT6 input? Unclear:
How to determine which programs are eligible for input event watching?
Unclear: Which input events are protected in which way (e.g. should the
terminal be able to reserve some keybinding or other input action for scrolling
the terminal screen (instead of scrolling in a fullscreen application))?
