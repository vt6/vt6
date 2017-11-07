# `vt6/how` - Design overview

This document is non-normative.
For the formal definitions of basic VT6 terminology, please refer to [`vt6/core`](../core/).


## 1. Combinations of vt6 server and clients

In the following illustrations there are two kinds of connection between servers and clients:

```

  ---------  I/O stream (most commonly stdin and stdout)

  - - - - -  vt6 message stream (message input, message output)

```

Call flows are denoted with arrows:

```

+--------+
| caller |
+--------+
    ||
    ||
   \||/
    \/
+--------+
| callee |
+--------+

```


## 1.1. vt6 clients and legacy programs

The clients of a vt6 server are divided into two categories:

- A **vt6 client** uses both an I/O channel and a vt6 message channel. This is the minimal vt6 setup.

```

+------------+         +------------+
|            |---------|            |
| vt6 server |         | vt6 client |
|            |- - - - -|            |
+------------+         +------------+

```

- A **legacy program** uses only the standard I/O channel:

```

+------------+         +----------------+
|            |         |                |
| vt6 server |---------| legacy program |
|            |         |                |
+------------+         +----------------+

```

The standard I/O channels are most commonly stdin, stdout, and stderr.


##  1.2. Wrapping

If the server is not compatible to a legacy program, the client can be wrapped in order to appear as a normal vt6 client.
The vt6 wrapper then 'translates' the legacy control sequences into vt6 messages and vice versa.

This example also illustrates the fact that a vt6 client can also be a (vt6-)server to another client at the same time.

```

+------------+         +-------------+         +----------------+
|            |---------|             |         |                |
| vt6 server |         | vt6 wrapper |---------| legacy program |
|            |- - - - -|             |         |                |
+------------+         +-------------+         +----------------+

```


## 1.3. Multiplexing

If a socket for vt6 messages can't be used even though both server and client are vt6-compatible, the multiplexed mode is being used.
Multiplexed connections use only the standard I/O channel:

```

+------------+         +------------+
|            |         |            |
| vt6 server |---------| vt6 client |
|            |         |            |
+------------+         +------------+

```


## 2. Conventional setup

The following illustration shows the example of a usual setup.
A vt6 terminal calls a process at startup, which usually is a vt6 shell.
From the vt6 shell the user can then start programs, which can also be vt6 clients.

```

        //========================\\
        ||                        ||
        ||                       \||/
        ||                        \/
+--------------+           +--------------+
|               \___________\             |
|  vt6 terminal  \           \ vt6 shell  |
|                /_ _ _ _ _ _/            |
|               /           /             |
+--------------+           +--------------+
       |  |                       ||       
          |                      \||/
       |  |                       \/
          |                +--------------+
       |  \_________________\             |
                             \ vt6 client |
       \ _ _ _ _ _ _ _ _ _ _ /            |
                            /             |
                           +--------------+

```


## 3. Exhaustive example setup

This example intends to summarize several possible constellations of programs running under a vt6 terminal.
It describes a possible setup when using a vt6-capable terminal, which acts as a VT6 server.
When the vt6 terminal starts up it typically calls a VT6 shell which acts as a VT6 client.
From this shell several more VT6 clients and legacy programs might be started by the user.
All clients talk to the original VT6 server, in this case the terminal.

```

        //========================\\
        ||                        ||
        ||                       \||/
        ||                        \/
+--------------+           +--------------+
|               \___________\             |
|  vt6 terminal  \           \ vt6 shell  |
|                /_ _ _ _ _ _/            |===\\
|               /           /             |   ||
+--------------+           +--------------+   ||
       |  |                                   ||
          |                       //==========//
       |  |                       ||          ||
          |                      \||/         ||
       |  |                       \/          ||
          |                +--------------+   ||
       |  \_________________\             |   ||
          |                  \ vt6 client |   ||
       \ _|_ _ _ _ _ _ _ _ _ /            |   ||
       |  |                 /             |   ||
          |                +--------------+   ||
       |  |                                   ||
          |                       //==========//
       |  |                       ||          ||
          |                      \||/         ||
       |  |                       \/          ||
          |                +--------------+   ||
       |  |                 \             |   ||
          \__________________\  legacy    |   ||
       |  |                  /  program   |   ||
          |                 /             |   ||
       |  |                +--------------+   ||
          |                                   ||
       |  |                       //==========//
          |                       ||          ||
       |  |                      \||/         ||
          |                       \/          ||
       |  |                +---------------+  ||     +---------------+
          \_________________\              |  ||      \              |
       |  |                  \ vt6 wrapper |___________\   legacy    |
        _ | _ _ _ _ _ _ _ _ _/ (e. g. SSH  |  ||       /   program   |
          |                 /   client)    |  ||      /              |
          |                +---------------+  ||     +---------------+
          |                       ||          ||             /\
          |                       ||          ||            /||\
          |                       ||          ||             ||
          |                       \\=========================//
          |                                   ||
          |                       //==========//
          |                       ||
          |                      \||/
          |                       \/
          |                +---------------+         +----------------------+
          |                 \              |          \                     |
          \__________________\ normal      |___________\ vt6 client         |
                             / SSH client  |           / (multiplexed mode) |
                            /              |          /                     |
                           +---------------+         +----------------------+

```
