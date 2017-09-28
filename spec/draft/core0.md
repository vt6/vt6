# `vt6/core0` - Fundamental protocols and interface contracts

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://tools.ietf.org/html/rfc2119).
All content is normative, except for paragraphs starting with the keyword *Rationale* and sections whose heading starts with the word *Example*.

Refer to this document using the identifier `vt6/core0` or using its canonical URL, <https://vt6.io/std/draft/core0>.

## 1. Definitions and platform requirements

The VT6 protocol is divided into **modules** which each define **capabilities**.
A process which implements VT6 capabilities and exposes them to other processes is called a **VT6 server**.
A process that consumes these capabilities is called a **VT6 client**.
A process that acts both as a VT6 client to at least one process and as a VT6 server to at least one process at the same time is called as **VT6 proxy**.

A process that acts as a VT6 server SHALL be able to launch other processes which can then act as VT6 clients, or it alternatively SHALL be able to delegate this task to other processes.

A VT6 client SHALL have access to two objects, or a method to gain access to two such objects, one from which byte strings can be read and one into which byte strings can be written.
These objects shall be called this client's **standard input** and **standard output**, respectively.

A VT6 client MAY have access to two further objects, or a method to gain access to two such objects, one from which byte strings can be read and one into which byte strings can be written.
These objects shall be called this client's **message input** and **message output**, respectively.

If the platform allows VT6 client processes to be started while a VT6 server is not present, the client process MUST have a method to determine whether a VT6 server is present.
It SHALL then not be considered a VT6 client for the purpose of this specification, and any other specifications that inherit the meaning of the term "VT6 client" from it.

If a VT6 client has access to and is using a message input and message output, it is said to be operating in **normal mode**.
Otherwise, it is said to be operating in **multiplexed mode**.

### 1.1. POSIX platform

Operating systems that implement the [POSIX.1 specification](http://pubs.opengroup.org/onlinepubs/9699919799/) are admissible environments for VT6 clients and servers.
Standard input and output for each VT6 client are the file descriptors 0 and 1 of that process, respectively.

POSIX allows processes to be started while a VT6 server is not present.
Therefore, VT6 clients MUST use the following method to determine whether a VT6 server is present.

1. If the `VT6` environment variable is present, its content is the absolute path to a socket file.
   In this case, the VT6 client SHALL assume that a VT6 server is present, and operate in normal mode.
   To obtain the message input and message output, the VT6 client SHALL connect to this socket file with socket type `SOCK_SEQPACKET`, and upon success, use the open socket as both message input and message output.
   When the connection to the socket fails, the VT6 client MAY either bail out, or continue to operate as if no VT6 server is present.

2. If the `TERM` environment variable is present and contains the string `vt6`, the VT6 client SHALL assume that a VT6 server is present, and operate in multiplexed mode.

3. If the `VT6` environment variable is absent and the `TERM` environment variable does not contain the string `vt6`, the VT6 client MUST consider the VT6 server to be absent.

## 2. Messages

This section uses augmented Backus-Naur form (ABNF) as defined in [RFC5234](https://tools.ietf.org/html/rfc5234).

### 2.1. S-expression format

```abnf
s-expression    = "(" *space 1*( ( s-expression / atom ) *space ) ")"

atom            = bareword / quoted-string

bareword        = letter *( letter / digit / "." / "-" / "_" )

quoted-string   = quote *( quoted-char / bslash ( bslash / quote ) ) quote

quote   = %x22              ; " (double quote)
bslash  = %x5C              ; \ (backslash)
digit   = %x30-39           ; decimal digits 0-9
letter  = %x41-5A / %x61-7A ; letters A-Z and a-z
space   = %x20 / %x09-0D    ; ASCII characters which are accepted by isspace() under the C locale
```

Furthermore, the `<quoted-char>` element accepts all byte strings which encode exactly one Unicode character that is not in ASCII.

An **s-expression** is a parenthesis-delimited sequence of atoms or other s-expressions.
Whitespace (sequences of `<space>`) between the parentheses and atoms is ignored.
For example, the following three s-expressions are equivalent.

```vt6
(foo bar)

(           foo bar)

(foo   bar   )
```

The **length** of an s-expression is the number of atoms or other s-expressions that it contains, without counting atoms or s-expressions inside the contained s-expressions.
For example, the length of the s-expression `(a (b c) d)` is 3.
The shortest s-expression is the empty s-expression, `()`, with length 0.

An **atom** is either a bareword or a quoted string.
Each atom **represents** a string of Unicode characters.

A **bareword** is a sequence of ASCII letters, digits, dots, dashes or underscores, such that the first character is a letter.
A bareword **represents** itself.

```
bareword             valid
example-bareword     valid
example3.0           valid
example bareword     invalid (contains whitespace)
5example             invalid (does not start with letter)
"bareword"           invalid (contains forbidden ASCII character)
¯\_(ツ)_/¯           invalid (contains character not in ASCII)
```

A **quoted string** is a string of printable Unicode characters in the UTF-8 encoding, except for the double quote or backslash, enclosed by double quotes.
The quoted string **represents** the string of characters between its enclosing quotes, except for escaping rules as noted below.
For example, the quoted string `"abc"` represents the same 3-letter string as the bareword `abc`.

A quoted string may represent a string containing double quotes or backslashes, if these characters are escaped by inserting a backslash before them.
For example, the quoted string `"ab\\\"cd\""` represents the string `ab\"cd"`.
For each string of Unicode characters, there exists exactly one quoted string that represents it.

### 2.2. Message format

<!--

TODO: define message format based on s-expressions; example message exchange ("->" is client-to-server, "<-" vice versa):

   ->    (want core1 ui2 cli1)
   <-    (have core1.3 ui2.5)
   ->    (core1.subscribe ui2.width ui2.height)
   <-    (core1.notify ui2.width 80 ui2.height 25)

NOTE: no need for multiplexing of messages onto standard in/out, or text onto message in/out, unless in multiplexed mode

TODO: define maximum message size, and re-synchronization algorithm as follows:

   1. discard until next "("
   2. try to parse as message
   3. if invalid or unknown message, back to step 1

TODO: define "want", "have" messages (the only ones that are unversioned and not bound to a module)

NOTE: Not for this module, but: Syntax highlighting to be achieved by sending a "file type hint" message on message out.
When multiple programs form a pipe, the latest file type hint (in pipe chronology) wins.
NOTE: This requires the job control plugin to have a method of establishing a notion of pipe topology on the server.

-->
