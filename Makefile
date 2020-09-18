cruft := notes.pdf slides.pdf slides.nav slides.log slides.aux slides.toc slides.snm
cache_directories := slides_cache slides_files

all: slides.pdf notes.pdf

clean:
ifneq ($(cruft),)
	rm -f $(cruft)
endif

clean_cache:
	$(RM) -rf $(cache_directories)





slides.pdf: slides.Rmd style/header.tex style/body.tex style/footer.tex
	# render the rmd to md using knitr
	cat style/slides.yaml slides.Rmd > tmp.Rmd
	R -e "rmarkdown::render('tmp.Rmd',clean=FALSE,run_pandoc=FALSE)" ;
	# run pandoc to generate beamer tex
	/usr/bin/env pandoc \
		+RTS -K512m \
		-RTS tmp.utf8.md \
		--to beamer \
		--from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash-implicit_figures \
		--output slides.tex \
		--highlight-style tango \
		--self-contained \
		--include-in-header style/header.tex \
		--include-before-body style/body.tex \
		--include-after style/footer.tex;
	# turn off the ignorenonframetext class option (which blocks full-size images)
	grep -v "ignorenonframetext" slides.tex > slides2.tex ;
	mv slides2.tex slides.tex ;
	# run pdflatex twice to get the transparency right
	pdflatex slides.tex ;
	pdflatex slides.tex ;
	# remove cruft
	rm \
		slides.nav slides.log slides.aux slides.toc slides.snm slides.tex \
		tmp.knit.md tmp.Rmd tmp.utf8.md
	
notes.pdf: slides.Rmd style/header.tex style/body.tex style/footer.tex
	# render the rmd to md using knitr
	cat style/notes.yaml slides.Rmd > tmp.Rmd
	R -e "rmarkdown::render('tmp.Rmd',clean=FALSE,run_pandoc=FALSE)" ;
	# run pandoc to generate beamer tex
	/usr/bin/env pandoc \
		+RTS -K512m \
		-RTS tmp.utf8.md \
		--to beamer \
		--from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash-implicit_figures \
		--output notes.tex \
		--highlight-style tango \
		--self-contained \
		--include-in-header style/notes.tex \
		--include-before-body style/body.tex \
		--include-after style/footer.tex;
	# turn off the ignorenonframetext class option (which blocks full-size images)
	grep -v "ignorenonframetext" notes.tex > notes2.tex ;
	mv notes2.tex notes.tex ;
	# run pdflatex twice to get the transparency right
	pdflatex notes.tex ;
	pdflatex notes.tex ;
	# remove cruft
	rm \
		notes.nav notes.log notes.aux notes.toc notes.snm notes.tex \
		tmp.knit.md tmp.Rmd tmp.utf8.md


tmp.utf8.md: slides.Rmd
	cat style/beamer.yaml slides.Rmd > tmp.Rmd
	R -e "rmarkdown::render('tmp.Rmd',clean=FALSE,run_pandoc=FALSE)" ;