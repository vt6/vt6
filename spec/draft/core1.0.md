# `vt6/core1.0` - Fundamental protocols and interface contracts

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://tools.ietf.org/html/rfc2119).

Refer to this document using the identifier `vt6/core1.0` or using its canonical URL, <https://vt6.io/std/draft/core1.0>.

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

bareword        = ( letter / "_" ) *( letter / digit / "." / "-" / "_" )

quoted-string   = quote *( quoted-char / bslash ( bslash / quote ) ) quote

quote   = %x22              ; " (double quote)
bslash  = %x5C              ; \ (backslash)
digit   = %x30-39           ; decimal digits 0-9
nzdigit = %x31-39           ; non-zero decimal digits 1-9
letter  = %x41-5A / %x61-7A ; letters A-Z and a-z
space   = %x20 / %x09-0D    ; ASCII characters which are accepted by isspace() under the C locale
```

Furthermore, the `<quoted-char>` element accepts all byte strings which encode exactly one Unicode character that is not in ASCII.

An **s-expression** is a parenthesis-delimited sequence of atoms or other s-expressions, which are referred to as the s-expression's **elements**.
Whitespace (sequences of `<space>`) between the parentheses and atoms is ignored.
For example, the following three s-expressions are equivalent.

```vt6
(foo bar)

(           foo bar)

(foo   bar   )
```

The **length** of an s-expression is the number of elements that it contains.
Any element that is an s-expression itself counts as one element regardless of how many elements it contains.
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

```abnf
version-number =  "0" / ( nzdigit *digit )

module-name    = ( letter / "_" ) *( letter / "." / "-" / "_" ) version-number

function-name  = bareword

message-type   = "want" / "have" / ( module-name "." function-name )

