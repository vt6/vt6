all: logo-dark.svgz logo-light.svgz logo-dark.png logo-light.png logo-dark-wide.svgz logo-light-wide.svgz logo-dark-wide.png logo-light-wide.png

logo-%-wide.svgz: logo-svg.pl
	perl $< $* wide | gzip > $@
logo-%.svgz: logo-svg.pl
	perl $< $* square | gzip > $@
logo-%.png: logo-%.svgz
	convert $< $@
	optipng $@
