#!/usr/bin/perl

use strict;
use warnings;
use v5.20;

chomp(my $first_line = <STDIN>);

if ($first_line =~ /^# `(.+?)` - (.+?)$/) {
  say "---";
  say "  title: '$1'";
  say "  description: '$2'";
  say "---\n";
} else {
  say {*STDERR} "first line of $ARGV[0] does not match expected format";
  exit 1;
}

# copy stdin to stdout...
my $text = join '', ($first_line, <STDIN>);
# ...but fix links to .md files to point to the rendered HTML files instead
$text =~ s{ (?:\./|\../)? (draft/)? (\w+)\.md }{/std/$1$2/}gx;
say $text;
