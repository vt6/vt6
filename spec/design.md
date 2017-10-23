# `vt6/design` - Design overview

This document is non-normative.
For the formal definitions of basic VT6 terminology, please refer to [`vt6/core`](../core/).

## 1. Motivation

Even in the 21st century, text terminals remain a staple of computing, although typically in the form of terminal emulators rather than as the physical devices that were common in the 20th century, until the advent of graphical user interfaces.
Terminal emulators typically support [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code) to allow applications to control the presentation of text content more precisely, including cursor movement commands which can be used to render rich user interfaces.
The ncurses library provides a high-level interface for the creation of such user interfaces.

However, this approach suffers from several drawbacks.

1. Existing ANSI escape codes imply that a text terminal is a fixed-size 2D character matrix.
   This precludes terminal emulators from exposing the GUI capabilities of their host platform to applications running in the terminal.
   For example, a program offering an autocomplete functionality needs to render its own text-based selection menu, instead of using the dropdown menu component that is available in the GUI.

2. The restriction to a character matrix display also forbids applications that run in the terminal from displaying image content in the terminal.

3. The reliance on low-level drawing commands rather than a more high-level semantic vocabulary requires applications to reinvent the wheel over and over again.
   To witness, look at how many programs offer a `--color` switch that adds syntax highlighting to the program's output.

VT6 aims to implement much of what ncurses does and provide additional semantic vocabulary, but not as a *library*, but as a *protocol* between terminal emulators and applications.
Terminal emulators can announce certain capabilities, thus becoming *VT6 servers*, and applications can consume these capabilities, thus becoming *VT6 clients*.

We are specifically using the notions of server and client here instead of "terminal" and "application" to account for *VT6 proxies*, programs that are both server and client at the same time.

1. Terminal multiplexers such as `screen(1)` and `tmux(1)` act as a terminal towards the applications running within them, and as an application to the terminal which the users to connect to them.

2. A VT6 server can act as a proxy for another server to present additional capabilities to clients, and translate these capabilities into the ones that the proxied server understands (or into plain ANSI escape codes, if the proxied server is a legacy terminal).

## 2. Guiding principles

The following principles guide and inform the design of the VT6 protocols and the supporting tools.

1. **Modularity** - New capabilities can be added to the protocol as the need arises, and old capabilities can be deprecated and removed from the protocol, both without affecting the functionality of other capabilities.

2. **Backwards compatibility** - VT6 clients can be used with legacy terminals, and conversely, legacy applications emitting ANSI escape codes can be used with VT6 servers.

3. **Focus on semantics** - VT6 applications should prefer semantic over presentational markup (e.g. a file type annotation over syntax highlighting color codes), so that the VT6 server can choose a method of presentation that is appropriate for both the content and the target platform.

4. **Platform independence** - The VT6 protocol tries to not rely on operating system specifics as much as possible (but consider the platform requirements noted in [`vt6/core0`](./draft/core0.md)).

5. **Ease of use** - VT6 commands should be human-readable, and the protocol should be as easy to emit and consume in all programming and scripting languages as long as the ease of use does not significantly impede performance or resource requirements.
