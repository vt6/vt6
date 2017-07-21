all: logos assets website

logos: $(foreach color,dark light,$(foreach type,square plain wide,$(foreach ext,svgz png,brand/logo-$(color)-$(type).$(ext))))
assets: $(foreach type,plain wide,website/themes/vt6/static/img/logo-dark-$(type).png)

space = $(null) $(null)

brand/logo-%.svgz: brand/logo-svg.pl
	perl $< $(subst -,$(space),$*) | gzip > $@
brand/logo-%.png: brand/logo-%.svgz
	gunzip < $< | convert svg:- $@
	optipng $@
website/themes/vt6/static/img/%.png: brand/%.png
	cp $< $@

website: assets
	cd website && hugo
