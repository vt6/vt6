# `vt6/spec-style` - Style guide for VT6 specifications

Tip: This style guide is formatted according to itself.

1. Format VT6 specifications as Markdown.
   This is what the rendering pipeline for the website understands.

2. Use `#` headings only for the top heading.
   Sections start with `##`, subsections start with `###`, and so on.
   Include numbers in headings like shown below.

```markdown
## 1. First
## 2. Second
### 2.1. First sub
### 2.2. Second sub
## 3. Third
### 3.1. First sub
```

3. The top heading must be on the first line and must be formatted as shown below.
   This is required by the rendering machinery for the [vt6.io](https://vt6.io) website.

```markdown
# `vt6/core1.0` - Fundamental protocols and interface contracts
   ^^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   Module name                Scope of this module
  + minor vers.        (appears on the list of all specs)
```

4. If the specification is a draft (i.e., not yet released and frozen), add another line before the first heading which contains the comment `<!-- draft -->`.
   This causes the website rendering machinery to include the prominent "Draft" marker along the browser window's left edge.
   Also, note that "This is a non-normative draft" in the text before the first subheading.

5. Before the first subheading, include the two magic phrases mandated, respectively, by section 3 of `vt6/core1.0` and by RFC 2119.
   For drafts, include the additional phrase "This is a non-normative draft" in bold.

6. Inside the text body (i.e., in paragraphs and in lists), put each sentence on a separate line.
   Each line inside the text body should end with a period.
   This disincentivizes overly long sentences, and makes diffs easier to read.
