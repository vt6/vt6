# Stefan's notes

## Prior art

* [TermKit](https://github.com/unconed/TermKit) ([announcement](http://acko.net/blog/on-termkit/)) arrived at a lot of
  the same design decisions as we already did (separate the view in/out aka VT6 in/out from the data; client-server
  architecture), but apparently didn't give a f~#$ about backwards compatibility, cf. the mandatory headers like
  "Content-Type" on stdin/stdout. I would like these very very much, but I don't see how to do this in a
  backwards-compatible way. [Here's the author explaining why the project failed, BTW.](https://www.reddit.com/r/programming/comments/137kd9/18_months_ago_termkit_a_nextgeneration_terminal/)

## Known requirements that are not yet accounted for

Clients need to...

* negotiate capabilities with server (esp. color depth)
* act on behalf of another client (when multiplexing)
* get terminal size in chars [1]
* notify client about terminal size [2]
* allocate screen areas [3]
* draw into screen areas, select which screen area stdout draws into
* watch input events [4] and control echoing
* submit large screen updates as atomic transactions to avoid tearing ([ref](https://github.com/jwilm/alacritty/issues/598))
* need to know whether stdout is connected to a terminal [5]

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

[5] To avoid inline VT6 messages if this is not the case, similar to how
existing applications use isatty() to determine whether to print in color.
