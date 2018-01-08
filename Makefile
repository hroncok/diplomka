all: DP_Hroncok_Miroslav_2016.pdf

DP_Hroncok_Miroslav_2016.pdf: library.bib DP_Hroncok_Miroslav_2016.tex *.tex */*.tex template images/*.pdf pdfs
	arara DP_Hroncok_Miroslav_2016

clean:
	git clean -Xf

.PHONY: clean all
