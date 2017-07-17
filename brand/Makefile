all: $(foreach color,dark light,$(foreach type,square plain wide,$(foreach ext,svgz png,logo-$(color)-$(type).$(ext))))

space = $(null) $(null)

logo-%.svgz: logo-svg.pl
	perl $< $(subst -,$(space),$*) | gzip > $@
logo-%.png: logo-%.svgz
	gunzip < $< | convert svg:- $@
	optipng $@
