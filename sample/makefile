sample.pdf: sample.dvi
	dvipdfmx sample.dvi

sample.dvi: sample.tex
	- platex -interaction=batchmode sample.tex

sample.tex: sample.laml
	cd ..
	stack exec laml-exe < sample.laml > sample.tex

.PHONY: clean
clean:
	rm -f *.log *.tex *.pdf *.aux *.dvi *.log