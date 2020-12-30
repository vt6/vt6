<!-- draft -->
# `vt6/foundation` - Fundamental protocols and interface contracts

The canonical URL for this document is <https://vt6.io/std/foundation/>.

**This is a non-normative draft.**

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://tools.ietf.org/html/rfc2119).

This document uses augmented Backus-Naur form (ABNF) as defined in [RFC 5234](https://tools.ietf.org/html/rfc5234).

## 1. Terminal application topology

### 1.1. Traditional terminals

Under normal circumstances, processes running in a terminal have access to three one-directional byte streams.
The process can read text from **standard input (stdin)** and write text onto **standard output (stdout)** and **standard error (stderr)**.
We will refer to this set of streams as the **standard streams** of that process.

While stderr is usually directly connected to the terminal, every process's stdin can be another process's stdout and vice versa.
Processes running in the terminal therefore form a pipeline:
The terminal sends input text into the stdin of the first process in the pipeline.
The stdout of one process in the pipeline is the next process's stdin.
And finally, the last process's stdout gets sent to the terminal for display.

Some processes may launch child processes that (either temporarily or permanently) take their place in a pipeline.
We shall refer to such processes as **shells**.

For example, when a shell like `bash` or `csh` executes a command, it creates a new child process, or a set of multiple child processes.
Unless input/output redirection is configured, it then lends its own stdin to the first of these children, its stdout to the last of them, and its stderr to all of them.
It also sets up new pipes to connect all children together, so that they form a consecutive sequence within the pipeline that the shell used to be a part of.

Some shells allow multiple such pipelines of child processes to be running in parallel.
In this case, each pipeline of child processes started by the shell is usually called a **job**.
For each job, the stdin of the first process in the job's pipeline is called the **job's stdin**, and the stdout of the last process in the job's pipeline is called the **job's stdout**.
When multiple jobs are running below a shell, the shell's stdin is identical to all jobs' stdins, and the shell's stdout is identical to all jobs' stdouts, except where input/output redirection is configured.

We will use the term **client** to refer to any process that is not a terminal and which is receiving text data from or sending text data to a terminal either directly, or indirectly through a pipeline as described above.

### 1.2. Message streams

On VT6-enabled terminals, the one-directional pipes of traditional pipelines are augmented with a two-directional structured message protocol that supersedes the [special capabilities of terminal devices defined, for example, by POSIX](https://linux.die.net/man/3/termios), as well as the traditional output markup using ANSI escape sequences.

Clients running in a VT6-enabled terminal SHALL have access (or be able to get access) to a bidirectional stream, which is called that process's **message stream**, respectively.
When the individual standard streams are referred to as stdin, stdout and stderr, respectively, this stream may be called **msgio**.
Message streams allow clients to engage in request-response conversations with the terminal.

*Rationale:* The server-client topology of msgio mirrors the way that the special capabilities of teletype devices (tty) work on traditional Unix: Each client with a file descriptor for a tty can interact with the kernel to read and write properties of the tty directly.
We do not like that stdio and msgio have fundamentally different topologies, but we believe it is a necessary compromise.
An earlier draft of this document specified identical topologies for msgio and stdio, with msgio flowing back and forth along pipelines to reach the terminal and back.
This would have made message flow and proxying of msgio feel more consistent and more predictable, but it would also have imposed an unreasonable burden on client implementations because they would have to forward everyone else's msgio messages, even if they themselves don't do msgio at all.
Another downside of the design in this document is that extra logic is required for multiplexing through point-to-point connections such as SSH.
But at least this complexity is concentrated in a single place, the implementation of a multiplexing proxy.

When a shell launches child processes, it SHALL arrange for them to have access (or be able to get access) to a message stream.
The method for doing so is platform-specific (see section 2.5).
No exceptions SHALL be made for processes that have their stdin or stdout redirected from or to a file or other non-terminal device.

*Rationale:* Processes with input/output redirection should still be able to talk to the terminal.
For example, consider a decryption tool that receives the input ciphertext on stdin.
Even when stdin is a regular file, msgin and msgout should be connected to the terminal, so that it can ask the terminal to display a password prompt to the user.

As an exception, shells MAY launch jobs without suitably connected message streams if the job may outlive the terminal process.
In this case, the job's stdin and stdout SHALL NOT be connected to the terminal directly, nor indirectly through other clients.

*Rationale:* This rule accommodates long-running daemon processes that are launched by the shell, but are not bound by the lifetime of the terminal in which they are spawned.

If a shell has at most one child process at a time, the shell MAY pass its own message stream to its child if the shell does not use its message streams for the runtime of the child, and the shell can guarantee that the child is VT6-enabled and handles the message stream correctly.

*Rationale:* This exception prevents us, for example, from unnecessarily constraining the design of applications that consist of multiple processes internally.
In such an application, the initial process may want to hand control over its message stream to some internal helper process.

### 1.3 Proxies

A shell is said to be a **proxy** when it acts as a man-in-the-middle between its terminal and the clients launched by it.
That is, the shell poses as the terminal towards the clients launched by it, and poses as these clients towards its own terminal.

*Rationale:* Proxies are used when the behavior of the terminal towards the clients or of the clients towards the terminal needs to be altered.
For example, a proxy could act like a polyfill and provide support for modules that are not natively supported by the terminal.

This specification does not prescribe any extra behavior for proxies.
It just defines the term for other specifications that want to use it.
Proxies are compliant with this specification as long as they act as a compliant terminal towards their clients and as a compliant client or set of clients towards its own terminal.

## 2. Protocol concepts

### 2.1. Modules

```abnf
letter     = %x41-5A / %x61-7A                  ; letters A-Z and a-z
identifier = ( letter / "_" ) *( letter / "-" / "_" )
```

The VT6 protocol is divided into **modules**.
Each module has a name which is accepted by `<identifier>`.
When it is not clear from the context that a given identifier refers to a module name, the prefix `vt6/` may be prepended to it.

A module is considered **official** if its specifications are developed in the same repository as this specification.
The name of any unofficial module MUST start with a leading underscore and SHOULD indicate the organization that is responsible for its specification.

A module is considered **private** if it is intended to only be used between applications of a single vendor.
The name of any private module SHOULD start with two leading underscores.

*Rationale:* We strive to avoid name clashes between modules by different vendors, and reserve short module names for official modules to minimize message length for common messages.

Modules partition the VT6 protocol into parts which each may or may not be supported by a given terminal or proxy.
This includes, most prominently, message types (see section 2.2) and properties (see section 2.3).

### 2.2. Message types

A **message type** is a name for a kind of message (see section 3) that can be sent and received either on the message stream or the standard streams of a process.
Each message type is defined by its name, its role (see below) and a set of criteria describing when a message of that type is to be considered (semantically) valid by the recipient.
These criteria include at least:

- the number of arguments that a message of this type may contain,
- the format and/or structure of said arguments,
- the behavior that is expected of the recipient upon having received the message.

Each message type has one of four roles: Messages of a particular type can be either **events**, **requests**, **responses**, or **special messages**.
When a message is said to **be an event** (or a request or a response or a special message, respectively), it means that the message's type is one that has the role "event" (or "request" or "response" or "special message", respectively) according to the specification defining the message type.

Event messages MUST be sent over the standard streams (see section 3.2).

Request and response messages MUST be sent over the message stream (see section 3.3).
Requests SHALL only be sent by a client.
Responses SHALL only be sent by the terminal, in response to a request.
The specification for a request message type MUST note whether the request requires the terminal to send a response, and if so, which message type is expected as a response.

For special messages, the specification defining the respective message type MUST define when and by whom this kind of message can be sent.

### 2.3. Properties

A **property** is a quantifiable aspect of the terminal, or of the message stream over which messages concerning this property are exchanged.
Each concrete value of a property is represented as a byte string (see section 3.1.1), but for any given property, not all byte strings may be valid values.

Each property is defined by its name and at least the following criteria:

- the set of values that the property can have,
- whether, and under which circumstances, a client may update the property's value,
- how the behavior of the publishing side of the terminal is influenced by the value of this property.

For each message type, there SHALL NOT be a property of the same name.

*Rationale:* Even though technically possible, it would cause unnecessary confusion.

### 2.4. Module versions, scoped identifiers

```abnf
digit   = %x30-39 ; decimal digits 0-9
nzdigit = %x31-39 ; non-zero decimal digits 1-9

version-number = "0" / ( nzdigit *digit )

major-version = version-number
minor-version = version-number
full-version  = major-version "." minor-version
```

Each module can have multiple **versions**.
Each module version has a **major version number** and a **minor version number**, as accepted by the `<major-version>` and `<minor-version>` grammar elements defined above.
When both version numbers are shown together, they are formatted as implied by the definition of the `<full-version>` grammar element defined above.

When referring to a module version in specifications and other documents, the recommended way is to append the full version number to the module name including the `vt6/` prefix.

As an exception, although this current document is identified as `vt6/foundation` in its title, there is no module called `foundation` and this is not a module specification.
This is because this specification contains the platform-independent unversionable parts of the VT6 protocol.

Each module specification MUST clearly indicate the module name and full version number, preferably by including the recommended module version identifier in the document title.

When the first specification of a module is created, its full version number MUST be set to `1.0`.
Everytime a new specification of that module is released, the module version MUST be adjusted as follows:

1. The minor version number is incremented.
2. Then, if the specification has been changed in a backwards-incompatible way compared to the previous release (see below), the major version number is incremented and the minor version number is reset to 0.

This requirement does not apply when the release is only a draft or pre-release that is not considered normative, and clearly labeled as such.

*Rationale:* This follows the basic notion of [semantic versioning](http://semver.org/spec/v2.0.0.html), albeit massively simplified to suit the usecase of module specifications.

The following changes to a module specification are considered **backwards-compatible**:

- addition of a new message type or property
- deprecation (but not removal) of an existing message type or property
- definition of previously undefined or underdefined behavior of an existing message type or property
- copyediting of the specification

Every other change to a module specification is considered **backwards-incompatible**, especially:

- removal of a message type or property
- change of behavior of an existing message type or property in such a way that there may exist VT6 applications that conform to the previous module version, but not to the current one

Each module specification whose minor version number is bigger than 0 SHOULD indicate which parts of it have been added or changed compared to previous specifications of that module with the same major version number.

*Rationale:* Implementors should not have to `diff` specification documents manually.

```abnf
scoped-identifier = identifier major-version "." identifier
message-type      = want / have / nope / scoped-identifier

; cannot use string literals here (e.g. want = "want")
; because those are case-insensitive in ABNF
want = %x77.61.6E.74
have = %x68.61.76.65
nope = %x6E.6F.70.65
```

Modules act as namespaces for message types and properties.
Each message type or property name MUST be accepted by `<scoped-identifier>`, and the part before the dot MUST be equal to the name and major version of the module version defining it.

For example, the module `example1.2` may define a message type named `example1.foo` and a property named `example1.bar`, but not a message type named `example2.foo` (major version mismatch) or a property named `sample1.bar` (module name mismatch).

As an exception, this document defines several message types that are plain identifiers which do not belong to any module.
Syntactically valid message types are all strings that are accepted by `<message-type>`.

### 2.5. Platforms

A **platform** is an operating environment which is admissible for VT6 applications.
A platform SHALL define how processes access their standard streams and message stream.

Each platform is defined by a **platform integration module**, which is a VT6 module.

For each official module that references **platform-specific behavior**, any module version of a platform integration module MUST define said behavior for its platform, or it MUST define that the module referencing platform-specific behavior is not supported on its platform.
This does not apply to platform-specific behavior that is first described in module versions released after the module version in question of the platform integration module.

A platform integration module MAY define message types and properties which are only available on the platform defined by it.

*The remainder of this section is non-normative.*

The following platform integration modules are available at the time of publication of this document:

- [vt6/posix](../../posix/) for operating systems that implement the POSIX specification

### 2.6. Client IDs

```abnf
client-id = 1*( letter / digit )      ; corresponds to the regex /[a-zA-Z0-9]+/
```

For each message stream, there is a **client ID**, as accepted by the `<client-id>` grammar element defined above, to identify the client using this message stream.
At any point in time, each message stream's client ID SHALL be unique within the set of message streams connected to the same terminal.
Once a message stream is closed, its client ID MAY be reused for a message stream connected to the same terminal which is opened later on.

A client ID is said to **include** another client ID if it is a prefix of the other client ID and not identical to it.
A client ID is said to **be included in** another client ID if the other client ID includes it.

Client IDs are conceptually tied to process lifetimes.
Some types of request messages have side effects that are bound by the lifetime of the client ID.
This means that the effect of those requests end when the message stream corresponding to that client ID is closed.
The details of what "end of effect" means are laid out in the specification defining the message type in question.

When a terminal launches client processes, it SHALL choose a client ID for each of them, such that none of the client IDs so chosen include each other.

When a shell launches client processes, it SHALL choose a client ID for each of them.
However, there need not be a separate process for each client ID.
A client can also choose new client IDs for itself, to describe durations inside the lifetime of its main client ID.

A client chooses new client IDs by appending an arbitary string to its own client ID, such that the new string is also a valid client ID.
The client's original client ID therefore includes all client IDs so generated.
Upon choosing a client ID, the client MUST make the terminal aware of the new client ID by sending an appropriate request message, such as `core1.client-make`.

*Rationale:* This is necessary because message streams are always associated with a client ID.
The newly spanwed client will not be able to obtain a message stream if the terminal is not aware of its client ID.

The lifetime of a client ID end when the terminal receives a corresponding request message, such as `core1.client-end`.
When the terminal observes the end of the lifetime of a client ID in this way, it SHALL also consider the lifetimes of all client IDs that are included in this client ID to have ended.
In other words, the lifetime of each client ID is bound by the lifetime of all client IDs that include it.
When the lifetime of a client ID ends, the terminal SHALL close the message stream with this client ID, if there is one.

*Rationale:* The lifetimes of client IDs form a hierarchy that resembles the hierarchy of programs running in the terminal.
When a shell launches a job, it allocates client IDs for all client processes (with lifetimes bound by the lifetime of its own client ID), and announces the end of the lifetime of those client IDs when the job is done.
The lifetime mechanic solves a design problem of the legacy terminal implementation in POSIX: When a process wishes to change attributes of the terminal (e.g. set the input mode from cooked to raw), it has to remember to reset the attributes when it's done with the terminal.
If it doesn't (e.g. because of a crash), the terminal is left in a misconfigured state.
By binding such operations to the lifetime of client IDs, the shell can reset the terminal into a known state when a child process crashes, by simply ending the lifetime of the crashed process's client ID.

## 3. Messages

### 3.1. Syntax

#### 3.1.1. Netstrings

```abnf
byte   = %x00-FF ; any single byte
length = "0" / nzdigit *digit

netstring = length ":" *byte ","
```

A **netstring** is a sequence of bytes such that:

- it is accepted by `<netstring>`, and
- the number of bytes between the first colon and the trailing comma is equal to the decimal value of the sequence of ASCII digits before the first colon.

The sequence of bytes between the first colon and the trailing comma is called the **value** of the netstring.

*Rationale:* The [netstring encoding](https://cr.yp.to/proto/netstrings.txt) was first described by Daniel J. Bernstein.

#### 3.1.2. Messages

```abnf
message = "{" length "|" 1*netstring "}"
```

A **VT6 message** (or just **message**, if the term is not ambiguous) is a bytestring such that:

- it is accepted by `<message>`,
- the number of netstrings in the sequence after the pipe symbol is equal to the decimal value of the sequence of ASCII digits before the pipe symbol, and
- the value of the first netstring after the pipe symbol is accepted by `<message-type>`, and
- the entire message, including the surrounding braces, does not exceed a length of 1024 bytes.

The first netstring after the pipe symbol is called the message's **type**.
Any following netstrings are called the message's **arguments**.
A message may have arbitrarily many arguments, including zero arguments.

*Rationale:* We avoid compactly-coded escape sequences like those specified by [ECMA-48](https://www.ecma-international.org/publications/files/ECMA-ST/ECMA-48,%202nd%20Edition,%20August%201979.pdf) aka ANSI&nbsp;X3.64 aka ISO/IEC&nbsp;6429 because of the risk that escape sequences specified by different modules collide with each other.
We choose an adaptation of the netstring format because it can be implemented very easily, both on the generating and on the parsing side.
The curly brackets that enclose messages serve as a sequence point where parsing can be restarted after a parsing error (see sections 3.2 and 3.3).
The maximum size limit of 1024 bytes reduces implementation complexity for simple client processes that cannot perform (or do not want to perform) dynamic memory allocation.
Most applications will not have to check the 1024-byte limit on messages generated by them explicitly, because most types of messages are intentionally designed to be short.

```abnf
fenced-message = escape-char message escape-char new-line

escape-char = %x1B
new-line = %x0A
```

A message is **fenced** when it is preceded by one ESC character and succeeded by another ESC character, followed by a newline.

*Rationale:* Fencing is used when interleaving messages into stdio.
The use of ESC characters as delimiters is inspired by ANSI escape sequences, which also start with an ESC character.
The trailing `\n` is considered part of the fenced message because, in section 3.2.2, we recommend that messages be placed on separate lines to simplify the job of line-based text filters such as `grep`, `sed` and `awk`.
If the message did not end with a `\n` by itself, it could not be placed on its own line without introducing a superfluous line break in the surrounding text data.

#### 3.1.3. Human-readable representation

The following alternative representation for netstrings and messages may be used when showing messages in specifications or informational displays, such as logs:

- Netstrings whose value matches the regular expression `^[A-Za-z0-9._-]+$` are represented directly by their value.
- Other netstrings (including empty strings) are represented as C string literals with the same value.
- Messages are represented by a whitespace-separated concatenation of the representations of the netstrings contained in it, enclosed in parentheses.

*Rationale:* This format is more human-readable and thus better suited for examples within specifications, or for diagnostic output of programs that process VT6 messages.

For example:

```
actual         = {3|9:core1.set,13:example.title,13:hello "world",}
human-readable = (core1.set example.title "hello \"world\"")

actual         = {3|9:core1.set,13:example.title,0:,}
human-readable = (core1.set example.title "")
```

### 3.2. Using the standard streams

#### 3.2.1. Standard input

When a client reads from stdin, it SHOULD look for fenced messages.

Once it reads the byte sequence `<ESC>{` (decimal byte sequence 27, 123) from its stdin, it SHALL attempt to read an entire fenced message.
If, upon further reading, the initial `<ESC>{` turns out not to start a syntactically valid fenced message, those bytes, as well as all bytes up to the next `<ESC>{` SHALL be treated as ordinary input data.
If, however, a syntactically valid fenced message is read from stdin, it shall be processed as a single unit occurring within the input stream, rather than as a string of individual bytes.
The bytes that make up the fenced message SHALL NOT be considered part of the input text.

When a terminal reads a client's stdout, it MUST look for events in the same way as described above.

Event messages have defined semantics, but only terminals MUST honor them.
There are no set rules for what clients can or cannot do with the events.

*Rationale:* The most common way for a client to treat an incoming event is to forward it to its stdout unaltered.
This applies especially to all programs that only manipulate text data, such as `grep`, `sed` or `awk`.

*TODO:* Do we need some sort of escaping for plain ESC characters?

#### 3.2.2. Standard output/error

When writing to stdout or stderr, a client MAY include events as fenced messages.

Events SHOULD appear on their own line, that is: They should, if possible, directly succeed a newline character or another event.

*Rationale:* This increases the likelihood that legacy programs like `grep`, `sed` or `awk` forward the event unaltered, since these programs tend to operate on entire lines of input.

### 3.3. Using the message stream

Clients send requests to the terminal by writing request messages onto their message stream.
Terminals respond by writing response messages onto the same message stream.

Whenever input becomes available on a message stream, processes SHALL read that input without unreasonable delay.
Input from one of the message stream that is not part of a syntactically valid VT6 message SHALL be discarded.
The reading process SHALL skip ahead to the next `{` character and attempt to read the next message from this point.

#### 3.3.1. As a client

Clients SHALL NOT write anything other than request messages into their message stream.

When a client reads a message from its message stream:

- If the message is a response to a request made by the client, the client can consume the response.
- If the message is a request or an event or an unexpected response, the message SHALL be discarded.

#### 3.3.2. As a terminal

When a terminal reads a message from the message stream:

- If the message is a request and semantically valid, the terminal SHALL act upon the request and, if necessary, reply with the appropriate response message type.
- If the message is a response or event, or if it is semantically invalid, the terminal SHALL reply with a `nope` message (see section 5.1).
- If the message is of an unknown type, the terminal SHALL inspect the part of the message type before the dot, and reply with a `have` message (see section 4.2) describing the available support for the module and major version named therein.

In each case, the terminal SHALL reply by writing the response as a message onto the same message stream where the original request was received.
Terminals SHALL NOT write anything other than response messages into any message stream.

*Rationale:* Events and responses always require a `nope` response because events are delivered over the standard streams, and responses are only ever sent by the terminal, not received by it.

If the message is a request and the specification defining its message type allows it, the terminal MAY produce multiple responses.
In this case, the first response message MUST be sent immediately, and further responses may be sent at any point in time until the lifetime of the requester's client ID ends.
All responses must be sent on the same message stream where the original request was received.
Every response except for the first one is called **delayed response**.

*Rationale:* This rule accommodates subscription and callback mechanisms like `core1.sub` and `core1.pub`, where the client subscribes once and receives multiple publications asynchronously.

When a terminal answers requests by writing responses back into the same message stream, it MUST write responses in the same order in which the original requests were read from the message stream.
The only exception to this are delayed responses, which may occur at any point.

*Rationale:* These rules ensure that, when clients send multiple requests, they will read back the responses in the exact same order.
This can be used to simplify the message handling code in resource-constrained client implementations.

### 3.4. Invalid messages, and handling thereof

A message is **syntactically invalid** if it does not conform to the definitions in section 3.1.

A message is **semantically invalid** if:

- it was sent on the standard streams, but the message is not an event,
- it was sent on the message streams, but the message is an event, or
- the message's arguments do not conform with the requirements for the message's type, as stated in the specification defining the message type in question.

Receipt of a syntactically or semantically invalid message by a terminal MUST NOT cause any effect (besides error responses, see section 3.3.2) that can be observed by the sender.

## 4. Version discovery

Before using any message types or properties of a module, a client MAY check whether the module is supported by the terminal, by sending a `want` request and observing the `have` response.

Alternatively, the client can just send a request with a message type from a heretofore unused module.
The terminal will respond with a negative `have` message if it does not support that module, or with a positive `have` message if it supports that module, but not any version that defines the message type that was used (see section 3.3.2).

### 4.1. The `want` message

- Role: request (answered by `have`)
- Directionality: any
- Number of arguments: one

A client can send a `want` message to check if a module is supported by the terminal.

```abnf
want-argument = identifier major-version
```

The first and only argument MUST be the module name including major version, as accepted by the `<want-argument>` element defined above.

### 4.2. The `have` message

- Role: response (answers `want`)
- Directionality: any
- Number of arguments: one

A terminal MUST send a `have` message in response to:

- any syntactically valid `want` request, regardless of whether the module is supported, or
- any request whose message type is not supported by (or unknown to) the terminal (see section 3.3.2).

```abnf
negative-have-argument = identifier major-version
positive-have-argument = identifier major-version "." minor-version
```

If a `want` message is being replied to and the terminal supports the given module and major version, the only argument of the `have` response SHALL be formatted according to the `<positive-have-argument>` grammar element defined above.
The module name and major version SHALL be identical to the respective parts of the `want` argument, and the minor version SHALL indicate the highest module version of that module and major version supported by the terminal.

If a `want` message is being replied to and the terminal does not support any module version with the same module name and major version as stated in the `want` argument, the only argument of the `have` response SHALL be identical to the original `want` argument, as indicated in the `<negative-have-argument>` grammar element defined above.

For example, assuming that the original request was `(want foo1)`:

- The response `(have foo1)` indicates that no 1.x version of the `foo` module is supported.
- The response `(have foo1.2)` indicates that versions 1.0, 1.1 and 1.2 of the `foo` module are supported.

If a message of an unsupported type is being replied to, the only argument of the `have` response SHALL be identical to:

- the part of the request message type before the dot, if the terminal does not support any module version with that same module name and major version, or otherwise,
- the part of the request message type up to and including the dot, followed by the highest minor version of that module and major version that is supported by the terminal.

For example, if a terminal receives the message `(foo3.bar qux 42)`:

- The response `(have foo3)` indicates that no 3.x version of the `foo` module is supported.
- The response `(have foo3.1)` indicates that versions 3.0 and 3.1 of the `foo` module are supported, but none of them define the `foo3.bar` message type.

## 5. Other eternal message types

All message types defined in this specification are called **eternal** because they are not defined by a versioned module specification and thus cannot be changed.

### 5.1. The `nope` message

- Role: response (to any request)
- Directionality: any
- Number of arguments: one

A terminal (or a proxy acting as a terminal) SHALL send a `nope` message in response to a semantically invalid request message (see section 3.3.2 and section 3.4).
The only argument of the `nope` message SHALL be the message type of the original request message.
