# VT6 - a presentation-layer protocol for text-oriented terminals

This repository contains the specification of the VT6 protocol, including all
standardized modules and capabilities.

## Non-normative documents

The documents in this section are non-normative and may occasionally be
extended and updated.

* [`why`](./spec/why.md) describes the basic motivation and the guiding
  principles of vt6.
* [`how`](./spec/how.md) explains the overall design directions of vt6.

## Core modules

The documents in this section are normative and strictly versioned. Once a
specific version is released, it is frozen and will not be changed anymore.
Draft versions may be changed at any time and without notice.

* [`core`](./spec/core/) defines the fundamental interface contracts between
  VT6 providers and consumers.
