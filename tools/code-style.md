# `vt6/code-style` - Style guide for VT6 code and code snippets in specs

## Symbol Names

Symbol name components (usually separated by a '-' character) SHALL be ordered from the most abstract one to the most specific one.
For example, in `core1.server-msg-bytes-max` the component `msg` is an aspect of the server, `bytes` are an aspect of messages, and `max` is the aspect of the maximum amount of bytes.
