# `vt6/core` - Fundamental protocols and interface contracts

**This document is non-normative**. For the formal specifications, select one of the version numbers from the navigation menu.

Right now, this page is only a tech demo for the new website renderer.
Here's how an embedded drawing looks like:

```tikz
\usetikzlibrary{positioning}
\tikzset{>=stealth}
\tikzstyle{every node}=[minimum width=1.5cm,rectangle,draw]
---
\draw[draw=none] (-5,0) rectangle (5,0); % explicit whitespace at the left/right

\node (core)  at (+0,+0) { core1 };
\node (term)  at (-2,-0.5) { term1 };
\node (sig)   at (+2,-0.5) { sig1 };
\node (frame) at (+0,-1) { frame1 };
\node (tui)   at (-2,-1.5) { tui1 };

\draw[->] (term.east)  -| (core.south);
\draw     (sig.west)   -| (core.south);
\draw[->] (frame.east) -| (sig.south);
\draw[->] (frame.west) -| (term.south);
\draw     (tui.north)  -- (term.south);
```
