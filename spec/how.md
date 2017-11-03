# `vt6/how` - Design overview

This document is non-normative.
For the formal definitions of basic VT6 terminology, please refer to [`vt6/core`](../core/).

## 1. Minimal setup

```

        //========================\\
        ||                        ||
        ||                       \||/
        ||                        \/
+--------------+           +--------------+
|               \___________\             |
|   terminal     \           \  shell     |
|                /_ _ _ _ _ _/            |
|               /           /             |     -----  standard I/O
+--------------+           +--------------+
       |  |                       ||            - - -  message I/O
          |                       ||
       |  |                       ||              ||
          |                      \||/            \||/  call flow
       |  |                       \/              \/
          |                +--------------+
       |  \_________________\             |
                             \  program   |
       \ _ _ _ _ _ _ _ _ _ _ /            |
                            /             |
                           +--------------+

```

## 2. Basic workflow example

This example describes the usual workflow when using a VT6-capable terminal.
This terminal acts as a VT6 server.
When it starts up it typically calls a VT6 shell which acts as a VT6 client.
From this shell several more VT6 clients and legacy clients might be started.
All clients talk to the original VT6 server, in this case the terminal.
In order for legacy clients to be able to communicate with the VT6 server they are each wrapped by a VT6-capable wrapper which acts as a VT6 client.
