Sources:
- https://news.ycombinator.com/item?id=16013950
- private mails

# Nice quotes

  "At first I would state one curious fact: if decades ago terminal was extremly dumb device connected to a relatively
  powerful computer, now the reverse is the case: terminal runs on a relatively powerful hardware while a program
  working with a terminal can be run on a microcontroller with 2Kb RAM. So I see no reason to allow a terminal to be a
  dumb-terminal. A terminal could be pretty smart now."

  "There is a lot of history in the terminal; it's time to learn from it and plan for a future beyond ASCII."

# General important properties of a terminal

- low latency
- 24-bit color
- predictability
- information density

# Feature requests that frames will fix

For the output of a single command, offer to...
- save output into file (either stdout or stderr or both)
- fold output (e.g. long `make` output w/o any interesting stuff in it)
- search in output
- re-use the output as the input to a new command
...from the terminal UI (after the command has exited, or at any time during command execution).

- diff one frame with another one (i.e. text only in one frame is highlighted there; the shell could do this
  automatically when the same command is run twice in a row)

# Text presentation

- highlight lines that were written on stderr
- handle copy/cut/paste correctly with multi-line selections, i.e. terminal has to be aware whether a line break
  occurred because of wrapping or because of an actual line feed character (even within pagers like `less`)
- make non-fixed-width fonts a first-class citizen
- format text in the terminal (right-justifying text, centering, min/max-width, maybe tables)

# GUI

- support autocompletion functionality of shells with a GUI dropdown component
- PostScript support (like NeXTStep): specify fonts, show images, draw charts, etc.
  - "Frankly the future of terminals should look like Python Notebooks such as Jupyter."
- apps (shells, editors) can query/set the window icon/title
- image support: `cat` a picture and it's displayed, `ls` a directory of pictures and see thumbnails
  - more generally, file type detection and appropriate presentation for each output
- metadata on output: `ls` a directory and click on a filename to open it
- "a presentation-based UI, where every on-screen element is always linked to the data it represents"
- "It would be nice if the terminal and/or shell exposed some metadata. For example which machine and folder it is
  currently at. This would allow one to have two terminals connected to two different machines ( via ssh for example )
  and drag and drop files from one terminal to the other, even if there is no route between the two hosts."
- support navigation
  - URL bar displaying the file path and allowing navigation (like breadcrumbs in a file explorer)
  - back and forward button, history, bookmarks
  - right-click on a file path and "open URL in browser", "untar file", "open in libreoffice" etc.
  - ctrl+left-click on a path to `cd` into it or `xdg-open` it
  - this should be customizable (note to self: this is similar to plumber in acme(1))
- split-screen/tabs/quake-mode support

continue at "I'm a Mac User, and honestly..."
