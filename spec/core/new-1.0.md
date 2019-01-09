### 2.5. Predefined property types

When a property is said to **accept string values**, this means that the set of acceptable values for this property is the set of all byte strings whose value is a properly UTF-8-encoded string.
The module specification defining the property may impose additional restrictions on the string value of the property.

*Rationale:* [utf8everywhere.org](http://utf8everywhere.org) nicely sums up the arguments for not bothering with other text encodings.

```abnf
integer          = "0" / ( [sign] nzdigit *digit )
unsigned-integer = "0" / ( nzdigit *digit )

sign = "+" / "-"
```

When a property is said to **accept integer values**, this means that the set of acceptable values for this property is the set of all byte strings whose value matches the `<integer>` grammar element defined above.
Analogously, when a property is said to **accept unsigned integer values**, this means that the set of acceptable values for this property is the set of all byte strings whose value matches the `<unsigned-integer>` grammar element defined above.

In both these cases, the **numerical value** of each such byte string is the decimal value of the sequence of digits in the byte string's value.
The module specification defining the property may impose additional restrictions on the numerical value of the property.

Module specifications which use some or all of the property types defined in this section SHALL reference this section.
The recommended way to do so is by including the following sentence near the start of the specification:

> This document uses the predefined property types from section 2.5 of `vt6/core1.0`.

## 4. Other eternal message types
### 4.1. The `nope` message
  This message type is link-local and only indicates syntax errors because otherwise it would reintroduce the routing problem.

## 5. Message types for `vt6/core1.0`
### 5.2. The `core1.lifetime-end` message
  Ends a lifetime and all effects bound to it.
### 5.3. The `core1.sub` message
### 5.4. The `core1.pub` message
### 5.5. The `core1.set` message
