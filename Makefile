mds = $(shell for F in *.md; do echo $${F%.md}; done | grep -v README)
ymls = $(shell for F in *.yml; do echo $${F%.yml}; done)
pngs = $(shell for F in images/*.png; do echo $${F%.png}; done)

all: BP_Hroncokova_Barbora_2016.pdf

BP_Hroncokova_Barbora_2016.pdf: BP_Hroncokova_Barbora_2016.tex $(addsuffix .tex,$(mds) $(ymls)) template $(addsuffix .pdf,$(pngs)) pdfs
	arara BP_Hroncokova_Barbora_2016

meta.tex: meta.yml bin/convert
	./bin/convert meta.yml

acronyms.tex: acronyms.yml bin/convert
	./bin/convert acronyms.yml

hyphenation.tex: hyphenation.yml bin/convert
	./bin/convert hyphenation.yml

%.tex: %.md bin/convert
	./bin/convert "$<"
	vlna "$@" 2>/dev/null || :

images/%.pdf: images/%.png bin/png2scaledpdf
	./bin/png2scaledpdf "$<"

clean:
	git clean -Xf

.PHONY: clean all
