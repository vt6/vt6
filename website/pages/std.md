# Specifications

**This document is non-normative**.

The VT6 protocol is structured into versioned **modules**.
Servers and clients negotiate which VT6 modules, and versions thereof, they understand.

Through the module structure, VT6 can adapt to clients and servers with vastly different feature sets.
Through the use of versioning, new capabilities can be added and old functionality can be deprecated without having to break interoperability with old implementations.

The navigation bar at the top of the screen shows all the modules that currently exist. `Foundation` is an exception, since it defines fundamental protocols and interface contracts, and is not a versioned module that can be negotiated.
For each module, there is an overview page, such as https://vt6.io/std/core/, that explains the module, its core features and how it fits together with other modules. Below this path, you can find the normative specifications for each module version, such as https://vt6.io/std/core/1.0/.

## Foundation

Every VT6 server (that is, every terminal, proxy, etc.) needs to implement at least two modules:

* [vt6/core](core/) It contains the most basic parts of the VT6 protocol that can be versioned, such as basic property types and some message types for handling properties and lifetimes. The only thing more basic is [`vt6/foundation`](https://vt6.io/std/foundation/) which contains the unversionable parts of the VT6 protocol.

Furthermore, every server must implement a platform integration module. A platform integration modules defines the platform-specific behavior that all other modules reference. The following platform integration modules exist as of now:

* [vt6/posix](posix/) is for servers and clients running on a POSIX-compliant operating system, such as Linux or any BSD.

A server that implements only vt6/core, vt6/term and a platform integration module (but no legacy ANSI escape sequences) is roughly comparable in functionality to a line printer.

## Common modules

Clients can expect the modules in this section to be supported by most server implementations, except for those on very constrained hardware like embedded systems.

* [vt6/sig](sig/) provides a basic signal handling mechanism, allowing the user to interrupt, terminate, or suspend running programs.

* TODO: add to this list as new modules become available
