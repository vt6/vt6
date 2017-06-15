all: logo-dark.svg logo-light.svg logo-dark.png logo-light.png

logo-%.svg: logo-svg.pl
	perl $< $* > $@
logo-%.png: logo-%.svg
	convert $< $@
