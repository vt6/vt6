# Style guide for VT6 specifications

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

3. Inside the text body (i.e., in paragraphs and in lists), put each sentence on a separate line.
   Each line inside the text body should end with a period.
   This disincentivizes overly long sentences, and makes diffs easier to read.
