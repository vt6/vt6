#!/usr/bin/perl

use strict;
use warnings;
use v5.20;

die "usage: $0 [dark|light]" if @ARGV != 1 or $ARGV[0] !~ /^(?:dark|light)$/;

my @pattern = (
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,],
  [2,2,1,1,2,2,1,2,2,2,2,2,2,1,1,1,],
  [2,2,1,1,2,2,1,2,2,2,2,2,2,1,1,1,],
  [2,2,1,1,2,2,1,1,1,2,2,1,1,3,3,1,],
  [2,2,1,1,2,2,1,1,1,2,2,1,3,1,1,1,],
  [2,2,1,1,2,2,1,1,1,2,2,1,3,3,3,1,],
  [2,2,1,1,2,2,1,1,1,2,2,1,3,1,1,3,],
  [1,2,2,2,2,1,1,1,1,2,2,1,3,1,1,3,],
  [1,1,2,2,1,1,1,1,1,2,2,1,1,3,3,1,],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,],
);

my @colors;
if ($ARGV[0] eq 'dark') {
  @colors = (
    # background
    '#111111',
    # mute foreground
    '#222222',
    # actual foreground
    '#FFFFFF',
    '#00FF00',
  );
} else {
  @colors = (
    # background
    '#F0F0F0',
    # mute foreground
    '#E0E0E0',
    # actual foreground
    '#000000',
    '#009900',
  );
}

my $step = 16;
my $size = 10;

my $offset      = int(($step - $size) / 2);
my $full_width  = scalar(@{$pattern[0]}) * $step;
my $full_height = scalar(@pattern) * $step;

say '<?xml version="1.0" standalone="no"?>';
say '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';
say qq'<svg viewBox="0 0 $full_width $full_height" version="1.1">';

# background layer
say qq'<rect x="0" y="0" width="$full_width" height="$full_height" fill="$colors[0]" />';

for my $ix (0..$#{$pattern[0]}) { for my $iy (0..$#pattern) {
  my $x0 = $ix * $step + $offset;
  my $y0 = $iy * $step + $offset;
  say qq'<rect x="$x0" y="$y0" width="$size" height="$size" fill="$colors[$pattern[$iy][$ix]]" />';
}}

say '</svg>';
