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
   When the connection to the socket fails, the VT6 client MAY either bail out, or continue to operate as if a VT6 server is absent.

2. If the `TERM` environment variable is present and contains the string `vt6`, the VT6 client MAY operate in multiplexed mode.
   In this case, the VT6 client SHALL assume that a VT6 server is present, and operate in multiplexed mode.

3. If the `VT6` environment variable is absent and the `TERM` environment variable does not contain the string `vt6`, the VT6 client MUST consider the VT6 server to be absent.
