all: logos website

logos: $(foreach color,dark light,$(foreach type,square plain wide,$(foreach ext,svgz png,brand/logo-$(color)-$(type).$(ext))))

space = $(null) $(null)

brand/logo-%.svgz: brand/logo-svg.pl
	perl $< $(subst -,$(space),$*) | gzip > $@
brand/logo-%.png: brand/logo-%.svgz
	gunzip < $< | convert svg:- $@
	optipng $@

assets: $(foreach type,plain wide,website/themes/vt6/static/img/logo-dark-$(type).png)

website/themes/vt6/static/img/%.png: brand/%.png
	cp $< $@

pages: $(patsubst spec/%.md,website/content/std/%.md,$(wildcard spec/*.md spec/draft/*.md))

website/content/std/%.md: spec/%.md tools/prepare-spec.pl
	perl tools/prepare-spec.pl $< < $< > $@ || ( rm $@; false )

website: assets pages
	cd website && hugo
