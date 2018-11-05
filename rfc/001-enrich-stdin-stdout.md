# RFC: A proposal for the enrichment of stdin/stdout channels

An issue that has not yet been addressed in the VT6 protocol design is how to
deliver structured annotations for standard output, e.g. for marking parts of
the output as being an image or being code in a certain language, to enable
proper representation by the terminal.

Zooming out a bit, the bigger picture is that many VT6 messages relate to
standard input and standard output, and should thus be restricted to clients
whose stdin (and stdout, respectively) is actually connected to the terminal.

There is one design element in the current VT6 protocol that allows for
associating a stdin/stdout channel with messages concerning it: multiplexed
mode. This RFC proposes extending the multiplexing strategy of multiplexed mode
to all stdin/stdout streams.

*Note:* I will repeat some rationales from the existing design in the RFC in
order to form a cohesive big picture.

## The proposal

Suppose the shell is executing the following command:

    $ cmd1 | cmd2

Under the current design (including the proposed changes in #36), cmd1 receives
as its stdin a bidirectional byte stream in stdin mode; and cmd2 recieves a
bidirectional byte stream in stdout mode as its stdout. Both channels are
restricted to operating like traditional stdin and stdout, i.e. one-way. Stdin
cannot be used to send anything from cmd1 to the server, and stdout cannot be
used to send anything from the server to cmd2.

I propose to enable multiplexed mode for those stream modes as well. cmd1 should
be able to exchange messages regarding its stdin using its stdin, and cmd2
should be able to exchange messages with the server regarding its stdout using
its stdout.

To distinguish VT6-capable clients from legacy clients, a protocol upgrade
procedure is needed, similar to the existing upgrade procedure from stdio mode
into multiplexed mode. Since both stdin and stdout are one-way streams, we can
use the heretofore unused direction to initiate the upgrade.

In the case of cmd1's stdin, cmd1 would initiate the upgrade by writing a magic
string (e.g. `<ESC>[6V`) into stdin. And the server would complete the upgrade
by replying with another magic string (e.g. `<ESC>[6V`) on the same stream.

The explicit reply from the server is important as a sequencing point. It allows
the client to distinguish between a plain stdin (before the magic string) and a
multiplexed stdin (after the magic string).

Because the initial magic string sent by the client is a valid ANSI escape
sequence, this does not conflict with legacy clients and servers:

1. If cmd1 is a legacy client, it will just not attempt to write into stdin.

2. If the server is a legacy terminal, it will receive the magic string as if it
   were written on the stdout of cmd2 (remember that cmd1 stdin and cmd2 stdout
   are both duplicates of the TTY slave FD owned by the shell), but disregard it
   since it is an ANSI escape sequence that the legacy server does not know.

The upgrade works analogously for cmd2's stdout. In this case, the server sends
the magic string first and the client answers with another magic string.
This does not conflict with legacy clients and servers either:

1. If the server is a legacy terminal, it will just not attempt to write into stdout.

2. If cmd2 is a legacy client, it will just not attempt to read from stdout.

If terminal and both commands are VT6-capable, we reach the following setup
after both upgrade procedures:

       <- msg, stdin    +--------------+           msg ->
       -> msg           |              |   stdout, msg <-
       +--------------->+   terminal   +<---------------+
       |                |              |                |
       |                +--------------+                |
       |                                                |
       v                                                v
    +--+------------------+          +------------------+--+
    |                     |   data   |                     |
    |         cmd1        +--------->+         cmd2        |
    |                     |          |                     |
    +---------------------+          +---------------------+

cmd1 can now use message types and properties on stdin that are only allowed for
clients with an stdin connected to the terminal, e.g.

    term.input-immediate
    term.input-echo
    sig.explicit-eof

This proposal would allow a new property `sig.explicit-eof` to be added, which
allows cmd1 to request that the terminal send an `sig.eof` message whenever
Ctrl-D is pressed. In this way, this RFC would solve #26 once and for all. (The
old "close most recent stdin" behavior for Ctrl-D would remain as a fallback for
when no explicit EOF has been requested.)

Analogously, cmd2 can now use message types and properties on stdout that are
only allowed for clients with an stdout connected to the terminal, e.g.

    mono.enabled
    mono.width etc.
    term.output-protected

*Note:* I was going to extend this proposal with a revamp of how server
connections are spawned, but this proposal is already large enough, especially
with what's coming in the next section, so I'll leave that for the next RFC.

## Taking it one step further: Client-client messages

Now that the start and the end of the command pipeline are VT6-ified, the
obvious next step would be to do the same for the pipes connecting subsequent
pipeline steps (in this case, cmd1's stdout with cmd2's stdin).

I propose to replace the traditional unidirectional pipes, as obtained from
`pipe()`, with bidirectional byte streams, e.g. as obtained from
`socketpair(AF_UNIX, SOCK_STREAM, ...)`.

Then, like with terminal-connected stdins/stdouts, the heretofore unused
direction can be used to initiate a protocol upgrade to a multiplexed
data/message stream.

    +----------+                    +----------+
    |          |     data, msg ->   |          |
    |   cmd1   +------------------->+   cmd2   |
    |          |           msg <-   |          |
    +----------+                    +----------+

If we allow this, it brings up a HUGE open question: Which message types do we
want to allow here? We could restrict this to data annotation (on the level of
`content_type = image/png`).

Or we could go ALL IN on what this design suggests, throw away the client/server
distinction and move to a consumer/producer model instead (cmd1 consumes what
the terminal produces, cmd2 consumes what cmd1 produces, the terminal consumes
what cmd2 produces) and redesign the entire protocol about that. I like this
idea because of its beautiful symmetry, but this is not a step to be taken
lightly.

## Open questions and issues

I can see the following issues with this design:

- When VT6 programs are mixed with legacy programs, an upgrade request could go
  unnoticed, causing the unreceived magic string to occupy kernel memory until
  the client process exits and the streams are teared down. I do not consider
  this a big problem since the client process itself holds quite a bit of kernel
  memory already.

- When a VT6 client is used with a legacy terminal, the upgrade request sent by
  the client on stdin could go unnoticed and block the client waiting to read
  the answer. This is sort of the same problem as with the existing multiplexed
  mode, and I propose that this be solved by involving additional side channels
  (such as the TERM and VT6 environment variables) to allow the client to
  determine in advance when an upgrade procedure is pointless because the server
  appears to be a legacy terminal.

Also, the following open questions:

- It needs to be seen if replacing `pipe()` with `socketpair()` leads to any
  unintended side effects. For example, is the behavior of SIGPIPE/EPIPE
  replicated correctly?

- The big question from above: Is it a good idea to abandon the client/server
  dichotomy in favor of a producer/consumer model?

- In any case, how does stderr fit into all of this? Is it another bidirectional
  byte stream that's always connected to the terminal (unless explicitly
  redirected)?

- Also, how does the traditional usecase for multiplexed mode (SSH) fit into all
  of this? An additional layer of multiplexing may be required here since we're
  now dealing with two separate bidirectional byte streams (SSH's stdin and
  stdout).
