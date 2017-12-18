# Stefan's notes

## Open points

* `core` module
  * Are the definitions in `core1.0` compatible with the notion of proxying that is going to be introduced in a subsequent module (maybe `mux1`)?
  * Properties right now are scoped to the module level. What about properties of objects? For instance, in the UI library, clients may define an arbitrary number of panels, which each have width/height.
* job control module
  * Need to devise a method to establish a notion of pipe topology on the server, e.g. for the "file type hint" message that enables syntax highlighting, where the last file type hint in a pipe wins.

* situation with frames
  * Frame IDs are secrets; they should be sufficiently random and not guessable.
  * Each client receives a `$VT6_FRAME` environment variable with the frame ID corresponding to its stdio.
  * Shell uses `(make-frame <parent-frame-id>)` to create subframes; terminal answers with `(new-frame <frame-id>)`.
  * Shell obtains stdio for this frame by making a new message FD, then sending `(io-for <frame-id>)<ESC>` (after the required `want/have` exchange).
  * Shell launches subprocesses of pipeline with stdio for the pipeline's frame, setting `$VT6_FRAME` variable accordingly.
  * When a frame is active, the terminal sends signals to the process which created the frame (i.e., to the same connection where `make-frame` was received).
  * When a connection is closed, IOs for frames which were created through it are closed by the terminal.

## Learning resources

* [The TTY demystified](http://www.linusakesson.net/programming/tty/)
* [Proper handling of SIGINT/SIGQUIT](https://www.cons.org/cracauer/sigint.html)
* [Reference for control sequences recognized by xterm](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html)

## Prior art

* [TermKit](https://github.com/unconed/TermKit) ([announcement](http://acko.net/blog/on-termkit/)) arrived at a lot of
  the same design decisions as we already did (separate the view in/out aka message in/out from the data; client-server
  architecture), but apparently didn't give a f~#$ about backwards compatibility, cf. the mandatory headers like
  "Content-Type" on stdin/stdout. I would like these very very much, but I don't see how to do this in a
  backwards-compatible way. [Here's the author explaining why the project failed, BTW.](https://www.reddit.com/r/programming/comments/137kd9/18_months_ago_termkit_a_nextgeneration_terminal/)

## Known requirements that are not yet accounted for

Clients need to...

* negotiate capabilities with server (esp. color depth)
* act on behalf of another client (when multiplexing)
* get terminal size in chars [1]
* be notified about changing terminal size [2]
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
granularity. Unclear: Is key event presented on stdin or message input? Unclear:
How to determine which programs are eligible for input event watching?
Unclear: Which input events are protected in which way (e.g. should the
terminal be able to reserve some keybinding or other input action for scrolling
the terminal screen (instead of scrolling in a fullscreen application))?

[5] To avoid inline VT6 messages if this is not the case, similar to how
existing applications use isatty() to determine whether to print in color.
