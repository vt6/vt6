# `vt6/core` - Fundamental protocols and interface contracts

**This document is non-normative**. For the formal specifications, select one of the version numbers from the navigation menu above.

## Servers and clients

The VT6 protocol is spoken between **servers** and **clients**.
A VT6 server is a process or system that provides a terminal of some sort: a physical terminal, a line printer, a virtual terminal (as a window on a desktop), or an internal data structure that behaves like a terminal.
A VT6 client is a process that reads user input from this terminal, writes text onto the terminal, and possibly exchanges messages with the server to control its behavior or learn about its state.

In the most common case (commands running inside a shell inside a terminal emulator, all on the same machine), the terminal emulator is the server, and all the programs running inside the terminal are its clients.

```tikz
\usepackage{mathpazo}
\usetikzlibrary{calc}
\tikzset{>=stealth}
\tikzstyle{prog}=[minimum width=1.9cm,rectangle,draw]
\tikzstyle{call}=[node font=\small,auto]
---
\draw[draw=none] (-5,0) rectangle (5,0); % explicit whitespace at the left/right

\node[node font=\small,anchor=south] at (-2,+0.5) { Server };
\node[node font=\small,anchor=south] at (+2,+0.5) { Clients };

\node[prog] (term)  at (-2,+0) { Terminal };
\node[prog] (shell) at (+2,+0) { Shell };
\node[prog] (prog1) at (+2,-1) { Program 1 };
\node[prog] (prog2) at (+2,-2) { Program 2 };

% standard IO
\draw ($(term.east)+(0,0.1)$) -- ($(shell.west)+(0,0.1)$);
\draw (0.1,0.1) |- ($(prog1.west)+(0,0.1)$);
\draw (0.1,0.1) |- (prog2.west);

% message IO
\draw[dashed] ($(term.east)+(0,-0.1)$) -- ($(shell.west)+(0,-0.1)$);
\draw[dashed] ($(term.south east)+(-0.15,0)$) |- ($(prog1.west)+(0,-0.1)$);

% call flow
\draw[->] ($(term.north east)+(0.1,0.1)$)
  to [bend left=20]
  node[call,midway] { executes } ($(shell.north west)+(-0.1,0.1)$);
\draw[->] ($(shell.east)+(0.1,0)$)
  to [bend left=20] ($(prog1.east)+(0.1,0)$);
\draw[->] ($(shell.east)+(0.1,0)$)
  to [bend left=20]
  node[call,midway] { executes } ($(prog2.east)+(0.1,0)$);

% legend
\node[anchor=west,node font=\scriptsize,align=left] at (-4.5,-1.5) {
  \tikz\draw (0,0) -- (0.5,0) (0,-0.08); Standard input/output \\
  \tikz\draw[dashed] (0,0) -- (0.5,0) (0,-0.08); Server connection
};
```

Every client has a standard input and output that connects to the terminal.
Clients may also have one (or more) server connections to exchange VT6 messages with the server.
Messages provide all the functionality that legacy terminals implement:

