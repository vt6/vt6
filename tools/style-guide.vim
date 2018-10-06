" Source this file (with the :source command) to have vim warn you when you violate the style guide for VT6 specs.
" To identify a highlighted error, place the cursor on the red area, then type :VT6IdentifyStyleError<CR>

set ft=markdown
syn sync fromstart

syn match vt6StyleErrorLineNotEndingWithDot +^\%(```\)\@![^#<1-9-].*\%([.:]\**\)\@<!\n+
syn match vt6StyleErrorSentenceEndWithinLine +^\%(```\)\@![^#<1-9-][^1-9].\{-}[A-Za-z]\{2}\.\s+
" Note: The phrase ^\%(```)\@![^#<1-9-] skips lines that are not part of a paragraph (headings, code snippets, embedded HTML, unordered and ordered lists).
" Note: The character group [^1-9] ensures that the dot in an enumeration ("1.", "2.", etc.) is not considered for the match.
" Note: [A-Za-z]{2} excludes abbreviations like "i.e." and "e.g.".
"
syn match vt6Todo +^\%(TODO\|FIXME\|XXX\)\>.*$+ contains=vt6TodoMarker
syn keyword vt6TodoMarker TODO FIXME XXX

hi def link vt6TodoMarker Todo
hi def link vt6StyleErrorLineNotEndingWithDot Error
hi def link vt6StyleErrorSentenceEndWithinLine Error

com! VT6IdentifyStyleError echo synIDattr(synID(line("."),col("."),1), "name")
