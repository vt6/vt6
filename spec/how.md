# `vt6/how` - Design overview

This document is non-normative.
For the formal definitions of basic VT6 terminology, please refer to [`vt6/core`](core/).


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
   \||/
    \/
+--------+
| callee |
+--------+

```


### 1.1. vt6 clients and legacy programs

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


###  1.2. Wrapping

A program can be wrapped in order to appear as a normal vt6 client.
This is usually the case when the server does not support ANSI escape sequences.
The vt6 wrapper then 'translates' the terminal control sequences from the legacy program to vt6 messages and vice versa.

```

+------------+         +-------------+         +----------------+
|            |---------|             |         |                |
| vt6 server |         | vt6 wrapper |---------| legacy program |
|            |- - - - -|             |         |                |
+------------+         +-------------+         +----------------+

```


### 1.3. Multiplexing

If a socket for vt6 messages can't be used even though both server and client are vt6-compatible, the multiplexed mode is being used.
Multiplexed connections use only the standard I/O channel.

```

+------------+         +------------+
|            |         |            |
| vt6 server |---------| vt6 client |
|            |         |            |
+------------+         +------------+

```


## 2. Setup examples

### 2.1. Conventional setup example

The following illustration shows the example of a usual setup.
A vt6 terminal calls a process at startup, which usually is a vt6 shell.
From the vt6 shell the user then starts programs, which can also be vt6 clients.

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


### 2.2. Legacy program setup example

A vt6 shell can also be used to execute legacy programs, as shown in the following illustration.

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
        |                         ||
        |                        \||/
        |                         \/
        |                  +--------------+
        |                  |              |
        \__________________|   legacy     |
                           |   program    |
                           |              |
                           +--------------+

```


### 2.3 Wrapped legacy program setup example

The following illustration shows another possible way to run a legacy program under a vt6 terminal, namely by using a wrapper.
The legacy program thus appears to the vt6 server as a regular vt6 client.

For understanding the usability of this setup, imagine the wrapper being a vt6-capable SSH client and the legacy program running on another machine.
In this example the connection between the wrapper and the legacy program is a normal bi-directional connection over a network.

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
          |                +---------------+         +--------------+
       |  \_________________\              |         |              |
                             \ vt6 wrapper |_________|   legacy     |
       \ _ _ _ _ _ _ _ _ _ _ /             |         |   program    |
                            /              |         |              |
                           +---------------+         +--------------+

```


### 2.4. Multiplexed vt6 connection setup example

Now picture the case with the SSH as above, only this time the wrapped program is a vt6 client.
In this case the multiplexed mode is used between the wrapper and the wrapped vt6 client.

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
          |                +---------------+         +--------------+
       |  \_________________\              |          \             |
                             \ vt6 wrapper |___________\ vt6 client |
       \ _ _ _ _ _ _ _ _ _ _ /             |           /            |
                            /              |          /             |
                           +---------------+         +--------------+

```


To make it clear that the multiplexed connection can go all the way through to the terminal, here is a second case in which the SSH client is not vt6-capable.

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
        |                         ||
        |                        \||/
        |                         \/
        |                  +---------------+         +--------------+
        |                   \              |          \             |
        \____________________\ vt6 wrapper |___________\ vt6 client |
                             /             |           /            |
                            /              |          /             |
                           +---------------+         +--------------+

```