message        = "(" *space message-type *space *( ( s-expression / atom ) *space ) ")"
```

A **VT6 message** (or just **message**, if the term is not ambiguous) is a nonempty s-expression whose first element is an atom that is accepted by `<message-type>`.
The first element of a message is therefore called the message's **type**.
Any following elements of a message are called the message's **arguments**.
A message may have arbitrarily many arguments, including zero arguments.
As can be seen in the grammar definition above, a message type consists of a module name (see section TODO) and a function name, separated by a dot.
As an exception, the function names "want" and "have" are message types without a module name (see section TODO).

```abnf
message-stream = *( *space message ) *space
```

A **VT6 message stream** (or just **message stream**, if the term is not ambiguous) is a sequence of VT6 messages which are optionally preceded, succeeded and/or separated by whitespace.

**Rationale:** Allowing for whitespace between messages is especially useful when messages are emitted by a script in a language where a `print` operation appends a line separator by default.

### 2.3. Server-client communication

When a VT6 client is running in normal mode, it sends messages to its server by writing a message stream onto the message output, and receives messages from the server by reading a message stream from the message input.
Furthermore, it can read input data from standard input and write output data to standard output.
This specification does not restrict the form of these input and output data.

TODO: define behavior and semantics of multiplexed mode (need some sort of escape sequence for `\x1B{`)

### 2.4. Invalid messages, and handling thereof

A message is **invalid** if...

- the message is not accepted by `<s-expression>`,

- the message's first element is not an atom accepted by `<message-type>`,

- the message's arguments do not conform to the requirements for the message's type, as stated in the specification defining the message type in question,

- the size of the bytestring encoding the message exceeds the recipient's maximum message size (see section TODO), usually 4096 bytes, or

- the message type is unknown or its use has not been negotiated with the recipient (see section TODO).

A VT6 server receiving an invalid message from a VT6 client MUST act towards the client as if the message had never been received at all, and vice versa for messages from the server to the client.

A VT6 client or server MAY continue parsing and acting on a partially received message only if it is able to rollback all actions performed because of this message if the message turns out to be invalid once fully received, or if the connection is lost before the message is fully received.
This only concerns actions that are performed towards the sender of the message.
For example, the action of a server reporting a malformed client message to the user is not restricted by this rule, since the action is towards the user rather than the VT6 client.

If, while parsing a message stream, a message in the stream exceeds the recipient's maximum message size, the recipient SHOULD employ the following algorithm to reset the stream parser and find the next well-formed message.

1. Discard all input characters until a `(` character is found, without keeping track of whether the `(` is inside a quoted string or not.
2. Try to parse a message starting from this character.
3. If no valid message could be read, go back to step 1.

*Rationale:* The basic idea is pretty obvious.
We explicitly recommend to ignore quotes when trying to fast-forward to the start of the next message, because, given the simple syntax of s-expressions, the most likely syntax error is malformed quoted strings because of unescaped quotes or backslashes.

## 3. Modules

The VT6 protocol specification is divided into **modules**, each of which has a **name**.
For example, this document specifies the `core1` module.

Each module contains the message types (see section TODO), properties (see section TODO) and capabilities (see section TODO) defined in its specification.
For each message type and property name defined in a module's specification, the part of the message type property name before the dot MUST be equivalent to the module name.
For example, a module with a name of `example2` may define a `example2.foo` message type and an `example2.bar` property, but not an `example1.foo` message type or a `sample2.bar` property.

Each module name, as accepted by the `<module-name>` grammar element defined above, has a trailing positive integer.
This number is the **major version** of this module's specification.
The module also has a second (positive integer) version number, which is called **minor version** and is not part of the module name.

When a new module specification is created, its major and minor version number MUST be set to 0 and 1, respectively.
A module specification MUST clearly indicate its major and minor version number.
The recommended way to do so is by including the following sentence near the start of the specification:

```
Refer to this document using the identifier `vt6/<module-name>.<version-number>`.
```

Herein, `<module-name>` is the module name including the major version number, and `<version-number>` is the module specification's minor version number.

Everytime a new release of the module specification is made, its version number MUST be adjusted as follows:

1. The minor version number is incremented.
2. If the major version is greater than 0, and the module specification has been changed in a backwards-incompatible way compared to the previous release, the major version number is incremented and the minor version number is reset to 0.
3. If the major version is 0, the major version MAY be incremented to 1 and the minor version reset to 0 if the module specification is considered stable by its authors.

This requirement does not apply when the release is only a prerelease that is not considered normative.

The following changes to a module specification are considered **backwards-compatible** for the purpose of this algorithm:

- definition of a new message type, property or capability
- deprecation (but not removal) of an existing message type, property or capability
- definition of previously undefined or underdefined behavior of an existing message type, property or capability
- copyediting

The following changes to a module specification are considered **backwards-incompatible** for the purpose of this algorithm:

- removal of a message type, property or capability
- change of behavior of an existing message type, property or capability in such a way that there may exist programs that conform to the previous version of the specification, but not to the current one

TODO These lists do not feel exhaustive. Double-check.

**Rationale:** This follows the basic notion of [semantic versioning](http://semver.org/spec/v2.0.0.html), albeit massively simplified to suit the usecase of specifications.

### 3.1. Capability discovery

TODO describe "want" and "have" message types

## 4. Properties

TODO define only the basic notion of properties here (note: MUST have an initial value)

## 5. Capabilities

## 6. Message types for `vt6/core1`

### 6.1. The `core1.sub` message

TODO

### 6.2. The `core1.pub` message

TODO

### 6.3. The `core1.set` message

TODO

## 7. Properties for `vt6/core1`

### 7.1. The `core1.server-max-message-bytes` property

TODO

### 7.2. The `core1.client-max-message-bytes` property

TODO

<!--

TODO: define message format based on s-expressions; example message exchange ("->" is client-to-server, "<-" vice versa):

   ->    (want core1 ui2 cli1)
   <-    (have core1.3 ui2.5)
   ->    (core1.sub ui2.width ui2.height)
   <-    (core1.pub ui2.width 80 ui2.height 25)

NOTE: no need for multiplexing of messages onto standard in/out, or text onto message in/out, unless in multiplexed mode

NOTE: Not for this module, but: Syntax highlighting to be achieved by sending a "file type hint" message on message out.
When multiple programs form a pipe, the latest file type hint (in pipe chronology) wins.
NOTE: This requires the job control plugin to have a method of establishing a notion of pipe topology on the server.

-->
