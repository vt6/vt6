<!--{ "title": "VT6", "description": "The VT6 project is working towards a modern protocol for virtual terminals." }-->

The way that text terminals work on UNIX and operating systems derived from it has not fundamentally changed for the last 40 years. Even though security concerns have become a focus of attention, most terminal handling code is still running in kernel space. And even though graphical interfaces have conquered every part of our life, text terminals still struggle to provide consistent true-color support, and cannot display bitmap images reliably.

The **VT6 project**, though still in its earliest stages, is working towards a modern protocol for virtual terminals, which, among other things, runs almost entirely in userspace and provides a modular basis on which to serve both legacy clients and forward-looking terminals that want to provide modern capabilities to applications.

Development is taking place on [GitHub](https://github.com/vt6/vt6). Specifications and documentation regarding the specifications can be found in the [`std/` subtree](/std/).