- via the [magic capabilities of terminal devices](https://linux.die.net/man/3/termios) provided by Unix kernels, or
- using [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code).

Complex clients, such as shells or text editors, will always use a server connection.
Simple text-processing tools, such as `cat`, `grep` or `awk`, will typically not need to use a server connection (see "Program 2" in the picture above).

The method by which server connections are established depends on the platform.
Platform-dependent behavior like this is defined in the **platform integration module** for each supported platform, such as [vt6/posix](/std/posix/1.0/).
<!-- TODO replace link above by link to /std/posix/ once that page exists -->

### Wrapping legacy clients

A VT6 server implementation might not support legacy ANSI escape codes.
When legacy clients need to be used with such a server, a wrapper may be used that translates ANSI escape codes into VT6 messages and vice versa:

```tikz
\usepackage{mathpazo}
\usetikzlibrary{calc}
\tikzset{>=stealth}
\tikzstyle{prog}=[minimum width=1.9cm,rectangle,draw]
---
\draw[draw=none] (-5,0) rectangle (5,0); % explicit whitespace at the left/right

\node[prog] (term)  at (-3,+0) { Terminal };
\node[prog] (shell) at (+0,+0) { Shell };
\node[prog] (wrap)  at (+0,-1) { Wrapper };
\node[prog] (prog)  at (+3,-1) { Program };

% standard IO
\draw ($(term.east)+(0,0.1)$) -- ($(shell.west)+(0,0.1)$);
\draw ($(term.east)+(0.6,0.1)$) |- ($(wrap.west)+(0,0.1)$);
\draw (wrap.east) -- (prog.west);

% message IO
\draw[dashed] ($(term.east)+(0,-0.1)$) -- ($(shell.west)+(0,-0.1)$);
\draw[dashed] ($(term.south east)+(-0.15,0)$) |- ($(wrap.west)+(0,-0.1)$);
```

TODO link to an implementation of such a wrapper once there is one

### Enhancing insufficient servers

A **VT6 proxy** is a program that sits inbetween a client and a server, acting as the client towards the server and as the server towards the client.

```tikz
\usepackage{mathpazo}
\usetikzlibrary{calc}
\tikzset{>=stealth}
\tikzstyle{prog}=[minimum width=1.9cm,rectangle,draw]
---
\draw[draw=none] (-5,0) rectangle (5,0); % explicit whitespace at the left/right

\node[prog] (term) at (-3,+0) { Terminal };
\node[prog] (shell) at (+0,+0) { Shell };
\node[prog] (wrap) at (+0,-1) { Proxy };
\node[prog] (prog) at (+3,-1) { Client };

% standard IO
\draw ($(term.east)+(0,0.1)$) -- ($(shell.west)+(0,0.1)$);
\draw ($(term.east)+(0.6,0.1)$) |- ($(wrap.west)+(0,0.1)$);
\draw ($(wrap.east)+(0,0.1)$) -- ($(prog.west)+(0,0.1)$);

% message IO
\draw[dashed] ($(term.east)+(0,-0.1)$) -- ($(shell.west)+(0,-0.1)$);
\draw[dashed] ($(term.south east)+(-0.15,0)$) |- ($(wrap.west)+(0,-0.1)$);
\draw[dashed] ($(wrap.east)+(0,-0.1)$) -- ($(prog.west)+(0,-0.1)$);
```

When a server implementation does not implement all the modules that a client needs, the client can use a VT6 proxy to provide the missing features.
For example, when a server is not able to display images on the terminal, a proxy may be used that converts the client's images into ASCII art.

TODO link to and describe `6lint` (or however it will be called) once it exists

### Connecting over the network

Some clients can only reach their server over a single connection, most commonly when SSH is used to execute a client on a remote machine.
In these cases, all server connections and standard inputs/outputs are multiplexed onto a single server connection.
That server connection is then said to be operating in **multiplexed mode**, rather than in the more common **normal mode**.

TODO figure out how this works exactly (who muxes, who demuxes? do we need to patch SSH?)

TODO note to self: It appears sufficient if the terminal demuxes, although SSH on the source side may choose to demux. However, we need to adapt the protocol such that multiplexed mode starts at the first `\e[6V` (with everything before that being plain stdio), rather than requiring that `\e[6V` is the first thing on stdio, because SSH might show a password prompt or stuff like that before patching stdio through to the remote client.

## Modules

The VT6 protocol defines **message types** and **properties**.
To make the protocol extensible, message types and properties are namespaced into **modules**.
Each message type or property name is prefixed with the name of its module in the following way:

```tikz
\usepackage{mathpazo}
\usetikzlibrary{decorations.pathreplacing,positioning}
\tikzset{node distance=0pt,inner sep=0pt}
---
\draw[draw=none] (-5,0) rectangle (5,0); % explicit whitespace at the left/right

\node (core) { \strut core };
\node (dot) [right=of core] { \strut . };
\node (sub) [right=of dot] { \strut sub };

\draw [decorate,decoration={brace,amplitude=3pt,mirror}] (core.south west) -- (core.south east) node [midway,auto,swap,font=\tiny,yshift=-5pt] { module name };
\draw [decorate,decoration={brace,amplitude=3pt}] (core.north west) -- (sub.north east) node [midway,auto,font=\tiny,yshift=+5pt] { message type };
```

Modules are versioned with a pair of major and minor version number, following a simplified variant of [semantic versioning](https://semver.org).
Minor versions can add new message types, properties or other behavior.
All other changes to a module's specification are backwards-incompatible and must result in a new major version.

```tikz
\usepackage{mathpazo}
---
\draw[draw=none] (-5,0) rectangle (5,0); % explicit whitespace at the left/right
\node at (0,0) { $1.0 < 1.1 < 1.2 < \ldots < 2.0 < 2.1 < \ldots$ };
```

In specifications and documentations, we use the following syntax to refer to module versions:

```
identifier = module_name + module_version
if ambiguous {
  identifier = "vt6/" + identifier
}
```

For example, version 1.2 of the module `core` may be referred to as `vt6/core1.2` or just `core1.2`.

## Messages

When a client wants to do more than just write plain text to standard output or read plain text from standard input, it opens a server connection (for example, on POSIX, a connection to the Unix domain socket provided by the server).
On the wire, messages look like this:

```vt6
{3|8:core.pub,11:term.width,2:80,}
```

The message is a sequence of bytestrings.
The message header `{3|` contains the number of bytestrings.
Each bytestring has the form `<count>:<bytes>,`, where `<count>` is the number of `<bytes>`.
The list of bytestrings is followed by a `}` character, mostly as a visual aid.
The first bytestring in a message is the **message type**, the remaining bytestrings are called the **arguments** of the message.

This format is simple and extensible and can be generated and parsed without requiring additional memory allocations, but it's slightly hard to type by hand or parse with the naked eye.
For specifications and documentation, we therefore use an alternate representation for messages that looks like this:

```vt6
(core.pub term.width 80)
```

This representation uses parentheses instead of curly brackets to avoid confusion between both formats.
When any of the bytestrings contain special characters or spaces, they are quoted like C string literals.

## Protocol negotiation

Since message types are grouped into modules, but not every server or client may implement every module, modules need to be negotiated before their message types (and properties) can be used.
The only exceptions to this rule are the three eternal message types `want` and `have` (which are used for this negotiation process) and `nope` (which servers use to respond to invalid messages).
A module is negotiated in two steps: First, the client sends a `want` message to announce that it wants to use this module, and to indicate which major versions of that module it supports.

```vt6
(want core 1 2)
```

The example above would mean that the client wants to use the `core` module, and that it supports major versions 1 and 2.
The server replies either with a `have` message indicating that it agrees to using that module, for example:

```vt6
(have core 1.3)
```

Alternatively, the server can reply with an empty `have` message to indicate that it cannot use that module:

```vt6
(have)
```

When that happens, the client can either bail out or choose to work without that module, e.g. by reducing its feature set.

Some modules may depend on other modules, meaning that the server must agree to the dependencies before it can agree to the module itself.
Most clients will want to send a stream of `want` messages all at once when starting up to negotiate all the modules that they need to use or might want to use.

## Properties

Finally, `vt6/core` provides a standard interface for **properties** relating to the state of the server or the individual server connection.
Clients can **subscribe** to a property with the `core.sub` message.
The server will answer with a `core.pub` message containing the property's value immediately, and (from this point on) whenever the value changes.

```vt6
[client] (core.sub term.width)
[server] (core.pub term.width 80)
...
[user]   resizes terminal window
[server] (core.pub term.width 100)
```

Properties can also be set by the client using the `core.set` command.
The server must always answer with another `core.pub`, even if it could not change the value because the property is read-only.
Even for editable properties, the new property value indicated in `core.pub` may be different from what the client requested.
For example, in the following conversation, the terminal cannot be resized beyond 250 characters width because of the constraints of the physical screen:

```vt6
[client] (core.sub term.width)
[server] (core.pub term.width 80)
[client] (core.set term.width 400)
[server] (core.pub term.width 200)
```
