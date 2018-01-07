default: logos

logos: $(foreach type,square plain wide,brand/logo-$(type).png)

brand/logo-%.png: brand/logo-svg.pl
	perl $< $* | convert pbm:- $@
	optipng $@


website: FORCE
	vt6-website-build $(CURDIR) $(CURDIR)/output

.PHONY: FORCE
