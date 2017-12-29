all: logos website

################################################################################
# logos

logos: $(foreach color,dark light,$(foreach type,square plain wide,$(foreach ext,svgz png,brand/logo-$(color)-$(type).$(ext))))

space = $(null) $(null)

brand/logo-%.svgz: brand/logo-svg.pl
	perl $< $(subst -,$(space),$*) | gzip > $@
brand/logo-%.png: brand/logo-%.svgz
	gunzip < $< | convert svg:- $@
	optipng $@
